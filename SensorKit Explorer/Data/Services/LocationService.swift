import CoreLocation

extension Coordinates {
    func distance(from other: Coordinates) -> Double {
        let otherLocation = CLLocation(latitude: other.latitude, longitude: other.longitude)
        let selfLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = selfLocation.distance(from: otherLocation)
        return distance
    }
}

enum AuthorizationStatus {
    case notDetermined
    case authorizedWhenInUse
    case authorizedAlways
    case denied
    case restricted
    case unknown
    var requestPermission: Bool {
        switch self {
        case .notDetermined: return true
        default: return false
        }
    }
    var isAuthorized: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }
    }
    var isDenied: Bool {
        switch self {
        case .denied, .restricted: return true
        default: return false
        }
    }
}

extension CLAuthorizationStatus {
    var customStatus: AuthorizationStatus {
        switch self {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorizedAlways, .authorized: .authorizedAlways
        case .authorizedWhenInUse: .authorizedWhenInUse
        @unknown default: .unknown
        }
    }
}

protocol LocationPermisionProtocol {
    func authorizationStream() -> AsyncStream<AuthorizationStatus>
    func requestPermission()
}

final class LocationService: NSObject, LocationServiceProtocol, LocationPermisionProtocol {
    private let locationManager = CLLocationManager()
    private var continuation: AsyncThrowingStream<Coordinates, Error>.Continuation?
    nonisolated(unsafe) private var authorization: AsyncStream<AuthorizationStatus>.Continuation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    func requestPermission() {
        print("[LocationService] Request send for whenInUse")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func authorizationStream() -> AsyncStream<AuthorizationStatus> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.authorization = continuation
            continuation.yield(locationManager.authorizationStatus.customStatus)
            continuation.onTermination = { [weak self] reason in
                print("[LocationService] Authorization stream terminated:", reason)
                self?.authorization = nil
            }
        }
    }

    func locationStream() -> AsyncThrowingStream<Coordinates, Error> {
        print("[LocationService] Star streaming")
        return AsyncThrowingStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.continuation = continuation
            let status = locationManager.authorizationStatus
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .denied:
                continuation.finish(throwing: LocationServiceError.permissionDenied)
            case .restricted:
                continuation.finish(throwing: LocationServiceError.permissionRestricted)
            @unknown default:
                continuation.finish(throwing: LocationServiceError.unknown)
            }
            let locationManagerC = self.locationManager
            continuation.onTermination = { reason in
                print("[LocationService] Location stream terminated:", reason)
                locationManagerC.stopUpdatingLocation()
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        let coordinate = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        continuation?.yield(coordinate)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus.customStatus
        authorization?.yield(status)
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied:
            continuation?.finish(throwing: LocationServiceError.permissionDenied)
        case .restricted:
            continuation?.finish(throwing: LocationServiceError.permissionRestricted)
        default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        continuation?.finish(throwing: error)
    }
}

import Foundation

enum LocationServiceError: LocalizedError {
    case permissionDenied
    case permissionRestricted
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission was denied. Please enable location access in Settings."
        case .permissionRestricted:
            return "Location services are restricted on this device."
        case .unknown:
            return "An unknown location error occurred."
        }
    }
}

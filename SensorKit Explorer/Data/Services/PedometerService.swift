import Foundation
import CoreMotion

protocol PedometerServiceProtocol {
    func cadenceStream() -> AsyncThrowingStream<Double, Error>
}

protocol PedometerPermisionProtocol {
    func requestPermission()
    func authorizationStream() -> AsyncStream<AuthorizationStatus>
}

extension CMAuthorizationStatus {
    var customStatus: AuthorizationStatus {
        switch self {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorized: .authorizedAlways
        @unknown default: .unknown
        }
    }
}

final class PedometerService: PedometerServiceProtocol, PedometerPermisionProtocol {
    private let pedometer = CMPedometer()
    nonisolated(unsafe) private var authorization: AsyncStream<AuthorizationStatus>.Continuation?
    
    func requestPermission() {
        print("[PedometerService] Requesting pedometer permission")
        guard CMPedometer.isStepCountingAvailable() else { return }
        pedometer.queryPedometerData(from: Date(), to: Date()) { _, _ in
            let status = CMPedometer.authorizationStatus()
            self.authorization?.yield(status.customStatus)
        }
    }
    func authorizationStream() -> AsyncStream<AuthorizationStatus> {
        print("[PedometerService] Start pedometer authorization stream")
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.authorization = continuation
            let currentStatus = CMPedometer.authorizationStatus()
            continuation.yield(currentStatus.customStatus)
            continuation.onTermination = { [weak self] reason in
                print("[PedometerService] Authorization stream terminated:", reason)
                self?.authorization = nil
            }
        }
    }
    func cadenceStream() -> AsyncThrowingStream<Double, Error> {
        print("[PedometerService] Star streaming")
        return AsyncThrowingStream { continuation in
            guard CMPedometer.isStepCountingAvailable() else {
                continuation.finish(throwing: PedometerServiceError.pedometerUnavailable)
                return
            }
            let startDate = Date()
            pedometer.startUpdates(from: startDate) { data, error in
                if let error {
                    continuation.finish(throwing: PedometerServiceError.underlying(error))
                    return
                }
                guard let data else { return }
                if let cadence = data.currentCadence {
                    continuation.yield(cadence.doubleValue)
                }
            }
            let pedometerC = self.pedometer
            continuation.onTermination = { _ in
                print("[PedometerService] End streaming")
                pedometerC.stopUpdates()
            }
        }
    }
}

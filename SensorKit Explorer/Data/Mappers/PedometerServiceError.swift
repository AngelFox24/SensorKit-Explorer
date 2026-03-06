import Foundation

enum PedometerServiceError: LocalizedError {
    case pedometerUnavailable
    case cadenceUnavailable
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .pedometerUnavailable:
            return "Pedometer is not available on this device."
        case .cadenceUnavailable:
            return "Cadence data is not available."
        case .underlying:
            return "Unknown pedometer error."
        }
    }
}

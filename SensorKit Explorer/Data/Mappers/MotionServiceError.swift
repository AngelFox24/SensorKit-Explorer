import Foundation

enum MotionServiceError: LocalizedError {
    case deviceMotionUnavailable
    case gyroscopeUnavailable
    case creationFailed
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .deviceMotionUnavailable:
            return "Device motion is not available on this device."
        case .gyroscopeUnavailable:
            return "This device does not have a gyroscope."
        case .creationFailed:
            return "Error al crear CHHapticPatternPlayer."
        case .underlying:
            return "Error desconocido."
        }
    }
}

import Foundation

enum HapticsServiceError: LocalizedError {
    case creationFailed
    case exportFailure
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .creationFailed:
            return "Error al crear CHHapticPatternPlayer."
        case .exportFailure:
            return "Error al exportar el patrón de haptics."
        case .underlying:
            return "Error desconocido."
        }
    }
}

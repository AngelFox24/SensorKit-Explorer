enum CompassHaptic {
    case strong
    case light
}

extension CompassHaptic {
    var intensity: Float {
        switch self {
        case .strong: 1.0
        case .light: 0.4
        }
    }
    var sharpness: Float {
        switch self {
        case .strong: 0.9
        case .light: 0.3
        }
    }
}

enum CardinalDirection {
    case north
    case other
}

extension CardinalDirection {
    var compassHaptic: CompassHaptic {
        switch self {
        case .north: .strong
        case .other: .light
        }
    }
}

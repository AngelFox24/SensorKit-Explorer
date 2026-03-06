struct EmitHapticUseCase {
    private let hapticsService: HapticsServiceProtocol

    init(
        hapticsService: HapticsServiceProtocol
    ) {
        self.hapticsService = hapticsService
    }

    func execute(for direction: CardinalDirection) {
        hapticsService.impact(intensity: direction.compassHaptic.intensity, sharpness: direction.compassHaptic.sharpness)
    }
    
    func executeStrong() {
        let type = CompassHaptic.strong
        hapticsService.impact(intensity: type.intensity, sharpness: type.sharpness)
    }
    
    func play(pattern: HapticPatternModel) throws {
        try hapticsService.play(pattern: pattern)
    }
}

import CoreHaptics

protocol HapticsServiceProtocol {
    func impact(intensity: Float, sharpness: Float)
    func play(pattern: HapticPatternModel) throws
    func stop()
}

extension HapticPatternModel {
    func buildPattern() -> CHHapticPattern? {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return nil }
        var events: [CHHapticEvent] = []
        if !sustained {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity)),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness))
                ],
                relativeTime: 0
            )
            events.append(event)
        } else {
            let durationValue = max(duration, attackTime + decayTime)
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [],
                relativeTime: 0,
                duration: durationValue
            )
            events.append(event)
            var intensityControlPoints: [CHHapticParameterCurve.ControlPoint] = []
            var sharpnessControlPoints: [CHHapticParameterCurve.ControlPoint] = []
            intensityControlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0))
            intensityControlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: attackTime, value: Float(intensity)))
            sharpnessControlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0))
            sharpnessControlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: attackTime, value: Float(sharpness)))
            let sustainEndTime = max(durationValue - decayTime, attackTime)
            if sustainEndTime > attackTime {
                intensityControlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: sustainEndTime, value: Float(intensity)))
                sharpnessControlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: sustainEndTime, value: Float(sharpness)))
            }
            intensityControlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: durationValue, value: 0))
            sharpnessControlPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: durationValue, value: 0))
            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: intensityControlPoints,
                relativeTime: 0
            )
            let sharpnessCurve = CHHapticParameterCurve(
                parameterID: .hapticSharpnessControl,
                controlPoints: sharpnessControlPoints,
                relativeTime: 0
            )
            return try? CHHapticPattern(events: events, parameterCurves: [intensityCurve, sharpnessCurve])
        }

        return try? CHHapticPattern(events: events, parameters: [])
    }
}

final class HapticsService: HapticsServiceProtocol {
    private var engine: CHHapticEngine?
    private var currentPlayer: CHHapticPatternPlayer?

    init() {
        engine = try? CHHapticEngine()
        try? engine?.start()
    }

    func impact(intensity: Float = 1.0, sharpness: Float = 1.0) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensityParameter = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: intensity
        )
        let sharpnessParameter = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: sharpness
        )

        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensityParameter, sharpnessParameter],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("[HapticsService] Impact failed:", error)
        }
    }
    func play(pattern: HapticPatternModel) throws {
        guard let chPattern = pattern.buildPattern() else { return }
        try currentPlayer?.stop(atTime: 0)
        let player = try engine?.makePlayer(with: chPattern)
        currentPlayer = player
        try player?.start(atTime: 0)
    }
    func stop() {
        engine?.stop(completionHandler: nil)
    }
}

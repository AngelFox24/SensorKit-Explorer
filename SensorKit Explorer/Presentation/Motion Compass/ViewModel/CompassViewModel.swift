import Foundation
import SwiftUI

@Observable
final class CompassViewModel {
    var rotationAngle: Angle {
        .degrees(-Double(heading))
    }
    private(set) var heading: Int = 0
    private var previousHeading: Int = 0
    //Use Cases
    private let deviceOrientationUseCase: ObserveDeviceOrientationUseCase
    private let hapticUseCase: EmitHapticUseCase
    init(
        deviceOrientationUseCase: ObserveDeviceOrientationUseCase,
        hapticUseCase: EmitHapticUseCase
    ) {
        self.deviceOrientationUseCase = deviceOrientationUseCase
        self.hapticUseCase = hapticUseCase
    }
    func start() async {
        do {
            for try await deviceOrientation in deviceOrientationUseCase.execute() {
                let newHeading = Int(deviceOrientation.heading.rounded())
                let adjustedHeading = Int(normalizedAngle(Double(newHeading) + 90).rounded())
                if adjustedHeading != previousHeading {
                    if let cardinal = crossedCardinal(from: previousHeading, to: adjustedHeading) {
                        switch cardinal {
                        case .north:
                            hapticUseCase.execute(for: .north)
                        case .other:
                            hapticUseCase.execute(for: .other)
                        }
                    }
                    heading = adjustedHeading
                    previousHeading = adjustedHeading
                }
            }
        } catch {
            
        }
    }

    private func crossedCardinal(from old: Int, to new: Int) -> CardinalDirection? {
        if 0 == new {
            return .north
        } else if 90 == new || 180 == new || 270 == new {
            return .other
        }
        return nil
    }

    private func normalizedAngle(_ angle: Double) -> Double {
        let value = angle.truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }
}

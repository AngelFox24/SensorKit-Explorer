import CoreMotion

final class CoreMotionService: MotionServiceProtocol {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    init() {
        queue.name = "CoreMotionServiceQueue"
        queue.qualityOfService = .userInteractive
    }
    
    func motionStream() -> AsyncThrowingStream<DeviceOrientation, Error> {
        AsyncThrowingStream { continuation in
            guard motionManager.isGyroAvailable else {
                continuation.finish(throwing: MotionServiceError.gyroscopeUnavailable)
                return
            }
            guard motionManager.isDeviceMotionAvailable else {
                continuation.finish(throwing: MotionServiceError.deviceMotionUnavailable)
                return
            }
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            
            var lastOrientation: DeviceOrientation? = nil
            
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: queue) { motion, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let motion else { return }
                let attitude = motion.attitude
                let yaw = attitude.yaw * 180 / .pi
                let pitch = attitude.pitch * 180 / .pi
                let roll = attitude.roll * 180 / .pi
                let heading = yaw < 0 ? yaw + 360 : yaw
                
                let roundedHeading = (heading * 100).rounded() / 100
                let roundedPitch = (pitch * 100).rounded() / 100
                let roundedRoll = (roll * 100).rounded() / 100
                
                let currentOrientation = DeviceOrientation(
                    heading: roundedHeading,
                    pitch: roundedPitch,
                    roll: roundedRoll
                )
                
                if currentOrientation != lastOrientation {
                    lastOrientation = currentOrientation
                    continuation.yield(currentOrientation)
                }
            }
            let manager = motionManager
            continuation.onTermination = { _ in
                manager.stopDeviceMotionUpdates()
            }
        }
    }
}

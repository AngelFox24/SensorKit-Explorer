import Foundation

protocol MotionServiceProtocol {
    func motionStream() -> AsyncThrowingStream<DeviceOrientation, Error>
}

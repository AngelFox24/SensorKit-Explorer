import Foundation

struct ObserveDeviceOrientationUseCase {
    private let motionService: MotionServiceProtocol
    
    init(
        motionService: MotionServiceProtocol
    ) {
        self.motionService = motionService
    }
    
    func execute() -> AsyncThrowingStream<DeviceOrientation, Error> {
        motionService.motionStream()
    }
}

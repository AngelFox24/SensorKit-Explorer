import Foundation

struct PedometerServiceUseCase {
    private let pedometerService: PedometerServiceProtocol
    
    init(
        pedometerService: PedometerServiceProtocol
    ) {
        self.pedometerService = pedometerService
    }
    
    func cadenceStream() -> AsyncThrowingStream<Double, Error> {
        pedometerService.cadenceStream()
    }
}

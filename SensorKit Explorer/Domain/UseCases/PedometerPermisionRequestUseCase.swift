import Foundation

struct PedometerPermisionRequestUseCase {
    private let pedometerService: PedometerPermisionProtocol
    
    init(
        pedometerService: PedometerPermisionProtocol
    ) {
        self.pedometerService = pedometerService
    }
    
    func authorizationStream() -> AsyncStream<AuthorizationStatus> {
        pedometerService.authorizationStream()
    }
    
    func requestPermission() {
        pedometerService.requestPermission()
    }
}

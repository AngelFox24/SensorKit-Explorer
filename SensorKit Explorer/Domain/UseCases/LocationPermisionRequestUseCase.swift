import Foundation

struct LocationPermisionRequestUseCase {
    private let locationService: LocationPermisionProtocol
    
    init(
        locationService: LocationPermisionProtocol
    ) {
        self.locationService = locationService
    }
    
    func authorizationStream() -> AsyncStream<AuthorizationStatus> {
        locationService.authorizationStream()
    }
    
    func requestPermission() {
        locationService.requestPermission()
    }
}

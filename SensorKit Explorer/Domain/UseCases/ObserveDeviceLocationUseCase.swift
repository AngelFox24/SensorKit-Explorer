import Foundation

struct ObserveDeviceLocationUseCase {
    private let locationService: LocationServiceProtocol
    
    init(
        locationService: LocationServiceProtocol
    ) {
        self.locationService = locationService
    }
    
    func execute() -> AsyncThrowingStream<Coordinates, Error> {
        locationService.locationStream()
    }
}

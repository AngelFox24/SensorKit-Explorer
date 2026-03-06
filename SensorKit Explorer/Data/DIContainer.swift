import SwiftUI

@Observable
final class DIContainer {
    //Services
    private let motionService: MotionServiceProtocol
    private let locationService: LocationServiceProtocol & LocationPermisionProtocol
    private let hapticsService: HapticsServiceProtocol
    private let pedometerService: PedometerServiceProtocol & PedometerPermisionProtocol
    private let hapticPersistenceService: HapticPersistenceServiceProtocol
    //UseCases
    let observeDeviceOrientationUseCase: ObserveDeviceOrientationUseCase
    let emitHapticUseCase: EmitHapticUseCase
    let observeDeviceLocationUseCase: ObserveDeviceLocationUseCase
    let pedometerServiceUseCase: PedometerServiceUseCase
    let hapticPersistenceUseCase: HapticPersistenceUseCase
    //Permisions UseCases
    let locationPermisionRequestUseCase: LocationPermisionRequestUseCase
    let pedometerPermisionRequestUseCase: PedometerPermisionRequestUseCase
    
    init() {
        //Services
        self.motionService = CoreMotionService()
        self.locationService = LocationService()
        self.hapticsService = HapticsService()
        self.pedometerService = PedometerService()
        self.hapticPersistenceService = HapticPersistenceService()
        //UseCases
        self.observeDeviceOrientationUseCase = ObserveDeviceOrientationUseCase(motionService: motionService)
        self.emitHapticUseCase = EmitHapticUseCase(hapticsService: hapticsService)
        self.observeDeviceLocationUseCase = ObserveDeviceLocationUseCase(locationService: locationService)
        self.pedometerServiceUseCase = PedometerServiceUseCase(pedometerService: pedometerService)
        self.hapticPersistenceUseCase = HapticPersistenceUseCase(hapticsPersistenceService: hapticPersistenceService)
        //Permisions
        self.locationPermisionRequestUseCase = LocationPermisionRequestUseCase(locationService: locationService)
        self.pedometerPermisionRequestUseCase = PedometerPermisionRequestUseCase(pedometerService: pedometerService)
    }
}

struct HapticTrailViewModelBuilder {
    static func getViewModel(container: DIContainer) -> HapticTrailViewModel {
        HapticTrailViewModel(
            locationUseCase: container.observeDeviceLocationUseCase,
            hapticUseCase: container.emitHapticUseCase,
            pedometerUseCase: container.pedometerServiceUseCase
        )
    }
}

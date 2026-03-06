struct CompassViewModelBuilder {
    static func getViewModel(container: DIContainer) -> CompassViewModel {
        CompassViewModel(
            deviceOrientationUseCase: container.observeDeviceOrientationUseCase,
            hapticUseCase: container.emitHapticUseCase
        )
    }
}

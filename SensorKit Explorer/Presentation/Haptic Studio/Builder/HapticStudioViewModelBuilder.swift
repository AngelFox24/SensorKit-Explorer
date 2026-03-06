struct HapticStudioViewModelBuilder {
    static func getViewModel(container: DIContainer) -> HapticStudioViewModel {
        HapticStudioViewModel(
            hapticUseCase: container.emitHapticUseCase,
            hapticPersistenceUseCase: container.hapticPersistenceUseCase
        )
    }
}

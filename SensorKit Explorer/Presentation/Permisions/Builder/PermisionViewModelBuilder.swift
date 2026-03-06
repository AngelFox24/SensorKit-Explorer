struct PermisionViewModelBuilder {
    static func getViewModel(for viewType: ViewsWithPermisions, container: DIContainer) -> PermisionViewModel {
        PermisionViewModel(
            for: viewType,
            locationPermisionUseCase: container.locationPermisionRequestUseCase,
            pedometerPermisionUseCase: container.pedometerPermisionRequestUseCase
        )
    }
}

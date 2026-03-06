import SwiftUI

protocol PermisionRequestable {
    var icon: String { get }
    var title: String { get }
    var message: String { get }
}

enum PermisionsRequests {
    case location
    case pedometer
}

extension PermisionsRequests: PermisionRequestable {
    var icon: String {
        switch self {
        case .location: "location.fill"
        case .pedometer: "figure.walk"
        }
    }
    var title: String {
        switch self {
        case .location: "Localizacion"
        case .pedometer: "Pedometer"
        }
    }
    var message: String {
        switch self {
        case .location: "Necesitamos acceso a tu localizacion para poder mostrarte tu recorrido."
        case .pedometer: "Necesitamos acceso a tu dispositivo para poder mostrar tus pasos."
        }
    }
    var titleDenied: String {
        switch self {
        case .location: "No tienes acceso a tu localizacion"
        case .pedometer: "No tienes acceso a tu dispositivo"
        }
    }
    var messageDenied: String {
        switch self {
        case .location: "Por favor, habilita el acceso a tu localizacion en tus configuraciones de dispositivo."
        case .pedometer: "Por favor, habilita el acceso a tu dispositivo en tus configuraciones de dispositivo."
        }
    }
}

enum ViewStatus {
    case checkPermisions
    case iddle
}

enum ViewsWithPermisions {
    case motionCompass
    case hapticTrail
    case hapticStudio
    var permisionsRequests: [PermisionsRequests] {
        switch self {
        case .motionCompass: []
        case .hapticTrail: [.location, .pedometer]
        case .hapticStudio: []
        }
    }
}

struct HapticTrailView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: HapticTrailViewModel
    init(container: DIContainer) {
        self._viewModel = State(initialValue: HapticTrailViewModelBuilder.getViewModel(container: container))
    }
    var body: some View {
        ZStack(alignment: .top) {
            MapViewRepresentable(coordinates: viewModel.coordinates)
                .ignoresSafeArea()
            HUDOverlay(
                cadence: viewModel.cadence,
                distance: viewModel.distance,
                startDate: viewModel.startDate
            )
            .padding()
            VStack {
                Spacer()
                Button(viewModel.isStarted ? "Stop" : "Start") {
                    viewModel.toggleActivity()
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 40)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                self.viewModel.evaluateStart()
            case .background, .inactive:
                self.viewModel.stopStreams()
            @unknown default:
                break
            }
        }
    }
}

struct HapticTrailStateView: View {
    @State private var status: ViewStatus = .checkPermisions
    let container: DIContainer
    var body: some View {
        switch status {
        case .checkPermisions:
            PermisionView(for: .hapticTrail, viewStatus: $status, container: container)
        case .iddle:
            HapticTrailView(container: container)
        }
    }
}

#Preview {
    HapticTrailView(container: DIContainer())
}

import Foundation

@Observable
final class PermisionViewModel {
    var icon: String = ""
    var title: String = ""
    var message: String = ""
    var buttonInfo: ButtonInfo?
    var pendingPermissions: [PermisionsRequests] = []
    var pendingPermissionsCount: Int { pendingPermissions.count }
    var viewStatus: ViewStatus = .checkPermisions
    //Use cases
    private var locationPermisionUseCase: LocationPermisionRequestUseCase
    private var pedometerPermisionUseCase: PedometerPermisionRequestUseCase
    init(
        for viewType: ViewsWithPermisions,
        locationPermisionUseCase: LocationPermisionRequestUseCase,
        pedometerPermisionUseCase: PedometerPermisionRequestUseCase
    ) {
        self.pendingPermissions = viewType.permisionsRequests
        self.locationPermisionUseCase = locationPermisionUseCase
        self.pedometerPermisionUseCase = pedometerPermisionUseCase
    }
    @MainActor
    func startRequestPermisions() async {
        print("[PermisionViewModel] pendingPermissions: \(pendingPermissions)")
        guard let currentPermision = pendingPermissions.first else {
            self.viewStatus = .iddle
            return
        }
        switch currentPermision {
        case .location:
            for await status in locationPermisionUseCase.authorizationStream() {
                self.updateViewForNewStatus(for: status, type: .location)
                if status.isAuthorized {
                    break
                }
            }
        case .pedometer:
            for await status in pedometerPermisionUseCase.authorizationStream() {
                self.updateViewForNewStatus(for: status, type: .pedometer)
                print("[PermisionViewModel] New Status: \(status)")
                if status.isAuthorized {
                    print("[PermisionViewModel] Authorized")
                    break
                }
            }
        }
    }
    @MainActor
    func updateViewForNewStatus(for status: AuthorizationStatus, type: PermisionsRequests) {
        if status.isAuthorized {
            self.removePermision(for: type)
        } else if status.isDenied {
            self.updateViewForDenied(for: type)
        } else if status.requestPermission {
            self.updateViewForPermision(for: type)
        }
    }
    @MainActor
    func removePermision(for permision: PermisionsRequests) {
        self.pendingPermissions.removeAll { $0 == permision }
        if self.pendingPermissions.isEmpty {
            self.viewStatus = .iddle
        }
    }
    @MainActor
    func updateViewForDenied(for permision: PermisionsRequests) {
        self.icon = permision.icon
        self.title = permision.titleDenied
        self.message = permision.messageDenied
        self.buttonInfo = .denied(permision: permision)
    }
    @MainActor
    func updateViewForPermision(for permision: PermisionsRequests) {
        self.icon = permision.icon
        self.title = permision.title
        self.message = permision.message
        self.buttonInfo = .forPermision(permision: permision)
    }
    @MainActor
    func mainButtonAction(for info: ButtonInfo) {
        switch info {
        case .forPermision(let permision):
            switch permision {
            case .location:
                self.locationPermisionUseCase.requestPermission()
            case .pedometer:
                self.pedometerPermisionUseCase.requestPermission()
            }
        case .denied:
            return
        }
    }
}

enum ButtonInfo {
    case forPermision(permision: PermisionsRequests)
    case denied(permision: PermisionsRequests)
}

extension ButtonInfo {
    var title: String {
        switch self {
        case .forPermision: "Aceptar"
        case .denied: "Ir a configuraciones"
        }
    }
}

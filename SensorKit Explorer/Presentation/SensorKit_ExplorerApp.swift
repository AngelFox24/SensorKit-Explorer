import SwiftUI

@main
struct SensorKit_ExplorerApp: App {
    private let container = DIContainer()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(container)
        }
    }
}

import SwiftUI

private enum Tab: Hashable {
    case compass
    case trail
    case studio
    
    var title: String {
        switch self {
        case .compass: return "Compass"
        case .trail: return "Trail"
        case .studio: return "Studio"
        }
    }
    
    var systemImage: String {
        switch self {
        case .compass: return "location.north.line"
        case .trail: return "map.fill"
        case .studio: return "slider.horizontal.3"
        }
    }
}

struct MainView: View {
    @Environment(DIContainer.self) var container: DIContainer
    @State private var selectedTab: Tab = .compass

    var body: some View {
        TabView(selection: $selectedTab) {
            CompassView(container: container)
                .tabItem {
                    Label(Tab.compass.title, systemImage: Tab.compass.systemImage)
                }
                .tag(Tab.compass)

            HapticTrailStateView(container: container)
                .tabItem {
                    Label(Tab.trail.title, systemImage: Tab.trail.systemImage)
                }
                .tag(Tab.trail)

            HapticStudioView(container: container)
                .tabItem {
                    Label(Tab.studio.title, systemImage: Tab.studio.systemImage)
                }
                .tag(Tab.studio)
        }
    }
}

#Preview {
    MainView()
}

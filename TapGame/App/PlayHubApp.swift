import SwiftUI

@main
struct PlayHubApp: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(sessionStore)
                .environmentObject(locationService)
                .task { locationService.requestPermission() }
        }
    }
}

private struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeTab() }
                .tabItem { Label("Home", systemImage: "gamecontroller.fill") }
            NavigationStack { StatsTab() }
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
            NavigationStack { MapTab() }
                .tabItem { Label("Map", systemImage: "map.fill") }
            NavigationStack { SettingsTab() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(.purple)
    }
}

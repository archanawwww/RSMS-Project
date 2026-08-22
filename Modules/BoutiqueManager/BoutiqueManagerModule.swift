import SwiftUI

public struct BoutiqueLoginGatewayView: View {
    public init() {}

    public var body: some View {
        LoginView()
    }
}

public struct BoutiqueManagerModuleRootView: View {
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            StaffView()
                .tabItem {
                    Label("Staff", systemImage: "person.2.fill")
                }
                .tag(1)

            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "archivebox")
                }
                .tag(2)

            EventsView()
                .tabItem {
                    Label("Events", systemImage: "ticket.fill")
                }
                .tag(3)
        }
    }
}

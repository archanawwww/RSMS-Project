import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: InventoryAppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .environmentObject(ShipmentsViewModel())
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            RequestsView()
                .tabItem {
                    Label("Requests", systemImage: "tray.full")
                }
                .tag(1)
            
            ShipmentsDashboardView()
                .tabItem {
                    Label("Shipments", systemImage: "box.truck")
                }
                .tag(2)
            
            InventoryPlaceholderView()
                .tabItem {
                    Label("Inventory", systemImage: "archivebox")
                }
                .tag(3)
            
            // Cycle Count is hidden from the bottom tab bar for now.
            // Re-enable this block if it needs to return as a visible tab.
//            NavigationStack {
//                CycleCountView()
//                    .navigationTitle("Cycle Count")
//                    .navigationBarTitleDisplayMode(.large)
//            }
//            .tabItem {
//                Label("Cycle Count", systemImage: "barcode.viewfinder")
//            }
//            .tag(4)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(InventoryAppState())
}

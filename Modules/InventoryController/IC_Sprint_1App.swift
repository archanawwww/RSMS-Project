import SwiftUI

@main
struct IC_Sprint_1App: App {
    @StateObject private var appState = InventoryAppState()
    @StateObject private var shipmentsViewModel = ShipmentsViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(shipmentsViewModel)
        }
    }
}

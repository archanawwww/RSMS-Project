import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            if authManager.authState == .authenticated, let role = authManager.currentUser?.role {
                switch role {
                case .corporateAdmin:
                    CorporateAdminTabView()
                        .transition(.opacity)
                case .boutiqueManager:
                    BoutiqueManagerTabView()
                        .transition(.opacity)
                case .inventoryController:
                    InventoryControllerTabView()
                        .transition(.opacity)
                case .salesAssociate:
                    SalesAssociateTabView()
                        .transition(.opacity)
                }
            } else {
                LoginView()
                    .transition(.move(edge: .bottom))
            }
        }
        .environmentObject(authManager)
        .animation(.default, value: authManager.authState)
    }
}

#Preview {
    ContentView()
}

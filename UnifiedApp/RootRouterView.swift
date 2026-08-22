import BoutiqueManagerModule
import CorporateAdminModule
import InventoryControllerModule
import SalesAssociateModule
import SwiftUI

struct RootRouterView: View {
    @State private var authManager = AuthManager.shared

    var body: some View {
        Group {
            if let user = authManager.userContext {
                authenticatedRoot(for: user)
                    .id("\(user.id.uuidString)-\(user.role.rawValue)")
            } else {
                BoutiqueLoginGatewayView()
                    .id("boutique-login")
            }
        }
    }

    @ViewBuilder
    private func authenticatedRoot(for user: UnifiedUserContext) -> some View {
        switch user.role {
        case .corporateAdmin:
            CorporateAdminModuleRootView(
                userID: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                phoneNumber: user.phoneNumber,
                assignedStoreID: user.assignedStoreID,
                onLogout: logout
            )

        case .boutiqueManager:
            BoutiqueManagerModuleRootView()

        case .inventoryController:
            InventoryControllerModuleRootView(onLogout: logout)

        case .salesAssociate:
            SalesAssociateModuleRootView(
                userID: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                phoneNumber: user.phoneNumber,
                onLogout: logout
            )
        }
    }

    private func logout() {
        Task {
            await authManager.logout()
        }
    }
}

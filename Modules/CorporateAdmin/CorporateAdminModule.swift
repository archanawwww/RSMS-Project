import SwiftUI

@MainActor
public struct CorporateAdminModuleRootView: View {
    @StateObject private var authManager = AuthenticationManager()

    private let userID: UUID
    private let firstName: String
    private let lastName: String
    private let email: String
    private let phoneNumber: String
    private let assignedStoreID: UUID?
    private let onLogout: () -> Void

    public init(
        userID: UUID,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        assignedStoreID: UUID?,
        onLogout: @escaping () -> Void
    ) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.assignedStoreID = assignedStoreID
        self.onLogout = onLogout
    }

    public var body: some View {
        Group {
            if authManager.authState == .authenticated {
                CorporateAdminTabView()
                    .environmentObject(authManager)
            } else {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .onAppear {
            authManager.unifiedLogoutHandler = onLogout
        }
        .task(id: userID) {
            await authManager.adoptUnifiedSession(
                userID: userID,
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: phoneNumber,
                assignedStoreID: assignedStoreID
            )
        }
    }
}

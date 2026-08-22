import SwiftUI
import UIKit

public struct SalesAssociateModuleRootView: View {
    private let userID: UUID
    private let firstName: String
    private let lastName: String
    private let email: String
    private let phoneNumber: String
    private let onLogout: () -> Void

    public init(
        userID: UUID,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        onLogout: @escaping () -> Void
    ) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.onLogout = onLogout
    }

    public var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                SalesAssociateRootView(
                    onBack: {},
                    loggedInDashboard: dashboard,
                    onLogout: performLogout
                )
            } else {
                SalesAssociateRequiresIPadView()
            }
        }
    }

    private var dashboard: SalesAssociateDashboard {
        SalesAssociateDashboard.createDynamic(
            from: DBUser(
                id: userID.uuidString,
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: phoneNumber,
                userRole: "associate"
            )
        )
    }

    private func performLogout() {
        Task {
            await SupabaseDBService.shared.updateUserActiveStatus(
                userId: userID.uuidString,
                isActive: false
            )
            await MainActor.run {
                onLogout()
            }
        }
    }
}

private struct SalesAssociateRequiresIPadView: View {
    var body: some View {
        ContentUnavailableView(
            "iPad Required",
            systemImage: "ipad",
            description: Text("The Sales Associate workspace is available on iPadOS.")
        )
    }
}

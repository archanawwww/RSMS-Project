import Foundation
import Observation
import Supabase
import UIKit

public enum UnifiedUserRole: String, Codable, Sendable {
    case corporateAdmin = "admin"
    case boutiqueManager = "manager"
    case inventoryController = "inventory"
    case salesAssociate = "associate"
}

public struct UnifiedUserContext: Equatable, Sendable {
    public let id: UUID
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phoneNumber: String
    public let role: UnifiedUserRole
    public let assignedStoreID: UUID?

    public var displayName: String {
        [firstName, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

@Observable
public final class AuthManager {
    public static let shared = AuthManager()
    
    var currentUser: User? = nil
    public var isAuthenticated: Bool {
        currentUser != nil
    }

    public var userContext: UnifiedUserContext? {
        guard let currentUser, let role = currentUser.role else { return nil }
        return UnifiedUserContext(
            id: currentUser.id,
            firstName: currentUser.firstName,
            lastName: currentUser.lastName,
            email: currentUser.email,
            phoneNumber: currentUser.phoneNumber,
            role: UnifiedUserRole(rawValue: role.rawValue)!,
            assignedStoreID: currentUser.assignedStoreID
        )
    }
    
    public private(set) var isLoading = false
    public private(set) var errorMessage: String? = nil
    
    private init() {}
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await AuthenticationService.shared.login(email: email, password: password)
            let session = try await SupabaseService.shared.client.auth.session
            let authUserID = session.user.id
            
            // Corporate-created users keep their Supabase Auth UUID in authUserID,
            // while legacy records use the same UUID as the public User.id.
            let linkedProfiles: [User] = try await SupabaseService.shared.client
                .from("User")
                .select()
                .eq("authUserID", value: authUserID.uuidString)
                .limit(1)
                .execute()
                .value

            let user: User
            if let linkedProfile = linkedProfiles.first {
                user = linkedProfile
            } else {
                user = try await SupabaseService.shared.client
                    .from("User")
                    .select()
                    .eq("id", value: authUserID.uuidString)
                    .single()
                    .execute()
                    .value
            }

            guard user.isActive else {
                throw UnifiedAuthenticationError.inactiveUser
            }
            guard let role = user.role else {
                throw UnifiedAuthenticationError.missingRole
            }

            try validateDevice(for: role)

            UserDefaults.standard.set(session.accessToken, forKey: "active_session_access_token")
            UserDefaults.standard.set(session.accessToken, forKey: "supabase_access_token_\(user.email.lowercased())")
            
            await MainActor.run {
                self.currentUser = user
                self.isLoading = false
            }
        } catch {
            try? await AuthenticationService.shared.logout()
            await MainActor.run {
                UserDefaults.standard.removeObject(forKey: "active_session_access_token")
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("Login error: \(error)")
        }
    }
    
    public func logout() async {
        isLoading = true
        do {
            try await AuthenticationService.shared.logout()
        } catch {
            print("Logout error: \(error)")
        }
        await MainActor.run {
            UserDefaults.standard.removeObject(forKey: "active_session_access_token")
            self.currentUser = nil
            self.isLoading = false
        }
    }

    private func validateDevice(for role: UserRoleType) throws {
        let idiom = UIDevice.current.userInterfaceIdiom

        if role == .salesAssociate, idiom != .pad {
            throw UnifiedAuthenticationError.iPadRequired
        }

        if role != .salesAssociate, idiom == .pad {
            throw UnifiedAuthenticationError.iPhoneRequired
        }
    }
}

private enum UnifiedAuthenticationError: LocalizedError {
    case inactiveUser
    case missingRole
    case iPadRequired
    case iPhoneRequired

    var errorDescription: String? {
        switch self {
        case .inactiveUser:
            return "This account is inactive. Contact an administrator."
        case .missingRole:
            return "No application role is assigned to this account."
        case .iPadRequired:
            return "iPad required. Sales Associate accounts can only sign in on iPad."
        case .iPhoneRequired:
            return "iPhone required. This account can only sign in on iPhone."
        }
    }
}

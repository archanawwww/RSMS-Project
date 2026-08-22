//
//  User.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Core Organization                   │
//  │  USER STORIES: CA-01, Authentication, All    │
//  │                Approvals, All Reporting       │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — creates, deactivates, and assigns users to stores
//  • Boutique Manager — views staff under their store
//  • Sales Associate — identifies themselves during sales
//  • Inventory Controller — identifies themselves during stock operations
//
//  WHAT THIS MODEL DOES:
//  Represents every person who logs into the RSMS app.
//  Each user has a role, an optional store assignment, and an active flag.
//  This is the foundation for all authentication and authorization.
//

import Foundation

// MARK: - User

struct User: Identifiable, Codable, Hashable {

    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var role: UserRoleType
    var assignedStoreID: UUID?     // nil for Corporate Admins (they oversee all stores)
    var isActive: Bool

    // MARK: Computed Helpers

    /// Full display name — e.g. "Rajesh Kumar"
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Two-letter initials for avatar circles — e.g. "RK"
    var initials: String {
        let f = firstName.prefix(1).uppercased()
        let l = lastName.prefix(1).uppercased()
        return "\(f)\(l)"
    }

    // MARK: Init

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        role: UserRoleType,
        assignedStoreID: UUID? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.role = role
        self.assignedStoreID = assignedStoreID
        self.isActive = isActive
    }
}

// MARK: - UserRoleType

/// The four stakeholder roles in the RSMS.
/// Each role maps to a different dashboard and permission set.
///
/// ```
/// .corporateAdmin    → CorporateAdminDashboard
/// .boutiqueManager   → BoutiqueManagerDashboard
/// .salesAssociate    → SalesAssociateDashboard
/// .inventoryController → InventoryControllerDashboard
/// ```
enum UserRoleType: String, Codable, CaseIterable, Hashable {
    case corporateAdmin      = "Corporate Admin"
    case boutiqueManager     = "Boutique Manager"
    case salesAssociate      = "Sales Associate"
    case inventoryController = "Inventory Controller"
}

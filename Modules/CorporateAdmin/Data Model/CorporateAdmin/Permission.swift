//
//  Permission.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Core Organization — Access Control  │
//  │  USER STORIES: CA-01                         │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — defines and assigns permissions to roles
//  • All roles — system checks permissions before allowing actions
//
//  WHAT THIS MODEL DOES:
//  Defines a single permission entry (e.g. "Approve Planogram").
//  Each permission belongs to a module (Inventory, Sales, etc.)
//  and lists the allowed actions (create, read, approve, etc.).
//  Together, a set of Permissions forms a role's access policy.
//
//  EXAMPLES:
//  ┌─────────────────────┬─────────────┬─────────────────────────┐
//  │ Permission Name     │ Module      │ Allowed Actions         │
//  ├─────────────────────┼─────────────┼─────────────────────────┤
//  │ Approve Planogram   │ Planograms  │ approve, reject, review │
//  │ Review Compliance   │ Compliance  │ review, approve, reject │
//  │ Create Sale         │ Sales       │ create, read            │
//  │ Transfer Inventory  │ Inventory   │ transfer, approve, read │
//  └─────────────────────┴─────────────┴─────────────────────────┘
//

import Foundation

// MARK: - Permission

struct Permission: Identifiable, Codable, Hashable {

    let id: UUID
    var name: String                       // e.g. "Approve Planogram"
    var module: PermissionModule           // e.g. .planograms
    var allowedActions: [PermissionAction] // e.g. [.approve, .reject]

    init(
        id: UUID = UUID(),
        name: String,
        module: PermissionModule,
        allowedActions: [PermissionAction]
    ) {
        self.id = id
        self.name = name
        self.module = module
        self.allowedActions = allowedActions
    }
}

// MARK: - PermissionModule

/// Top-level RSMS modules that a permission can scope to.
enum PermissionModule: String, Codable, CaseIterable, Hashable {
    case products       = "Products"
    case promotions     = "Promotions"
    case planograms     = "Planograms"
    case compliance     = "Compliance"
    case inventory      = "Inventory"
    case sales          = "Sales"
    case customers      = "Customers"
    case reporting      = "Reporting"
    case userManagement = "User Management"
}

// MARK: - PermissionAction

/// Action verbs that can be allowed or denied within a module.
enum PermissionAction: String, Codable, CaseIterable, Hashable {
    case create   = "Create"
    case read     = "Read"
    case update   = "Update"
    case delete   = "Delete"
    case approve  = "Approve"
    case reject   = "Reject"
    case transfer = "Transfer"
    case submit   = "Submit"
    case review   = "Review"
    case export   = "Export"
}

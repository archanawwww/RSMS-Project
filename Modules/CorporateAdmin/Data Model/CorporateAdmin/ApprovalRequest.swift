//
//  ApprovalRequest.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Governance — Approval Workflow      │
//  │  USER STORIES: All approval flows            │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — reviews and acts on all approval requests
//  • Boutique Manager — submits planogram/compliance/return approvals
//  • Sales Associate — triggers return approvals
//  • Inventory Controller — triggers stock transfer approvals
//
//  WHAT THIS MODEL DOES:
//  A GENERIC approval wrapper. Instead of building a separate approval
//  system for planograms, compliance, returns, etc., this single model
//  handles them all via the ApprovalType enum.
//
//  EXAMPLE:
//  ┌──────────────────────────────────────────────────┐
//  │ type: .planogram                                 │
//  │ submittedBy: Boutique Manager "Priya Sharma"     │
//  │ status: .pending                                 │
//  │ approvedBy: nil (not yet reviewed)               │
//  └──────────────────────────────────────────────────┘
//

import Foundation

// MARK: - ApprovalRequest

struct ApprovalRequest: Identifiable, Codable, Hashable {

    let id: UUID
    var type: ApprovalType
    var submittedBy: UUID      // User.id of the person requesting approval
    var approvedBy: UUID?      // User.id of the reviewer (nil until reviewed)
    var status: ApprovalStatus
    var comments: String?

    init(
        id: UUID = UUID(),
        type: ApprovalType,
        submittedBy: UUID,
        approvedBy: UUID? = nil,
        status: ApprovalStatus = .pending,
        comments: String? = nil
    ) {
        self.id = id
        self.type = type
        self.submittedBy = submittedBy
        self.approvedBy = approvedBy
        self.status = status
        self.comments = comments
    }
}

// MARK: - ApprovalType

/// What kind of approval this is.
enum ApprovalType: String, Codable, CaseIterable, Hashable {
    case planogram     = "Planogram Approval"
    case compliance    = "Compliance Approval"
    case product       = "Product Approval"
    case returnRequest = "Return Approval"
    case stockTransfer = "Stock Transfer Approval"
    case exception     = "Exception Approval"
}

// MARK: - ApprovalStatus

/// Shared status used by ApprovalRequest AND ProductRequest.
/// Do NOT duplicate this enum — both models reference this one.
enum ApprovalStatus: String, Codable, CaseIterable, Hashable {
    case pending   = "Pending"
    case approved  = "Approved"
    case rejected  = "Rejected"
    case escalated = "Escalated"
}

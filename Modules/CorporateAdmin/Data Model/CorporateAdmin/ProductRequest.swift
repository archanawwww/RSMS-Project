//
//  ProductRequest.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Product & Merchandising — Approvals │
//  │  USER STORIES: Corporate Approval Flow       │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — reviews and approves/rejects product changes
//  • Boutique Manager — may submit product change requests
//
//  WHAT THIS MODEL DOES:
//  When someone wants to add a new Product to the master catalog or
//  modify an existing one, they submit a ProductRequest. The Corporate
//  Admin reviews it, then approves or rejects with comments.
//
//  WORKFLOW:
//  1. Boutique Manager or IC submits a ProductRequest
//  2. Corporate Admin sees it in "Pending Approvals"
//  3. Corporate Admin sets status to .approved or .rejected
//  4. If approved, the Product record is created/updated
//

import Foundation

// MARK: - ProductRequest

struct ProductRequest: Identifiable, Codable, Hashable {

    let id: UUID
    var productID: UUID        // the Product this request is about
    var submittedBy: UUID      // User.id of the submitter
    var status: ApprovalStatus // .pending → .approved / .rejected
    var reviewedBy: UUID?      // User.id of the Corporate Admin reviewer
    var reviewDate: Date?      // when the review happened
    var comments: String?      // reviewer notes

    init(
        id: UUID = UUID(),
        productID: UUID,
        submittedBy: UUID,
        status: ApprovalStatus = .pending,
        reviewedBy: UUID? = nil,
        reviewDate: Date? = nil,
        comments: String? = nil
    ) {
        self.id = id
        self.productID = productID
        self.submittedBy = submittedBy
        self.status = status
        self.reviewedBy = reviewedBy
        self.reviewDate = reviewDate
        self.comments = comments
    }
}

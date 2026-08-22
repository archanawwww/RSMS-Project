//
//  ComplianceReport.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Boutique Manager Team                │
//  │  DOMAIN: Product & Merchandising — Compliance│
//  │  USER STORIES: CA-05, BM Compliance          │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Boutique Manager — takes photos and submits compliance proof
//  • Corporate Admin — reviews the submission and approves/rejects
//
//  WHAT THIS MODEL DOES:
//  After Corporate Admin publishes a Planogram (see CorporateAdmin/
//  Planogram.swift), the Boutique Manager must execute it in-store
//  and prove it by submitting this report with photos.
//
//  WORKFLOW:
//  1. BM receives a published Planogram
//  2. BM arranges the store according to the planogram
//  3. BM takes photos and creates a ComplianceReport → status = .submitted
//  4. Corporate Admin reviews photos → status = .approved or .rejected
//
//  CROSS-REFERENCE:
//  • planogramID → CorporateAdmin/Planogram.swift
//  • storeID → BoutiqueManager/Store.swift
//  • submittedBy, reviewedBy → CorporateAdmin/User.swift
//

import Foundation

// MARK: - ComplianceReport

struct ComplianceReport: Identifiable, Codable, Hashable {

    let id: UUID
    var storeID: UUID          // which store this is for
    var planogramID: UUID      // which planogram is being complied with
    var submittedBy: UUID      // User.id of the Boutique Manager
    var photos: [String]       // array of photo URLs or local file paths
    var comments: String?      // optional notes from BM
    var status: ComplianceStatus
    var reviewedBy: UUID?      // User.id of the Corporate Admin reviewer

    init(
        id: UUID = UUID(),
        storeID: UUID,
        planogramID: UUID,
        submittedBy: UUID,
        photos: [String] = [],
        comments: String? = nil,
        status: ComplianceStatus = .submitted,
        reviewedBy: UUID? = nil
    ) {
        self.id = id
        self.storeID = storeID
        self.planogramID = planogramID
        self.submittedBy = submittedBy
        self.photos = photos
        self.comments = comments
        self.status = status
        self.reviewedBy = reviewedBy
    }
}

// MARK: - ComplianceStatus

enum ComplianceStatus: String, Codable, CaseIterable, Hashable {
    case submitted   = "Submitted"     // BM has submitted, awaiting review
    case underReview = "Under Review"  // CA is looking at it
    case approved    = "Approved"      // CA approved — store is compliant
    case rejected    = "Rejected"      // CA rejected — BM must redo
}

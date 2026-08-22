//
//  Planogram.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Product & Merchandising — Visual    │
//  │  USER STORIES: CA-06, BM Compliance          │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — creates planograms and publishes to stores
//  • Boutique Manager — receives planograms and submits compliance proof
//
//  WHAT THIS MODEL DOES:
//  A planogram is a visual merchandising directive — it tells a store
//  how to arrange products on shelves, in windows, on mannequins, etc.
//  Corporate Admin publishes it; Boutique Manager executes it in-store
//  and submits photos via ComplianceReport (in BoutiqueManager folder).
//
//  WORKFLOW:
//  1. Corporate Admin creates planogram → status = .draft
//  2. Corporate Admin publishes → status = .published
//  3. Boutique Manager receives it → status = .pendingCompliance
//  4. Boutique Manager submits ComplianceReport with photos
//  5. Corporate Admin reviews → status = .compliant or .rejected
//

import Foundation

// MARK: - Planogram

struct SupabasePlanogram: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var version: String?
    var category: String?
    var effectiveDate: String?
    var boutiquesAssigned: Int
    var createdBy: UUID?
    var status: String
    var documentURL: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "planogram_id"
        case title
        case version
        case category
        case effectiveDate = "effective_date"
        case boutiquesAssigned = "boutiques_assigned"
        case createdBy = "created_by"
        case status
        case documentURL = "document_url"
        case createdAt = "created_at"
    }
}

// MARK: - PlanogramStatus

enum PlanogramStatus: String, Codable, CaseIterable, Hashable {
    case draft             = "Draft"
    case published         = "Published"
    case pendingCompliance = "Pending Compliance"
    case compliant         = "Compliant"
    case rejected          = "Rejected"
}

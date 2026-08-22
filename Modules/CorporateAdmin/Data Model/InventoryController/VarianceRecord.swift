//
//  VarianceRecord.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Inventory Controller Team            │
//  │  DOMAIN: Inventory — Audit & Shrinkage       │
//  │  USER STORIES: Variance handling, Audit,     │
//  │                Shrinkage tracking              │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Inventory Controller — investigates and resolves variances
//  • Boutique Manager — notified about variance alerts
//  • Corporate Admin — views shrinkage metrics in reports
//
//  WHAT THIS MODEL DOES:
//  When a cycle count reveals that the actual stock doesn't match the
//  expected stock, a VarianceRecord is created. The IC investigates
//  the reason (theft, miscount, damage, etc.) and resolves it.
//
//  EXAMPLE (from the dashboard):
//  ┌─────────────────────────────────────────────────────┐
//  │ Missing: SKU-8821 — Cartier Love Bracelet           │
//  │ Expected: 2 | Actual: 1 | Variance: -1              │
//  │ Reason: "Not found during daily cycle count."       │
//  │ Status: .open                                        │
//  └─────────────────────────────────────────────────────┘
//
//  CROSS-REFERENCE:
//  • productID → CorporateAdmin/Product.swift
//

import Foundation

// MARK: - VarianceRecord

struct VarianceRecord: Identifiable, Codable, Hashable {

    let id: UUID
    var productID: UUID
    var expectedQuantity: Int      // what the system says we should have
    var actualQuantity: Int        // what we actually counted
    var reason: String?            // e.g. "Not found during cycle count"
    var status: VarianceStatus

    /// Difference: positive = surplus, negative = shrinkage.
    var variance: Int { actualQuantity - expectedQuantity }

    /// True when actual < expected (something is missing).
    var isShrinkage: Bool { variance < 0 }

    init(
        id: UUID = UUID(),
        productID: UUID,
        expectedQuantity: Int,
        actualQuantity: Int,
        reason: String? = nil,
        status: VarianceStatus = .open
    ) {
        self.id = id
        self.productID = productID
        self.expectedQuantity = expectedQuantity
        self.actualQuantity = actualQuantity
        self.reason = reason
        self.status = status
    }
}

// MARK: - VarianceStatus

enum VarianceStatus: String, Codable, CaseIterable, Hashable {
    case open          = "Open"           // just discovered
    case investigating = "Investigating"  // IC is looking into it
    case resolved      = "Resolved"       // root cause found, corrected
    case writtenOff    = "Written Off"    // loss accepted, shrinkage logged
}

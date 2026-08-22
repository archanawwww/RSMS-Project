//
//  InventoryRecord.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Inventory Controller Team            │
//  │  DOMAIN: Inventory — Stock Levels            │
//  │  USER STORIES: Stock visibility, Availability│
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Inventory Controller — owns and updates stock levels
//  • Sales Associate — checks availability before promising to customer
//  • Boutique Manager — monitors store-level stock health
//
//  WHAT THIS MODEL DOES:
//  The SINGLE SOURCE OF TRUTH for how much stock exists for a given
//  product at a given store. Every sale, transfer, receipt, and
//  variance adjustment ultimately updates an InventoryRecord.
//
//  IMPORTANT:
//  The identity is a composite of productID + storeID.
//  One product can have different quantities at different stores.
//
//  REORDER LOGIC:
//  When quantity ≤ reorderThreshold, the `needsReorder` flag is true.
//  This triggers alerts on the IC dashboard.
//
//  CROSS-REFERENCE:
//  • productID → CorporateAdmin/Product.swift
//  • storeID → BoutiqueManager/Store.swift
//

import Foundation

// MARK: - InventoryRecord

struct InventoryRecord: Identifiable, Codable, Hashable {

    /// Composite identity — one record per product per store.
    var id: String { "\(productID.uuidString)-\(storeID.uuidString)" }

    var productID: UUID
    var storeID: UUID
    var quantity: Int              // current on-hand count
    var reorderThreshold: Int     // alert when quantity drops to this level
    var lastUpdated: Date

    /// True when stock is at or below the reorder point.
    var needsReorder: Bool { quantity <= reorderThreshold }

    init(
        productID: UUID,
        storeID: UUID,
        quantity: Int,
        reorderThreshold: Int = 5,
        lastUpdated: Date = Date()
    ) {
        self.productID = productID
        self.storeID = storeID
        self.quantity = quantity
        self.reorderThreshold = reorderThreshold
        self.lastUpdated = lastUpdated
    }
}

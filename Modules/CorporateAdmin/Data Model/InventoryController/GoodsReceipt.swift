//
//  GoodsReceipt.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Inventory Controller Team            │
//  │  DOMAIN: Inventory — Receiving               │
//  │  USER STORIES: Receive Goods, Cycle Count    │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Inventory Controller — records receipt of goods from vendor
//
//  WHAT THIS MODEL DOES:
//  When a vendor shipment arrives (from a VendorRequest), the IC
//  manually counts the items and creates a GoodsReceipt.
//
//  NOTE: RFID scanning is OUT OF SCOPE. All verification is manual.
//  The IC physically counts items and records the received quantity.
//
//  WORKFLOW:
//  1. Goods arrive at the store
//  2. IC opens the corresponding VendorRequest
//  3. IC counts items → creates GoodsReceipt
//  4. If receivedQuantity ≠ ordered quantity → variance investigation
//  5. InventoryRecord.quantity is updated
//
//  CROSS-REFERENCE:
//  • vendorRequestID → InventoryController/VendorRequest.swift
//  • verifiedBy → CorporateAdmin/User.swift (the IC who verified)
//

import Foundation

// MARK: - GoodsReceipt

struct GoodsReceipt: Identifiable, Codable, Hashable {

    let id: UUID
    var vendorRequestID: UUID      // which VendorRequest this fulfills
    var receivedDate: Date         // when goods were counted
    var receivedQuantity: Int      // how many were actually received
    var verifiedBy: UUID           // User.id of the IC who counted

    init(
        id: UUID = UUID(),
        vendorRequestID: UUID,
        receivedDate: Date = Date(),
        receivedQuantity: Int,
        verifiedBy: UUID
    ) {
        self.id = id
        self.vendorRequestID = vendorRequestID
        self.receivedDate = receivedDate
        self.receivedQuantity = receivedQuantity
        self.verifiedBy = verifiedBy
    }
}

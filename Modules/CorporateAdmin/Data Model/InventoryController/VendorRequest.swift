//
//  VendorRequest.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Inventory Controller Team            │
//  │  DOMAIN: Inventory — External Sourcing       │
//  │  USER STORIES: External sourcing,            │
//  │                Replenishment                  │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Inventory Controller — creates orders to external suppliers
//
//  WHAT THIS MODEL DOES:
//  When inter-store transfer can't satisfy demand (no other store has
//  the product either), the IC creates a VendorRequest to order from
//  an external supplier. Once shipped and received, a GoodsReceipt
//  is created (see GoodsReceipt.swift).
//
//  WORKFLOW:
//  1. IC identifies need → creates VendorRequest → status = .pending
//  2. Order placed with supplier → status = .ordered
//  3. Supplier ships → status = .shipped
//  4. Goods arrive → IC creates GoodsReceipt → status = .received
//
//  CROSS-REFERENCE:
//  • productID → CorporateAdmin/Product.swift
//  • After receipt → InventoryController/GoodsReceipt.swift
//

import Foundation

// MARK: - VendorRequest

struct VendorRequest: Identifiable, Codable, Hashable {

    let id: UUID
    var supplierName: String   // e.g. "Hermès Paris"
    var productID: UUID        // which product to order
    var quantity: Int
    var status: VendorRequestStatus

    init(
        id: UUID = UUID(),
        supplierName: String,
        productID: UUID,
        quantity: Int,
        status: VendorRequestStatus = .pending
    ) {
        self.id = id
        self.supplierName = supplierName
        self.productID = productID
        self.quantity = quantity
        self.status = status
    }
}

// MARK: - VendorRequestStatus

enum VendorRequestStatus: String, Codable, CaseIterable, Hashable {
    case pending   = "Pending"    // IC created, not yet ordered
    case ordered   = "Ordered"    // PO sent to supplier
    case shipped   = "Shipped"    // supplier has dispatched
    case received  = "Received"   // goods arrived, GoodsReceipt created
    case cancelled = "Cancelled"
}

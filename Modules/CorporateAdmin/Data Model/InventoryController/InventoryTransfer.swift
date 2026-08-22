//
//  InventoryTransfer.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Inventory Controller Team            │
//  │  DOMAIN: Inventory — Physical Movement       │
//  │  USER STORIES: Inventory Movement            │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Inventory Controller — creates and tracks the physical shipment
//
//  WHAT THIS MODEL DOES:
//  Records the actual PHYSICAL movement of goods after a StockRequest
//  has been approved. Think of StockRequest as the "please send me stock"
//  and InventoryTransfer as the "I shipped it on this date, here's the
//  tracking status."
//
//  RELATIONSHIP:
//  StockRequest (1) ──creates──→ InventoryTransfer (1)
//
//  CROSS-REFERENCE:
//  • stockRequestID → BoutiqueManager/StockRequest.swift
//

import Foundation

// MARK: - InventoryTransfer

struct InventoryTransfer: Identifiable, Codable, Hashable {

    let id: UUID
    var stockRequestID: UUID       // links back to the approved StockRequest
    var transferDate: Date         // when the shipment was initiated
    var status: InventoryTransferStatus

    init(
        id: UUID = UUID(),
        stockRequestID: UUID,
        transferDate: Date = Date(),
        status: InventoryTransferStatus = .initiated
    ) {
        self.id = id
        self.stockRequestID = stockRequestID
        self.transferDate = transferDate
        self.status = status
    }
}

// MARK: - InventoryTransferStatus

enum InventoryTransferStatus: String, Codable, CaseIterable, Hashable {
    case initiated = "Initiated"   // IC has started the process
    case inTransit = "In Transit"  // goods are on the way
    case delivered = "Delivered"    // arrived at destination
    case verified  = "Verified"    // destination IC confirmed receipt
    case cancelled = "Cancelled"
}

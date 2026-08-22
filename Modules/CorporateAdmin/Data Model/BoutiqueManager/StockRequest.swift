//
//  StockRequest.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Boutique Manager Team                │
//  │  DOMAIN: Inventory — Inter-Store Transfers   │
//  │  USER STORIES: SA-05, BM Approval, IC        │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Boutique Manager — approves transfer requests for their store
//  • Sales Associate — initiates a request when a product is out of stock
//  • Inventory Controller — fulfills approved requests (ships/receives)
//
//  WHAT THIS MODEL DOES:
//  A request to move stock from one store to another.
//  Example: A customer in Mumbai wants a watch that only Delhi has.
//  The SA creates a StockRequest, the BM approves it, and the IC ships it.
//
//  WORKFLOW:
//  1. Sales Associate creates StockRequest → status = .pending
//  2. Boutique Manager (source store) approves → status = .approved
//  3. Inventory Controller ships goods → status = .inTransit
//  4. Destination IC receives → status = .delivered
//
//  CROSS-REFERENCE:
//  • productID → CorporateAdmin/Product.swift
//  • sourceStoreID, destinationStoreID → BoutiqueManager/Store.swift
//  • After approval, an InventoryTransfer is created (see InventoryController/)
//

import Foundation

// MARK: - StockRequest

struct StockRequest: Identifiable, Codable, Hashable {

    let id: UUID
    var productID: UUID            // which product to transfer
    var sourceStoreID: UUID        // send FROM this store
    var destinationStoreID: UUID   // send TO this store
    var quantity: Int
    var urgency: RequestUrgency
    var status: TransferRequestStatus

    init(
        id: UUID = UUID(),
        productID: UUID,
        sourceStoreID: UUID,
        destinationStoreID: UUID,
        quantity: Int,
        urgency: RequestUrgency = .normal,
        status: TransferRequestStatus = .pending
    ) {
        self.id = id
        self.productID = productID
        self.sourceStoreID = sourceStoreID
        self.destinationStoreID = destinationStoreID
        self.quantity = quantity
        self.urgency = urgency
        self.status = status
    }
}

// MARK: - RequestUrgency

enum RequestUrgency: String, Codable, CaseIterable, Hashable {
    case low    = "Low"
    case normal = "Normal"
    case high   = "High"
    case urgent = "Urgent"    // customer waiting in-store
}

// MARK: - TransferRequestStatus

enum TransferRequestStatus: String, Codable, CaseIterable, Hashable {
    case pending   = "Pending"        // awaiting BM approval
    case approved  = "Approved"       // BM approved, awaiting IC shipment
    case rejected  = "Rejected"       // BM rejected
    case inTransit = "In Transit"     // IC has shipped
    case delivered = "Delivered"      // received at destination
    case cancelled = "Cancelled"
}

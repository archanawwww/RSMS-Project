//
//  ReturnRequest.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Boutique Manager Team                │
//  │  DOMAIN: Customer & Sales — Returns          │
//  │  USER STORIES: SA-09, Manager Approval       │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Sales Associate — creates the return request on behalf of customer
//  • Boutique Manager — approves or rejects the return
//
//  WHAT THIS MODEL DOES:
//  When a customer wants to return a purchased item, the Sales Associate
//  creates a ReturnRequest. The Boutique Manager then reviews and
//  approves or rejects it. Once approved, the refund/exchange happens.
//
//  WORKFLOW:
//  1. Customer walks in with the item
//  2. Sales Associate creates ReturnRequest → status = .pending
//  3. Boutique Manager reviews reason → status = .approved or .rejected
//  4. If approved → refund processed → status = .processed
//
//  CROSS-REFERENCE:
//  • saleID → SalesAssociate/Sale.swift (the original transaction)
//  • customerID → SalesAssociate/Customer.swift
//  • approvedBy → CorporateAdmin/User.swift
//

import Foundation

// MARK: - ReturnRequest

struct ReturnRequest: Identifiable, Codable, Hashable {

    let id: UUID
    var saleID: UUID           // which Sale is being returned
    var customerID: UUID?      // optional — guest sales have no customer
    var reason: String         // e.g. "Defective clasp", "Wrong size"
    var status: ReturnStatus
    var approvedBy: UUID?      // User.id of the Boutique Manager

    init(
        id: UUID = UUID(),
        saleID: UUID,
        customerID: UUID? = nil,
        reason: String,
        status: ReturnStatus = .pending,
        approvedBy: UUID? = nil
    ) {
        self.id = id
        self.saleID = saleID
        self.customerID = customerID
        self.reason = reason
        self.status = status
        self.approvedBy = approvedBy
    }
}

// MARK: - ReturnStatus

enum ReturnStatus: String, Codable, CaseIterable, Hashable {
    case pending   = "Pending"    // SA submitted, awaiting BM review
    case approved  = "Approved"   // BM approved the return
    case rejected  = "Rejected"   // BM rejected the return
    case processed = "Processed"  // refund/exchange completed
}

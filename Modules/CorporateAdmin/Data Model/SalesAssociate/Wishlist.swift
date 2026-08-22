//
//  Wishlist.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Sales Associate Team                 │
//  │  DOMAIN: Customer & Sales — Assisted Selling │
//  │  USER STORIES: SA-02, SA-06                  │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Sales Associate — adds products to a customer's wishlist
//
//  WHAT THIS MODEL DOES:
//  A list of Product IDs that a customer is interested in but hasn't
//  purchased yet. Used during clienteling ("I'll save this Birkin for
//  you") and assisted selling ("Here's what you had your eye on").
//
//  CROSS-REFERENCE:
//  • customerID → SalesAssociate/Customer.swift
//  • productIDs[] → CorporateAdmin/Product.swift
//

import Foundation

// MARK: - Wishlist

struct Wishlist: Identifiable, Codable, Hashable {

    let id: UUID
    var customerID: UUID       // which customer owns this wishlist
    var productIDs: [UUID]     // Product.ids of items they're interested in

    /// How many items are in the wishlist.
    var itemCount: Int { productIDs.count }

    init(
        id: UUID = UUID(),
        customerID: UUID,
        productIDs: [UUID] = []
    ) {
        self.id = id
        self.customerID = customerID
        self.productIDs = productIDs
    }
}

//
//  Cart.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Sales Associate Team                 │
//  │  DOMAIN: Customer & Sales — Checkout         │
//  │  USER STORIES: SA-06, SA-08                  │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Sales Associate — builds the cart during assisted selling, displaying tax and currency details
//
//  WHAT THIS MODEL DOES:
//  An in-progress shopping session. The SA adds CartItems as they show products to the customer.
//  Uses the assigned Store context to calculate region-wise taxation (GST/VAT/Sales Tax) and format
//  all pricing in the store's currency. Converts to a Sale on checkout.
//
//  LIFECYCLE:
//  Cart (in-progress) ──checkout──→ Sale (finalized)
//
//  CROSS-REFERENCE:
//  • customerID → SalesAssociate/Customer.swift (nil for guest sales)
//  • storeID → BoutiqueManager/Store.swift
//  • CartItem.productID → CorporateAdmin/Product.swift
//

import Foundation

// MARK: - Cart

struct Cart: Identifiable, Codable, Hashable {

    let id: UUID
    var customerID: UUID?      // nil for guest/walk-in sales
    var storeID: UUID          // associated boutique location
    var currency: Currency     // operational currency for checkout
    var taxRate: Double        // tax rate percentage (e.g. 0.18 for 18%)
    var taxName: String        // localized tax tag (e.g. "GST")
    var items: [CartItem]
    var totalAmount: Double    // stored/finalized total amount

    // MARK: - Calculated Pricing

    /// Pre-tax subtotal = sum of all line item subtotals
    var preTaxSubtotal: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }

    /// Calculated tax amount on the subtotal
    var computedTax: Double {
        preTaxSubtotal * taxRate
    }

    /// Computed total amount = pre-tax subtotal + computed tax
    var computedTotal: Double {
        preTaxSubtotal + computedTax
    }

    // MARK: - Formatted Strings

    /// Formatted total with currency symbol and locale group separators
    var formattedTotal: String {
        currency.format(computedTotal)
    }

    /// Formatted tax portion
    var formattedTax: String {
        currency.format(computedTax)
    }

    /// Formatted pre-tax subtotal
    var formattedPreTaxSubtotal: String {
        currency.format(preTaxSubtotal)
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        customerID: UUID? = nil,
        storeID: UUID,
        currency: Currency = .inr,
        taxRate: Double = 0.0,
        taxName: String = "Tax",
        items: [CartItem] = [],
        totalAmount: Double = 0.0
    ) {
        self.id = id
        self.customerID = customerID
        self.storeID = storeID
        self.currency = currency
        self.taxRate = taxRate
        self.taxName = taxName
        self.items = items
        self.totalAmount = totalAmount
    }
}

// MARK: - CartItem

/// A single line in the cart.
struct CartItem: Identifiable, Codable, Hashable {

    let id: UUID
    var productID: UUID        // which Product
    var productName: String    // display name (denormalized for speed)
    var quantity: Int
    var unitPrice: Double      // price per unit in the store's currency

    /// Line total = unitPrice × quantity
    var subtotal: Double {
        unitPrice * Double(quantity)
    }

    init(
        id: UUID = UUID(),
        productID: UUID,
        productName: String,
        quantity: Int = 1,
        unitPrice: Double
    ) {
        self.id = id
        self.productID = productID
        self.productName = productName
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

//
//  Sale.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Sales Associate Team                 │
//  │  DOMAIN: Customer & Sales — Transactions     │
//  │  USER STORIES: Checkout, KPIs, Reports       │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Sales Associate — creates a Sale when checkout completes
//  • Boutique Manager — views daily sales and tax reports for their store
//  • Corporate Admin — aggregates sales data for regional KPIs and reports
//
//  WHAT THIS MODEL DOES:
//  A finalized, immutable transaction record. Created when a Cart is successfully checked out.
//  Maintains multi-currency information and detailed regional tax breakdowns (pre-tax amount,
//  tax amount, local tax name/rate) to satisfy global corporate audit standards.
//
//  PAYMENT METHODS:
//  ┌──────────────┬─────────────────────────────────────┐
//  │ cash         │ Physical cash payment                │
//  │ card         │ Credit/debit card                    │
//  │ upi          │ UPI (Google Pay, PhonePe, etc.)      │
//  │ bankTransfer │ NEFT/RTGS                            │
//  │ emi          │ Equated Monthly Installment           │
//  │ mixed        │ Split across multiple methods        │
//  └──────────────┴─────────────────────────────────────┘
//
//  CROSS-REFERENCE:
//  • customerID → SalesAssociate/Customer.swift (nil for guest sales)
//  • salesAssociateID → CorporateAdmin/User.swift
//  • storeID → BoutiqueManager/Store.swift
//

import Foundation

// MARK: - Sale

struct Sale: Identifiable, Codable, Hashable {

    let id: UUID
    var customerID: UUID?              // nil for guest/walk-in
    var salesAssociateID: UUID         // who made the sale
    var storeID: UUID                  // which store
    var saleDate: Date
    var currency: Currency             // Local store currency of transaction
    var preTaxAmount: Double           // Pre-tax subtotal
    var taxAmount: Double              // Calculated tax amount paid
    var taxRate: Double                // Tax rate percentage applied (e.g. 0.18)
    var taxName: String                // Applied tax name (e.g. "GST", "VAT")
    var totalAmount: Double            // Gross transaction total (preTax + tax)
    var paymentMethod: PaymentMethod

    // MARK: Display Helpers

    /// Formatted gross total — e.g. "₹12,00,000.00" or "$12,000.00"
    var formattedTotal: String {
        currency.format(totalAmount)
    }

    /// Formatted tax amount — e.g. "₹2,16,000.00"
    var formattedTax: String {
        currency.format(taxAmount)
    }

    /// Formatted pre-tax amount — e.g. "₹9,84,000.00"
    var formattedPreTax: String {
        currency.format(preTaxAmount)
    }

    /// Display summary of tax rate, e.g. "18% GST" or "8.88% Sales Tax"
    var taxSummary: String {
        let percent = Int(round(taxRate * 100))
        return "\(percent)% \(taxName)"
    }

    // MARK: Init

    init(
        id: UUID = UUID(),
        customerID: UUID? = nil,
        salesAssociateID: UUID,
        storeID: UUID,
        saleDate: Date = Date(),
        currency: Currency = .inr,
        preTaxAmount: Double,
        taxAmount: Double,
        taxRate: Double,
        taxName: String,
        totalAmount: Double,
        paymentMethod: PaymentMethod
    ) {
        self.id = id
        self.customerID = customerID
        self.salesAssociateID = salesAssociateID
        self.storeID = storeID
        self.saleDate = saleDate
        self.currency = currency
        self.preTaxAmount = preTaxAmount
        self.taxAmount = taxAmount
        self.taxRate = taxRate
        self.taxName = taxName
        self.totalAmount = totalAmount
        self.paymentMethod = paymentMethod
    }
}

// MARK: - PaymentMethod

enum PaymentMethod: String, Codable, CaseIterable, Hashable {
    case cash         = "Cash"
    case card         = "Card"
    case upi          = "UPI"
    case bankTransfer = "Bank Transfer"
    case emi          = "EMI"
    case mixed        = "Mixed"
}

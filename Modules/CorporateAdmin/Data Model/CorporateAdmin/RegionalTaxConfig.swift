//
//  RegionalTaxConfig.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Pricing & Merchandising — Taxation  │
//  │  USER STORIES: CA-07, SA checkout            │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — configures standard tax profiles by market region and edits them dynamically
//  • Boutique Manager — reviews local boutique margins including tax implications
//  • Sales Associate — performs checkout where local tax is automatically calculated
//
//  WHAT THIS MODEL DOES:
//  Encapsulates taxation rules for a specific country or retail market.
//  Tax details can be edited dynamically per store location.
//

import Foundation

// MARK: - TaxType

/// General tax categories used across global boutique regions.
enum TaxType: String, Codable, CaseIterable, Hashable {
    case vat = "VAT"
    case gst = "GST"
    case salesTax = "Sales Tax"
    case consumptionTax = "Consumption Tax"
    case custom = "Custom"
    case none = "None"
}

// MARK: - RegionalTaxConfig

/// Dynamic tax rule configuration for a store location.
struct RegionalTaxConfig: Codable, Hashable {
    
    /// The classification category of taxation
    var taxType: TaxType
    
    /// Customizable display name of the tax (e.g. "CGST + SGST", "VAT 20%")
    var taxName: String
    
    /// Tax rate as a decimal (e.g. 0.18 for 18%). Can be edited dynamically.
    var taxRate: Double

    /// Calculates tax amount on top of a net/pre-tax base price
    func calculateTax(for preTaxAmount: Double) -> Double {
        return preTaxAmount * taxRate
    }

    /// Extracts tax portion from a gross/post-tax total amount
    func extractTax(from totalAmount: Double) -> Double {
        return totalAmount - (totalAmount / (1.0 + taxRate))
    }
    
    /// Calculates pre-tax amount from a gross/post-tax total amount
    func extractPreTaxAmount(from totalAmount: Double) -> Double {
        return totalAmount / (1.0 + taxRate)
    }
}

//
//  Currency.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Pricing & Merchandising — Currency  │
//  │  USER STORIES: CA-07, CA-08, SA checkout     │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — sets product base prices and evaluates multi-currency KPI reports
//  • Boutique Manager — views daily store performance in local currency
//  • Sales Associate — handles POS checkout and prints invoices in local currency
//
//  WHAT THIS MODEL DOES:
//  Represents a supported currency within the multinational outlets of Noir Luxe.
//  Provides locale-aware, high-precision currency formatting helpers and simple
//  mock exchange rates to convert prices dynamically.
//

import Foundation

/// Supported transaction and reporting currencies in Noir Luxe boutiques.
enum Currency: String, Codable, CaseIterable, Hashable {
    case inr = "INR"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case aed = "AED"
    case jpy = "JPY"
    case cny = "CNY"
    case aud = "AUD"

    /// Currency symbol for display
    var symbol: String {
        switch self {
        case .inr: return "₹"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .aed: return "AED "
        case .jpy: return "¥"
        case .cny: return "CN¥"
        case .aud: return "A$"
        }
    }

    /// Format double amount to localized currency string with correct separator and symbols
    func format(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = self.rawValue
        formatter.currencySymbol = self.symbol
        formatter.minimumFractionDigits = (self == .jpy) ? 0 : 2
        formatter.maximumFractionDigits = (self == .jpy) ? 0 : 2
        
        switch self {
        case .inr:
            formatter.locale = Locale(identifier: "en_IN") // Lakhs/Crores grouping (e.g. ₹12,00,000.00)
        case .usd:
            formatter.locale = Locale(identifier: "en_US") // Thousands grouping (e.g. $1,200,000.00)
        case .eur:
            formatter.locale = Locale(identifier: "fr_FR") // Space separator, trailing symbol
        case .gbp:
            formatter.locale = Locale(identifier: "en_GB")
        case .aed:
            formatter.locale = Locale(identifier: "ar_AE")
        case .jpy:
            formatter.locale = Locale(identifier: "ja_JP") // No decimals
        case .cny:
            formatter.locale = Locale(identifier: "zh_CN")
        case .aud:
            formatter.locale = Locale(identifier: "en_AU")
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(self.symbol)\(amount)"
    }

    /// Converts an amount in this currency to a target currency using standard corporate mock exchange rates
    func convert(to target: Currency, amount: Double) -> Double {
        // Exchange rates relative to a standard base (1.0 EUR)
        let ratesInEUR: [Currency: Double] = [
            .eur: 1.0,
            .usd: 1.08,    // 1 EUR = 1.08 USD
            .gbp: 0.85,    // 1 EUR = 0.85 GBP
            .inr: 90.0,    // 1 EUR = 90.0 INR
            .aed: 3.97,    // 1 EUR = 3.97 AED
            .jpy: 172.0,   // 1 EUR = 172.0 JPY
            .cny: 7.85,    // 1 EUR = 7.85 CNY
            .aud: 1.62     // 1 EUR = 1.62 AUD
        ]
        
        let sourceRate = ratesInEUR[self] ?? 1.0
        let targetRate = ratesInEUR[target] ?? 1.0
        
        // Amount / sourceRate = value in EUR
        let valueInEUR = amount / sourceRate
        // valueInEUR * targetRate = value in target currency
        return valueInEUR * targetRate
    }
}

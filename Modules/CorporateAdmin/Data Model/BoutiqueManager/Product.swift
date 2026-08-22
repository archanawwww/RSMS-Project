//
//  Product.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Product & Merchandising             │
//  │  USER STORIES: CA-02, SA-04, IC workflows    │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — creates and manages the master product catalog
//  • Sales Associate — searches products, adds to cart, checks availability
//  • Inventory Controller — tracks stock levels per product per store
//
//  WHAT THIS MODEL DOES:
//  The master record for a single SKU (Stock-Keeping Unit).
//  Contains product identity (SKU, barcode), base corporate pricing, categorization,
//  and an active/inactive flag. Exposes functions to calculate store-specific local
//  prices based on multinational currency conversions.
//

import Foundation

// MARK: - Product

struct Product: Identifiable, Codable, Hashable {

    /// The base corporate catalog currency (all products are standard-priced in EUR at HQ)
    static let baseCurrency: Currency = .eur

    let id: UUID
    var sku: String            // e.g. "SKU-8992"
    var name: String           // e.g. "Birkin 35"
    var brand: String          // e.g. "Hermès"
    var category: ProductCategory
    var barcode: String        // EAN-13 or internal barcode
    var basePrice: Double      // in corporate catalog base currency (EUR)
    var isActive: Bool

    // MARK: - Computed Helpers & Localization

    /// Formatted base price in the catalog's base currency (EUR) — e.g. "€12,000.00"
    var formattedPrice: String {
        return Product.baseCurrency.format(basePrice)
    }

    /// Resolves the price of this product converted to a specific store's local currency
    func localizedPrice(for store: Store) -> Double {
        return Product.baseCurrency.convert(to: store.currency, amount: basePrice)
    }

    /// Returns the formatted price in a specific currency
    func formattedPrice(in currency: Currency) -> String {
        let localizedVal = Product.baseCurrency.convert(to: currency, amount: basePrice)
        return currency.format(localizedVal)
    }

    /// Returns the localized, formatted price for a specific store's currency
    func localizedFormattedPrice(for store: Store) -> String {
        let localizedVal = localizedPrice(for: store)
        return store.currency.format(localizedVal)
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        sku: String,
        name: String,
        brand: String,
        category: ProductCategory,
        barcode: String,
        basePrice: Double,
        isActive: Bool = true
    ) {
        self.id = id
        self.sku = sku
        self.name = name
        self.brand = brand
        self.category = category
        self.barcode = barcode
        self.basePrice = basePrice
        self.isActive = isActive
    }
}

// MARK: - ProductCategory

/// Luxury retail product categories.
enum ProductCategory: String, Codable, CaseIterable, Hashable {
    case handbags    = "Handbags"
    case jewelry     = "Jewelry"
    case watches     = "Watches"
    case accessories = "Accessories"
    case readyToWear = "Ready-to-Wear"
    case footwear    = "Footwear"
    case fragrances  = "Fragrances"
    case leather     = "Leather Goods"
    case other       = "Other"
}

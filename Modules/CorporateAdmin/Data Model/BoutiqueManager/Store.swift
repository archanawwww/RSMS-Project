//
//  Store.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Boutique Manager Team                │
//  │  DOMAIN: Core Organization — Store           │
//  │  USER STORIES: All roles                     │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Boutique Manager — this is THEIR store; they own floor ops here
//  • Corporate Admin — oversees all stores, assigns managers
//  • Sales Associate — works within a store
//  • Inventory Controller — manages stock within a store
//
//  WHAT THIS MODEL DOES:
//  Represents a single physical boutique location.
//  Each store has a name, location, region, and references to
//  the staff assigned to it (manager, IC, and sales associates).
//  Exposes local currency and regional tax configurations as mutable, stored
//  properties that can be edited dynamically in the app (e.g. updating local tax rates).
//
//  IMPORTANT:
//  The `managerID` and `inventoryControllerID` are User.id values.
//  The `salesAssociateIDs` array lists all SAs assigned to this store.
//

import Foundation

// MARK: - Store

struct Store: Identifiable, Codable, Hashable {

    let id: UUID
    var name: String                    // e.g. "Mumbai Flagship"
    var location: String                // e.g. "Horniman Circle, Fort"
    var region: StoreRegion             // Multinational region
    var managerID: UUID?                // User.id of the Boutique Manager
    var inventoryControllerID: UUID?    // User.id of the Inventory Controller
    var salesAssociateIDs: [UUID]       // User.ids of all Sales Associates

    // MARK: - Stored Configurable Fields

    /// The local operational currency for this boutique (editable dynamically)
    var currency: Currency

    /// The local taxation rules governing this store location (editable dynamically)
    var taxConfig: RegionalTaxConfig

    // MARK: - Local Mappings

    /// The local privacy regulation framework governing this store
    var privacyRegulation: String {
        region.privacyRegulation
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        name: String,
        location: String,
        region: StoreRegion,
        managerID: UUID? = nil,
        inventoryControllerID: UUID? = nil,
        salesAssociateIDs: [UUID] = [],
        currency: Currency? = nil,
        taxConfig: RegionalTaxConfig? = nil
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.region = region
        self.managerID = managerID
        self.inventoryControllerID = inventoryControllerID
        self.salesAssociateIDs = salesAssociateIDs
        self.currency = currency ?? region.defaultCurrency
        self.taxConfig = taxConfig ?? region.defaultTaxConfig
    }
}

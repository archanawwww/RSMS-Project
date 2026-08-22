//
//  CustomerPreference.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Sales Associate Team                 │
//  │  DOMAIN: Customer & Sales — Clienteling      │
//  │  USER STORIES: Clienteling, AI Recommendations│
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Sales Associate — records customer preferences during conversations
//
//  WHAT THIS MODEL DOES:
//  Stores a customer's style preferences: brands they like, materials
//  they prefer, their sizes, and any freeform notes. This data powers
//  personalized product recommendations during assisted selling.
//
//  EXAMPLE:
//  ┌────────────────────┬──────────────────────────────┐
//  │ preferredBrands    │ ["Hermès", "Cartier"]        │
//  │ preferredMaterials │ ["Leather", "Rose Gold"]     │
//  │ sizes              │ ["Medium", "35cm"]           │
//  │ notes              │ "Prefers muted tones"        │
//  └────────────────────┴──────────────────────────────┘
//
//  NOTE: This is embedded inside a Customer, not a separate collection.
//  A Customer has ONE CustomerPreference (1:1 relationship).
//

import Foundation

// MARK: - CustomerPreference

struct CustomerPreference: Codable, Hashable {

    var preferredBrands: [String]       // e.g. ["Hermès", "Cartier"]
    var preferredMaterials: [String]    // e.g. ["Leather", "Rose Gold"]
    var sizes: [String]                 // e.g. ["Medium", "35cm"]
    var notes: String?                  // freeform SA notes

    init(
        preferredBrands: [String] = [],
        preferredMaterials: [String] = [],
        sizes: [String] = [],
        notes: String? = nil
    ) {
        self.preferredBrands = preferredBrands
        self.preferredMaterials = preferredMaterials
        self.sizes = sizes
        self.notes = notes
    }
}

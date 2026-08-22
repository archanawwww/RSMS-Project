//
//  Customer.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Sales Associate Team                 │
//  │  DOMAIN: Customer & Sales — Clienteling      │
//  │  USER STORIES: SA-01, SA-02, SA-07           │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Sales Associate — creates and manages customer profiles
//  • Corporate Admin — views aggregate customer data in reports
//
//  WHAT THIS MODEL DOES:
//  A customer (client) profile. Sales Associates create these during
//  clienteling — when a customer walks in, the SA looks up or creates
//  their profile to track preferences, VIP status, and purchase history.
//
//  VIP TIERS (Luxury Focused):
//  ┌───────────┬───────────────────────────────────────────┐
//  │ gold      │ Premium clients                           │
//  │ platinum  │ Ultra high-tier loyalty members           │
//  │ diamond   │ Elite VVIP clients - private viewings     │
//  └───────────┴───────────────────────────────────────────┘
//
//  consentGranted: Whether the customer has opted in for marketing
//  communications (emails, SMS). Required for GDPR/data compliance.
//

import Foundation

// MARK: - Customer

struct Customer: Identifiable, Codable, Hashable {

    let id: UUID
    var name: String           // e.g. "Aisha Nair"
    var email: String?         // optional — not all customers share email
    var phone: String          // primary contact, e.g. "+91-9900112233"
    var vipTier: VIPTier
    var consentGranted: Bool   // marketing opt-in

    init(
        id: UUID = UUID(),
        name: String,
        email: String? = nil,
        phone: String,
        vipTier: VIPTier = .gold,
        consentGranted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.vipTier = vipTier
        self.consentGranted = consentGranted
    }
}

// MARK: - VIPTier

/// Exclusively high-end loyalty tiers for luxury customer profiles.
enum VIPTier: String, Codable, CaseIterable, Hashable {
    case gold     = "Gold"
    case platinum = "Platinum"
    case diamond  = "Diamond"
}

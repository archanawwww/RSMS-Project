//
//  Promotion.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Product & Merchandising — Campaigns │
//  │  USER STORIES: CA-03, SA checkout            │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — creates, schedules, and manages promotions
//  • Sales Associate — applies active promotions during checkout
//
//  WHAT THIS MODEL DOES:
//  A time-bound promotional campaign. Corporate Admin sets the dates,
//  discount type (percentage or flat amount), and discount value.
//  Provides currency grounding for flat discounts to support multinational outlets.
//
//  EXAMPLE:
//  "Diwali Luxury Celebration" — 10% off accessories, Oct 15–Nov 15
//

import Foundation

// MARK: - Promotion

struct Promotion: Identifiable, Codable, Hashable {

    let id: UUID
    var title: String          // e.g. "Diwali Luxury Celebration"
    var description: String    // what's included
    var startDate: Date
    var endDate: Date
    var discountType: DiscountType
    var discountValue: Double  // 10 means 10% or flat currency units
    var currency: Currency?    // Specific currency for flat amounts (nil defaults to store currency)
    var status: PromotionStatus

    // MARK: Computed Helpers

    /// Is this promotion active right now?
    var isCurrentlyActive: Bool {
        let now = Date()
        return status == .active && now >= startDate && now <= endDate
    }

    /// Calculates the flat discount amount converted to a specific target currency
    func flatDiscountAmount(convertedTo target: Currency) -> Double {
        guard discountType == .flatAmount else { return 0 }
        let promoCurrency = currency ?? target
        return promoCurrency.convert(to: target, amount: discountValue)
    }

    // MARK: Init

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        discountType: DiscountType,
        discountValue: Double,
        currency: Currency? = nil,
        status: PromotionStatus = .draft
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.discountType = discountType
        self.discountValue = discountValue
        self.currency = currency
        self.status = status
    }
}

// MARK: - DiscountType

enum DiscountType: String, Codable, CaseIterable, Hashable {
    case percentage = "Percentage"   // e.g. 10 → 10% off
    case flatAmount = "Flat Amount"  // e.g. 20000 → flat currency discount
}

// MARK: - PromotionStatus

enum PromotionStatus: String, Codable, CaseIterable, Hashable {
    case draft   = "Draft"    // being prepared
    case active  = "Active"   // live and applicable
    case paused  = "Paused"   // temporarily halted
    case expired = "Expired"  // past end date
}

//
//  KPIReport.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Governance — Executive Dashboard    │
//  │  USER STORIES: CA-08                         │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — views KPIs on the executive dashboard
//
//  WHAT THIS MODEL DOES:
//  An aggregated snapshot of organizational health. Grounded in a consolidated corporate
//  reporting currency to standardize multinational boutique sales numbers.
//
//  ┌──────────────────────────┬──────────────────────┐
//  │ totalSales               │ Consolidated Revenue │
//  │ inventoryHealth          │ "98.5%"              │
//  │ complianceScore          │ "98%"                │
//  │ campaignPerformance      │ "72%"                │
//  └──────────────────────────┴──────────────────────┘
//

import Foundation

// MARK: - KPIReport

struct KPIReport: Codable, Hashable {

    var reportingCurrency: Currency    // Consolidated reporting currency (e.g. EUR)
    var totalSales: Double             // Consolidated sales volume in reportingCurrency
    var inventoryHealth: Double        // 0.0 – 1.0 (percentage as decimal)
    var complianceScore: Double        // 0.0 – 1.0
    var campaignPerformance: Double    // 0.0 – 1.0

    // MARK: Display Helpers

    /// Consolidated total sales formatted in reporting currency
    var formattedTotalSales: String {
        reportingCurrency.format(totalSales)
    }

    /// e.g. "98%"
    var compliancePercentage: String {
        "\(Int(complianceScore * 100))%"
    }

    /// e.g. "98%"
    var inventoryHealthPercentage: String {
        "\(Int(inventoryHealth * 100))%"
    }

    // MARK: Init

    init(
        reportingCurrency: Currency = .eur,
        totalSales: Double = 0,
        inventoryHealth: Double = 0,
        complianceScore: Double = 0,
        campaignPerformance: Double = 0
    ) {
        self.reportingCurrency = reportingCurrency
        self.totalSales = totalSales
        self.inventoryHealth = inventoryHealth
        self.complianceScore = complianceScore
        self.campaignPerformance = campaignPerformance
    }
}

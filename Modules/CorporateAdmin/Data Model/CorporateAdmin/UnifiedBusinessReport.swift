//
//  UnifiedBusinessReport.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Corporate Admin Team                 │
//  │  DOMAIN: Governance — Corporate Reporting    │
//  │  USER STORIES: CA-07                         │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Corporate Admin — generates and exports comprehensive business reports
//
//  WHAT THIS MODEL DOES:
//  A date-stamped comprehensive report that pulls together metrics from
//  FOUR sub-domains: Sales, Inventory, Compliance, and Campaigns.
//  Expresses financial metrics in a unified reporting base currency for corporate-wide audits.
//
//  STRUCTURE:
//  UnifiedBusinessReport
//  ├── reportDate
//  ├── salesMetrics        → revenue, transactions, avg value, top category (in base currency)
//  ├── inventoryMetrics    → SKU count, stock health, transfers, variances
//  ├── complianceMetrics   → submitted, approved, rejected, overall score
//  └── campaignMetrics     → active campaigns, reach, conversion, revenue (in base currency)
//

import Foundation

// MARK: - UnifiedBusinessReport

struct UnifiedBusinessReport: Identifiable, Codable, Hashable {

    var id: String { reportDate.ISO8601Format() }

    var reportDate: Date
    var salesMetrics: SalesMetrics
    var inventoryMetrics: InventoryMetrics
    var complianceMetrics: ComplianceMetrics
    var campaignMetrics: CampaignMetrics

    init(
        reportDate: Date = Date(),
        salesMetrics: SalesMetrics = SalesMetrics(),
        inventoryMetrics: InventoryMetrics = InventoryMetrics(),
        complianceMetrics: ComplianceMetrics = ComplianceMetrics(),
        campaignMetrics: CampaignMetrics = CampaignMetrics()
    ) {
        self.reportDate = reportDate
        self.salesMetrics = salesMetrics
        self.inventoryMetrics = inventoryMetrics
        self.complianceMetrics = complianceMetrics
        self.campaignMetrics = campaignMetrics
    }
}

// MARK: - SalesMetrics

struct SalesMetrics: Codable, Hashable {
    var reportingCurrency: Currency      // Unified base reporting currency
    var totalRevenue: Double             // total revenue converted to reporting currency
    var transactionCount: Int            // number of sales
    var averageTransactionValue: Double   // totalRevenue / transactionCount
    var topSellingCategory: String        // e.g. "Handbags"

    init(
        reportingCurrency: Currency = .eur,
        totalRevenue: Double = 0,
        transactionCount: Int = 0,
        averageTransactionValue: Double = 0,
        topSellingCategory: String = ""
    ) {
        self.reportingCurrency = reportingCurrency
        self.totalRevenue = totalRevenue
        self.transactionCount = transactionCount
        self.averageTransactionValue = averageTransactionValue
        self.topSellingCategory = topSellingCategory
    }
}

// MARK: - InventoryMetrics

struct InventoryMetrics: Codable, Hashable {
    var totalSKUs: Int                    // how many products are tracked
    var stockHealthPercentage: Double     // 0.0 – 1.0
    var pendingTransfers: Int             // transfers not yet delivered
    var openVariances: Int                // unresolved stock discrepancies

    init(
        totalSKUs: Int = 0,
        stockHealthPercentage: Double = 0,
        pendingTransfers: Int = 0,
        openVariances: Int = 0
    ) {
        self.totalSKUs = totalSKUs
        self.stockHealthPercentage = stockHealthPercentage
        self.pendingTransfers = pendingTransfers
        self.openVariances = openVariances
    }
}

// MARK: - ComplianceMetrics

struct ComplianceMetrics: Codable, Hashable {
    var totalReportsSubmitted: Int
    var approvedCount: Int
    var rejectedCount: Int
    var overallScore: Double              // 0.0 – 1.0

    init(
        totalReportsSubmitted: Int = 0,
        approvedCount: Int = 0,
        rejectedCount: Int = 0,
        overallScore: Double = 0
    ) {
        self.totalReportsSubmitted = totalReportsSubmitted
        self.approvedCount = approvedCount
        self.rejectedCount = rejectedCount
        self.overallScore = overallScore
    }
}

// MARK: - CampaignMetrics

struct CampaignMetrics: Codable, Hashable {
    var activeCampaigns: Int
    var totalReach: Int                   // number of customers reached
    var conversionRate: Double            // 0.0 – 1.0
    var reportingCurrency: Currency      // Unified base reporting currency
    var revenueFromPromotions: Double     // revenue from promos converted to reporting currency

    init(
        activeCampaigns: Int = 0,
        totalReach: Int = 0,
        conversionRate: Double = 0,
        reportingCurrency: Currency = .eur,
        revenueFromPromotions: Double = 0
    ) {
        self.activeCampaigns = activeCampaigns
        self.totalReach = totalReach
        self.conversionRate = conversionRate
        self.reportingCurrency = reportingCurrency
        self.revenueFromPromotions = revenueFromPromotions
    }
}

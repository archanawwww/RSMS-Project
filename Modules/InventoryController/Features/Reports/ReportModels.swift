import SwiftUI
import Combine

// MARK: - Report Type

enum ReportType: String, CaseIterable, Identifiable {
    case inventoryVariance   = "Inventory Variance"
    case shipmentVariance    = "Shipment Variance"
    case inventoryAdjustment = "Inventory Adjustment"
    case cycleCountCompleted = "Cycle Count Completed"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .inventoryVariance:   return "exclamationmark.triangle"
        case .shipmentVariance:    return "shippingbox"
        case .inventoryAdjustment: return "arrow.left.arrow.right"
        case .cycleCountCompleted: return "checkmark.circle"
        }
    }

    /// Only variance records use the warning orange.
    /// Everything else is neutral — matching the app's single-accent palette.
    var iconColor: Color {
        switch self {
        case .inventoryVariance:  return Color(UIColor.systemOrange)
        case .shipmentVariance:   return Color(UIColor.systemOrange)
        default:                  return Color(UIColor.secondaryLabel)
        }
    }

    var isVariance: Bool {
        self == .inventoryVariance || self == .shipmentVariance
    }
}

// MARK: - Report Status

enum ReportStatus: String, CaseIterable, Identifiable {
    case synced      = "Synced"
    case pendingSync = "Pending Sync"
    case syncFailed  = "Sync Failed"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .synced:      return Color(UIColor.systemGreen)
        case .pendingSync: return Color(UIColor.systemOrange)
        case .syncFailed:  return Color(UIColor.systemRed)
        }
    }
}

// MARK: - Filter Enums

enum ReportDateRange: String, CaseIterable, Identifiable {
    case allTime    = "All Time"
    case today      = "Today"
    case last7Days  = "Last 7 Days"
    case last30Days = "Last 30 Days"

    var id: String { rawValue }
}

enum ReportSortOrder: String, CaseIterable, Identifiable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"

    var id: String { rawValue }
}

// MARK: - Filter State

struct ReportFilter {
    var type:      ReportType?     = nil
    var status:    ReportStatus?   = nil
    var dateRange: ReportDateRange = .allTime
    var sortOrder: ReportSortOrder = .newestFirst

    var isActive: Bool { type != nil || status != nil || dateRange != .allTime }
}

// MARK: - Report Record

struct ReportRecord: Identifiable {
    let id:              String
    let type:            ReportType
    let status:          ReportStatus
    let entityName:      String
    let entityId:        String?
    let summary:         String
    let difference:      Int?
    let timestamp:       Date
    // Detail fields
    let sku:             String?
    let category:        String?
    let location:        String?
    let cycleCountName:  String?
    /// Session reference — used to navigate back to the source cycle count.
    let sourceSession:   CycleCountSession?
    let expectedQty:     Int?
    let countedQty:      Int?
    let reason:          String?
    let notes:           String?
    let reportedBy:      String?
}

// MARK: - Date Group

struct ReportDateGroup: Identifiable {
    let id:      String
    let title:   String
    let records: [ReportRecord]
}

// Report synchronization UI removed — status pill intentionally not exposed.

// MARK: - Reports Store (observable singleton)
// Receives records from CycleCountExecutionView on completion.
// ReportsView reads from here instead of static mock data.

final class ReportsStore: ObservableObject {
    static let shared = ReportsStore()

    @Published var records: [ReportRecord] = ReportRecord.seedData

    private init() {}

    /// Called by CycleCountExecutionView after the user completes a cycle count.
    func addRecords(from adjustments: [InventoryAdjustmentRecord],
                   session: CycleCountSession) {
        let newRecords: [ReportRecord] = adjustments.map { adj in
            let diff = adj.counted - adj.expected
            let isVariance = diff != 0
            return ReportRecord(
                id:             "IV-\(Int(adj.timestamp.timeIntervalSince1970))-\(adj.sku)",
                type:           isVariance ? .inventoryVariance : .inventoryAdjustment,
                status:         .pendingSync,
                entityName:     adj.productName,
                entityId:       adj.sku,
                summary:        isVariance
                                    ? "\(adj.reason) • \(diff < 0 ? "−\(abs(diff))" : "+\(diff)") Units"
                                    : "\(adj.reason)",
                difference:     diff,
                timestamp:      adj.timestamp,
                sku:            adj.sku,
                category:       nil,
                location:       nil,
                cycleCountName: adj.sessionName,
                sourceSession:  session,
                expectedQty:    adj.expected,
                countedQty:     adj.counted,
                reason:         adj.reason,
                notes:          adj.notes,
                reportedBy:     "Inventory Controller"
            )
        }

        // Also add a "Cycle Count Completed" summary record
        let summaryRecord = ReportRecord(
            id:             "CC-\(Int(Date().timeIntervalSince1970))-\(session.id)",
            type:           .cycleCountCompleted,
            status:         .pendingSync,
            entityName:     session.title,
            entityId:       nil,
            summary:        adjustments.isEmpty ? "0 Variances" : "\(adjustments.count) Variance\(adjustments.count == 1 ? "" : "s")",
            difference:     adjustments.count,
            timestamp:      Date(),
            sku:            nil,
            category:       nil,
            location:       nil,
            cycleCountName: session.title,
            sourceSession:  session,
            expectedQty:    session.total,
            countedQty:     session.counted,
            reason:         nil,
            notes:          nil,
            reportedBy:     "Inventory Controller"
        )

        withAnimation(.easeOut(duration: 0.3)) {
            records.insert(contentsOf: [summaryRecord] + newRecords, at: 0)
        }

        // No automatic UI-exposed sync state — do not mutate record status here.
    }
}

// MARK: - Seed / Mock Data

extension ReportRecord {
    static var seedData: [ReportRecord] {
        let cal = Calendar.current
        let now = Date()

        func at(_ daysAgo: Int, h: Int, m: Int) -> Date {
            let base = cal.date(byAdding: .day, value: -daysAgo, to: now)!
            return cal.date(bySettingHour: h, minute: m, second: 0, of: base)!
        }

        let luxurySession = CycleCountSession(
            title: "Luxury Watches", dateLabel: "Today",
            status: .completed, counted: 60, total: 60, variance: 2
        )

        return [
            ReportRecord(
                id: "IV-2026-0702-0017",
                type: .inventoryVariance, status: .synced,
                entityName: "Rolex Daytona", entityId: "RX-116503",
                summary: "Shrinkage • −2 Units", difference: -2,
                timestamp: at(0, h: 16, m: 15),
                sku: "RX-116503", category: "Luxury Watches",
                location: "Luxury Vault A", cycleCountName: "Luxury Watches",
                sourceSession: luxurySession,
                expectedQty: 8, countedQty: 6, reason: "Shrinkage",
                notes: "Two watches could not be located during verification of watch drawer #3.",
                reportedBy: "Inventory Controller"
            ),
            ReportRecord(
                id: "SV-2026-0702-0004",
                type: .shipmentVariance, status: .synced,
                entityName: "Rolex Shipment", entityId: "ASN-241",
                summary: "Shortage • −3 Units", difference: -3,
                timestamp: at(0, h: 11, m: 42),
                sku: nil, category: nil, location: nil,
                cycleCountName: nil, sourceSession: nil,
                expectedQty: 12, countedQty: 9, reason: "Shortage",
                notes: nil, reportedBy: "Inventory Controller"
            ),
            ReportRecord(
                id: "IA-2026-0701-0009",
                type: .inventoryAdjustment, status: .synced,
                entityName: "Rolex GMT-Master II", entityId: "RX-126710",
                summary: "+2 Units", difference: 2,
                timestamp: at(1, h: 15, m: 20),
                sku: "RX-126710", category: "Luxury Watches",
                location: "Luxury Vault A", cycleCountName: "Luxury Watches",
                sourceSession: luxurySession,
                expectedQty: 3, countedQty: 5, reason: "Receiving not recorded",
                notes: nil, reportedBy: "Inventory Controller"
            ),
            ReportRecord(
                id: "IV-2026-0701-0011",
                type: .inventoryVariance, status: .synced,
                entityName: "Cartier Tank", entityId: "CT-W5200005",
                summary: "Damaged • −1 Unit", difference: -1,
                timestamp: at(1, h: 8, m: 18),
                sku: "CT-W5200005", category: "Luxury Watches",
                location: "Display Cabinet A", cycleCountName: "Luxury Watches",
                sourceSession: luxurySession,
                expectedQty: 5, countedQty: 4, reason: "Damaged",
                notes: nil, reportedBy: "Inventory Controller"
            ),
            ReportRecord(
                id: "CC-2026-0630-0002",
                type: .cycleCountCompleted, status: .synced,
                entityName: "Luxury Watches", entityId: nil,
                summary: "0 Variances", difference: 0,
                timestamp: at(3, h: 18, m: 5),
                sku: nil, category: nil, location: nil,
                cycleCountName: "Luxury Watches",
                sourceSession: luxurySession,
                expectedQty: 60, countedQty: 60, reason: nil,
                notes: nil, reportedBy: "Inventory Controller"
            ),
        ]
    }
}

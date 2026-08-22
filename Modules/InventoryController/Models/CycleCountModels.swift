import Foundation

enum CycleCountStatus: Hashable {
    case pending, inProgress, completed
}

struct CycleCountSession: Identifiable, Hashable {
    let id: UUID
    let title: String
    let dateLabel: String
    var status: CycleCountStatus

    // ── Scheduled fields ──────────────────────────────────────────────────
    var location: String?
    var totalSKUs: Int = 0
    var expectedUnits: Int = 0
    var productIDs: [String] = []

    // ── In-progress fields ────────────────────────────────────────────────
    var counted: Int = 0
    var total: Int = 0

    // ── Completed fields ──────────────────────────────────────────────────
    var variance: Int = 0
    var completedDate: String?
    var isResolved: Bool = false
    var inventoryUpdated: Bool = false
    var reportStatus: String = "Synced"
    var completedResults: [CycleCountResult] = []
    var isOnHold: Bool = false

    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(counted) / Double(total)
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        dateLabel: String,
        status: CycleCountStatus,
        location: String? = nil,
        totalSKUs: Int = 0,
        expectedUnits: Int = 0,
        productIDs: [String] = [],
        counted: Int = 0,
        total: Int = 0,
        variance: Int = 0,
        completedDate: String? = nil,
        isResolved: Bool = false,
        inventoryUpdated: Bool = false,
        reportStatus: String = "Synced",
        completedResults: [CycleCountResult] = [],
        isOnHold: Bool = false
    ) {
        self.id = id
        self.title = title
        self.dateLabel = dateLabel
        self.status = status
        self.location = location
        self.totalSKUs = totalSKUs
        self.expectedUnits = expectedUnits
        self.productIDs = productIDs
        self.counted = counted
        self.total = total
        self.variance = variance
        self.completedDate = completedDate
        self.isResolved = isResolved
        self.inventoryUpdated = inventoryUpdated
        self.reportStatus = reportStatus
        self.completedResults = completedResults
        self.isOnHold = isOnHold
    }
}

enum CycleCountItemState: Codable, Hashable {
    case notCounted(expected: Int)
    case matched(expected: Int, counted: Int)
    case variance(expected: Int, counted: Int)

    var isNotCounted: Bool { if case .notCounted = self { return true }; return false }
    var isMatched:    Bool { if case .matched    = self { return true }; return false }
    var isVariance:   Bool { if case .variance   = self { return true }; return false }
}

struct CycleCountItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let sku: String
    let imageUrl: String?
    let category: String?
    let basePrice: Double?
    var state: CycleCountItemState
    
    init(
        id: UUID = UUID(),
        name: String,
        sku: String,
        imageUrl: String? = nil,
        category: String? = nil,
        basePrice: Double? = nil,
        state: CycleCountItemState
    ) {
        self.id = id
        self.name = name
        self.sku = sku
        self.imageUrl = imageUrl
        self.category = category
        self.basePrice = basePrice
        self.state = state
    }
    
    var expectedQuantity: Int {
        switch state {
        case .notCounted(let expected): return expected
        case .matched(let expected, _): return expected
        case .variance(let expected, _): return expected
        }
    }
    
    var countedQuantity: Int {
        switch state {
        case .notCounted: return 0
        case .matched(_, let counted): return counted
        case .variance(_, let counted): return counted
        }
    }
}

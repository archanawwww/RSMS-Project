import SwiftUI
import Combine

struct CycleCountResult: Identifiable, Hashable {
    let id = UUID()
    let productName: String
    let sku: String
    let expected: Int
    let counted: Int
    let variance: Int
    let reason: String?
    let notes: String?
}

enum CycleCountCompletionError: LocalizedError {
    case sessionNotFound
    case incompleteCount
    case unreviewedVariances(expected: Int, received: Int)

    var errorDescription: String? {
        switch self {
        case .sessionNotFound:
            return "The selected cycle count could not be found."
        case .incompleteCount:
            return "All products must be counted before completing the cycle count."
        case .unreviewedVariances:
            return "Every variance must be reviewed before completion."
        }
    }
}

@MainActor
final class CycleCountStore: ObservableObject {
    static let shared = CycleCountStore()

    @Published var todaySessions: [CycleCountSession]
    @Published var upcomingSessions: [CycleCountSession]
    @Published var completedSessions: [CycleCountSession]
    @Published var inProgressItemStates: [UUID: [String: CycleCountItemState]]
    @Published var loadError: String?

    var sessions: [CycleCountSession] {
        todaySessions + upcomingSessions + completedSessions
    }

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    private let repository = CycleCountRepository()
    private let productRepository = ProductRepository()

    private var itemStatesFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("cycleCountItemStates.json")
    }

    private init() {
        todaySessions = []
        upcomingSessions = []
        completedSessions = []
        inProgressItemStates = [:]
        loadError = nil
        loadPersistedItemStates()
    }

    private func persistItemStates() {
        guard let data = try? JSONEncoder().encode(inProgressItemStates) else { return }
        try? data.write(to: itemStatesFileURL, options: .atomic)
    }

    private func loadPersistedItemStates() {
        guard let data = try? Data(contentsOf: itemStatesFileURL) else { return }
        inProgressItemStates = (try? JSONDecoder().decode([UUID: [String: CycleCountItemState]].self, from: data)) ?? [:]
    }

    func saveItemState(sessionID: UUID, sku: String, state: CycleCountItemState) {
        var states = inProgressItemStates[sessionID] ?? [:]
        states[sku] = state
        inProgressItemStates[sessionID] = states
        persistItemStates()
    }

    func savedStates(for sessionID: UUID) -> [String: CycleCountItemState] {
        inProgressItemStates[sessionID] ?? [:]
    }

    func clearItemStates(for sessionID: UUID) {
        inProgressItemStates.removeValue(forKey: sessionID)
        persistItemStates()
    }

    func loadFromSupabase() async {
        do {
            let counts = try await repository.fetchCycleCounts()
            let allProducts: [Product]?
            do {
                allProducts = try await productRepository.fetchProducts()
            } catch {
                print("[CycleCountStore] Failed to fetch products for SKU mapping: \(error)")
                allProducts = nil
            }
            let skuToProductID = allProducts.map { products in
                Dictionary(uniqueKeysWithValues: products.map { ($0.sku, $0.id.uuidString) })
            } ?? [:]

            var remoteToday: [CycleCountSession] = []
            var remoteUpcoming: [CycleCountSession] = []
            var remoteCompleted: [CycleCountSession] = []

            var localByID: [UUID: (section: Int, index: Int)] = [:]
            for s in todaySessions.enumerated() { localByID[s.element.id] = (0, s.offset) }
            for s in upcomingSessions.enumerated() { localByID[s.element.id] = (1, s.offset) }
            for s in completedSessions.enumerated() { localByID[s.element.id] = (2, s.offset) }

            var updatedToday = todaySessions
            var updatedUpcoming = upcomingSessions
            var updatedCompleted = completedSessions

            for count in counts {
                guard let remoteId = UUID(uuidString: count.cycle_count_id) else { continue }

                let newStatus: CycleCountStatus
                switch count.status?.lowercased() {
                case "inprogress", "in_progress":
                    newStatus = .inProgress
                case "completed":
                    newStatus = .completed
                default:
                    newStatus = .pending
                }

                if let local = localByID[remoteId] {
                    let localSession: CycleCountSession
                    switch local.section {
                    case 0: localSession = todaySessions[local.index]
                    case 1: localSession = upcomingSessions[local.index]
                    default: localSession = completedSessions[local.index]
                    }

                    if localSession.status != newStatus {
                        var updated = localSession
                        updated.status = newStatus
                        if newStatus == .completed {
                            updated.completedDate = count.completed_date
                            updated.reportStatus = "Synced"
                        }

                        switch local.section {
                        case 0: updatedToday.removeAll { $0.id == remoteId }
                        case 1: updatedUpcoming.removeAll { $0.id == remoteId }
                        case 2: updatedCompleted.removeAll { $0.id == remoteId }
                        default: break
                        }
                        switch newStatus {
                        case .pending:    updatedUpcoming.append(updated)
                        case .inProgress: updatedToday.append(updated)
                        case .completed:  updatedCompleted.append(updated)
                        }
                    }
                    continue
                }

                var productIDs: [String] = []
                var totalSKUs = 0
                var completedResults: [CycleCountResult] = []

                do {
                    let lines = try await repository.fetchLines(for: count.cycle_count_id)
                    totalSKUs = lines.count

                    if newStatus != .completed {
                        productIDs = lines.compactMap { skuToProductID[$0.sku] }
                    }

                    if newStatus == .completed {
                        let skuToName = allProducts.map { products in
                            Dictionary(uniqueKeysWithValues: products.map { ($0.sku, $0.name) })
                        } ?? [:]
                        completedResults = lines.map { line in
                            let expected = Int(line.system_qty ?? 0)
                            let counted = Int(line.counted_qty ?? 0)
                            return CycleCountResult(
                                productName: skuToName[line.sku] ?? line.sku,
                                sku: line.sku,
                                expected: expected,
                                counted: counted,
                                variance: counted - expected,
                                reason: line.reason_code,
                                notes: nil
                            )
                        }
                    }
                } catch {
                    print("[CycleCountStore] Failed to fetch lines for count \(count.cycle_count_id): \(error)")
                }

                let dateLabel = Self.formatDateOnly(count.scheduled_date) ?? "Unscheduled"

                var session = CycleCountSession(
                    id: remoteId,
                    title: count.count_type ?? "Cycle Count",
                    dateLabel: dateLabel,
                    status: newStatus,
                    location: count.warehouse_id,
                    totalSKUs: totalSKUs,
                    expectedUnits: 0,
                    productIDs: productIDs
                )

                if newStatus == .completed {
                    session.completedDate = count.completed_date
                    session.reportStatus = "Synced"
                    session.completedResults = completedResults
                    session.variance = completedResults.filter { $0.variance != 0 }.count
                    session.counted = totalSKUs
                    session.total = totalSKUs
                }

                switch newStatus {
                case .pending: remoteUpcoming.append(session)
                case .inProgress: remoteToday.append(session)
                case .completed: remoteCompleted.append(session)
                }
            }

            todaySessions = updatedToday + remoteToday
            upcomingSessions = updatedUpcoming + remoteUpcoming
            completedSessions = updatedCompleted + remoteCompleted
            loadError = nil
        } catch {
            print("[CycleCountStore] Failed to load cycle counts: \(error)")
            loadError = error.localizedDescription
        }
    }

    func createCycleCountInDB(title: String, scheduledDate: Date, warehouseId: String?, productIDs: [String]) async throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let params = CreateCycleCountParams(
            warehouse_id: warehouseId,
            count_type: title,
            status: "pending",
            scheduled_date: formatter.string(from: scheduledDate)
        )

        let created = try await repository.createCycleCount(params)
        let countId = created.cycle_count_id

        let allProducts = try await productRepository.fetchProducts()
        let selectedProducts = productIDs.isEmpty ? allProducts : allProducts.filter { productIDs.contains($0.id.uuidString) }

        for product in selectedProducts {
            let lineParams = CreateCycleCountLineParams(
                count_id: countId,
                sku: product.sku,
                system_qty: Double(max(product.currentStock ?? 0, 0)),
                counted_qty: 0,
                status: "Pending"
            )
            do {
                _ = try await repository.createCycleCountLine(lineParams)
            } catch {
                print("[CycleCountStore] Failed to insert line for SKU \(product.sku): \(error)")
            }
        }

        let id = UUID(uuidString: countId) ?? UUID()
        let dateLabel = Self.formatDateOnly(created.scheduled_date) ?? "Unscheduled"
        let sessionProductIDs = productIDs.isEmpty ? selectedProducts.map { $0.id.uuidString } : productIDs

        let session = CycleCountSession(
            id: id,
            title: created.count_type ?? title,
            dateLabel: dateLabel,
            status: .pending,
            location: created.warehouse_id,
            totalSKUs: selectedProducts.count,
            productIDs: sessionProductIDs
        )

        upcomingSessions.append(session)
    }

    func startSession(_ session: CycleCountSession) async {
        do {
            try await repository.updateCycleCountStatus(id: session.id.uuidString.lowercased(), status: "in_progress")
        } catch {
            print("[CycleCountStore] Failed to persist in_progress status: \(error)")
        }
        upcomingSessions.removeAll { $0.id == session.id }
        var inProgress = session
        inProgress.status = .inProgress
        inProgress.counted = 0
        inProgress.total = max(session.productIDs.count, session.totalSKUs, 1)
        todaySessions.append(inProgress)
    }

    func toggleHold(for id: UUID) {
        if let idx = todaySessions.firstIndex(where: { $0.id == id }) {
            todaySessions[idx].isOnHold.toggle()
        } else if let idx = upcomingSessions.firstIndex(where: { $0.id == id }) {
            upcomingSessions[idx].isOnHold.toggle()
        } else if let idx = completedSessions.firstIndex(where: { $0.id == id }) {
            completedSessions[idx].isOnHold.toggle()
        }
    }

    func deleteSessionFromDB(id: UUID) async {
        let idStr = id.uuidString.lowercased()
        do {
            try await repository.deleteCycleCount(id: idStr)
        } catch {
            print("[CycleCountStore] Failed to delete cycle count \(idStr): \(error)")
        }
        todaySessions.removeAll { $0.id == id }
        upcomingSessions.removeAll { $0.id == id }
        completedSessions.removeAll { $0.id == id }
        clearItemStates(for: id)
    }

    private static func formatDateOnly(_ isoString: String?) -> String? {
        guard let isoString else { return nil }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = parser.date(from: isoString) else { return nil }
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        return df.string(from: date)
    }

    var activeSessionCount: Int {
        todaySessions.filter { $0.status != .completed }.count +
        upcomingSessions.filter { $0.status != .completed }.count
    }

    func session(with id: UUID) -> CycleCountSession? {
        todaySessions.first(where: { $0.id == id }) ??
        upcomingSessions.first(where: { $0.id == id }) ??
        completedSessions.first(where: { $0.id == id })
    }

    func updateSessionProgress(id: UUID, counted: Int, total: Int, variances: Int = 0) {
        if let idx = todaySessions.firstIndex(where: { $0.id == id }) {
            var session = todaySessions[idx]
            session.counted = counted
            session.total = total
            session.variance = variances
            todaySessions[idx] = session
        }
    }

    func completeCycleCount(
        session: CycleCountSession,
        items: [CycleCountItem],
        adjustmentRecords: [InventoryAdjustmentRecord]
    ) async throws {
        guard let persistedSession = self.session(with: session.id) else {
            throw CycleCountCompletionError.sessionNotFound
        }

        guard !items.contains(where: { $0.state.isNotCounted }) else {
            throw CycleCountCompletionError.incompleteCount
        }

        let varianceItems = items.filter { $0.state.isVariance }
        guard varianceItems.count == adjustmentRecords.count else {
            throw CycleCountCompletionError.unreviewedVariances(
                expected: varianceItems.count,
                received: adjustmentRecords.count
            )
        }

        let reviewedSKUs = Set(adjustmentRecords.map(\.sku))
        guard Set(varianceItems.map(\.sku)) == reviewedSKUs else {
            throw CycleCountCompletionError.unreviewedVariances(
                expected: varianceItems.count,
                received: adjustmentRecords.count
            )
        }

        let completionDate = Date()
        let completionLabel = formatter.string(from: completionDate)

        // ── Write to Supabase FIRST (lines before status) ────────────────────
        let countId = session.id.uuidString.lowercased()

        let existingLines = try await repository.fetchLines(for: countId)
        let lineBySKU = Dictionary(uniqueKeysWithValues: existingLines.map { ($0.sku, $0) })
        let adjBySKU = Dictionary(uniqueKeysWithValues: adjustmentRecords.map { ($0.sku, $0) })

        for item in items {
            guard let line = lineBySKU[item.sku] else { continue }
            let expected: Double
            let counted: Double
            switch item.state {
            case .notCounted(let e):
                expected = Double(e)
                counted = Double(e)
            case .matched(let e, let c):
                expected = Double(e)
                counted = Double(c)
            case .variance(let e, let c):
                expected = Double(e)
                counted = Double(c)
            }
            let variance = counted - expected
            let reason = adjBySKU[item.sku]?.reason

            try await repository.updateCycleCountLine(
                lineId: line.line_id,
                countedQty: counted,
                varianceQty: variance,
                reasonCode: reason
            )
        }

        try await repository.updateCycleCountStatus(id: countId, status: "completed")

        // ── All DB writes succeeded — update local state NOW ──────────────────
        let resultLookup = Dictionary(uniqueKeysWithValues: adjustmentRecords.map { ($0.sku, $0) })
        let results = items.map { item -> CycleCountResult in
            let expected: Int
            let counted: Int
            switch item.state {
            case .notCounted(let value):
                expected = value
                counted = value
            case .matched(let exp, let cnt):
                expected = exp
                counted = cnt
            case .variance(let exp, let cnt):
                expected = exp
                counted = cnt
            }

            let variance = counted - expected
            let adjustment = resultLookup[item.sku]

            return CycleCountResult(
                productName: item.name,
                sku: item.sku,
                expected: expected,
                counted: counted,
                variance: variance,
                reason: adjustment?.reason,
                notes: adjustment?.notes
            )
        }

        var completedSession = persistedSession
        completedSession.status = CycleCountStatus.completed
        completedSession.completedDate = completionLabel
        completedSession.counted = items.count
        completedSession.total = items.count
        completedSession.variance = varianceItems.count
        completedSession.isResolved = true
        completedSession.inventoryUpdated = true
        completedSession.reportStatus = "Synced"
        completedSession.completedResults = results

        todaySessions.removeAll { $0.id == session.id }
        upcomingSessions.removeAll { $0.id == session.id }
        completedSessions.removeAll { $0.id == session.id }
        completedSessions.insert(completedSession, at: 0)

        clearItemStates(for: session.id)

        ReportsStore.shared.addRecords(from: adjustmentRecords, session: completedSession)
    }
}

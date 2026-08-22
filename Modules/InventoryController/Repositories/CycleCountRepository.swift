import Foundation
import Supabase

struct SupabaseCycleCount: Codable {
    let cycle_count_id: String
    let ic_id: String?
    let warehouse_id: String?
    let count_type: String?
    let status: String?
    let sync_reference_id: String?
    let scheduled_date: String?
    let completed_date: String?
    let requires_approval: Bool?
    let created_at: String?
    let updated_at: String?
}

struct SupabaseCycleCountLine: Codable {
    let line_id: String
    let count_id: String
    let sku: String
    let partner_item_id: String?
    let lot_number: String?
    let serial_number: String?
    let uom: String?
    let system_qty: Double?
    let counted_qty: Double?
    let variance_qty: Double?
    let variance_value: Double?
    let reason_code: String?
    let status: String?
    let created_at: String?
}

struct CreateCycleCountParams: Codable {
    var ic_id: String?
    var warehouse_id: String?
    var count_type: String?
    var status: String? = "Scheduled"
    var scheduled_date: String?
    var requires_approval: Bool? = false
}

struct UpdateCycleCountLineParams: Codable {
    var counted_qty: Double?
    var variance_qty: Double?
    var reason_code: String?
}

struct CreateCycleCountLineParams: Codable {
    var count_id: String
    var sku: String
    var partner_item_id: String?
    var lot_number: String?
    var serial_number: String?
    var uom: String? = "EACH"
    var system_qty: Double?
    var counted_qty: Double?
    var variance_qty: Double?
    var variance_value: Double?
    var reason_code: String?
    var status: String? = "Pending"
}

class CycleCountRepository {

    func fetchCycleCounts() async throws -> [SupabaseCycleCount] {
        let counts: [SupabaseCycleCount] = try await SupabaseService.shared.client
            .from("cycle_count")
            .select()
            .execute()
            .value
        return counts
    }

    func fetchLines(for countId: String) async throws -> [SupabaseCycleCountLine] {
        let lines: [SupabaseCycleCountLine] = try await SupabaseService.shared.client
            .from("cycle_count_line")
            .select()
            .eq("count_id", value: countId)
            .execute()
            .value
        return lines
    }

    func createCycleCount(_ params: CreateCycleCountParams) async throws -> SupabaseCycleCount {
        let count: SupabaseCycleCount = try await SupabaseService.shared.client
            .from("cycle_count")
            .insert(params)
            .select()
            .single()
            .execute()
            .value
        return count
    }

    func createCycleCountLine(_ params: CreateCycleCountLineParams) async throws -> SupabaseCycleCountLine {
        let line: SupabaseCycleCountLine = try await SupabaseService.shared.client
            .from("cycle_count_line")
            .insert(params)
            .select()
            .single()
            .execute()
            .value
        return line
    }

    func updateCycleCountStatus(id: String, status: String) async throws {
        try await SupabaseService.shared.client
            .from("cycle_count")
            .update(["status": status])
            .eq("cycle_count_id", value: id)
            .execute()
    }

    func updateCycleCountLine(lineId: String, countedQty: Double?, varianceQty: Double?, reasonCode: String?) async throws {
        let params = UpdateCycleCountLineParams(
            counted_qty: countedQty,
            variance_qty: varianceQty,
            reason_code: reasonCode
        )

        try await SupabaseService.shared.client
            .from("cycle_count_line")
            .update(params)
            .eq("line_id", value: lineId)
            .execute()
    }

    func deleteCycleCount(id: String) async throws {
        try await SupabaseService.shared.client
            .from("cycle_count")
            .delete()
            .eq("cycle_count_id", value: id)
            .execute()
    }
}

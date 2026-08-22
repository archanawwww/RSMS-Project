import Foundation
import Supabase

class DashboardRepository {
    func fetchSummary() async throws -> DashboardSummary {
        
        try await SupabaseService.shared.client
            .from("dashboard_summary")
            .select()
            .single()
            .execute()
            .value
    }

    func fetchTasks() async throws -> [DashboardTask] {

        try await SupabaseService.shared.client
            .from("dashboard_tasks")
            .select()
            .execute()
            .value
    }

}

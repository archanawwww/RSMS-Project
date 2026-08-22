import Foundation

extension AuthenticationManager {
    
    @MainActor
    public func fetchPlanograms() async {
        do {
            let response = try await SupabaseAuthService.shared.fetchPlanograms()
            self.planograms = response.sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
        } catch {
            // Silently handle error
        }
    }
    
    @MainActor
    public func createPlanogram(_ planogram: SupabasePlanogram, documentData: Data?, fileName: String?) async throws {
        var newPlanogram = planogram
        
        if let documentData = documentData, let fileName = fileName {
            let publicURL = try await SupabaseStorageService.shared.uploadPlanogramDocument(data: documentData, fileName: fileName)
            newPlanogram.documentURL = publicURL
        }
        
        // Assign created_by if current user exists
        if let user = self.currentUser {
            newPlanogram.createdBy = user.id
        }
        
        try await SupabaseAuthService.shared.createPlanogram(planogram: newPlanogram)
        await fetchPlanograms()
    }
    
    @MainActor
    public func deletePlanogram(id: UUID) async {
        do {
            try await SupabaseAuthService.shared.deletePlanogram(id: id)
            await fetchPlanograms()
        } catch {
            // Silently handle error
        }
    }
}

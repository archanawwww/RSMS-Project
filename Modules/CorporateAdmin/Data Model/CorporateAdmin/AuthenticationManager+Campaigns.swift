import Foundation
import Combine

extension AuthenticationManager {
    
    public func fetchCampaigns() async {
        do {
            let fetchedCampaigns = try await SupabaseAuthService.shared.fetchCampaigns()
            await MainActor.run {
                self.campaigns = fetchedCampaigns.sorted(by: { $0.createdAt ?? Date() > $1.createdAt ?? Date() })
            }
        } catch {
            print("Failed to fetch campaigns: \(error)")
        }
    }
    
    public func createCampaign(_ campaign: SupabaseCampaign) async throws {
        try await SupabaseAuthService.shared.createCampaign(campaign: campaign)
        await fetchCampaigns()
    }
    
    public func updateCampaign(_ campaign: SupabaseCampaign) async {
        do {
            try await SupabaseAuthService.shared.updateCampaign(campaign: campaign)
            await fetchCampaigns()
        } catch {
            print("Failed to update campaign: \(error)")
        }
    }
    
    public func deleteCampaign(id: UUID) async {
        do {
            try await SupabaseAuthService.shared.deleteCampaign(id: id)
            await fetchCampaigns()
        } catch {
            print("Failed to delete campaign: \(error)")
        }
    }
    
    public func sendCampaignEmail(campaign: SupabaseCampaign, recipients: [String]) async throws -> Bool {
        do {
            let success = try await SupabaseAuthService.shared.sendCampaignEmail(campaign: campaign, recipients: recipients)
            // If the mock email function returns true, we can also update the campaign status
            var updatedCampaign = campaign
            updatedCampaign.emailStatus = "Email sent"
            try await SupabaseAuthService.shared.updateCampaign(campaign: updatedCampaign)
            await fetchCampaigns()
            return success
        } catch {
            print("Failed to send campaign email: \(error)")
            throw error
        }
    }
}

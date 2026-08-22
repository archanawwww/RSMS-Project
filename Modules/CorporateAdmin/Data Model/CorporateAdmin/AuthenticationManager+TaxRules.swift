import Foundation
import Combine

extension AuthenticationManager {
    
    public func fetchTaxRules() async {
        do {
            let fetchedRules = try await SupabaseAuthService.shared.fetchTaxRules()
            await MainActor.run {
                self.taxRules = fetchedRules.sorted(by: { $0.country < $1.country })
            }
        } catch {
            print("Failed to fetch tax rules: \(error)")
        }
    }
    
    public func createTaxRule(_ rule: SupabaseTaxRule) async {
        do {
            try await SupabaseAuthService.shared.createTaxRule(rule: rule)
            await fetchTaxRules()
        } catch {
            print("Failed to create tax rule: \(error)")
        }
    }
    
    public func updateTaxRule(_ rule: SupabaseTaxRule) async {
        do {
            try await SupabaseAuthService.shared.updateTaxRule(rule: rule)
            await fetchTaxRules()
        } catch {
            print("Failed to update tax rule: \(error)")
        }
    }
    
    public func deleteTaxRule(id: UUID) async {
        do {
            try await SupabaseAuthService.shared.deleteTaxRule(id: id)
            await fetchTaxRules()
        } catch {
            print("Failed to delete tax rule: \(error)")
        }
    }
    
    // MARK: - Store Integration
    
    public func activeTaxRule(for store: Store) -> SupabaseTaxRule? {
        // First check for a store-specific override
        if let storeOverride = taxRules.first(where: { $0.storeID == store.id && $0.status == "Active" }) {
            return storeOverride
        }
        // Then check for a regional rule based on the store's region enum string
        // Assuming StoreRegion enum names map loosely to the rules
        let regionName = store.region.rawValue
        
        // This is a naive match, usually we'd match on country and region strictly.
        if let regionalRule = taxRules.first(where: {
            ($0.country.lowercased() == regionName.lowercased() ||
             $0.region.lowercased() == regionName.lowercased() ||
             $0.country.lowercased() == "united states" && regionName == "US" ||
             $0.country.lowercased() == "europe" && regionName == "EU") &&
            $0.status == "Active"
        }) {
            return regionalRule
        }
        
        return nil
    }
    
    public func activeTaxConfig(for store: Store) -> RegionalTaxConfig {
        if let rule = activeTaxRule(for: store) {
            let taxTypeEnum = TaxType(rawValue: rule.taxType) ?? .custom
            return RegionalTaxConfig(taxType: taxTypeEnum, taxName: rule.taxType, taxRate: rule.rate)
        }
        
        // Fallback to the default if no database rule exists
        return store.region.defaultTaxConfig
    }
}

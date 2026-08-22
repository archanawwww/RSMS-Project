import Foundation
import Combine

extension AuthenticationManager {
    
    public func addCompanyPolicy(title: String, content: String) {
        let newPolicy = CompanyPolicy(title: title, content: content)
        companyPolicies.append(newPolicy)
        Task {
            do {
                try await SupabaseAuthService.shared.createCompanyPolicy(
                    SupabaseCompanyPolicy(id: newPolicy.id, title: newPolicy.title, content: newPolicy.content, lastUpdated: newPolicy.lastUpdated)
                )
                self.logAuditAction(action: .create, tableName: "Policies", recordID: newPolicy.id, previousValues: nil, newValues: "Name: \(title)")
            } catch {
                print("Failed to create company policy: \(error)")
            }
        }
    }
    
    public func updateCompanyPolicy(_ policy: CompanyPolicy) {
        if let index = companyPolicies.firstIndex(where: { $0.id == policy.id }) {
            let existingPolicy = companyPolicies[index]
            var updatedPolicy = policy
            updatedPolicy.lastUpdated = Date()
            companyPolicies[index] = updatedPolicy
            
            var oldValues: [String] = []
            var newVals: [String] = []
            
            if existingPolicy.title != updatedPolicy.title {
                oldValues.append("Title: \(existingPolicy.title)")
                newVals.append("Title: \(updatedPolicy.title)")
            }
            if existingPolicy.content != updatedPolicy.content {
                oldValues.append("Content: (Changed)")
                newVals.append("Content: (Changed)")
            }
            
            let prevStr = oldValues.isEmpty ? nil : oldValues.joined(separator: ", ")
            let newStr = newVals.isEmpty ? nil : newVals.joined(separator: ", ")
            
            Task {
                do {
                    try await SupabaseAuthService.shared.updateCompanyPolicy(
                        SupabaseCompanyPolicy(id: updatedPolicy.id, title: updatedPolicy.title, content: updatedPolicy.content, lastUpdated: updatedPolicy.lastUpdated)
                    )
                    self.logAuditAction(action: .update, tableName: "Policies", recordID: updatedPolicy.id, previousValues: prevStr, newValues: newStr)
                } catch {
                    print("Failed to update company policy: \(error)")
                }
            }
        }
    }
    
    public func deleteCompanyPolicy(id: UUID) {
        let policyToDelete = companyPolicies.first(where: { $0.id == id })
        companyPolicies.removeAll { $0.id == id }
        Task {
            do {
                try await SupabaseAuthService.shared.deleteCompanyPolicy(id: id)
                if let deletedPolicy = policyToDelete {
                    self.logAuditAction(action: .delete, tableName: "Policies", recordID: id, previousValues: "Name: \(deletedPolicy.title)", newValues: nil)
                }
            } catch {
                print("Failed to delete company policy: \(error)")
            }
        }
    }
}

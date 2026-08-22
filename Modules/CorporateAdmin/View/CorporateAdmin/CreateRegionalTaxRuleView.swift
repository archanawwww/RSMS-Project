import SwiftUI

struct CreateRegionalTaxRuleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var country: String = ""
    @State private var region: String = ""
    @State private var taxType: String = "GST"
    @State private var rateString: String = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Location details")) {
                    TextField("Country (e.g., India, France)", text: $country)
                    TextField("Region (e.g., Maharashtra, Paris)", text: $region)
                }
                
                Section(header: Text("Tax Details")) {
                    TextField("Tax Type (e.g., GST, VAT, Sales Tax)", text: $taxType)
                    TextField("Rate % (e.g., 18)", text: $rateString)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Tax Rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveTaxRule()
                        }
                    }
                    .fontWeight(.bold)
                    .disabled(country.isEmpty || region.isEmpty || rateString.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }
    
    private func saveTaxRule() async {
        isSaving = true
        let ratePercent = Double(rateString) ?? 0.0
        let rate = ratePercent / 100.0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let currentDateStr = dateFormatter.string(from: Date())
        
        let newRule = SupabaseTaxRule(
            id: UUID(),
            country: country,
            region: region,
            taxType: taxType,
            rate: rate,
            effectiveDate: currentDateStr, status: "Active",
            lastUpdated: currentDateStr,
            updatedBy: "Admin", notificationRef: "Manual Entry",
            history: [
                SupabaseTaxHistoryEntry(
                    rate: rate,
                    date: currentDateStr,
                    description: "Initial creation",
                    reference: "Manual Entry",
                    enteredBy: "Admin"
                )
            ]
        )
        
        await authManager.createTaxRule(newRule)
        isSaving = false
        dismiss()
    }
}

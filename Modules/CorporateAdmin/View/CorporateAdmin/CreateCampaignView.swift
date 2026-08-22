import SwiftUI

// MARK: - Create Campaign View

struct CreateCampaignView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    
    
    // Form States
    @State private var campaignName: String = "Summer Glow Fest"
    @State private var campaignType: String = "Discount"
    @State private var description: String = "Flat 20% off on all skincare products across selected boutiques and counters."
    @State private var startDate: Date = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1)) ?? Date()
    @State private var endDate: Date = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 15)) ?? Date()
    
    // Selected Categories
    @State private var selectedCategories: Set<String> = ["Skincare"]
    
    // Offer Details States
    @State private var isPercentageDiscount: Bool = true
    @State private var discountValue: String = "20"
    
    // Error handling
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var minPurchase: String = "2,000"
    @State private var maxDiscount: String = "5,000"
    
    // Share with states
    @State private var selectedBoutiqueCount = 3
    @State private var selectedCounterCount = 5
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Section 1: Campaign Details Form
                        campaignDetailsSection
                        
                        // Section 2: Offer Details
                        offerDetailsSection
                        
                        // Section 3: Share With Summary removed from Details tab as per mockup
                        
                        // Action Buttons bottom
                        HStack(spacing: 12) {
                            Button("Cancel") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                            
                            Button("Confirm & Save") {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                let startString = formatter.string(from: startDate)
                                let endString = formatter.string(from: endDate)
                                
                                let newCampaign = SupabaseCampaign(
                                    id: UUID(),
                                    title: campaignName,
                                    description: description,
                                    type: campaignType == "Discount" ? "Promotion" : campaignType,
                                    startDate: startString,
                                    endDate: endString,
                                    productIDs: [], // Empty array for now
                                    status: "Active",
                                    sentTo: "Selected Boutiques (\(selectedBoutiqueCount))",
                                    sentToRegion: "India",
                                    emailStatus: "Not sent",
                                    themeName: campaignName.lowercased().contains("glow") ? "summer" : "diwali",
                                    discountType: isPercentageDiscount ? "Percentage" : "Flat",
                                    discountValue: Double(discountValue) ?? 0.0,
                                    createdAt: Date()
                                )
                                Task {
                                    do {
                                        try await authManager.createCampaign(newCampaign)
                                        await MainActor.run {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    } catch {
                                        await MainActor.run {
                                            errorMessage = error.localizedDescription
                                            showError = true
                                        }
                                    }
                                }
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.ivoryMatte)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(MatteTheme.Colors.primaryGold)
                        }
                        .padding(.top, 10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("New Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .font(.system(size: 15))
                }
            }
        }
        .alert("Error Creating Campaign", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Subviews: Campaign Details Card
    
    private var campaignDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Campaign Name
            formLabel("Campaign Name")
            HStack {
                TextField("e.g. Summer Glow Fest", text: $campaignName)
                    .font(.system(size: 15))
                    .onChange(of: campaignName) { newValue in
                        if newValue.count > 60 {
                            campaignName = String(newValue.prefix(60))
                        }
                    }
                Spacer()
                Text("\(campaignName.count)/60")
                    .font(.system(size: 11))
                    .foregroundColor(MatteTheme.Colors.textTertiary)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
            
            // Campaign Type Dropdown
            formLabel("Campaign Type")
            Menu {
                Button("Discount") { campaignType = "Discount" }
                Button("Product Launch") { campaignType = "Launch" }
                Button("VIP Special") { campaignType = "VIP" }
                Button("Anniversary") { campaignType = "Anniversary" }
            } label: {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 12))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    
                    Text(campaignType)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
                .padding(14)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
            }
            .buttonStyle(.plain)
            
            // Description TextEditor
            formLabel("Description")
            VStack(alignment: .trailing, spacing: 4) {
                TextEditor(text: $description)
                    .font(.system(size: 14))
                    .frame(height: 80)
                    .onChange(of: description) { newValue in
                        if newValue.count > 200 {
                            description = String(newValue.prefix(200))
                        }
                    }
                Text("\(description.count)/200")
                    .font(.system(size: 11))
                    .foregroundColor(MatteTheme.Colors.textTertiary)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
            
            // Dates Row
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    formLabel("Start Date")
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "en_GB"))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    formLabel("End Date")
                    DatePicker("", selection: $endDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "en_GB"))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                }
            }
            
            // Applicable Categories horizontal buttons
            formLabel("Applicable Categories")
            HStack(spacing: 8) {
                categoryCardButton(name: "Skincare", icon: "drop.fill")
                categoryCardButton(name: "Fragrances", icon: "wind")
                categoryCardButton(name: "Handbags", icon: "bag")
                categoryCardButton(name: "Watches", icon: "clock")
                categoryCardButton(name: "More", icon: "ellipsis")
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    // MARK: - Subviews: Offer Details Card
    
    private var offerDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            formLabel("Offer Type")
            HStack(spacing: 12) {
                // Percentage Discount Radio card
                Button(action: { isPercentageDiscount = true }) {
                    HStack {
                        Image(systemName: isPercentageDiscount ? "largecircle.fill.playwrap" : "circle")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(isPercentageDiscount ? MatteTheme.Colors.primaryGold : MatteTheme.Colors.textTertiary, MatteTheme.Colors.primaryGold)
                            .font(.system(size: 16))
                        Text("Percentage Discount")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isPercentageDiscount ? MatteTheme.Colors.primaryGold.opacity(0.05) : Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(isPercentageDiscount ? MatteTheme.Colors.primaryGold : MatteTheme.Colors.borderLight, lineWidth: 1))
                }
                .buttonStyle(.plain)
                
                // Flat Discount Radio card
                Button(action: { isPercentageDiscount = false }) {
                    HStack {
                        Image(systemName: !isPercentageDiscount ? "largecircle.fill.playwrap" : "circle")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(!isPercentageDiscount ? MatteTheme.Colors.primaryGold : MatteTheme.Colors.textTertiary, MatteTheme.Colors.primaryGold)
                            .font(.system(size: 16))
                        Text("Flat Discount")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(!isPercentageDiscount ? MatteTheme.Colors.primaryGold.opacity(0.05) : Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(!isPercentageDiscount ? MatteTheme.Colors.primaryGold : MatteTheme.Colors.borderLight, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            
            // Discount Value input
            formLabel("Discount Value")
            HStack {
                TextField("e.g. 20", text: $discountValue)
                    .font(.system(size: 15))
                    .keyboardType(.decimalPad)
                Spacer()
                Text(isPercentageDiscount ? "% OFF" : "₹ OFF")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(MatteTheme.Colors.dashboardBackground)
                    .cornerRadius(4)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
            
            // Optional Threshold Rows
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    formLabel("Minimum Purchase (Optional)")
                    HStack {
                        Text("₹")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                        TextField("2,000", text: $minPurchase)
                            .font(.system(size: 14))
                            .keyboardType(.decimalPad)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    formLabel("Max Discount (Optional)")
                    HStack {
                        Text("₹")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                        TextField("5,000", text: $maxDiscount)
                            .font(.system(size: 14))
                            .keyboardType(.decimalPad)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    // MARK: - Subviews: Share With Card
    
    private var shareWithSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            formLabel("Share With")
            
            HStack(spacing: 24) {
                HStack(spacing: 8) {
                    Image(systemName: "storefront.fill")
                        .foregroundColor(MatteTheme.Colors.primaryGold)
                    Text("Boutiques (\(selectedBoutiqueCount))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(MatteTheme.Colors.info)
                    Text("Counters (\(selectedCounterCount))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    // MARK: - Helpers & Category buttons
    
    private func categoryCardButton(name: String, icon: String) -> some View {
        let isSelected = selectedCategories.contains(name)
        return Button(action: {
            if isSelected {
                selectedCategories.remove(name)
            } else {
                selectedCategories.insert(name)
            }
        }) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? MatteTheme.Colors.primaryGold : MatteTheme.Colors.textSecondary)
                        .frame(width: 48, height: 48)
                        .background(isSelected ? MatteTheme.Colors.primaryGold.opacity(0.06) : MatteTheme.Colors.dashboardBackground)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? MatteTheme.Colors.primaryGold : Color.clear, lineWidth: 1.5))
                    
                    if isSelected {
                        // Checkmark indicator exactly matching mockup
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(MatteTheme.Colors.primaryGold)
                            .background(Circle().fill(Color.white))
                            .padding(.top, -3)
                            .padding(.trailing, -3)
                    }
                }
                
                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isSelected ? MatteTheme.Colors.primaryGold : MatteTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    private func formLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(MatteTheme.Colors.textSecondary)
    }
}

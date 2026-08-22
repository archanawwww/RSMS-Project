import SwiftUI
import Combine

// MARK: - Regional Tax Rules Models

// Using SupabaseTaxRule from SupabaseAuthService

enum TaxSheetMode {
    case detail
    case update
    case schedule
    case history
}

// Global Helper
func flagEmoji(for countryName: String) -> String {
    switch countryName.lowercased() {
    case "india": return "🇮🇳"
    case "united states": return "🇺🇸"
    case "china": return "🇨🇳"
    case "germany": return "🇩🇪"
    case "france": return "🇫🇷"
    default: return "🏳️"
    }
}

// MARK: - Regional Tax Rules View

struct RegionalTaxRulesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    // State variables
    
    @State private var searchText = ""
    @State private var selectedCountryFilter: String? = nil
    @State private var selectedTaxTypeFilter: String? = nil
    @State private var selectedStatusFilter: String? = nil
    
    // Collapsed state tracking (Key is country name)
    @State private var collapsedCountries: Set<String> = []
    
    // Multi-mode sheet properties
    @State private var selectedConfig: SupabaseTaxRule? = nil
    @State private var showCreateRule = false
    
    private var countriesList: [String] {
        Array(Set(authManager.taxRules.map(\.country))).sorted()
    }
    
    private var taxTypesList: [String] {
        Array(Set(authManager.taxRules.map(\.taxType))).sorted()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Summary cards removed as requested
                
                // Search Bar and Filters
                VStack(spacing: 12) {
                    searchBar
                    filterDropdowns
                }
                .padding(14)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
                
                // Main Configurations Header
                HStack {
                    Text("GOVERNMENT TAX CONFIGURATIONS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
                
                // Grouped country list
                VStack(spacing: 16) {
                    ForEach(groupedCountriesKeys, id: \.self) { country in
                        countrySectionView(country: country, configs: groupedConfigs[country] ?? [])
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 96)
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .navigationTitle("Regional Tax Rules")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCreateRule = true }) {
                    Label("Create", systemImage: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(20)
                }
            }
        }
        .onAppear {
            Task {
                await authManager.fetchTaxRules()
            }
        }
        .sheet(item: $selectedConfig) { config in
            TaxConfigurationSheetContainer(
                config: config,
                selectedConfig: $selectedConfig,
                authManager: authManager
            )
        }
        .sheet(isPresented: $showCreateRule) {
            CreateRegionalTaxRuleView()
        }
    }
    
    // MARK: - Summary Cards Section
    
    private var summaryCardsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                summaryCard(value: "\(countriesList.count)", title: "Total Countries", icon: "globe")
                summaryCard(value: "\(authManager.taxRules.count)", title: "Total Regions Configured", icon: "building.columns")
                summaryCard(value: "\(authManager.taxRules.filter { $0.status == "Active" }.count)", title: "Active Government Tax", icon: "checkmark.shield")
                summaryCard(value: "1", title: "Scheduled Government Updates", icon: "clock")
            }
        }
    }
    
    private func summaryCard(value: String, title: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                    .font(.title2)
            }
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(width: 140, height: 110)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Search Bar & Filter Dropdowns
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(MatteTheme.Colors.textSecondary)
            TextField("Search Country, State or Tax Type", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(MatteTheme.Colors.textPrimary)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
            }
        }
        .padding(10)
        .background(MatteTheme.Colors.dashboardBackground)
        .cornerRadius(10)
    }
    
    private var filterDropdowns: some View {
        HStack(spacing: 8) {
            // Country
            Menu {
                Button("All Countries") { selectedCountryFilter = nil }
                ForEach(countriesList, id: \.self) { country in
                    Button("\(flagEmoji(for: country)) \(country)") { selectedCountryFilter = country }
                }
            } label: {
                filterTag(text: selectedCountryFilter ?? "Country")
            }
            
            // Tax Type
            Menu {
                Button("All Tax Types") { selectedTaxTypeFilter = nil }
                ForEach(taxTypesList, id: \.self) { type in
                    Button(type) { selectedTaxTypeFilter = type }
                }
            } label: {
                filterTag(text: selectedTaxTypeFilter ?? "Tax Type")
            }
            
            // Status
            Menu {
                Button("All Statuses") { selectedStatusFilter = nil }
                Button("Active") { selectedStatusFilter = "Active" }
                Button("Scheduled") { selectedStatusFilter = "Scheduled" }
                Button("Inactive") { selectedStatusFilter = "Inactive" }
            } label: {
                filterTag(text: selectedStatusFilter ?? "Status")
            }
            
            Spacer()
        }
    }
    
    private func filterTag(text: String) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textSecondary)
            Image(systemName: "chevron.down")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(MatteTheme.Colors.dashboardBackground)
        .cornerRadius(8)
    }
    
    // MARK: - Country Section
    
    private var groupedCountriesKeys: [String] {
        groupedConfigs.keys.sorted()
    }
    
    private var groupedConfigs: [String: [SupabaseTaxRule]] {
        Dictionary(grouping: filteredConfigs, by: \.country)
    }
    
    private var filteredConfigs: [SupabaseTaxRule] {
        authManager.taxRules.filter { config in
            if !searchText.isEmpty {
                let query = searchText.lowercased()
                let match = config.country.lowercased().contains(query) ||
                            config.region.lowercased().contains(query) ||
                            config.taxType.lowercased().contains(query)
                if !match { return false }
            }
            if let selectedCountryFilter, config.country != selectedCountryFilter {
                return false
            }
            if let selectedTaxTypeFilter, config.taxType != selectedTaxTypeFilter {
                return false
            }
            if let selectedStatusFilter, config.status != selectedStatusFilter {
                return false
            }
            return true
        }
    }
    
    private func countrySectionView(country: String, configs: [SupabaseTaxRule]) -> some View {
        let isCollapsed = collapsedCountries.contains(country)
        
        return VStack(alignment: .leading, spacing: 0) {
            // Country Header Row
            Button(action: {
                if isCollapsed {
                    collapsedCountries.remove(country)
                } else {
                    collapsedCountries.insert(country)
                }
            }) {
                HStack(spacing: 12) {
                    Text(flagEmoji(for: country))
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(country)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                        Text("\(configs.count) regions configured")
                            .font(.system(size: 11))
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(16)
                .background(Color.white)
            }
            .buttonStyle(.plain)
            
            if !isCollapsed {
                Divider().background(MatteTheme.Colors.borderLight)
                
                // Region Rows inside the Country Section
                VStack(spacing: 0) {
                    ForEach(configs) { config in
                        Button(action: {
                            selectedConfig = config
                        }) {
                            VStack(spacing: 0) {
                                HStack(spacing: 14) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(config.region)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(MatteTheme.Colors.textPrimary)
                                        Text("Effective \(config.effectiveDate)")
                                            .font(.system(size: 11))
                                            .foregroundColor(MatteTheme.Colors.textTertiary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Tax type badge
                                    Text(config.taxType)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(MatteTheme.Colors.primaryGold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(MatteTheme.Colors.primaryGold.opacity(0.08))
                                        .cornerRadius(4)
                                    
                                    // Tax Rate
                                    Text(formatRateGlobal(config.rate))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                    
                                    // Status Badge
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(config.status == "Active" ? MatteTheme.Colors.success : (config.status == "Scheduled" ? MatteTheme.Colors.primaryGold : MatteTheme.Colors.textTertiary))
                                            .frame(width: 6, height: 6)
                                        Text(config.status)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(config.status == "Active" ? MatteTheme.Colors.success : (config.status == "Scheduled" ? MatteTheme.Colors.primaryGold : MatteTheme.Colors.textSecondary))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(config.status == "Active" ? MatteTheme.Colors.success.opacity(0.08) : (config.status == "Scheduled" ? MatteTheme.Colors.primaryGold.opacity(0.08) : Color.black.opacity(0.04)))
                                    .cornerRadius(6)
                                    
                                    // Arrow chevron
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(MatteTheme.Colors.textTertiary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                
                                if config.id != configs.last?.id {
                                    Divider()
                                        .padding(.leading, 16)
                                        .background(MatteTheme.Colors.borderLight)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    private func formatRateGlobal(_ rate: Double) -> String {
        let pct = rate * 100.0
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        return (formatter.string(from: NSNumber(value: pct)) ?? String(format: "%.1f", pct)) + "%"
    }
}

// MARK: - Tax Configuration Sheet Container

struct TaxConfigurationSheetContainer: View {
    let config: SupabaseTaxRule
    @Binding var selectedConfig: SupabaseTaxRule?
    let authManager: AuthenticationManager
    
    @State private var activeSheetMode: TaxSheetMode = .detail
    
    // Form update bindings
    @State private var editRateString = ""
    @State private var editEffectiveDate = ""
    @State private var editNotificationRef = ""
    @State private var editNotes = ""
    
    var body: some View {
        VStack(spacing: 0) {
            switch activeSheetMode {
            case .detail:
                taxDetailView(config: config)
            case .update:
                updateGovernmentTaxView(config: config)
            case .schedule:
                scheduleGovernmentTaxView(config: config)
            case .history:
                taxUpdateHistoryView(config: config)
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.96).ignoresSafeArea())
    }
    
    // MARK: - Subview 1: Tax Detail View
    
    private func taxDetailView(config: SupabaseTaxRule) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(flagEmoji(for: config.country))
                    .font(.system(size: 28))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(config.region)
                        .font(.title3.weight(.bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    
                    Text("\(config.country) • \(config.taxType)")
                        .font(.caption)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: { selectedConfig = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Big Rate Box
                    VStack(spacing: 6) {
                        Text(formatRate(config.rate))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.luxuryGold)
                        
                        Text("Government Defined \(config.taxType) Rate")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(MatteTheme.Colors.primaryGold.opacity(0.06))
                    .cornerRadius(16)
                    
                    // Detailed Information Rows
                    VStack(spacing: 12) {
                        detailRow(label: "STATUS", value: config.status.uppercased())
                        Divider().background(MatteTheme.Colors.borderLight)
                        detailRow(label: "EFFECTIVE DATE", value: config.effectiveDate)
                        Divider().background(MatteTheme.Colors.borderLight)
                        detailRow(label: "LAST VERIFIED/UPDATED", value: config.lastUpdated)
                        Divider().background(MatteTheme.Colors.borderLight)
                        detailRow(label: "UPDATED BY", value: config.updatedBy)
                        Divider().background(MatteTheme.Colors.borderLight)
                        detailRow(label: "GOVERNMENT NOTIFICATION REFERENCE", value: config.notificationRef)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
                    )
                    
                    // Info Checkbox Card
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(MatteTheme.Colors.success)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Government Defined Configuration")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(MatteTheme.Colors.success)
                            
                            Text("Tax rates are issued by government authorities. Corporate Administrators only update the ERP after official tax notifications. Boutique Managers cannot modify these values.")
                                .font(.system(size: 12))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                    .padding(16)
                    .background(MatteTheme.Colors.success.opacity(0.05))
                    .cornerRadius(14)
                    
                    // Action Buttons (Updated exactly as mockup)
                    VStack(spacing: 10) {
                        // Button 1: Update Government Tax
                        Button {
                            editRateString = String(format: "%.1f", config.rate * 100)
                            editEffectiveDate = ""
                            editNotificationRef = ""
                            editNotes = ""
                            activeSheetMode = .update
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(MatteTheme.Colors.ivoryMatte)
                                    .frame(width: 38, height: 38)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Update Government Tax")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Apply a newly announced rate")
                                        .font(.system(size: 11))
                                        .opacity(0.8)
                                }
                                Spacer()
                            }
                            .foregroundColor(MatteTheme.Colors.ivoryMatte)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(MatteTheme.Colors.primaryGold)
                            .cornerRadius(14)
                        }
                        .buttonStyle(.plain)
                        
                        // Button 2: Schedule Update
                        Button {
                            editRateString = ""
                            editEffectiveDate = ""
                            editNotificationRef = ""
                            activeSheetMode = .schedule
                        } label: {
                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(MatteTheme.Colors.textPrimary)
                                    .frame(width: 38, height: 38)
                                    .background(Color.black.opacity(0.05))
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Schedule Future Government Tax Update")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                    Text("Queue a rate change for a future date")
                                        .font(.system(size: 11))
                                        .foregroundColor(MatteTheme.Colors.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Button 3: View Update History (New added)
                        Button {
                            activeSheetMode = .history
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(MatteTheme.Colors.textPrimary)
                                    .frame(width: 38, height: 38)
                                    .background(Color.black.opacity(0.05))
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("View Update History")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                    Text("See every past government notification")
                                        .font(.system(size: 11))
                                        .foregroundColor(MatteTheme.Colors.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Subview 2: Update Government Tax View
    
    private func updateGovernmentTaxView(config: SupabaseTaxRule) -> some View {
        VStack(spacing: 0) {
            // Header exactly matching screenshot 2
            subSheetHeader(title: "Update Government Tax", subtitle: "\(flagEmoji(for: config.country)) \(config.country.uppercased()) • \(config.region.uppercased())")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Current rate Box
                    HStack {
                        Text("Current rate on file")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                        Spacer()
                        Text(formatRate(config.rate))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                    }
                    .padding()
                    .background(MatteTheme.Colors.primaryGold.opacity(0.06))
                    .cornerRadius(12)
                    
                    // Form fields
                    formFieldLabel("NEW GOVERNMENT TAX RATE")
                    HStack {
                        TextField("e.g. 18.5", text: $editRateString)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 15))
                        Spacer()
                        Image(systemName: "arrow.up.and.down")
                            .font(.system(size: 11))
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                        Text("%")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                    
                    Text("Enter the rate exactly as published in the official government notification.")
                        .font(.system(size: 12))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                        .padding(.top, -10)
                    
                    formFieldLabel("EFFECTIVE DATE")
                    TextField("e.g. 04/07/2026", text: $editEffectiveDate)
                        .font(.system(size: 15))
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                    
                    formFieldLabel("GOVERNMENT NOTIFICATION REFERENCE NUMBER")
                    TextField("e.g. CBIC-NOTIF-31/2026", text: $editNotificationRef)
                        .font(.system(size: 15))
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                    
                    formFieldLabel("NOTES (OPTIONAL)")
                    TextEditor(text: $editNotes)
                        .font(.system(size: 14))
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                    
                    // Buttons bottom
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            activeSheetMode = .detail
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                        
                        Button("Confirm Update") {
                            applyTaxUpdate(config: config, isScheduled: false)
                            activeSheetMode = .detail
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.ivoryMatte)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(MatteTheme.Colors.primaryGold)
                        .cornerRadius(14)
                        .disabled(editRateString.isEmpty || editEffectiveDate.isEmpty)
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Subview 3: Schedule Future Tax View
    
    private func scheduleGovernmentTaxView(config: SupabaseTaxRule) -> some View {
        VStack(spacing: 0) {
            // Header exactly matching screenshot 3
            subSheetHeader(title: "Schedule Future Government Tax Update", subtitle: "\(flagEmoji(for: config.country)) \(config.country.uppercased()) • \(config.region.uppercased())")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Current rate Box
                    HStack {
                        Text("Current rate on file")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                        Spacer()
                        Text(formatRate(config.rate))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                    }
                    .padding()
                    .background(MatteTheme.Colors.primaryGold.opacity(0.06))
                    .cornerRadius(12)
                    
                    // Form fields
                    formFieldLabel("UPCOMING GOVERNMENT TAX RATE")
                    HStack {
                        TextField("e.g. 21", text: $editRateString)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 15))
                        Spacer()
                        Image(systemName: "arrow.up.and.down")
                            .font(.system(size: 11))
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                        Text("%")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                    
                    Text("This rate will apply automatically once the effective date arrives.")
                        .font(.system(size: 12))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                        .padding(.top, -10)
                    
                    formFieldLabel("EFFECTIVE DATE")
                    TextField("e.g. 05/07/2026", text: $editEffectiveDate)
                        .font(.system(size: 15))
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                    
                    formFieldLabel("GOVERNMENT NOTIFICATION REFERENCE NUMBER")
                    TextField("e.g. DGFiP-2026-0512", text: $editNotificationRef)
                        .font(.system(size: 15))
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                    
                    // Buttons bottom
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            activeSheetMode = .detail
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
                        
                        Button("Schedule Update") {
                            applyTaxUpdate(config: config, isScheduled: true)
                            activeSheetMode = .detail
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.ivoryMatte)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(MatteTheme.Colors.primaryGold)
                        .cornerRadius(14)
                        .disabled(editRateString.isEmpty || editEffectiveDate.isEmpty)
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Subview 4: Tax Update History View (Timeline)
    
    private func taxUpdateHistoryView(config: SupabaseTaxRule) -> some View {
        VStack(spacing: 0) {
            // Header exactly matching screenshot 4
            subSheetHeader(title: "Update History", subtitle: "\(flagEmoji(for: config.country)) \(config.country.uppercased()) • \(config.region.uppercased())")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if config.history.isEmpty {
                        Text("No update history on file for this region.")
                            .font(.subheadline)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .padding(24)
                    } else {
                        // Timeline stack
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(0..<config.history.count, id: \.self) { idx in
                                let entry = config.history[idx]
                                let isLast = idx == config.history.count - 1
                                
                                HStack(alignment: .top, spacing: 18) {
                                    // Vertical line dot column
                                    VStack(spacing: 0) {
                                        Circle()
                                            .stroke(MatteTheme.Colors.primaryGold, lineWidth: 2)
                                            .background(Circle().fill(Color(red: 0.98, green: 0.98, blue: 0.96)))
                                            .frame(width: 14, height: 14)
                                        
                                        if !isLast {
                                            Rectangle()
                                                .fill(MatteTheme.Colors.primaryGold.opacity(0.3))
                                                .frame(width: 2, height: 80)
                                        }
                                    }
                                    
                                    // Details column
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(alignment: .firstTextBaseline) {
                                            Text(formatRate(entry.rate))
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(MatteTheme.Colors.textPrimary)
                                            
                                            Spacer()
                                            
                                            Text(entry.date)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                        }
                                        
                                        Text(entry.description)
                                            .font(.system(size: 13))
                                            .foregroundColor(MatteTheme.Colors.textPrimary)
                                        
                                        Text("Ref \(entry.reference) • Entered by \(entry.enteredBy)")
                                            .font(.system(size: 12))
                                            .foregroundColor(MatteTheme.Colors.textTertiary)
                                    }
                                    .padding(.top, -2)
                                }
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
    }
    
    // MARK: - Subview Helpers
    
    private func subSheetHeader(title: String, subtitle: String) -> some View {
        HStack {
            Button(action: { activeSheetMode = .detail }) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.bold))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 2)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(subtitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Button(action: { selectedConfig = nil }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(MatteTheme.Colors.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }
    
    private func formFieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(MatteTheme.Colors.textSecondary)
            .padding(.top, 6)
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(MatteTheme.Colors.textPrimary)
        }
    }
    
    // MARK: - Helpers
    
    private func formatRate(_ rate: Double) -> String {
        let pct = rate * 100.0
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        return (formatter.string(from: NSNumber(value: pct)) ?? String(format: "%.1f", pct)) + "%"
    }
    
    private func applyTaxUpdate(config: SupabaseTaxRule, isScheduled: Bool) {
        var updatedConfig = config
        
        let newRatePercent = Double(editRateString) ?? 0.0
        let newRate = newRatePercent / 100.0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let currentDateStr = dateFormatter.string(from: Date())
        
        let newEntry = SupabaseTaxHistoryEntry(
            rate: newRate,
            date: editEffectiveDate,
            description: isScheduled ? "Future tax update scheduled (Effective \(editEffectiveDate))." : "Current government-defined rate applied.",
            reference: editNotificationRef,
            enteredBy: "Admin"
        )
        
        if isScheduled {
            updatedConfig.status = "Scheduled"
        } else {
            updatedConfig.rate = newRate
            updatedConfig.effectiveDate = editEffectiveDate
            updatedConfig.lastUpdated = currentDateStr
            updatedConfig.notificationRef = editNotificationRef
            updatedConfig.status = "Active"
        }
        
        updatedConfig.history.insert(newEntry, at: 0)
        
        Task {
            await authManager.updateTaxRule(updatedConfig)
            await MainActor.run {
                selectedConfig = updatedConfig
                authManager.objectWillChange.send()
            }
        }
    }
}

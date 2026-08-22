import SwiftUI

// MARK: - Campaigns Management View

struct CampaignsManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    
    // State variables matching mockup filters
    @State private var searchText = ""
    @State private var selectedTypeFilter: String? = nil
    @State private var selectedStatusFilter: String? = nil
    
    @State private var showCreateSheet = false
    @State private var selectedCampaignForDetail: SupabaseCampaign? = nil
    
    // Unique options lists for filter menus
    private let typesList = ["Festival", "Seasonal", "Launch", "VIP", "Promotion", "Anniversary"]
    private let statusesList = ["Active", "Upcoming", "Completed", "Draft"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Description sub-label exactly matching screenshot
                    HStack {
                        Text("Create and manage marketing campaigns across boutiques.")
                            .font(.system(size: 13))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    // 2. Search Bar
                    searchBarView
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
                    
                    // 3. Campaigns List Container (Responsive layout)
                    VStack(spacing: 14) {
                        // Table Headers for Wide views/iPad, or section title for phone
                        HStack {
                            Text("ALL MARKETING CAMPAIGNS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 6)
                        
                        // Render Stacked Campaign cards
                        VStack(spacing: 12) {
                            if filteredCampaigns.isEmpty {
                                emptyCampaignState
                            } else {
                                ForEach(filteredCampaigns) { campaign in
                                    Button(action: {
                                        selectedCampaignForDetail = campaign
                                    }) {
                                        campaignRowCard(campaign: campaign)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Campaigns")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.primaryGold)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                    .font(.system(size: 15, weight: .semibold))
                }
            }
            .onAppear {
                Task {
                    await authManager.fetchCampaigns()
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateCampaignView()
                    .environmentObject(authManager)
            }
            .sheet(item: $selectedCampaignForDetail) { campaign in
                CampaignDetailSheetView(campaign: campaign)
                    .environmentObject(authManager)
                    .presentationDetents([.fraction(0.85), .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Subviews: Metrics
    
    private var metricsRowSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                metricCard(value: "24", label: "Total Campaigns", icon: "square.stack.3d.up.fill", color: MatteTheme.Colors.primaryGold)
                metricCard(value: "8", label: "Active", icon: "circle.inset.filled", color: MatteTheme.Colors.success)
                metricCard(value: "5", label: "Upcoming", icon: "clock.fill", color: MatteTheme.Colors.warning)
                metricCard(value: "7", label: "Completed", icon: "checkmark.circle.fill", color: Color.purple)
                metricCard(value: "4", label: "Drafts", icon: "doc.fill", color: MatteTheme.Colors.textTertiary)
            }
        }
    }
    
    private func metricCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                // Circle wrapped icon matching the mockup circles
                ZStack {
                    Circle()
                        .fill(color.opacity(0.08))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(color)
                }
                Spacer()
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .padding(16)
        .frame(width: 142, height: 95)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Subviews: Search & Filters
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(MatteTheme.Colors.textSecondary)
            TextField("Search campaigns...", text: $searchText)
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
    
    private var filtersRowView: some View {
        HStack(spacing: 8) {
            // Types menu
            Menu {
                Button("All Types") { selectedTypeFilter = nil }
                ForEach(typesList, id: \.self) { type in
                    Button(type) { selectedTypeFilter = type }
                }
            } label: {
                filterDropdownBadge(text: selectedTypeFilter ?? "All Types")
            }
            
            // Statuses menu
            Menu {
                Button("All Statuses") { selectedStatusFilter = nil }
                ForEach(statusesList, id: \.self) { status in
                    Button(status) { selectedStatusFilter = status }
                }
            } label: {
                filterDropdownBadge(text: selectedStatusFilter ?? "All Statuses")
            }
            
            // Static Filters trigger icon
            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 11, weight: .bold))
                    Text("Filters")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(MatteTheme.Colors.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(MatteTheme.Colors.dashboardBackground)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    
    private func filterDropdownBadge(text: String) -> some View {
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
    
    // MARK: - Campaign Row Card
    
    private func campaignRowCard(campaign: SupabaseCampaign) -> some View {
        HStack(alignment: .center, spacing: 14) {
            // Themed Mock Image Thumbnail (Festival, Winter, Launch, etc)
            campaignThumbnail(theme: campaign.themeName)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(campaign.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                
                Text(campaign.description)
                    .font(.system(size: 12))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Add chevron.right navigation indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
        )
    }
    
    // MARK: - Card Element Builders
    
    private func campaignThumbnail(theme: String) -> some View {
        ZStack {
            // High-quality mock visual gradient
            LinearGradient(
                colors: gradientColors(for: theme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 64, height: 64)
            .cornerRadius(12)
            
            // SF Symbol accent
            Image(systemName: iconName(for: theme))
                .font(.title3)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.12), radius: 2)
        }
    }
    
    private func typeBadge(type: String) -> some View {
        let colors = typeColors(type: type)
        return Text(type)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(colors.fg)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(colors.bg)
            .cornerRadius(4)
    }
    
    // MARK: - Logic & Formatting Helpers
    
    private var filteredCampaigns: [SupabaseCampaign] {
        authManager.campaigns.filter { item in
            if !searchText.isEmpty {
                let query = searchText.lowercased()
                let match = item.title.lowercased().contains(query) ||
                            item.description.lowercased().contains(query) ||
                            item.sentTo.lowercased().contains(query)
                if !match { return false }
            }
            if let selectedTypeFilter, item.type != selectedTypeFilter {
                return false
            }
            if let selectedStatusFilter, item.status != selectedStatusFilter {
                return false
            }
            return true
        }
    }
    
    private func formatPeriod(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }
    
    private func statusColor(status: String) -> Color {
        switch status.lowercased() {
        case "active": return MatteTheme.Colors.success
        case "upcoming": return MatteTheme.Colors.warning
        case "completed": return Color.purple
        default: return MatteTheme.Colors.textSecondary
        }
    }
    
    private func typeColors(type: String) -> (fg: Color, bg: Color) {
        switch type {
        case "Festival":
            return (MatteTheme.Colors.primaryGold, MatteTheme.Colors.primaryGold.opacity(0.08))
        case "Seasonal":
            return (MatteTheme.Colors.info, MatteTheme.Colors.info.opacity(0.08))
        case "Launch":
            return (Color.purple, Color.purple.opacity(0.08))
        case "VIP":
            return (MatteTheme.Colors.luxuryGold, MatteTheme.Colors.luxuryGold.opacity(0.08))
        case "Promotion":
            return (Color.teal, Color.teal.opacity(0.08))
        case "Anniversary":
            return (Color.pink, Color.pink.opacity(0.08))
        default:
            return (MatteTheme.Colors.textSecondary, Color.black.opacity(0.04))
        }
    }
    
    private func gradientColors(for theme: String) -> [Color] {
        switch theme {
        case "diwali":
            return [Color(red: 0.95, green: 0.55, blue: 0.15), Color(red: 0.85, green: 0.25, blue: 0.05)]
        case "winter":
            return [Color(red: 0.45, green: 0.75, blue: 0.95), Color(red: 0.15, green: 0.45, blue: 0.75)]
        case "launch":
            return [Color(red: 0.25, green: 0.25, blue: 0.25), Color(red: 0.05, green: 0.05, blue: 0.05)]
        case "vip":
            return [Color(red: 0.55, green: 0.15, blue: 0.75), Color(red: 0.15, green: 0.05, blue: 0.25)]
        case "summer":
            return [Color(red: 0.98, green: 0.80, blue: 0.20), Color(red: 0.95, green: 0.45, blue: 0.05)]
        case "anniversary":
            return [Color(red: 0.95, green: 0.50, blue: 0.65), Color(red: 0.85, green: 0.15, blue: 0.35)]
        case "valentines":
            return [Color(red: 0.95, green: 0.15, blue: 0.25), Color(red: 0.65, green: 0.05, blue: 0.15)]
        default:
            return [Color.gray, Color.black]
        }
    }
    
    private func iconName(for theme: String) -> String {
        switch theme {
        case "diwali": return "sparkles"
        case "winter": return "snowflake"
        case "launch": return "tag.fill"
        case "vip": return "crown.fill"
        case "summer": return "sun.max.fill"
        case "anniversary": return "gift.fill"
        case "valentines": return "heart.fill"
        default: return "megaphone.fill"
        }
    }
    
    private var emptyCampaignState: some View {
        VStack(spacing: 12) {
            Image(systemName: "megaphone.fill")
                .font(.system(size: 44))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            Text("No matching campaigns found.")
                .font(.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

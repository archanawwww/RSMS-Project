import SwiftUI
import Charts

struct OverallPerformanceView: View {
    let selectedCountry: String
    
    @State private var selectedPeriod: Period = .daily
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    // MARK: - Period Enum
    enum Period: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case monthly = "Monthly"
        case quarterly = "Quarterly"
        case yearly = "Yearly"
        
        var id: String { self.rawValue }
    }
    
    // MARK: - Boutique Rank Model
    struct RankedBoutique: Identifiable {
        let id = UUID()
        let name: String
        let location: String
        let revenue: Double
        let growth: String
        let growthValue: Double
        let imageName: String
    }
    
    // MARK: - Chart Data Model
    struct RevenueChartPoint: Identifiable {
        let id = UUID()
        let label: String
        let revenue: Double
    }
    
    // MARK: - Image Names for fallback
    private let imageNames = [" -1", " -2", " -3", " -4", " -5"]
    
    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                // Period Segmented Filter
                periodSelector
                    .padding(.top, 8)
                
                // Total Revenue Card with Line Chart
                totalRevenueCard
                
                // Top Performing Stores Card
                topPerformingStoresCard
            }
            .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
            .padding(.bottom, 32)
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Dashboard")
                    }
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Overall Performance")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    Text(subtitleText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Subtitle text helper
    private var subtitleText: String {
        let countText = selectedCountry == "World" ? "All Stores" : "\(selectedCountry) Stores"
        return "\(countText) • Real-time Overview"
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(Period.allCases) { period in
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedPeriod == period ? .white : MatteTheme.Colors.textSecondary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(selectedPeriod == period ? MatteTheme.Colors.luxuryGold : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.black.opacity(0.04))
        .clipShape(Capsule())
    }
    
    // MARK: - Total Revenue Card
    private var totalRevenueCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Revenue")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    
                    Text(formatCurrency(totalRevenueAmount))
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .contentTransition(.numericText())
                    
                    HStack(spacing: 4) {
                        Text(trendText)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.success)
                        Text(trendPeriodText)
                            .font(.system(size: 12))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            // Custom Line Chart
            revenueLineChart
        }
        .padding(MatteTheme.Spacing.cardPadding)
        .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.xlarge))
    }
    
    // MARK: - Revenue Line Chart
    private var revenueLineChart: some View {
        let data = chartPoints
        let maxVal = data.map { $0.revenue }.max() ?? 1000
        
        return Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Period", point.label),
                    y: .value("Revenue", point.revenue)
                )
                .foregroundStyle(MatteTheme.Colors.luxuryGold)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.monotone)
                
                AreaMark(
                    x: .value("Period", point.label),
                    y: .value("Revenue", point.revenue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            MatteTheme.Colors.luxuryGold.opacity(0.24),
                            MatteTheme.Colors.luxuryGold.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)
                
                PointMark(
                    x: .value("Period", point.label),
                    y: .value("Revenue", point.revenue)
                )
                .symbol {
                    Circle()
                        .stroke(MatteTheme.Colors.luxuryGold, lineWidth: 2.5)
                        .background(Circle().fill(Color.white))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(MatteTheme.Colors.textSecondary)
            }
        }
        .chartYAxis {
            AxisMarks(values: [0.0, maxVal * 0.2, maxVal * 0.4, maxVal * 0.6, maxVal * 0.8, maxVal]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(MatteTheme.Colors.borderLight.opacity(0.5))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(formatChartYAxis(doubleValue))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(MatteTheme.Colors.textTertiary)
                    }
                }
            }
        }
        .frame(height: 200)
    }
    
    // MARK: - Top Performing Stores Card
    private var topPerformingStoresCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Top Performing Stores")
                        .font(MatteTheme.Typography.headline)
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    Text("By Revenue Generated")
                        .font(MatteTheme.Typography.caption)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                NavigationLink(destination: BoutiqueInventoryView(navigationPath: .constant(NavigationPath()))) {
                    HStack(spacing: 2) {
                        Text("View All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 12) {
                let rankedBoutiques = topBoutiquesList
                
                ForEach(Array(rankedBoutiques.enumerated()), id: \.element.id) { index, store in
                    HStack(spacing: 12) {
                        // Rank circle
                        ZStack {
                            Circle()
                                .fill(rankBackgroundColor(for: index + 1))
                                .frame(width: 24, height: 24)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(rankTextColor(for: index + 1))
                        }
                        
                        // Boutique Image
                        Image(store.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
                            )
                        
                        // Name and City/Country
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(MatteTheme.Colors.textPrimary)
                            Text(store.location)
                                .font(.system(size: 11))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Revenue and Growth
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatCurrency(store.revenue))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(MatteTheme.Colors.textPrimary)
                            
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 9, weight: .bold))
                                Text(store.growth)
                            }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.success)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if index < rankedBoutiques.count - 1 {
                        Divider()
                            .background(MatteTheme.Colors.sectionDivider)
                    }
                }
            }
        }
        .padding(MatteTheme.Spacing.cardPadding)
        .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.xlarge))
    }
    
    // MARK: - Rank Styling Helpers
    private func rankBackgroundColor(for rank: Int) -> Color {
        switch rank {
        case 1: return MatteTheme.Colors.luxuryGold
        case 2: return Color.black.opacity(0.12)
        case 3: return MatteTheme.Colors.luxuryGold.opacity(0.3)
        default: return Color.black.opacity(0.04)
        }
    }
    
    private func rankTextColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .white
        case 2: return MatteTheme.Colors.textPrimary
        case 3: return MatteTheme.Colors.textPrimary
        default: return MatteTheme.Colors.textSecondary
        }
    }
    
    // MARK: - Dynamic Data Helpers
    
    private var baseMultiplier: Double {
        switch selectedCountry {
        case "World": return 6.5
        case "India": return 1.0
        case "United States": return 2.5
        case "China": return 4.0
        case "Germany": return 1.2
        case "France": return 1.5
        default: return 1.0
        }
    }
    
    private var totalRevenueAmount: Double {
        let baseAmount: Double
        switch selectedPeriod {
        case .daily: baseAmount = 2458320
        case .monthly: baseAmount = 18542000
        case .quarterly: baseAmount = 54280000
        case .yearly: baseAmount = 215000000
        }
        return baseAmount * baseMultiplier
    }
    
    private var trendText: String {
        switch selectedPeriod {
        case .daily: return "↗ 12.6%"
        case .monthly: return "↗ 15.2%"
        case .quarterly: return "↗ 18.4%"
        case .yearly: return "↗ 20.1%"
        }
    }
    
    private var trendPeriodText: String {
        switch selectedPeriod {
        case .daily: return " vs yesterday"
        case .monthly: return " vs last month"
        case .quarterly: return " vs last quarter"
        case .yearly: return " vs last year"
        }
    }
    
    private var chartPoints: [RevenueChartPoint] {
        let mult = baseMultiplier
        switch selectedPeriod {
        case .daily:
            return [
                RevenueChartPoint(label: "Sat", revenue: 65000 * mult),
                RevenueChartPoint(label: "Sun", revenue: 125000 * mult),
                RevenueChartPoint(label: "Mon", revenue: 130000 * mult),
                RevenueChartPoint(label: "Tue", revenue: 170000 * mult),
                RevenueChartPoint(label: "Wed", revenue: 155000 * mult),
                RevenueChartPoint(label: "Thu", revenue: 195000 * mult),
                RevenueChartPoint(label: "Today", revenue: 245832 * mult)
            ]
        case .monthly:
            return [
                RevenueChartPoint(label: "Jan", revenue: 1420000 * mult),
                RevenueChartPoint(label: "Feb", revenue: 1600000 * mult),
                RevenueChartPoint(label: "Mar", revenue: 1850000 * mult),
                RevenueChartPoint(label: "Apr", revenue: 2010000 * mult),
                RevenueChartPoint(label: "May", revenue: 2250000 * mult),
                RevenueChartPoint(label: "Jun", revenue: 2458320 * mult)
            ]
        case .quarterly:
            return [
                RevenueChartPoint(label: "Q1 25", revenue: 4800000 * mult),
                RevenueChartPoint(label: "Q2 25", revenue: 5200000 * mult),
                RevenueChartPoint(label: "Q3 25", revenue: 5000000 * mult),
                RevenueChartPoint(label: "Q4 25", revenue: 5600000 * mult),
                RevenueChartPoint(label: "Q1 26", revenue: 5900000 * mult),
                RevenueChartPoint(label: "Q2 26", revenue: 6428000 * mult)
            ]
        case .yearly:
            return [
                RevenueChartPoint(label: "2021", revenue: 14500000 * mult),
                RevenueChartPoint(label: "2022", revenue: 16200000 * mult),
                RevenueChartPoint(label: "2023", revenue: 18500000 * mult),
                RevenueChartPoint(label: "2024", revenue: 19800000 * mult),
                RevenueChartPoint(label: "2025", revenue: 21500000 * mult)
            ]
        }
    }
    
    // MARK: - Boutique Loader
    private var topBoutiquesList: [RankedBoutique] {
        let periodRevenue = totalRevenueAmount
        
        let rawBoutiques: [BoutiqueInventoryView.BoutiqueDetail]
        let stores = authManager.supabaseStores
        if stores.isEmpty {
            if selectedCountry == "World" {
                rawBoutiques = BoutiqueInventoryView.sharedCountriesData.flatMap { $0.boutiques }
            } else {
                rawBoutiques = BoutiqueInventoryView.sharedCountriesData.first { $0.name == selectedCountry }?.boutiques ?? []
            }
        } else {
            let allUsers = authManager.users
            let grouped = Dictionary(grouping: stores) { $0.region }
            
            if selectedCountry == "World" {
                rawBoutiques = stores.filter { 
                    !$0.name.lowercased().contains("warehouse") && !$0.name.lowercased().contains("headquarters")
                }.map { store in
                    let managerInfo = BoutiqueInventoryHelper.getManagerInfo(for: store, in: allUsers)
                    let city = store.location ?? ""
                    let code = BoutiqueInventoryHelper.getStoreCode(name: store.name, city: city)
                    return BoutiqueInventoryView.BoutiqueDetail(
                        name: store.name,
                        address: store.address ?? "",
                        city: city,
                        storeCode: code,
                        status: "Active",
                        manager: managerInfo.name,
                        email: managerInfo.email
                    )
                }
            } else {
                let storesInCountry = grouped[selectedCountry] ?? []
                rawBoutiques = storesInCountry.filter { 
                    !$0.name.lowercased().contains("warehouse") && !$0.name.lowercased().contains("headquarters")
                }.map { store in
                    let managerInfo = BoutiqueInventoryHelper.getManagerInfo(for: store, in: allUsers)
                    let city = store.location ?? ""
                    let code = BoutiqueInventoryHelper.getStoreCode(name: store.name, city: city)
                    return BoutiqueInventoryView.BoutiqueDetail(
                        name: store.name,
                        address: store.address ?? "",
                        city: city,
                        storeCode: code,
                        status: "Active",
                        manager: managerInfo.name,
                        email: managerInfo.email
                    )
                }
            }
        }
        
        // Define desired top boutique names for each country to show a diverse, high-performance mix
        let desiredNames: [String]
        switch selectedCountry {
        case "India":
            desiredNames = ["Delhi Boutique II", "Mumbai Boutique I", "Bengaluru Boutique I", "Hyderabad Boutique I", "Chennai Boutique II"]
        case "United States":
            desiredNames = ["New York Boutique I", "Los Angeles Boutique I", "Chicago Boutique I", "Miami Boutique I", "New York Boutique II"]
        case "China":
            desiredNames = ["Beijing Boutique I", "Shanghai Boutique I", "Shenzhen Boutique I", "Beijing Boutique II", "Shanghai Boutique II"]
        case "Germany":
            desiredNames = ["Berlin Boutique I", "Munich Boutique I", "Frankfurt Boutique I", "Hamburg Boutique I", "Berlin Boutique II"]
        case "France":
            desiredNames = ["Paris Boutique I", "Lyon Boutique I", "Marseille Boutique I", "Paris Boutique II", "Lyon Boutique II"]
        default: // World
            desiredNames = ["Delhi Boutique II", "New York Boutique I", "Paris Boutique I", "Beijing Boutique I", "Berlin Boutique I"]
        }
        
        // Filter and order rawBoutiques to match desiredNames
        var orderedBoutiques: [BoutiqueInventoryView.BoutiqueDetail] = []
        for name in desiredNames {
            if let match = rawBoutiques.first(where: { $0.name == name }) {
                orderedBoutiques.append(match)
            }
        }
        
        // If we have fewer than 5, fill in with any remaining rawBoutiques
        for b in rawBoutiques {
            if orderedBoutiques.count >= 5 { break }
            if !orderedBoutiques.contains(where: { $0.storeCode == b.storeCode }) {
                orderedBoutiques.append(b)
            }
        }
        
        let ranksDistribution: [(revenuePercent: Double, growth: String, growthVal: Double)] = [
            (0.223, "15.8%", 15.8),
            (0.176, "12.1%", 12.1),
            (0.153, "11.3%", 11.3),
            (0.121, "9.6%", 9.6),
            (0.100, "8.2%", 8.2)
        ]
        
        var list: [RankedBoutique] = []
        for i in 0..<min(orderedBoutiques.count, 5) {
            let boutique = orderedBoutiques[i]
            let dist = ranksDistribution[i % ranksDistribution.count]
            let storeRevenue = periodRevenue * dist.revenuePercent
            let countryName = countryForBoutique(boutique)
            let location = "\(boutique.city), \(countryName)"
            let imageIndex = i % imageNames.count
            
            list.append(
                RankedBoutique(
                    name: boutique.name,
                    location: location,
                    revenue: storeRevenue,
                    growth: dist.growth,
                    growthValue: dist.growthVal,
                    imageName: imageNames[imageIndex]
                )
            )
        }
        
        return list
    }
    
    private func countryForBoutique(_ boutique: BoutiqueInventoryView.BoutiqueDetail) -> String {
        let stores = authManager.supabaseStores
        if stores.isEmpty {
            for countryData in BoutiqueInventoryView.sharedCountriesData {
                if countryData.boutiques.contains(where: { $0.storeCode == boutique.storeCode }) {
                    return countryData.name
                }
            }
        } else {
            if let matchedStore = stores.first(where: { BoutiqueInventoryHelper.getStoreCode(name: $0.name, city: $0.location ?? "") == boutique.storeCode }) {
                return matchedStore.region
            }
        }
        return "India"
    }
    
    // MARK: - Currency Formatting
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        if selectedCountry == "India" {
            formatter.locale = Locale(identifier: "en_IN")
            // Apply Indian grouping separator explicitly
            if let formatted = formatter.string(from: NSNumber(value: value)) {
                return formatted
            }
            return "₹\(Int(value))"
        } else if selectedCountry == "World" || selectedCountry == "United States" {
            formatter.locale = Locale(identifier: "en_US")
            return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
        } else if selectedCountry == "China" {
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: NSNumber(value: value)) ?? "¥\(Int(value))"
        } else {
            formatter.locale = Locale(identifier: "de_DE")
            return formatter.string(from: NSNumber(value: value)) ?? "€\(Int(value))"
        }
    }
    
    private func formatChartYAxis(_ value: Double) -> String {
        if selectedCountry == "India" {
            let lakhs = value / 100000.0
            if lakhs == 0 { return "0" }
            return String(format: "%.1fL", lakhs)
        } else {
            if value >= 1000000 {
                return String(format: "%.1fM", value / 1000000.0)
            } else if value >= 1000 {
                return String(format: "%.0fK", value / 1000.0)
            } else {
                return String(format: "%.0f", value)
            }
        }
    }
}

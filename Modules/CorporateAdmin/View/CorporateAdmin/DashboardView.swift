import SwiftUI
import Charts
import UserNotifications
import MapKit

// MARK: - Dashboard View (Executive Overview)

/// Tab 0 — The executive dashboard for Corporate Admin.
/// Displays KPIs, charts, quick actions, audit logs, alerts, and notifications.
struct DashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    // Navigation callbacks
    var onNavigateToGovernance: (() -> Void)?
    var onNavigateToCatalog: (() -> Void)?
    var onNavigateToOperations: (() -> Void)?



    // Country & Map state
    @State private var showProfile = false
    @State private var selectedCountry: String = "India"
    @State private var showCountryPicker = false
    @State private var selectedDay: String? = nil

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 22.5937, longitude: 78.9629),
            span: MKCoordinateSpan(latitudeDelta: 26.0, longitudeDelta: 26.0)
        )
    )

    // MARK: - Country Boutique Data

    private struct CountryInfo {
        let name: String
        let flag: String
        let center: CLLocationCoordinate2D
        let span: MKCoordinateSpan
        let boutiques: [BoutiquePin]
        
        var boutiqueCount: Int {
            boutiques.filter { $0.type != .warehouse }.count
        }
    }

    private struct BoutiquePin: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
        let type: PinType
    }

    private enum PinType {
        case warehouse
        case boutique

        var color: Color {
            switch self {
            case .warehouse: return .blue
            case .boutique: return .green
            }
        }

        var icon: String {
            switch self {
            case .warehouse: return "shippingbox.fill"
            case .boutique: return "bag.fill"
            }
        }
    }

    private let countries: [String] = [
        "World", "India", "United States", "China", "Germany", "France"
    ]

    private let countryFlags: [String: String] = [
        "World": "🌍", "India": "🇮🇳", "United States": "🇺🇸", "China": "🇨🇳", "Germany": "🇩🇪",
        "France": "🇫🇷"
    ]

    private func countryInfo(for country: String) -> CountryInfo {
        let stores = authManager.supabaseStores
        if stores.isEmpty {
            switch country {
            case "World":
                let allPins = ["India", "United States", "China", "Germany", "France"].flatMap {
                    countryInfo(for: $0).boutiques
                }
                return CountryInfo(name: "World", flag: "🌍",
                    center: CLLocationCoordinate2D(latitude: 30.0, longitude: 10.0),
                    span: MKCoordinateSpan(latitudeDelta: 140, longitudeDelta: 140),
                    boutiques: allPins)
            case "India":
                return CountryInfo(name: "India", flag: "🇮🇳",
                    center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
                    span: MKCoordinateSpan(latitudeDelta: 22, longitudeDelta: 22),
                    boutiques: [
                        BoutiquePin(name: "India Warehouse", coordinate: CLLocationCoordinate2D(latitude: 20.2760, longitude: 72.8777), type: .warehouse),
                        BoutiquePin(name: "Delhi Boutique I", coordinate: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090), type: .boutique),
                        BoutiquePin(name: "Delhi Boutique II", coordinate: CLLocationCoordinate2D(latitude: 29.8339, longitude: 75.8290), type: .boutique),
                        BoutiquePin(name: "Delhi Boutique III", coordinate: CLLocationCoordinate2D(latitude: 27.2539, longitude: 78.6490), type: .boutique),
                        BoutiquePin(name: "Mumbai Boutique I", coordinate: CLLocationCoordinate2D(latitude: 19.0960, longitude: 72.8977), type: .boutique),
                        BoutiquePin(name: "Mumbai Boutique II", coordinate: CLLocationCoordinate2D(latitude: 17.5160, longitude: 71.5177), type: .boutique),
                        BoutiquePin(name: "Mumbai Boutique III", coordinate: CLLocationCoordinate2D(latitude: 17.5360, longitude: 74.3377), type: .boutique),
                        BoutiquePin(name: "Bengaluru Boutique I", coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), type: .boutique),
                        BoutiquePin(name: "Bengaluru Boutique II", coordinate: CLLocationCoordinate2D(latitude: 11.5916, longitude: 78.9146), type: .boutique),
                        BoutiquePin(name: "Hyderabad Boutique I", coordinate: CLLocationCoordinate2D(latitude: 17.3850, longitude: 78.4867), type: .boutique),
                        BoutiquePin(name: "Hyderabad Boutique II", coordinate: CLLocationCoordinate2D(latitude: 18.7050, longitude: 79.8067), type: .boutique),
                        BoutiquePin(name: "Chennai Boutique I", coordinate: CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707), type: .boutique),
                        BoutiquePin(name: "Chennai Boutique II", coordinate: CLLocationCoordinate2D(latitude: 14.4027, longitude: 81.5907), type: .boutique),
                    ])
            case "United States":
                return CountryInfo(name: "United States", flag: "🇺🇸",
                    center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
                    span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40),
                    boutiques: [
                        BoutiquePin(name: "United States Warehouse", coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), type: .warehouse),
                        BoutiquePin(name: "New York Boutique I", coordinate: CLLocationCoordinate2D(latitude: 40.7328, longitude: -73.9860), type: .boutique),
                        BoutiquePin(name: "New York Boutique II", coordinate: CLLocationCoordinate2D(latitude: 40.7528, longitude: -73.9660), type: .boutique),
                        BoutiquePin(name: "Los Angeles Boutique I", coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), type: .boutique),
                        BoutiquePin(name: "Los Angeles Boutique II", coordinate: CLLocationCoordinate2D(latitude: 34.0722, longitude: -118.2237), type: .boutique),
                        BoutiquePin(name: "Chicago Boutique I", coordinate: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298), type: .boutique),
                        BoutiquePin(name: "Miami Boutique I", coordinate: CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918), type: .boutique),
                    ])
            case "China":
                return CountryInfo(name: "China", flag: "🇨🇳",
                    center: CLLocationCoordinate2D(latitude: 35.8617, longitude: 104.1954),
                    span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30),
                    boutiques: [
                        BoutiquePin(name: "China Warehouse", coordinate: CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737), type: .warehouse),
                        BoutiquePin(name: "Beijing Boutique I", coordinate: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074), type: .boutique),
                        BoutiquePin(name: "Beijing Boutique II", coordinate: CLLocationCoordinate2D(latitude: 39.9242, longitude: 116.4274), type: .boutique),
                        BoutiquePin(name: "Shanghai Boutique I", coordinate: CLLocationCoordinate2D(latitude: 31.2504, longitude: 121.4937), type: .boutique),
                        BoutiquePin(name: "Shanghai Boutique II", coordinate: CLLocationCoordinate2D(latitude: 31.2704, longitude: 121.5137), type: .boutique),
                        BoutiquePin(name: "Shenzhen Boutique I", coordinate: CLLocationCoordinate2D(latitude: 22.5431, longitude: 114.0579), type: .boutique),
                    ])
            case "Germany":
                return CountryInfo(name: "Germany", flag: "🇩🇪",
                    center: CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515),
                    span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8),
                    boutiques: [
                        BoutiquePin(name: "Germany Warehouse", coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050), type: .warehouse),
                        BoutiquePin(name: "Berlin Boutique I", coordinate: CLLocationCoordinate2D(latitude: 52.5400, longitude: 13.4250), type: .boutique),
                        BoutiquePin(name: "Berlin Boutique II", coordinate: CLLocationCoordinate2D(latitude: 52.5600, longitude: 13.4450), type: .boutique),
                        BoutiquePin(name: "Berlin Boutique III", coordinate: CLLocationCoordinate2D(latitude: 52.5800, longitude: 13.4650), type: .boutique),
                        BoutiquePin(name: "Munich Boutique I", coordinate: CLLocationCoordinate2D(latitude: 48.1351, longitude: 11.5820), type: .boutique),
                        BoutiquePin(name: "Munich Boutique II", coordinate: CLLocationCoordinate2D(latitude: 48.1551, longitude: 11.6020), type: .boutique),
                        BoutiquePin(name: "Frankfurt Boutique I", coordinate: CLLocationCoordinate2D(latitude: 50.1109, longitude: 8.6821), type: .boutique),
                        BoutiquePin(name: "Frankfurt Boutique II", coordinate: CLLocationCoordinate2D(latitude: 50.1309, longitude: 8.7021), type: .boutique),
                        BoutiquePin(name: "Hamburg Boutique I", coordinate: CLLocationCoordinate2D(latitude: 53.5511, longitude: 9.9937), type: .boutique),
                    ])
            case "France":
                return CountryInfo(name: "France", flag: "🇫🇷",
                    center: CLLocationCoordinate2D(latitude: 46.6034, longitude: 1.8883),
                    span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10),
                    boutiques: [
                        BoutiquePin(name: "France Warehouse", coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), type: .warehouse),
                        BoutiquePin(name: "Paris Boutique I", coordinate: CLLocationCoordinate2D(latitude: 48.8766, longitude: 2.3722), type: .boutique),
                        BoutiquePin(name: "Paris Boutique II", coordinate: CLLocationCoordinate2D(latitude: 48.8966, longitude: 2.3922), type: .boutique),
                        BoutiquePin(name: "Paris Boutique III", coordinate: CLLocationCoordinate2D(latitude: 48.9166, longitude: 2.4122), type: .boutique),
                        BoutiquePin(name: "Lyon Boutique I", coordinate: CLLocationCoordinate2D(latitude: 45.7640, longitude: 4.8357), type: .boutique),
                        BoutiquePin(name: "Lyon Boutique II", coordinate: CLLocationCoordinate2D(latitude: 45.7840, longitude: 4.8557), type: .boutique),
                        BoutiquePin(name: "Marseille Boutique I", coordinate: CLLocationCoordinate2D(latitude: 43.2965, longitude: 5.3698), type: .boutique),
                    ])
            default:
                return CountryInfo(name: "India", flag: "🇮🇳",
                    center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
                    span: MKCoordinateSpan(latitudeDelta: 22, longitudeDelta: 22),
                    boutiques: [])
            }
        }
        
        let flag = BoutiqueInventoryHelper.flagEmoji(for: country)
        let centerAndSpan: (center: CLLocationCoordinate2D, span: MKCoordinateSpan)
        let boutiques: [BoutiquePin]
        
        if country == "World" {
            centerAndSpan = (CLLocationCoordinate2D(latitude: 30.0, longitude: 10.0), MKCoordinateSpan(latitudeDelta: 140, longitudeDelta: 140))
            boutiques = stores.map { store in
                let type: PinType = store.name.lowercased().contains("warehouse") ? .warehouse : .boutique
                return BoutiquePin(name: store.name, coordinate: BoutiqueInventoryHelper.getCoordinate(forStore: store), type: type)
            }
        } else {
            switch country {
            case "India":
                centerAndSpan = (CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629), MKCoordinateSpan(latitudeDelta: 22, longitudeDelta: 22))
            case "United States":
                centerAndSpan = (CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40))
            case "China":
                centerAndSpan = (CLLocationCoordinate2D(latitude: 35.8617, longitude: 104.1954), MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30))
            case "Germany":
                centerAndSpan = (CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515), MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8))
            case "France":
                centerAndSpan = (CLLocationCoordinate2D(latitude: 46.6034, longitude: 1.8883), MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
            default:
                centerAndSpan = (CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629), MKCoordinateSpan(latitudeDelta: 22, longitudeDelta: 22))
            }
            
            let grouped = Dictionary(grouping: stores) { $0.region }
            let storesInCountry = grouped[country] ?? []
            boutiques = storesInCountry.map { store in
                let type: PinType = store.name.lowercased().contains("warehouse") ? .warehouse : .boutique
                return BoutiquePin(name: store.name, coordinate: BoutiqueInventoryHelper.getCoordinate(forStore: store), type: type)
            }
        }
        
        return CountryInfo(
            name: country,
            flag: flag,
            center: centerAndSpan.center,
            span: centerAndSpan.span,
            boutiques: boutiques
        )
    }

    // MARK: - Revenue Chart Data

    private struct RevenueData: Identifiable {
        let id = UUID()
        let month: String
        let actual: Double
        let target: Double
    }

    private let revenueData = [
        RevenueData(month: "Jan", actual: 14.2, target: 15.0),
        RevenueData(month: "Feb", actual: 16.0, target: 15.5),
        RevenueData(month: "Mar", actual: 18.5, target: 17.0),
        RevenueData(month: "Apr", actual: 20.1, target: 19.5),
        RevenueData(month: "May", actual: 22.5, target: 21.0),
        RevenueData(month: "Jun", actual: 24.5, target: 22.0),
        RevenueData(month: "Jul", actual: 23.0, target: 24.0),
        RevenueData(month: "Aug", actual: 25.5, target: 25.0),
        RevenueData(month: "Sep", actual: 28.0, target: 26.5),
        RevenueData(month: "Oct", actual: 26.5, target: 28.0),
        RevenueData(month: "Nov", actual: 29.0, target: 28.5),
        RevenueData(month: "Dec", actual: 32.5, target: 30.0)
    ]

    private struct MTDRevenueData: Identifiable {
        let id = UUID()
        let day: String
        let revenue: Double
        let target: Double
    }

    private let mtdRevenueData = [
        MTDRevenueData(day: "1 Jun", revenue: 1.2, target: 1.0),
        MTDRevenueData(day: "4 Jun", revenue: 1.8, target: 1.5),
        MTDRevenueData(day: "7 Jun", revenue: 2.4, target: 2.0),
        MTDRevenueData(day: "10 Jun", revenue: 2.1, target: 2.2),
        MTDRevenueData(day: "13 Jun", revenue: 2.5, target: 2.4),
        MTDRevenueData(day: "16 Jun", revenue: 1.9, target: 2.1),
        MTDRevenueData(day: "19 Jun", revenue: 2.3, target: 2.3),
        MTDRevenueData(day: "22 Jun", revenue: 2.8, target: 2.6),
        MTDRevenueData(day: "25 Jun", revenue: 2.0, target: 2.5),
        MTDRevenueData(day: "28 Jun", revenue: 2.6, target: 2.8),
        MTDRevenueData(day: "30 Jun", revenue: 3.21, target: 3.0)
    ]

    // MARK: - Daily Sales Data (Weekly Chart)

    private struct DailySalesData: Identifiable {
        let id = UUID()
        let day: String
        let actual: Double
        let target: Double
    }

    private let dailySalesData = [
        DailySalesData(day: "Mon", actual: 6.2, target: 8.0),
        DailySalesData(day: "Tue", actual: 7.8, target: 8.0),
        DailySalesData(day: "Wed", actual: 8.5, target: 8.0),
        DailySalesData(day: "Thu", actual: 9.2, target: 10.0),
        DailySalesData(day: "Fri", actual: 12.0, target: 12.0),
        DailySalesData(day: "Sat", actual: 18.5, target: 20.0),
        DailySalesData(day: "Sun", actual: 21.0, target: 19.0)
    ]



    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MatteTheme.Colors.dashboardBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        kpiGrid
                        salesPerformanceChart
                        inventoryHealthCard
                        boutiquesMapCard
                    }
                    .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
                
                // Blurred top status bar overlay
                Color.clear
                    .frame(height: 60)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    globalCountrySelector
                }
            }
            .profileToolbar(showProfile: $showProfile)
            .sheet(isPresented: $showCountryPicker) {
                countryPickerSheet
            }
        }
    }

    // MARK: - Global Country Selector
    private var globalCountrySelector: some View {
        Button {
            showCountryPicker = true
        } label: {
            HStack(spacing: 6) {
                Text(countryFlags[selectedCountry] ?? "🌍")
                    .font(.system(size: 14))
                Text(selectedCountry == "World" ? "World" : selectedCountry)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
    }

    // MARK: - KPI Grid

    private func kpiData(for country: String) -> (revenue: String, revTrend: String, warehouses: String) {
        switch country {
        case "World":
            return ("$185.5 M", "↑ 15.2% MoM", "5")
        case "India":
            return ("₹24.5 Cr", "↑ 12.4% MoM", "1")
        case "United States":
            return ("$42.8 M", "↑ 10.1% MoM", "1")
        case "China":
            return ("¥145.2 M", "↑ 18.3% MoM", "1")
        case "Germany":
            return ("€18.4 M", "↑ 4.2% MoM", "1")
        case "France":
            return ("€22.1 M", "↑ 7.8% MoM", "1")
        default:
            return ("$0", "-", "0")
        }
    }

    private func salesPerformanceContext(for country: String) -> (total: String, change: String, prefix: String, suffix: String, maxVal: Double, data: [MTDRevenueData]) {
        let baseData = mtdRevenueData
        let multiplier: Double
        let prefix: String
        let suffix: String
        let maxVal: Double
        
        switch country {
        case "World": multiplier = 6.5; prefix = "$"; suffix = "M"; maxVal = 24.0
        case "India": multiplier = 1.0; prefix = "₹"; suffix = "Cr"; maxVal = 4.0
        case "United States": multiplier = 2.5; prefix = "$"; suffix = "M"; maxVal = 10.0
        case "China": multiplier = 4.0; prefix = "¥"; suffix = "M"; maxVal = 16.0
        case "Germany": multiplier = 1.2; prefix = "€"; suffix = "M"; maxVal = 6.0
        case "France": multiplier = 1.5; prefix = "€"; suffix = "M"; maxVal = 6.0
        default: multiplier = 1.0; prefix = ""; suffix = ""; maxVal = 4.0
        }
        
        let adjustedData = baseData.map {
            MTDRevenueData(day: $0.day, revenue: $0.revenue * multiplier, target: $0.target * multiplier)
        }
        let total = adjustedData.last?.revenue ?? 0
        let totalString = String(format: "\(prefix)%.2f %@", total, country == "India" ? "Crore" : suffix)
        
        return (totalString, "18.4%", prefix, suffix, maxVal, adjustedData)
    }

    private func inventoryHealthData(for country: String) -> (health: String, transfers: String, variances: String) {
        switch country {
        case "World": return ("92%", "45", "12")
        case "India": return ("87%", "5", "2")
        case "United States": return ("95%", "12", "1")
        case "China": return ("91%", "18", "4")
        case "Germany": return ("89%", "4", "2")
        case "France": return ("94%", "6", "3")
        default: return ("0%", "0", "0")
        }
    }

    private var kpiGrid: some View {
        let kpi = kpiData(for: selectedCountry)
        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            kpiCard(
                icon: "banknote",
                title: "Revenue",
                value: kpi.revenue,
                trend: kpi.revTrend,
                trendColor: MatteTheme.Colors.success,
                accentColor: MatteTheme.Colors.luxuryGold
            )

            kpiCard(
                icon: "building.fill",
                title: selectedCountry == "World" ? "Total Warehouses" : "Warehouse in \(selectedCountry)",
                value: kpi.warehouses,
                trend: "● Fully Operational",
                trendColor: MatteTheme.Colors.success,
                accentColor: MatteTheme.Colors.info
            )

            let info = countryInfo(for: selectedCountry)
            kpiCard(
                icon: "building.2.fill",
                title: "Active Boutiques",
                value: "\(info.boutiqueCount)",
                trend: "● In \(selectedCountry)",
                trendColor: MatteTheme.Colors.success,
                accentColor: MatteTheme.Colors.accent
            )

            kpiCard(
                icon: "shippingbox.fill",
                title: "Products",
                value: "\(authManager.productMasterRecords.count)",
                trend: "\(authManager.productMasterRecords.filter { $0.isActive }.count) active",
                trendColor: MatteTheme.Colors.primaryGold,
                accentColor: MatteTheme.Colors.success
            )
        }
    }

    private func kpiCard(icon: String, title: String, value: String, trend: String, trendColor: Color, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 34, height: 34)
                    .background(accentColor.opacity(0.12))
                    .clipShape(Circle())
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .contentTransition(.numericText())
                    .font(MatteTheme.Typography.kpiValue)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }

            Text(trend)
                .font(MatteTheme.Typography.metricLabel)
                .foregroundColor(trendColor)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.large))
    }

    // MARK: - Sales Performance Chart

    private var salesPerformanceChart: some View {
        let context = salesPerformanceContext(for: selectedCountry)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                    Text("Sales Performance")
                        .font(MatteTheme.Typography.sectionHeader)
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                }
                Spacer()
                NavigationLink(destination: LazyView { OverallPerformanceView(selectedCountry: selectedCountry) }) {
                    HStack(spacing: 4) {
                        Text("View All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .glassEffect(.regular, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOTAL REVENUE (MTD)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(context.total)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 144/255, green: 226/255, blue: 156/255))
                        Text(context.change)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(red: 144/255, green: 226/255, blue: 156/255))
                        Text("vs May 2025")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Chart {
                    ForEach(context.data) { data in
                        BarMark(
                            x: .value("Day", data.day),
                            y: .value("Revenue", data.revenue)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(4)
                        
                        // Keeping the annotation on the last bar as before
                        if selectedDay == nil && data.day == "30 Jun" {
                            BarMark(
                                x: .value("Day", data.day),
                                y: .value("Revenue", data.revenue)
                            )
                            .foregroundStyle(.clear)
                            .annotation(position: .top) {
                                Text("\(context.prefix)\(String(format: "%.2f", data.revenue)) \(context.suffix)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 2)
                            }
                        }
                    }
                    
                    if let selectedDay, let data = context.data.first(where: { $0.day == selectedDay }) {
                        RuleMark(x: .value("Selected Day", selectedDay))
                            .foregroundStyle(Color.white.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(data.day)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Actual: \(context.prefix)\(String(format: "%.2f", data.revenue)) \(context.suffix)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Target: \(context.prefix)\(String(format: "%.2f", data.target)) \(context.suffix)")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.85))
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                            }
                    }
                }
                .chartXSelection(value: $selectedDay)
                .chartYAxis {
                    AxisMarks(values: [0.0, context.maxVal / 2, context.maxVal]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.15))
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                let label = doubleValue == 0.0 ? "0" : "\(Int(doubleValue)) \(context.suffix)"
                                Text(label)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: ["1 Jun", "10 Jun", "20 Jun", "30 Jun"]) { value in
                        AxisValueLabel()
                            .font(.system(size: 10))
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                }
                .frame(height: 160)
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 165/255, green: 128/255, blue: 78/255),
                        Color(red: 104/255, green: 79/255, blue: 45/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
        }
    }

    // MARK: - Inventory Health Card

    private var inventoryHealthCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(MatteTheme.Colors.success)
                Text("Inventory Health")
                    .font(MatteTheme.Typography.sectionHeader)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Spacer()
                Button(action: { onNavigateToOperations?() }) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 14) {
                let healthData = inventoryHealthData(for: selectedCountry)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    inventoryMetric(label: "Stock Health", value: healthData.health, color: MatteTheme.Colors.success)
                    inventoryMetric(label: "Transfers", value: healthData.transfers, color: MatteTheme.Colors.warning)
                    inventoryMetric(label: "Variances", value: healthData.variances, color: MatteTheme.Colors.error)
                }
            }
            .padding(MatteTheme.Spacing.cardPadding)
            .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.large))
        }
    }

    private func inventoryMetric(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .contentTransition(.numericText())
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }



    // MARK: - Country Picker Sheet

    private var countryPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(countries, id: \.self) { country in
                    Button {
                        selectedCountry = country
                        let info = countryInfo(for: country)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            cameraPosition = .region(
                                MKCoordinateRegion(center: info.center, span: info.span)
                            )
                        }
                        showCountryPicker = false
                    } label: {
                        HStack(spacing: 14) {
                            Text(countryFlags[country] ?? "🌍")
                                .font(.system(size: 28))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(country)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(MatteTheme.Colors.textPrimary)
                                let info = countryInfo(for: country)
                                Text("\(info.boutiques.filter { $0.type != .warehouse }.count) Boutiques · 1 Warehouse")
                                    .font(.system(size: 12))
                                    .foregroundColor(MatteTheme.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            if selectedCountry == country {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Select Region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showCountryPicker = false
                    }
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Boutiques Map Card

    private var boutiquesMapCard: some View {
        let info = countryInfo(for: selectedCountry)
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                Text("Boutique Locations")
                    .font(MatteTheme.Typography.sectionHeader)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 14) {
            // Legend
            HStack(spacing: 14) {
                legendItem(color: .blue, text: "Warehouse")
                legendItem(color: .green, text: "Boutique")
                Spacer()
            }
            .padding(.bottom, 2)

            ZStack(alignment: .bottomTrailing) {
                Map(position: $cameraPosition) {
                    ForEach(info.boutiques) { pin in
                        Annotation(pin.name, coordinate: pin.coordinate) {
                            let cityName = pin.name.replacingOccurrences(of: " Boutique", with: "").replacingOccurrences(of: " Warehouse", with: "")
                            let boutiqueDetail = BoutiqueInventoryView.BoutiqueDetail(
                                name: pin.name,
                                address: "Location on map",
                                city: cityName,
                                storeCode: "LM-\(cityName.prefix(3).uppercased())-MAP",
                                status: "Active",
                                manager: "Sarah Williams",
                                email: "manager@luxemaison.com"
                            )
                            
                            let pinView = VStack(spacing: 2) {
                                Image(systemName: pin.type.icon)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(pin.type.color)
                                    .clipShape(Circle())
                                    .shadow(color: pin.type.color.opacity(0.4), radius: 4, y: 2)
                                
                                Text(pin.name)
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundColor(MatteTheme.Colors.textPrimary)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.95))
                                    .cornerRadius(4)
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
                            }
                            
                            if pin.type == .warehouse, let countryData = BoutiqueInventoryView.sharedCountriesData.first(where: { $0.name == selectedCountry }) {
                                NavigationLink(destination: CountryDetailView(selectedSegment: 1, country: countryData)) {
                                    pinView
                                }
                                .buttonStyle(.plain)
                            } else {
                                NavigationLink(destination: BoutiqueDetailView(boutique: boutiqueDetail)) {
                                    pinView
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .frame(height: 260)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }

                // Compact Apple-style Zoom and Recenter Controls
                VStack(spacing: 4) {
                    Button(action: { zoomIn() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .frame(width: 26, height: 26)
                            .background(Color.white.opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(color: Color.black.opacity(0.12), radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)

                    Button(action: { zoomOut() }) {
                        Image(systemName: "minus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .frame(width: 26, height: 26)
                            .background(Color.white.opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(color: Color.black.opacity(0.12), radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { resetToCountry(selectedCountry) }) {
                        Image(systemName: "scope")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .frame(width: 26, height: 26)
                            .background(Color.white.opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(color: Color.black.opacity(0.12), radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)
                }
                .padding(8)
            }
            }
            .padding(MatteTheme.Spacing.cardPadding)
            .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.large))
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("FocusInventoryOnMap"))) { notification in
                if let userInfo = notification.userInfo,
                   let countryName = userInfo["country"] as? String,
                   let inventoryName = userInfo["name"] as? String {
                    self.selectedCountry = countryName
                    let info = countryInfo(for: countryName)
                    if let pin = info.boutiques.first(where: { $0.name.localizedCaseInsensitiveContains(inventoryName) || inventoryName.localizedCaseInsensitiveContains($0.name) }) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: pin.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    private func zoomIn() {
        if let region = cameraPosition.region {
            let newSpan = MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta * 0.5,
                longitudeDelta: region.span.longitudeDelta * 0.5
            )
            withAnimation(.easeOut(duration: 0.3)) {
                cameraPosition = .region(MKCoordinateRegion(center: region.center, span: newSpan))
            }
        } else {
            let info = countryInfo(for: selectedCountry)
            let newSpan = MKCoordinateSpan(
                latitudeDelta: info.span.latitudeDelta * 0.5,
                longitudeDelta: info.span.longitudeDelta * 0.5
            )
            withAnimation(.easeOut(duration: 0.3)) {
                cameraPosition = .region(MKCoordinateRegion(center: info.center, span: newSpan))
            }
        }
    }

    private func zoomOut() {
        if let region = cameraPosition.region {
            let newSpan = MKCoordinateSpan(
                latitudeDelta: min(region.span.latitudeDelta * 2.0, 150.0),
                longitudeDelta: min(region.span.longitudeDelta * 2.0, 150.0)
            )
            withAnimation(.easeOut(duration: 0.3)) {
                cameraPosition = .region(MKCoordinateRegion(center: region.center, span: newSpan))
            }
        } else {
            let info = countryInfo(for: selectedCountry)
            let newSpan = MKCoordinateSpan(
                latitudeDelta: min(info.span.latitudeDelta * 2.0, 150.0),
                longitudeDelta: min(info.span.longitudeDelta * 2.0, 150.0)
            )
            withAnimation(.easeOut(duration: 0.3)) {
                cameraPosition = .region(MKCoordinateRegion(center: info.center, span: newSpan))
            }
        }
    }

    private func resetToCountry(_ country: String) {
        let info = countryInfo(for: country)
        withAnimation(.easeOut(duration: 0.3)) {
            cameraPosition = .region(MKCoordinateRegion(center: info.center, span: info.span))
        }
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
    }

    // MARK: - Helpers

    private var adminName: String {
        if let user = authManager.currentUser {
            let name = user.displayName
            return name.isEmpty ? user.username : name
        }
        return "Corporate Admin"
    }



    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

}

// MARK: - Lazy View Wrapper for SwiftUI Navigation Links
struct LazyView<Content: View>: View {
    let build: () -> Content
    var body: Content {
        build()
    }
}

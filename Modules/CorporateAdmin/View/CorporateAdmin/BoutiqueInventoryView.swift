import SwiftUI
import Charts

// MARK: - Navigation Routes
/// Single, value-based routing for the whole Boutiques/Inventory feature.
/// Using one consistent mechanism (NavigationLink(value:) + a single
/// navigationDestination) avoids the erratic behaviour SwiftUI exhibits when
/// link-based and item/value-based navigation are mixed in the same stack.
enum BoutiqueRoute: Hashable {
    case allCountries
    case country(BoutiqueInventoryView.CountryData)
    case boutique(BoutiqueInventoryView.BoutiqueDetail)
}

// MARK: - Boutiques & Inventory Hub View
struct BoutiqueInventoryView: View {
    @Binding var navigationPath: NavigationPath
    @State private var selectedSegment = 0 // 0 = Boutiques, 1 = Inventory
    @State private var searchText = ""
    @State private var showFilters = false
    @EnvironmentObject var authManager: AuthenticationManager


    // Country Data Models
    struct CountryData: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let flag: String
        let boutiqueCount: Int
        let boutiques: [BoutiqueDetail]
        let inventories: [InventoryDetail]

        static func == (lhs: CountryData, rhs: CountryData) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    struct BoutiqueDetail: Identifiable, Equatable, Hashable {
        var id: String { storeCode }
        let name: String
        let address: String
        let city: String
        let storeCode: String
        let status: String // "Active", "Under Review"
        let manager: String
        let email: String
    }

    struct InventoryDetail: Identifiable {
        let id = UUID()
        let name: String
        let stockLevel: String // "Optimal", "Low Stock", "High Stock"
        let totalItems: Int
        let valuation: String
    }

    // Static sample data matching screenshots and user prompt
    static let sharedCountriesData: [CountryData] = [
        CountryData(
            name: "India", flag: "🇮🇳", boutiqueCount: 12,
            boutiques: [
                BoutiqueDetail(name: "Delhi Boutique I", address: "Connaught Place, New Delhi, Delhi, India", city: "Delhi", storeCode: "LM-DEL-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-del-001@luxemaison.com"),
                BoutiqueDetail(name: "Delhi Boutique II", address: "Khan Market, New Delhi, Delhi, India", city: "Delhi", storeCode: "LM-DEL-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-del-002@luxemaison.com"),
                BoutiqueDetail(name: "Delhi Boutique III", address: "Select Citywalk, Saket, New Delhi, Delhi, India", city: "Delhi", storeCode: "LM-DEL-003", status: "Active", manager: "Sarah Williams", email: "manager.lm-del-003@luxemaison.com"),
                BoutiqueDetail(name: "Mumbai Boutique I", address: "Bandra Kurla Complex (BKC), Mumbai, Maharashtra, India", city: "Mumbai", storeCode: "LM-MUM-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-mum-001@luxemaison.com"),
                BoutiqueDetail(name: "Mumbai Boutique II", address: "Palladium Mall, Lower Parel, Mumbai, Maharashtra, India", city: "Mumbai", storeCode: "LM-MUM-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-mum-002@luxemaison.com"),
                BoutiqueDetail(name: "Mumbai Boutique III", address: "Jio World Drive, BKC, Mumbai, Maharashtra, India", city: "Mumbai", storeCode: "LM-MUM-003", status: "Active", manager: "Sarah Williams", email: "manager.lm-mum-003@luxemaison.com"),
                BoutiqueDetail(name: "Bengaluru Boutique I", address: "MG Road, Bengaluru, Karnataka, India", city: "Bengaluru", storeCode: "LM-BEN-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-ben-001@luxemaison.com"),
                BoutiqueDetail(name: "Bengaluru Boutique II", address: "Indiranagar 100 Feet Road, Bengaluru, Karnataka, India", city: "Bengaluru", storeCode: "LM-BEN-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-ben-002@luxemaison.com"),
                BoutiqueDetail(name: "Hyderabad Boutique I", address: "Banjara Hills, Hyderabad, Telangana, India", city: "Hyderabad", storeCode: "LM-HYD-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-hyd-001@luxemaison.com"),
                BoutiqueDetail(name: "Hyderabad Boutique II", address: "Jubilee Hills, Hyderabad, Telangana, India", city: "Hyderabad", storeCode: "LM-HYD-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-hyd-002@luxemaison.com"),
                BoutiqueDetail(name: "Chennai Boutique I", address: "Nungambakkam High Road, Chennai, Tamil Nadu, India", city: "Chennai", storeCode: "LM-CHE-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-che-001@luxemaison.com"),
                BoutiqueDetail(name: "Chennai Boutique II", address: "Express Avenue Mall, Royapettah, Chennai, Tamil Nadu, India", city: "Chennai", storeCode: "LM-CHE-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-che-002@luxemaison.com")
            ],
            inventories: [
                InventoryDetail(name: "India Warehouse", stockLevel: "Optimal", totalItems: 14200, valuation: "₹12.5 Cr")
            ]
        ),
        CountryData(
            name: "United States", flag: "🇺🇸", boutiqueCount: 6,
            boutiques: [
                BoutiqueDetail(name: "New York Boutique I", address: "Fifth Avenue, Manhattan, New York, NY", city: "New York", storeCode: "LM-YOR-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-yor-001@luxemaison.com"),
                BoutiqueDetail(name: "New York Boutique II", address: "SoHo, Manhattan, New York, NY", city: "New York", storeCode: "LM-YOR-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-yor-002@luxemaison.com"),
                BoutiqueDetail(name: "Los Angeles Boutique I", address: "Rodeo Drive, Beverly Hills, California", city: "Los Angeles", storeCode: "LM-LOS-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-los-001@luxemaison.com"),
                BoutiqueDetail(name: "Los Angeles Boutique II", address: "The Grove, Los Angeles, California", city: "Los Angeles", storeCode: "LM-LOS-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-los-002@luxemaison.com"),
                BoutiqueDetail(name: "Chicago Boutique I", address: "Magnificent Mile, Chicago, Illinois", city: "Chicago", storeCode: "LM-CHI-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-chi-001@luxemaison.com"),
                BoutiqueDetail(name: "Miami Boutique I", address: "Design District, Miami, Florida", city: "Miami", storeCode: "LM-MIA-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-mia-001@luxemaison.com")
            ],
            inventories: [
                InventoryDetail(name: "United States Warehouse", stockLevel: "Optimal", totalItems: 15400, valuation: "$13.5 M")
            ]
        ),
        CountryData(
            name: "China", flag: "🇨🇳", boutiqueCount: 5,
            boutiques: [
                BoutiqueDetail(name: "Beijing Boutique I", address: "Wangfujing Street, Beijing", city: "Beijing", storeCode: "LM-BEI-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-bei-001@luxemaison.com"),
                BoutiqueDetail(name: "Beijing Boutique II", address: "Sanlitun, Chaoyang District, Beijing", city: "Beijing", storeCode: "LM-BEI-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-bei-002@luxemaison.com"),
                BoutiqueDetail(name: "Shanghai Boutique I", address: "Nanjing Road, Shanghai", city: "Shanghai", storeCode: "LM-SHA-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-sha-001@luxemaison.com"),
                BoutiqueDetail(name: "Shanghai Boutique II", address: "Xintiandi, Shanghai", city: "Shanghai", storeCode: "LM-SHA-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-sha-002@luxemaison.com"),
                BoutiqueDetail(name: "Shenzhen Boutique I", address: "MixC Shopping Mall, Shenzhen", city: "Shenzhen", storeCode: "LM-SHE-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-she-001@luxemaison.com")
            ],
            inventories: [
                InventoryDetail(name: "China Warehouse", stockLevel: "Optimal", totalItems: 18500, valuation: "CN¥92.5 M")
            ]
        ),
        CountryData(
            name: "Germany", flag: "🇩🇪", boutiqueCount: 8,
            boutiques: [
                BoutiqueDetail(name: "Berlin Boutique I", address: "Kurfürstendamm, Berlin", city: "Berlin", storeCode: "LM-BER-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-ber-001@luxemaison.com"),
                BoutiqueDetail(name: "Berlin Boutique II", address: "Friedrichstraße, Berlin", city: "Berlin", storeCode: "LM-BER-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-ber-002@luxemaison.com"),
                BoutiqueDetail(name: "Berlin Boutique III", address: "Potsdamer Platz, Berlin", city: "Berlin", storeCode: "LM-BER-003", status: "Active", manager: "Sarah Williams", email: "manager.lm-ber-003@luxemaison.com"),
                BoutiqueDetail(name: "Munich Boutique I", address: "Maximilianstraße, Munich", city: "Munich", storeCode: "LM-MUN-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-mun-001@luxemaison.com"),
                BoutiqueDetail(name: "Munich Boutique II", address: "Marienplatz, Munich", city: "Munich", storeCode: "LM-MUN-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-mun-002@luxemaison.com"),
                BoutiqueDetail(name: "Frankfurt Boutique I", address: "Goethestraße, Frankfurt", city: "Frankfurt", storeCode: "LM-FRA-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-fra-001@luxemaison.com"),
                BoutiqueDetail(name: "Frankfurt Boutique II", address: "Zeil Shopping District, Frankfurt", city: "Frankfurt", storeCode: "LM-FRA-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-fra-002@luxemaison.com"),
                BoutiqueDetail(name: "Hamburg Boutique I", address: "Neuer Wall, Hamburg", city: "Hamburg", storeCode: "LM-HAM-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-ham-001@luxemaison.com")
            ],
            inventories: [
                InventoryDetail(name: "Germany Warehouse", stockLevel: "Optimal", totalItems: 11000, valuation: "€9.2 M")
            ]
        ),
        CountryData(
            name: "France", flag: "🇫🇷", boutiqueCount: 6,
            boutiques: [
                BoutiqueDetail(name: "Paris Boutique I", address: "Champs-Élysées, Paris", city: "Paris", storeCode: "LM-PAR-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-par-001@luxemaison.com"),
                BoutiqueDetail(name: "Paris Boutique II", address: "Avenue Montaigne, Paris", city: "Paris", storeCode: "LM-PAR-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-par-002@luxemaison.com"),
                BoutiqueDetail(name: "Paris Boutique III", address: "Le Marais, Paris", city: "Paris", storeCode: "LM-PAR-003", status: "Active", manager: "Sarah Williams", email: "manager.lm-par-003@luxemaison.com"),
                BoutiqueDetail(name: "Lyon Boutique I", address: "Rue de la République, Lyon", city: "Lyon", storeCode: "LM-LYO-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-lyo-001@luxemaison.com"),
                BoutiqueDetail(name: "Lyon Boutique II", address: "Part-Dieu District, Lyon", city: "Lyon", storeCode: "LM-LYO-002", status: "Active", manager: "Sarah Williams", email: "manager.lm-lyo-002@luxemaison.com"),
                BoutiqueDetail(name: "Marseille Boutique I", address: "Rue Saint-Ferréol, Marseille", city: "Marseille", storeCode: "LM-MAR-001", status: "Active", manager: "Sarah Williams", email: "manager.lm-mar-001@luxemaison.com")
            ],
            inventories: [
                InventoryDetail(name: "France Warehouse", stockLevel: "Optimal", totalItems: 19500, valuation: "€17.4 M")
            ]
        )
    ]
    
    var countriesData: [CountryData] {
        let stores = authManager.supabaseStores
        if stores.isEmpty {
            return Self.sharedCountriesData
        }
        
        let allUsers = authManager.users
        let grouped = Dictionary(grouping: stores) { $0.region }
        
        let sortedCountries = ["India", "United States", "China", "Germany", "France", "Italy", "Australia", "UAE", "Japan", "United Kingdom"]
        
        var result: [CountryData] = []
        for countryName in sortedCountries {
            guard let storesInCountry = grouped[countryName], !storesInCountry.isEmpty else { continue }
            
            let flag = BoutiqueInventoryHelper.flagEmoji(for: countryName)
            
            let boutiques = storesInCountry.filter { 
                !$0.name.lowercased().contains("warehouse") && !$0.name.lowercased().contains("headquarters")
            }.map { store in
                let managerInfo = BoutiqueInventoryHelper.getManagerInfo(for: store, in: allUsers)
                let city = store.location ?? ""
                let code = BoutiqueInventoryHelper.getStoreCode(name: store.name, city: city)
                return BoutiqueDetail(
                    name: store.name,
                    address: store.address ?? "",
                    city: city,
                    storeCode: code,
                    status: "Active",
                    manager: managerInfo.name,
                    email: managerInfo.email
                )
            }
            
            let inventories = storesInCountry.filter { 
                $0.name.lowercased().contains("warehouse")
            }.map { store in
                let warehouseRecords = authManager.inventoryRecords.filter { $0.storeID == store.id }
                let totalItems = warehouseRecords.reduce(0) { $0 + $1.quantity }
                let valuationVal = warehouseRecords.reduce(0.0) { sum, record in
                    let price = authManager.products.first(where: { $0.id == record.productID })?.basePrice ?? 0.0
                    return sum + Double(record.quantity) * price
                }
                let formattedValuation = BoutiqueInventoryHelper.formatValuation(value: valuationVal, currencyCode: store.currency)
                let isLow = warehouseRecords.contains(where: { $0.quantity < $0.reorderThreshold })
                let stockLevel = isLow ? "Low Stock" : "Optimal"
                
                return InventoryDetail(
                    name: store.name,
                    stockLevel: stockLevel,
                    totalItems: totalItems,
                    valuation: formattedValuation
                )
            }
            
            result.append(CountryData(
                name: countryName,
                flag: flag,
                boutiqueCount: boutiques.count,
                boutiques: boutiques,
                inventories: inventories
            ))
        }
        
        // Fallback for remaining countries in DB
        for (countryName, storesInCountry) in grouped {
            if !sortedCountries.contains(countryName) && !storesInCountry.isEmpty {
                let flag = BoutiqueInventoryHelper.flagEmoji(for: countryName)
                
                let boutiques = storesInCountry.filter { 
                    !$0.name.lowercased().contains("warehouse") && !$0.name.lowercased().contains("headquarters")
                }.map { store in
                    let managerInfo = BoutiqueInventoryHelper.getManagerInfo(for: store, in: allUsers)
                    let city = store.location ?? ""
                    let code = BoutiqueInventoryHelper.getStoreCode(name: store.name, city: city)
                    return BoutiqueDetail(
                        name: store.name,
                        address: store.address ?? "",
                        city: city,
                        storeCode: code,
                        status: "Active",
                        manager: managerInfo.name,
                        email: managerInfo.email
                    )
                }
                
                let inventories = storesInCountry.filter { 
                    $0.name.lowercased().contains("warehouse")
                }.map { store in
                    let warehouseRecords = authManager.inventoryRecords.filter { $0.storeID == store.id }
                    let totalItems = warehouseRecords.reduce(0) { $0 + $1.quantity }
                    let valuationVal = warehouseRecords.reduce(0.0) { sum, record in
                        let price = authManager.products.first(where: { $0.id == record.productID })?.basePrice ?? 0.0
                        return sum + Double(record.quantity) * price
                    }
                    let formattedValuation = BoutiqueInventoryHelper.formatValuation(value: valuationVal, currencyCode: store.currency)
                    let isLow = warehouseRecords.contains(where: { $0.quantity < $0.reorderThreshold })
                    let stockLevel = isLow ? "Low Stock" : "Optimal"
                    
                    return InventoryDetail(
                        name: store.name,
                        stockLevel: stockLevel,
                        totalItems: totalItems,
                        valuation: formattedValuation
                    )
                }
                
                result.append(CountryData(
                    name: countryName,
                    flag: flag,
                    boutiqueCount: boutiques.count,
                    boutiques: boutiques,
                    inventories: inventories
                ))
            }
        }
        
        return result
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Custom Luxury Segmented Control
                    customSegmentedControl

                    // Dynamic overview metric cards
                    overviewSection

                    // Top/Main Countries Section
                    countriesSection
                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Executive Hub")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: BoutiqueRoute.self) { route in
                switch route {
                case .allCountries:
                    AllCountriesListView(selectedSegment: selectedSegment, countriesData: countriesData)
                case .country(let country):
                    CountryDetailView(selectedSegment: selectedSegment, country: country)
                case .boutique(let boutique):
                    BoutiqueDetailView(boutique: boutique)
                }
            }
        }
        .task {
            await authManager.refreshUsersFromSupabase()
        }
    }

    // MARK: - Custom Luxury Segmented Control
    private var customSegmentedControl: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedSegment = 0
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "storefront.fill")
                        .font(.system(size: 14))
                    Text("Boutiques")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    selectedSegment == 0 ?
                    LinearGradient(
                        colors: [Color(red: 175/255, green: 135/255, blue: 75/255), Color(red: 200/255, green: 165/255, blue: 100/255)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
                )
                .foregroundColor(selectedSegment == 0 ? .white : MatteTheme.Colors.textSecondary)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedSegment = 1
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 14))
                    Text("Inventory")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    selectedSegment == 1 ?
                    LinearGradient(
                        colors: [Color(red: 175/255, green: 135/255, blue: 75/255), Color(red: 200/255, green: 165/255, blue: 100/255)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
                )
                .foregroundColor(selectedSegment == 1 ? .white : MatteTheme.Colors.textSecondary)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(4)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }

    // MARK: - Overview Cards Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Overview")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(MatteTheme.Colors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                if selectedSegment == 0 {
                    let totalBoutiques = countriesData.reduce(0) { $0 + $1.boutiques.count }
                    // Boutiques Metrics
                    overviewCard(title: "Total Boutiques", value: "\(totalBoutiques)", sub: "Across \(countriesData.count) Countries")
                    overviewCard(title: "Total Revenue", value: "₹124.5 Cr", sub: "YTD Performance")
                } else {
                    // Inventory Metrics
                    overviewCard(title: "Total Valuation", value: "₹45.2 Cr", sub: "Avg Asset Value")
                    overviewCard(title: "Active Warehouses", value: "5", sub: "100% Operational")
                }
            }
        }
    }

    private func overviewCard(title: String, value: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(MatteTheme.Colors.textPrimary)
            
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(MatteTheme.Colors.textPrimary)
            
            Text(sub)
                .font(.system(size: 11))
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    // MARK: - Countries List Section
    private var countriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Top Countries")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Spacer()
            }

            VStack(spacing: 10) {
                // Show all countries
                ForEach(countriesData) { country in
                    NavigationLink(value: BoutiqueRoute.country(country)) {
                        HStack(spacing: 14) {
                            Text(country.flag)
                                .font(.system(size: 24))
                            
                            Text(country.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(MatteTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Text(selectedSegment == 0 ? "\(country.boutiqueCount) Boutiques" : "\(country.inventories.count) Warehouses")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(MatteTheme.Colors.textTertiary)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .glassEffect(.regular, in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - View All Countries Screen
struct AllCountriesListView: View {
    let selectedSegment: Int
    let countriesData: [BoutiqueInventoryView.CountryData]
    @State private var searchText = ""

    var filteredCountries: [BoutiqueInventoryView.CountryData] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return countriesData
        }
        return countriesData.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                    TextField(selectedSegment == 0 ? "Search country or boutiques..." : "Search country or warehouse...", text: $searchText)
                        .font(.system(size: 15))
                }
                .padding(10)
                .background(Color(red: 245/255, green: 242/255, blue: 236/255))
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(.regular)

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Select a country to view its \(selectedSegment == 0 ? "boutiques" : "inventory")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    VStack(spacing: 10) {
                        ForEach(filteredCountries) { country in
                            NavigationLink(value: BoutiqueRoute.country(country)) {
                                HStack(spacing: 14) {
                                    Text(country.flag)
                                        .font(.system(size: 26))
                                    
                                    Text(country.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(selectedSegment == 0 ? "\(country.boutiqueCount) Boutiques" : "\(country.inventories.count) Warehouses")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(MatteTheme.Colors.textSecondary)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(MatteTheme.Colors.textTertiary)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                .glassEffect(.regular, in: .rect(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
            .background(MatteTheme.Colors.dashboardBackground)
        }
        .navigationTitle(selectedSegment == 0 ? "Boutiques" : "Inventory")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Country Boutiques Section (city filter + cards)
/// Owns the city-filter state locally so tapping a chip re-renders only this
/// section and reliably filters the boutique cards below.
private struct CountryBoutiquesSection: View {
    let country: BoutiqueInventoryView.CountryData
    @State private var selectedCity: String = "All"

    private let imageNames = ["login", "dxb 💫", " -4"]

    private var cityOptions: [String] {
        ["All"] + Array(Set(country.boutiques.map { $0.city })).sorted()
    }

    private var displayedBoutiques: [BoutiqueInventoryView.BoutiqueDetail] {
        selectedCity == "All"
            ? country.boutiques
            : country.boutiques.filter { $0.city == selectedCity }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Keep the horizontal filter outside the vertical card scroller.
            // This prevents the first card's NavigationLink hit region from
            // winning taps intended for a city chip.
            ScrollView(.horizontal, showsIndicators: true) {
                LazyHStack(spacing: 12) {
                    ForEach(cityOptions, id: \.self) { city in
                        cityChip(city)
                            .id(city)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .scrollTargetLayout()
            }
            .frame(height: 50)
            .scrollIndicators(.visible, axes: .horizontal)
            .scrollTargetBehavior(.viewAligned)
            .accessibilityIdentifier("boutique-city-filter")
            .padding(.vertical, 8)
            .background(MatteTheme.Colors.dashboardBackground)
            .zIndex(1)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(Array(displayedBoutiques.enumerated()), id: \.element.id) { index, boutique in
                        NavigationLink(value: BoutiqueRoute.boutique(boutique)) {
                            boutiqueCard(boutique, imgName: imageNames[index % imageNames.count])
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open \(boutique.name), store code \(boutique.storeCode)")
                    }

                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: Chip

    private func cityChip(_ city: String) -> some View {
        let isSelected = selectedCity == city
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCity = city
            }
        } label: {
            Text(city)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : MatteTheme.Colors.textSecondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? MatteTheme.Colors.luxuryGold : Color.white.opacity(0.4))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? MatteTheme.Colors.luxuryGold : Color.white.opacity(0.2), lineWidth: 1)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filter boutiques by \(city)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: Card

    private func boutiqueCard(_ boutique: BoutiqueInventoryView.BoutiqueDetail, imgName: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(imgName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.8), Color.black.opacity(0.3)],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack {
                HStack {
                    Spacer()
                    Text("LUXE MAISON")
                        .font(.system(size: 11, weight: .bold, design: .serif))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                        .tracking(2.0)
                    Spacer()
                }
                .padding(.top, 16)
                Spacer()
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(boutique.name)
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundColor(.white)

                    Text(boutique.address)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Store Code: \(boutique.storeCode)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                        .padding(.top, 1)
                }
                .padding(.leading, 16)
                .padding(.bottom, 16)
                .padding(.trailing, 40)

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 200)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, y: 4)
    }

}

// MARK: - Country Detail Detail list of boutiques or inventory
struct CountryDetailView: View {
    let selectedSegment: Int
    let country: BoutiqueInventoryView.CountryData
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if selectedSegment == 0 {
                CountryBoutiquesSection(country: country)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                    // Header Banner (Only show for Inventory warehouses)
                    HStack(spacing: 16) {
                        Text(country.flag)
                            .font(.system(size: 48))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(country.name)
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundColor(MatteTheme.Colors.textPrimary)
                            
                            Text("\(country.inventories.count) Distribution Warehouses")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))

                    Text("Asset Inventory")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(MatteTheme.Colors.textPrimary)

                    // Inventory Detail List
                    ForEach(country.inventories) { item in
                        Button(action: {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("FocusInventoryOnMap"),
                                object: nil,
                                userInfo: [
                                    "country": country.name,
                                    "name": item.name
                                ]
                            )
                        }) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(item.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                    Spacer()
                                    Text(item.stockLevel)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(item.stockLevel == "Optimal" ? MatteTheme.Colors.success : MatteTheme.Colors.warning)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(item.stockLevel == "Optimal" ? MatteTheme.Colors.successLight : MatteTheme.Colors.warningLight)
                                        .cornerRadius(6)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Image(systemName: "shippingbox.fill")
                                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                                    Text("\(item.totalItems) units")
                                        .font(.system(size: 12))
                                        .foregroundColor(MatteTheme.Colors.textSecondary)
                                    Spacer()
                                    Image(systemName: "indianrupeesign.circle.fill")
                                        .foregroundColor(MatteTheme.Colors.success)
                                    Text(item.valuation)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                }
                            }
                            .padding(16)
                            .glassEffect(.regular, in: .rect(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(MatteTheme.Colors.dashboardBackground)
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(selectedSegment == 0)
        .toolbar {
            if selectedSegment == 0 {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    }
                    .buttonStyle(.plain)
                }
                
            }
        }
    }
}

// MARK: - Boutique Performance Fixture
/// Deterministic sample performance keyed by store code. Until this screen is
/// connected to analytics, this keeps each boutique visibly distinct instead
/// of presenting the same hard-coded numbers for every valid route.
private struct BoutiquePerformance {
    let revenue: String
    let orders: Int
    let customers: Int
    let conversionRate: String
    let activeStaff: Int
    let staffIncrease: Int
    let revenueTrend: String
    let orderTrend: String
    let customerTrend: String
    let conversionTrend: String
    let revenuePoints: [Double]
    let orderPoints: [Double]
    let customerPoints: [Double]
    let conversionPoints: [Double]
    let activeTargetAmount: Double?

    init(boutique: BoutiqueInventoryView.BoutiqueDetail, liveData: LivePerformanceData? = nil) {
        let seed = boutique.storeCode.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        
        let staticRevenueValue = 39.0 + Double(seed % 100) / 10.0
        let staticOrderValue = 690 + seed % 190
        let staticCustomerValue = 420 + seed % 180
        let conversionValue = 58.0 + Double(seed % 110) / 10.0

        if let liveData = liveData {
            if liveData.totalRevenue == 0 {
                revenue = "₹0"
            } else {
                revenue = liveData.totalRevenue >= 100000 ? String(format: "₹%.1fL", liveData.totalRevenue / 100000.0) : String(format: "₹%.0f", liveData.totalRevenue)
            }
            orders = liveData.totalOrders
            customers = liveData.totalItemsSold > 0 ? liveData.totalItemsSold : staticCustomerValue
            activeTargetAmount = liveData.activeTargetAmount
            revenueTrend = "Live Data"
            orderTrend = "Live Data"
            customerTrend = "Live Items Sold"
        } else {
            revenue = String(format: "₹%.1fL", staticRevenueValue)
            orders = staticOrderValue
            customers = staticCustomerValue
            activeTargetAmount = nil
            revenueTrend = String(format: "↑ %.1f%% vs last month", 8.0 + Double(seed % 55) / 10.0)
            orderTrend = String(format: "↑ %.1f%% vs last month", 7.0 + Double(seed % 45) / 10.0)
            customerTrend = String(format: "↑ %.1f%% vs last month", 8.5 + Double(seed % 40) / 10.0)
        }

        conversionRate = String(format: "%.1f%%", conversionValue)
        activeStaff = 14 + seed % 10
        staffIncrease = 1 + seed % 4
        conversionTrend = String(format: "↑ %.1f%% vs last month", 4.0 + Double(seed % 35) / 10.0)
        
        revenuePoints = Self.sparkline(endingAt: liveData?.totalRevenue ?? staticRevenueValue)
        orderPoints = Self.sparkline(endingAt: Double(liveData?.totalOrders ?? orders))
        customerPoints = Self.sparkline(endingAt: Double(customers))
        conversionPoints = Self.sparkline(endingAt: conversionValue)
    }

    private static func sparkline(endingAt value: Double) -> [Double] {
        [0.79, 0.82, 0.81, 0.87, 0.86, 0.92, 0.95, 1.0].map { value * $0 }
    }
}

// MARK: - Boutique Detail View
/// One reusable detail screen is used for every boutique. The routed boutique
/// is the single source of truth, so title, address and store code cannot fall
/// back to the first item in a city or a generated "-001" value.
struct BoutiqueDetailView: View {
    let boutique: BoutiqueInventoryView.BoutiqueDetail
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedDate = Date()
    @State private var showCalendarPicker = false
    @State private var livePerformanceData: LivePerformanceData?
    
    private var performance: BoutiquePerformance {
        BoutiquePerformance(boutique: boutique, liveData: livePerformanceData)
    }
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthStr = formatter.string(from: selectedDate)
        
        let calendar = Calendar.current
        if let range = calendar.range(of: .day, in: .month, for: selectedDate) {
            return "1 – \(range.count) \(monthStr)"
        }
        return "1 – 31 \(monthStr)"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Insights Banner Card
                ZStack(alignment: .bottomLeading) {
                    // Background Image of the store
                    let imageNames = [" -2", " -1", " -3", " -4", " -5"]
                    let seed = boutique.storeCode.unicodeScalars.reduce(0) { $0 + Int($1.value) }
                    
                    Image(imageNames[seed % imageNames.count])
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                    
                    // Dark gradient overlay
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.black.opacity(0.3)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    
                    // Text layout inside the card
                    VStack(alignment: .leading, spacing: 6) {
                        Text(boutique.name)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Label(boutique.address, systemImage: "mappin.and.ellipse")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(2)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11))
                                .foregroundColor(MatteTheme.Colors.luxuryGold)
                            Text(formattedDateRange)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                        .padding(.top, 4)
                    }
                    .padding(20)
                }
                .frame(height: 180)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
                
                // 2x2 Metrics Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                    metricMiniCard(
                        icon: "indianrupeesign.circle.fill",
                        title: "Total Revenue",
                        value: performance.revenue,
                        trend: performance.revenueTrend,
                        points: performance.revenuePoints,
                        accentColor: MatteTheme.Colors.luxuryGold
                    )
                    
                    metricMiniCard(
                        icon: "bag.circle.fill",
                        title: "Total Orders",
                        value: "\(performance.orders)",
                        trend: performance.orderTrend,
                        points: performance.orderPoints,
                        accentColor: MatteTheme.Colors.info
                    )
                    
                    metricMiniCard(
                        icon: "person.2.circle.fill",
                        title: "Total Customers",
                        value: "\(performance.customers)",
                        trend: performance.customerTrend,
                        points: performance.customerPoints,
                        accentColor: MatteTheme.Colors.accent
                    )
                    
                    metricMiniCard(
                        icon: "percent",
                        title: "Conversion Rate",
                        value: performance.conversionRate,
                        trend: performance.conversionTrend,
                        points: performance.conversionPoints,
                        accentColor: MatteTheme.Colors.success
                    )
                }
                
                // Active Target Card
                if let target = performance.activeTargetAmount {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(MatteTheme.Colors.luxuryGold)
                            Text("Store Sales Target (Active)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(MatteTheme.Colors.textPrimary)
                        }
                        
                        let revenue = livePerformanceData?.totalRevenue ?? 0
                        let progress = min(1.0, revenue / target)
                        
                        ProgressView(value: progress)
                            .tint(progress >= 1.0 ? MatteTheme.Colors.success : MatteTheme.Colors.luxuryGold)
                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                            .padding(.vertical, 4)
                        
                        HStack {
                            Text(revenue >= 100000 ? String(format: "₹%.1fL", revenue / 100000.0) : String(format: "₹%.0f", revenue))
                                .fontWeight(.semibold)
                            Spacer()
                            Text(target >= 100000 ? String(format: "Target: ₹%.1fL", target / 100000.0) : String(format: "Target: ₹%.0f", target))
                        }
                        .font(.system(size: 12))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 14))
                }
                
                // Active Staff & Boutique Manager row card
                HStack(spacing: 14) {
                    // Active Staff
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 14))
                                .foregroundColor(MatteTheme.Colors.info)
                            Text("Active Staff")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }
                        
                        Text("\(performance.activeStaff)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                        
                        Text("Average Active Staff")
                            .font(.system(size: 9))
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                        
                        Text("↑ \(performance.staffIncrease) vs last month")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(MatteTheme.Colors.success)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .glassEffect(.regular, in: .rect(cornerRadius: 14))
                    
                    // Manager Overview Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .font(.system(size: 14))
                                .foregroundColor(MatteTheme.Colors.luxuryGold)
                            Text("Boutique Manager")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }
                        
                        Text(boutique.manager.components(separatedBy: " ").first ?? "Sarah")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .lineLimit(1)
                        
                        Text("Senior Manager")
                            .font(.system(size: 9))
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(MatteTheme.Colors.success)
                                .frame(width: 6, height: 6)
                            Text("Active")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(MatteTheme.Colors.success)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .glassEffect(.regular, in: .rect(cornerRadius: 14))
                }
                

                
                // Bottom quick reports grid
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        actionPill(icon: "doc.text.fill", title: "Generate Report", desc: "Create detailed performance report")
                        actionPill(icon: "arrow.down.doc.fill", title: "Export Report", desc: "Export data in PDF / Excel")
                        actionPill(icon: "phone.circle.fill", title: "Contact Manager", desc: "Call or message boutique manager")
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .task {
            await fetchLiveData()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(boutique.name)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    Text("Store Code: \(boutique.storeCode)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .frame(width: 38, height: 38)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                }
                .buttonStyle(.plain)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCalendarPicker = true }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .frame(width: 38, height: 38)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showCalendarPicker) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Select Month")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .padding(.top, 24)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .tint(MatteTheme.Colors.luxuryGold)
                        .labelsHidden()
                        .padding()
                    
                    Button(action: { showCalendarPicker = false }) {
                        Text("Done")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(MatteTheme.Colors.luxuryGold)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .background(MatteTheme.Colors.dashboardBackground)
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    private func fetchLiveData() async {
        let stores = authManager.supabaseStores
        if let matchedStore = stores.first(where: { BoutiqueInventoryHelper.getStoreCode(name: $0.name, city: $0.location ?? "") == boutique.storeCode }) {
            do {
                let data = try await DynamicSalesService.shared.fetchPerformance(for: matchedStore.id)
                await MainActor.run {
                    self.livePerformanceData = data
                }
            } catch {
                print("Failed to fetch live data for \(boutique.name): \(error)")
            }
        }
    }

    private func metricMiniCard(icon: String, title: String, value: String, trend: String, points: [Double], accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(MatteTheme.Colors.textPrimary)
            
            Text(trend)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(MatteTheme.Colors.success)
            
            // Sparkline graph
            Chart {
                ForEach(Array(points.enumerated()), id: \.offset) { index, pt in
                    LineMark(
                        x: .value("Day", index),
                        y: .value("Value", pt)
                    )
                    .foregroundStyle(accentColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Day", index),
                        y: .value("Value", pt)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [accentColor.opacity(0.15), accentColor.opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 35)
            .padding(.top, 4)
        }
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
      }
      
      private func actionPill(icon: String, title: String, desc: String) -> some View {
          HStack(spacing: 12) {
              ZStack {
                  Circle()
                      .fill(MatteTheme.Colors.luxuryGold.opacity(0.12))
                      .frame(width: 40, height: 40)
                  Image(systemName: icon)
                      .font(.system(size: 16))
                      .foregroundColor(MatteTheme.Colors.luxuryGold)
              }
              
              VStack(alignment: .leading, spacing: 2) {
                  Text(title)
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(MatteTheme.Colors.textPrimary)
                  Text(desc)
                      .font(.system(size: 10))
                      .foregroundColor(MatteTheme.Colors.textSecondary)
              }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .glassEffect(.regular, in: .rect(cornerRadius: 12))
      }
}

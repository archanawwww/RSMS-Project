import SwiftUI

struct HierarchicalCountry: Identifiable {
    let id = UUID()
    let name: String
    let flag: String
    var cities: [HierarchicalCity]
    
    var totalBoutiques: Int {
        cities.reduce(0) { $0 + $1.boutiques.count }
    }
}

struct HierarchicalCity: Identifiable {
    let id = UUID()
    let name: String
    var boutiques: [SupabaseStore]
}

struct BoutiqueSelectionSheet: View {
    @Binding var selectedStoreID: UUID?
    let availableStores: [SupabaseStore]
    
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var expandedCountries = Set<String>()
    @State private var expandedCities = Set<String>()
    
    // Auto-expansion logic when searching
    private func updateExpansions(for filtered: [HierarchicalCountry]) {
        if searchText.isEmpty {
            // Collapse all if search is empty
            // expandedCountries.removeAll()
            // expandedCities.removeAll()
        } else {
            // Expand all matching when searching
            for country in filtered {
                expandedCountries.insert(country.name)
                for city in country.cities {
                    expandedCities.insert(city.name)
                }
            }
        }
    }
    
    private var filteredCountries: [HierarchicalCountry] {
        var result: [HierarchicalCountry] = []
        let search = searchText.lowercased()
        
        for countryData in BoutiqueInventoryView.sharedCountriesData {
            var cityMap: [String: [SupabaseStore]] = [:]
            var orderedCities: [String] = []
            
            for boutique in countryData.boutiques {
                if let store = availableStores.first(where: { $0.name == boutique.name }) {
                    let matchesSearch = search.isEmpty ||
                        store.name.lowercased().contains(search) ||
                        boutique.address.lowercased().contains(search) ||
                        boutique.city.lowercased().contains(search) ||
                        countryData.name.lowercased().contains(search)
                        
                    if matchesSearch {
                        if cityMap[boutique.city] == nil {
                            cityMap[boutique.city] = []
                            orderedCities.append(boutique.city)
                        }
                        cityMap[boutique.city]?.append(store)
                    }
                }
            }
            
            var countryCities: [HierarchicalCity] = []
            for cityName in orderedCities {
                let cityBoutiques = cityMap[cityName] ?? []
                countryCities.append(HierarchicalCity(name: cityName, boutiques: cityBoutiques))
            }
            
            if !countryCities.isEmpty {
                result.append(HierarchicalCountry(name: countryData.name, flag: countryData.flag, cities: countryCities))
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    TextField("Search by boutique, city, country", text: $searchText)
                        .onChange(of: searchText) {
                            updateExpansions(for: filteredCountries)
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }
                    }
                }
                .padding(12)
                .background(MatteTheme.Colors.dashboardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(MatteTheme.Colors.borderLight, lineWidth: 1)
                )
                .padding()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredCountries) { country in
                            countryView(country)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Select Boutique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    private func countryView(_ country: HierarchicalCountry) -> some View {
        let isExpanded = expandedCountries.contains(country.name)
        
        return VStack(spacing: 0) {
            Button {
                withAnimation {
                    if isExpanded {
                        expandedCountries.remove(country.name)
                    } else {
                        expandedCountries.insert(country.name)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(country.flag)
                        .font(.title3)
                    Text(country.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    
                    Text("\(country.totalBoutiques) Boutiques")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(6)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                .padding(16)
                .background(Color.white)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                VStack(spacing: 0) {
                    ForEach(country.cities) { city in
                        cityView(city)
                        if city.id != country.cities.last?.id {
                            Divider().padding(.leading, 40)
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func cityView(_ city: HierarchicalCity) -> some View {
        let isExpanded = expandedCities.contains(city.name)
        
        return VStack(spacing: 0) {
            Button {
                withAnimation {
                    if isExpanded {
                        expandedCities.remove(city.name)
                    } else {
                        expandedCities.insert(city.name)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                        .frame(width: 24)
                    
                    Text(city.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    
                    Text("(\(city.boutiques.count))")
                        .font(.system(size: 14))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .padding(.leading, 12)
                .background(Color.white)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(city.boutiques) { boutique in
                        boutiqueRow(boutique)
                        if boutique.id != city.boutiques.last?.id {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground).opacity(0.4))
            }
        }
    }
    
    private func getAddress(for boutiqueName: String) -> String {
        for cd in BoutiqueInventoryView.sharedCountriesData {
            if let bd = cd.boutiques.first(where: { $0.name == boutiqueName }) {
                return bd.address
            }
        }
        return "Unknown Location"
    }
    
    private func boutiqueRow(_ store: SupabaseStore) -> some View {
        let isSelected = selectedStoreID == store.id
        
        return Button {
            selectedStoreID = store.id
            dismiss()
        } label: {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? MatteTheme.Colors.luxuryGold.opacity(0.15) : Color.clear)
                        .frame(width: 32, height: 32)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(MatteTheme.Colors.luxuryGold)
                            .font(.system(size: 14, weight: .bold))
                    } else {
                        Image(systemName: "building.2.crop.circle")
                            .foregroundColor(MatteTheme.Colors.luxuryGold.opacity(0.5))
                            .font(.system(size: 20))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name)
                        .font(.system(size: 15, weight: isSelected ? .bold : .semibold))
                        .foregroundColor(isSelected ? MatteTheme.Colors.luxuryGold : MatteTheme.Colors.textPrimary)
                    
                    Text(getAddress(for: store.name))
                        .font(.system(size: 12))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.textTertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .padding(.leading, 24)
            .background(isSelected ? MatteTheme.Colors.luxuryGold.opacity(0.05) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

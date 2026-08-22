import SwiftUI

// PlanogramItem mock removed

// MARK: - Planograms Management View

struct PlanogramsManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showCreateSheet = false
    
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Filter tags
    private let categoriesList = ["All", "Handbags", "Footwear", "Watches", "Draft"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Subtitle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CORPORATE ADMIN")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(MatteTheme.Colors.primaryGold)
                            Text("Planograms")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(MatteTheme.Colors.textPrimary)
                            Text("Visual merchandising standards")
                                .font(.system(size: 13))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Create Planogram Button
                        Button(action: { showCreateSheet = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Create")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.black)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 4)
                    
                    // 1. Metrics Grid Widget (2 Top cards, 3 Bottom cards)
                    // metricsSectionView removed per request
                    // 2. Search & Categories filters
                    VStack(spacing: 12) {
                        searchBarView
                        categoriesFilterRow
                    }
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
                    
                    // 3. Render list of visual cards
                    VStack(spacing: 16) {
                        if filteredPlanograms.isEmpty {
                            emptyPlanogramState
                        } else {
                            ForEach(filteredPlanograms) { planogram in
                                planogramCard(planogram: planogram)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                    .font(.system(size: 15, weight: .semibold))
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreatePlanogramView()
            }
        }
        .onAppear {
            Task {
                await authManager.fetchPlanograms()
            }
        }
    }
    
    // MARK: - Subviews: Metrics
    
    private var metricsSectionView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                metricBox(value: "24", label: "TOTAL PLANOGRAMS", details: nil)
                metricBox(value: "18", label: "ACTIVE", details: "↑ 3 this month")
            }
            
            HStack(spacing: 10) {
                metricBox(value: "\(authManager.planograms.filter { $0.status == "Draft" }.count)", label: "DRAFT", details: nil)
                metricBox(value: "2", label: "ARCHIVED", details: nil)
                metricBox(value: "83%", label: "IMPL. RATE", details: "↑ 5%")
            }
        }
    }
    
    private func metricBox(value: String, label: String, details: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textPrimary)
            
            if let details {
                Text(details)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(MatteTheme.Colors.success)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    // MARK: - Subviews: Search Bar
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(MatteTheme.Colors.textSecondary)
            TextField("Search planograms, category, version...", text: $searchText)
                .font(.system(size: 14))
                .textFieldStyle(.plain)
        }
        .padding(10)
        .background(MatteTheme.Colors.dashboardBackground)
        .cornerRadius(10)
    }
    
    // MARK: - Subviews: Categories Horizontal Filter
    
    private var categoriesFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categoriesList, id: \.self) { cat in
                    let isSelected = selectedCategory == cat
                    Button(action: { selectedCategory = cat }) {
                        Text(cat)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(isSelected ? .white : MatteTheme.Colors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.black : Color.white)
                            .cornerRadius(100)
                            .overlay(RoundedRectangle(cornerRadius: 100).stroke(isSelected ? Color.clear : MatteTheme.Colors.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Subviews: Planogram Row Card
    
    private func planogramCard(planogram: SupabasePlanogram) -> some View {
        VStack(spacing: 0) {
            // Visual Mock Product Card Image
            ZStack(alignment: .topTrailing) {
                // Generates customized design visuals instead of empty boxes
                ZStack(alignment: .bottomLeading) {
                    mockProductVisual(theme: planogram.category?.lowercased() ?? "handbags")
                    
                    // Version pill badge
                    Text("v\(planogram.version ?? "1.0")")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(12)
                }
                
                // Status pill badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(planogram.status == "Published" ? MatteTheme.Colors.success : MatteTheme.Colors.warning)
                        .frame(width: 5, height: 5)
                    Text(planogram.status)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(planogram.status == "Published" ? MatteTheme.Colors.success : MatteTheme.Colors.warning)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(6)
                .padding(12)
            }
            .frame(height: 160)
            
            // Description Content Card Body
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(planogram.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    
                    Spacer()
                }
                
                Text("\(planogram.category ?? "") · Effective \(planogram.effectiveDate ?? "")")
                    .font(.system(size: 12))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                
                // Assigned Boutiques count row
                HStack(spacing: 6) {
                    Image(systemName: "storefront.fill")
                        .font(.system(size: 11))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                    Text("\(planogram.boutiquesAssigned) boutiques assigned")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.02), radius: 6, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
    }
    
    // MARK: - Layout Custom Drawing product visuals
    
    private func mockProductVisual(theme: String) -> some View {
        ZStack {
            if theme == "handbags" {
                // High fashion dark backpack design visual
                LinearGradient(colors: [Color(red: 0.15, green: 0.15, blue: 0.15), Color(red: 0.25, green: 0.25, blue: 0.25)], startPoint: .top, endPoint: .bottom)
                
                // Center backpack canvas shape
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.35, green: 0.35, blue: 0.35))
                        .frame(width: 60, height: 75)
                        .overlay(
                            VStack {
                                Rectangle().fill(Color(red: 0.6, green: 0.4, blue: 0.2)).frame(width: 4, height: 45).padding(.leading, -20)
                                Spacer()
                            }
                        )
                }
            } else if theme == "watches" {
                // Minimal watches flat gray layout
                LinearGradient(colors: [Color(red: 0.88, green: 0.88, blue: 0.88), Color(red: 0.94, green: 0.94, blue: 0.94)], startPoint: .top, endPoint: .bottom)
                
                // Minimal watch band & bezel
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 140, height: 28)
                        .rotationEffect(.degrees(-35))
                    Circle()
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.04), radius: 4)
                }
            } else {
                // Leather shoes backdrop gradient
                LinearGradient(colors: [Color(red: 0.45, green: 0.35, blue: 0.25), Color(red: 0.3, green: 0.2, blue: 0.15)], startPoint: .top, endPoint: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
    
    // MARK: - Helpers
    
    private var filteredPlanograms: [SupabasePlanogram] {
        authManager.planograms.filter { item in
            if !searchText.isEmpty {
                let query = searchText.lowercased()
                let match = item.title.lowercased().contains(query) ||
                            (item.category?.lowercased().contains(query) ?? false)
                if !match { return false }
            }
            
            if selectedCategory != "All" {
                if selectedCategory == "Draft" {
                    return item.status.lowercased() == "draft"
                }
                return item.category == selectedCategory
            }
            return true
        }
    }
    
    private var emptyPlanogramState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.split.3x3")
                .font(.system(size: 44))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            Text("No planograms matching criteria.")
                .font(.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Planogram Detail Screen

struct PlanogramDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let planogram: SupabasePlanogram
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // 1. Visual Card Header
                visualHeaderBanner
                
                // 2. Metrics Info Card
                summaryDetailsCard
                
                // 3. Milestones Timeline Card
                timelineCardView
                
                // 4. Boutique Status list
                boutiqueImplementationCard
                
                // 5. Actions Card
                actionsGridCard
            }
            .padding(.bottom, 40)
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Detail Subviews: Header Banner
    
    private var visualHeaderBanner: some View {
        ZStack(alignment: .bottomLeading) {
            // Visual header drawing
            ZStack {
                if planogram.category?.lowercased() == "handbags" {
                    LinearGradient(colors: [Color(red: 0.15, green: 0.15, blue: 0.15), Color(red: 0.25, green: 0.25, blue: 0.25)], startPoint: .top, endPoint: .bottom)
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.35, green: 0.35, blue: 0.35))
                            .frame(width: 80, height: 100)
                        Spacer()
                    }
                } else {
                    LinearGradient(colors: [Color(red: 0.88, green: 0.88, blue: 0.88), Color(red: 0.94, green: 0.94, blue: 0.94)], startPoint: .top, endPoint: .bottom)
                }
            }
            .frame(height: 240)
            .clipped()
            
            // Header content gradient overlay
            LinearGradient(colors: [Color.clear, Color.black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                .frame(height: 120)
            
            // Back circular button
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 4)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 50)
                    
                    Spacer()
                }
                Spacer()
            }
            
            // Text overlays on top of visual card
            VStack(alignment: .leading, spacing: 6) {
                // Status pill
                HStack(spacing: 4) {
                    Circle()
                        .fill(MatteTheme.Colors.success)
                        .frame(width: 5, height: 5)
                    Text(planogram.status)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.success)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.9))
                .cornerRadius(6)
                
                Text(planogram.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(planogram.category ?? "") · Version \(planogram.version ?? "1.0")")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .padding(16)
        }
    }
    
    // MARK: - Detail Subviews: Summary Metrics
    
    private var summaryDetailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                summaryDetailCell(label: "Effective Date", value: planogram.effectiveDate ?? "", isAccent: false)
                summaryDetailCell(label: "Boutiques", value: "\(planogram.boutiquesAssigned) assigned", isAccent: false)
                summaryDetailCell(label: "Emails Sent", value: "All Delivered", isAccent: true)
                summaryDetailCell(label: "Implementation", value: "0 / \(planogram.boutiquesAssigned)", isAccent: false)
            }
            
            Divider()
            
            // Completion progress bar
            let completionRatio: Double = 0.0 // Placeholder until compliance feature is added
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(MatteTheme.Colors.borderLight)
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(MatteTheme.Colors.primaryGold)
                            .frame(width: geo.size.width * CGFloat(completionRatio), height: 6)
                    }
                }
                .frame(height: 6)
                
                Text("0 / \(planogram.boutiquesAssigned) boutiques completed")
                    .font(.system(size: 12))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(MatteTheme.Colors.borderLight, lineWidth: 1).padding(.horizontal, 16))
    }
    
    private func summaryDetailCell(label: String, value: String, isAccent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isAccent ? MatteTheme.Colors.success : MatteTheme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Detail Subviews: TimelineCard
    
    private var timelineCardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TIMELINE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            
            VStack(alignment: .leading, spacing: 0) {
                timelineStep(title: "Created", date: "01 Jul 2026", isCompleted: true, isLast: false)
                timelineStep(title: "Published", date: "03 Jul 2026", isCompleted: true, isLast: false)
                timelineStep(title: "Emails Sent", date: "03 Jul 2026", isCompleted: true, isLast: false)
                timelineStep(title: "Boutiques Viewed", date: "04 Jul 2026", isCompleted: true, isLast: false)
                timelineStep(title: "Implemented", date: "05 Jul 2026", isCompleted: true, isLast: false)
                timelineStep(title: "Completed", date: "Awaiting 3 boutiques", isCompleted: false, isLast: true)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(MatteTheme.Colors.borderLight, lineWidth: 1).padding(.horizontal, 16))
    }
    
    private func timelineStep(title: String, date: String, isCompleted: Bool, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isCompleted ? MatteTheme.Colors.textPrimary : MatteTheme.Colors.textTertiary)
                
                if !isLast {
                    Rectangle()
                        .fill(MatteTheme.Colors.border)
                        .frame(width: 1, height: 28)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Text(date)
                    .font(.system(size: 11))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            Spacer()
        }
    }
    
    // MARK: - Detail Subviews: Boutique Implementation
    
    private var boutiqueImplementationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BOUTIQUE IMPLEMENTATION")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            
            VStack(spacing: 12) {
                boutiqueItemRow(name: "Delhi Boutique I", region: "India", status: "Completed", date: "05 Jul 2026", color: MatteTheme.Colors.success, icon: "checkmark.circle.fill")
                Divider()
                boutiqueItemRow(name: "Delhi Boutique II", region: "India", status: "Implemented", date: "06 Jul 2026", color: MatteTheme.Colors.info, icon: "checkmark.circle.fill")
                Divider()
                boutiqueItemRow(name: "Mumbai Boutique I", region: "India", status: "Viewed", date: nil, color: MatteTheme.Colors.warning, icon: "eye.fill")
                Divider()
                boutiqueItemRow(name: "Berlin Boutique I", region: "Germany", status: "Pending", date: nil, color: MatteTheme.Colors.textTertiary, icon: "clock.fill")
                Divider()
                boutiqueItemRow(name: "Paris Boutique I", region: "France", status: "Pending", date: nil, color: MatteTheme.Colors.textTertiary, icon: "clock.fill")
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(MatteTheme.Colors.borderLight, lineWidth: 1).padding(.horizontal, 16))
    }
    
    private func boutiqueItemRow(name: String, region: String, status: String, date: String?, color: Color, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.08))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Text(region)
                    .font(.system(size: 11))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(status)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
                
                if let date {
                    Text(date)
                        .font(.system(size: 10))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
            }
        }
    }
    
    // MARK: - Detail Subviews: Action Cards
    
    private var actionsGridCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ACTIONS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.textTertiary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                actionGridButton(label: "Edit", icon: "pencil.line")
                actionGridButton(label: "Duplicate", icon: "doc.on.doc")
                actionGridButton(label: "New Version", icon: "arrow.up.circle")
                actionGridButton(label: "Resend Email", icon: "paperplane")
                actionGridButton(label: "Archive", icon: "archivebox")
                actionGridButton(label: "View Report", icon: "chart.bar")
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(MatteTheme.Colors.borderLight, lineWidth: 1).padding(.horizontal, 16))
    }
    
    private func actionGridButton(label: String, icon: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                Text(label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(MatteTheme.Colors.dashboardBackground)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

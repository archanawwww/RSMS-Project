import SwiftUI

// MARK: - Boutique Manager Tab View

/// Boutique Manager sees: Store, Local Inventory, Team, Sales Reports.
/// No Company Reports tab. Only their own store data.
struct BoutiqueManagerTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showProfile = false
    @State private var selectedInventoryTab = 0 // 0 = My Boutique, 1 = Global Network (Read-Only)

    var body: some View {
        TabView {
            storeTab
                .tabItem { Label("Store", systemImage: "building.2") }

            localInventoryTab
                .tabItem { Label("Inventory", systemImage: "shippingbox") }

            teamTab
                .tabItem { Label("Team", systemImage: "person.2") }

            salesReportsTab
                .tabItem { Label("Sales", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .tint(MatteTheme.Colors.textPrimary)
    }

    // MARK: - Store Tab

    private var storeTab: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                    storeOverviewCard
                    teamSummaryCard
                    recentActivityCard
                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.top, MatteTheme.Spacing.lg)
                .padding(.bottom, 96)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("My Store")
            .navigationBarTitleDisplayMode(.large)
            .profileToolbar(showProfile: $showProfile)
        }
    }

    // MARK: - Local Inventory Tab

    private var localInventoryTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Inventory Scope", selection: $selectedInventoryTab) {
                    Text("My Boutique").tag(0)
                    Text("Global Network (Read-Only)").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.vertical, MatteTheme.Spacing.sm)
                .background(MatteTheme.Colors.surface)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                        if selectedInventoryTab == 0 {
                            // My Boutique (Read/Write)
                            infoCard(
                                title: "Local Store Inventory",
                                subtitle: "You have full read & write permissions for stock in your assigned store: \(authManager.currentUser?.storeName ?? "My Store").",
                                icon: "shippingbox.fill"
                            )
                            
                            sectionCard(title: "Stock Levels", icon: "chart.bar") {
                                let localStoreID = authManager.currentUser?.assignedStoreID
                                let localRecords = authManager.inventoryRecords.filter { $0.storeID == localStoreID }
                                
                                if localRecords.isEmpty {
                                    Text("No inventory records found.")
                                        .font(MatteTheme.Typography.subheadline)
                                        .foregroundColor(MatteTheme.Colors.textSecondary)
                                } else {
                                    VStack(spacing: MatteTheme.Spacing.elementSpacing) {
                                        ForEach(localRecords) { record in
                                            let product = authManager.products.first(where: { $0.id == record.productID })
                                            let pName = product?.name ?? "Unknown Product"
                                            let sku = product?.sku ?? "SKU"
                                            
                                            HStack(spacing: MatteTheme.Spacing.md) {
                                                Circle()
                                                    .fill(stockColor(record.quantity <= record.reorderThreshold ? .critical : .healthy).opacity(0.12))
                                                    .frame(width: 44, height: 44)
                                                    .overlay(
                                                        Image(systemName: "cube.box")
                                                            .font(.system(size: 18, weight: .medium))
                                                            .foregroundColor(stockColor(record.quantity <= record.reorderThreshold ? .critical : .healthy))
                                                    )
                                                
                                                VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                                                    Text(pName)
                                                        .font(MatteTheme.Typography.subheadline)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                                        .lineLimit(1)
                                                    Text("\(sku) • Reorder point: \(record.reorderThreshold)")
                                                        .font(MatteTheme.Typography.caption)
                                                        .foregroundColor(MatteTheme.Colors.textSecondary)
                                                }
                                                
                                                Spacer()
                                                
                                                // Read/Write access Stepper
                                                HStack(spacing: MatteTheme.Spacing.sm) {
                                                    Button(action: {
                                                        if record.quantity > 0 {
                                                            try? authManager.updateInventoryQuantity(productID: record.productID, storeID: record.storeID, newQuantity: record.quantity - 1)
                                                        }
                                                    }) {
                                                        Image(systemName: "minus.circle.fill")
                                                            .font(.system(size: 24))
                                                            .foregroundColor(MatteTheme.Colors.textSecondary)
                                                    }
                                                    .buttonStyle(.plain)
                                                    
                                                    Text("\(record.quantity)")
                                                        .font(MatteTheme.Typography.headline)
                                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                                        .frame(minWidth: 28)
                                                        
                                                    Button(action: {
                                                        try? authManager.updateInventoryQuantity(productID: record.productID, storeID: record.storeID, newQuantity: record.quantity + 1)
                                                    }) {
                                                        Image(systemName: "plus.circle.fill")
                                                            .font(.system(size: 24))
                                                            .foregroundColor(MatteTheme.Colors.textPrimary)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                            if record.id != localRecords.last?.id {
                                                Divider()
                                                    .padding(.vertical, MatteTheme.Spacing.xs)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            // Global Network (Read-Only)
                            infoCard(
                                title: "Company-Wide Network Stock",
                                subtitle: "View-only access to inventory at other boutique locations and central warehouse storage.",
                                icon: "globe"
                            )
                            
                            let localStoreID = authManager.currentUser?.assignedStoreID
                            let otherRecords = authManager.inventoryRecords.filter { $0.storeID != localStoreID }
                            
                            if otherRecords.isEmpty {
                                Text("No other store records available.")
                                    .font(MatteTheme.Typography.subheadline)
                                    .foregroundColor(MatteTheme.Colors.textSecondary)
                            } else {
                                ForEach(authManager.stores.filter { $0.id != localStoreID }) { store in
                                    sectionCard(title: store.name, icon: "building.2") {
                                        let storeRecs = otherRecords.filter { $0.storeID == store.id }
                                        if storeRecs.isEmpty {
                                            Text("No stock information available.")
                                                .font(MatteTheme.Typography.caption)
                                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                        } else {
                                            VStack(alignment: .leading, spacing: MatteTheme.Spacing.elementSpacing) {
                                                ForEach(storeRecs) { record in
                                                    let product = authManager.products.first(where: { $0.id == record.productID })
                                                    HStack {
                                                        Text(product?.name ?? "Unknown")
                                                            .font(MatteTheme.Typography.subheadline)
                                                            .foregroundColor(MatteTheme.Colors.textPrimary)
                                                        Spacer()
                                                        Text("\(record.quantity) units")
                                                            .font(MatteTheme.Typography.subheadline)
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(MatteTheme.Colors.textSecondary)
                                                    }
                                                    if record.id != storeRecs.last?.id {
                                                        Divider()
                                                            .padding(.vertical, MatteTheme.Spacing.xs)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                    .padding(.top, MatteTheme.Spacing.lg)
                    .padding(.bottom, 96)
                }
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Inventory")
            .navigationBarTitleDisplayMode(.large)
            .profileToolbar(showProfile: $showProfile)
        }
    }

    // MARK: - Team Tab

    private var teamTab: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                    infoCard(
                        title: "Your Team",
                        subtitle: "Manage Sales Associates assigned to your store. Other managers' teams are not visible.",
                        icon: "person.2"
                    )

                    let associates = authManager.salesAssociatesUnderCurrentManager()
                    sectionCard(title: "Sales Associates (\(associates.count))", icon: "person.badge.plus") {
                        if associates.isEmpty {
                            Text("No Sales Associates created yet. Use the profile button to create one.")
                                .font(MatteTheme.Typography.subheadline)
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        } else {
                            VStack(spacing: MatteTheme.Spacing.elementSpacing) {
                                ForEach(associates) { user in
                                    teamMemberRow(user: user)
                                    if user.id != associates.last?.id {
                                        Divider()
                                            .padding(.vertical, MatteTheme.Spacing.xs)
                                    }
                                }
                            }
                        }
                    }

                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.top, MatteTheme.Spacing.lg)
                .padding(.bottom, 96)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Team")
            .navigationBarTitleDisplayMode(.large)
            .profileToolbar(showProfile: $showProfile)
        }
    }

    // MARK: - Sales Reports Tab

    private var salesReportsTab: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                    infoCard(
                        title: "Store Sales",
                        subtitle: "View sales performance for your store only. Company-wide reports are admin-only.",
                        icon: "chart.line.uptrend.xyaxis"
                    )

                    sectionCard(title: "Today's Summary", icon: "calendar") {
                        VStack(spacing: MatteTheme.Spacing.elementSpacing) {
                            reportRow(label: "Transactions", value: "14")
                            reportRow(label: "Revenue", value: "₹3,45,000")
                            reportRow(label: "Avg. Value", value: "₹24,643")
                            reportRow(label: "Returns", value: "1")
                        }
                    }

                    sectionCard(title: "This Week", icon: "chart.bar") {
                        VStack(spacing: MatteTheme.Spacing.elementSpacing) {
                            reportRow(label: "Total Sales", value: "₹18,60,000")
                            reportRow(label: "Top Category", value: "Handbags")
                            reportRow(label: "Best Associate", value: authManager.salesAssociatesUnderCurrentManager().first?.displayName ?? "—")
                        }
                    }
                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.top, MatteTheme.Spacing.lg)
                .padding(.bottom, 96)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Sales Reports")
            .navigationBarTitleDisplayMode(.large)
            .profileToolbar(showProfile: $showProfile)
        }
    }

    // MARK: - Reusable Components

    private var storeOverviewCard: some View {
        VStack(alignment: .leading, spacing: MatteTheme.Spacing.md) {
            if let user = authManager.currentUser {
                HStack(spacing: MatteTheme.Spacing.md) {
                    VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                        Text(user.storeName)
                            .font(MatteTheme.Typography.pageTitle)
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                        Text("\(user.region.rawValue), \(user.country.rawValue)")
                            .font(MatteTheme.Typography.subheadline)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                    Spacer()
                    roleCircle(for: user.role, size: 52)
                }
                HStack(spacing: MatteTheme.Spacing.sm) {
                    BadgeView(user.role.rawValue)
                    BadgeView(user.displayName)
                }
            }
        }
        .padding(MatteTheme.Spacing.cardPadding)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(MatteTheme.CornerRadius.large)
        .overlay(RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.large).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
        .shadow(color: MatteTheme.Colors.textPrimary.opacity(0.04), radius: 16, x: 0, y: 4)
    }

    private var teamSummaryCard: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MatteTheme.Spacing.elementSpacing) {
            metricTile(title: "Associates", value: "\(authManager.salesAssociatesUnderCurrentManager().count)", icon: "person.2", color: MatteTheme.Colors.success)
            metricTile(title: "Inactive", value: "\(authManager.salesAssociatesUnderCurrentManager().filter { !$0.isActive }.count)", icon: "person.crop.circle.badge.xmark", color: MatteTheme.Colors.warning)
        }
    }

    private var recentActivityCard: some View {
        sectionCard(title: "Recent Activity", icon: "clock.arrow.circlepath") {
            Text("Store activity feed coming soon.")
                .font(MatteTheme.Typography.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
    }

    private func teamMemberRow(user: ManagedUser) -> some View {
        HStack(spacing: MatteTheme.Spacing.md) {
            roleCircle(for: user.role, size: 44)
            VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                Text(user.displayName.isEmpty ? user.username : user.displayName)
                    .font(MatteTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Text("@\(user.username)")
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            Spacer()
            BadgeView(
                user.isActive ? "Active" : "Inactive"
            )
        }
        .padding(.vertical, MatteTheme.Spacing.xs)
    }

    private enum StockStatus { case healthy, low, critical }

    private func stockRow(product: String, qty: Int, threshold: Int, status: StockStatus) -> some View {
        HStack(spacing: MatteTheme.Spacing.md) {
            Circle()
                .fill(stockColor(status).opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "cube.box")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(stockColor(status))
                )
            VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                Text(product)
                    .font(MatteTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                    .lineLimit(1)
                Text("Qty: \(qty) / Reorder: \(threshold)")
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            Spacer()
            BadgeView(
                status == .healthy ? "OK" : (status == .low ? "Low" : "Critical")
            )
        }
        .padding(.vertical, MatteTheme.Spacing.xs)
    }

    private func stockColor(_ status: StockStatus) -> Color {
        switch status {
        case .healthy: return MatteTheme.Colors.success
        case .low: return MatteTheme.Colors.warning
        case .critical: return MatteTheme.Colors.error
        }
    }

    // MARK: - Shared Helpers

    private func roleCircle(for role: UserRole, size: CGFloat) -> some View {
        Circle()
            .fill(MatteTheme.Colors.roleColor(for: role).opacity(0.12))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: role.icon)
                    .font(size > 44 ? .title3 : .system(size: 18, weight: .medium))
                    .foregroundColor(MatteTheme.Colors.roleColor(for: role))
            )
    }

    private func metricTile(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: MatteTheme.Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(MatteTheme.Typography.pageTitle)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
            Text(title)
                .font(MatteTheme.Typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .padding(MatteTheme.Spacing.cardPadding)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(MatteTheme.CornerRadius.large)
        .overlay(RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.large).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
        .shadow(color: MatteTheme.Colors.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    private func infoCard(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: MatteTheme.Spacing.sm) {
            HStack(spacing: MatteTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(MatteTheme.Colors.accent)
                Text(title)
                    .font(MatteTheme.Typography.sectionHeader)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }
            Text(subtitle)
                .font(MatteTheme.Typography.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
                .lineSpacing(2)
        }
        .padding(MatteTheme.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(MatteTheme.CornerRadius.large)
        .overlay(RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.large).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
        .shadow(color: MatteTheme.Colors.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: MatteTheme.Spacing.md) {
            HStack(spacing: MatteTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(MatteTheme.Colors.accent)
                Text(title)
                    .font(MatteTheme.Typography.sectionHeader)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Spacer()
            }
            content()
        }
        .padding(MatteTheme.Spacing.cardPadding)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(MatteTheme.CornerRadius.large)
        .overlay(RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.large).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
        .shadow(color: MatteTheme.Colors.textPrimary.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    private func reportRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(MatteTheme.Typography.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(MatteTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(MatteTheme.Colors.textPrimary)
        }
    }
}

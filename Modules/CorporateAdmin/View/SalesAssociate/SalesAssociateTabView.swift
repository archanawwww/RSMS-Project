import SwiftUI

// MARK: - Sales Associate Tab View

/// The Sales Associate sees: Floor (Appointments/Events), Cart & Sales (Transactions), Customers (directory).
/// Do NOT show any inventory management views to the Sales Associate.
struct SalesAssociateTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showProfile = false

    // State for Cart
    @State private var selectedProductForCart = UUID()
    @State private var cartQuantity = 1
    @State private var currentCartItems: [CartItem] = []
    @State private var selectedCustomerForSale = ""
    @State private var checkoutStatusMessage: String?

    var body: some View {
        TabView {
            floorTab
                .tabItem { Label("Floor", systemImage: "figure.walk") }

            cartTab
                .tabItem { Label("Cart & Sales", systemImage: "cart") }

            customersTab
                .tabItem { Label("Customers", systemImage: "person.3") }
        }
        .tint(MatteTheme.Colors.textPrimary)
        .onAppear {
            initializeDefaults()
        }
    }

    private func initializeDefaults() {
        if let firstProd = authManager.products.first {
            selectedProductForCart = firstProd.id
        }
    }

    // MARK: - Floor Tab

    private var floorTab: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                    welcomeCard

                    infoCard(
                        title: "Boutique Floor Ops",
                        subtitle: "Your active client list, scheduled VIP appointments, and tasks for today at: \(authManager.currentUser?.storeName ?? "Boutique").",
                        icon: "door.left.hand.open"
                    )

                    sectionCard(title: "VIP Appointments", icon: "calendar") {
                        VStack(alignment: .leading, spacing: MatteTheme.Spacing.elementSpacing) {
                            appointmentRow(client: "Aditi Rao", time: "3:30 PM", notes: "Prefers leather goods, Birkin focus.")
                            Divider().padding(.vertical, MatteTheme.Spacing.xs)
                            appointmentRow(client: "Cyrus Poonawalla", time: "5:00 PM", notes: "Looking at diamond cufflinks.")
                        }
                    }

                    sectionCard(title: "Assigned Floor Tasks", icon: "checklist") {
                        let myTasks = authManager.tasksVisibleToCurrentUser()
                        if myTasks.isEmpty {
                            Text("No pending floor tasks assigned to you.")
                                .font(MatteTheme.Typography.subheadline)
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        } else {
                            VStack(alignment: .leading, spacing: MatteTheme.Spacing.elementSpacing) {
                                ForEach(myTasks) { task in
                                    VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                                        HStack {
                                            Text(task.title)
                                                .font(MatteTheme.Typography.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(MatteTheme.Colors.textPrimary)
                                            Spacer()
                                            BadgeView(text: task.priority.rawValue, color: priorityColor(task.priority))
                                        }
                                        if !task.notes.isEmpty {
                                            Text(task.notes)
                                                .font(MatteTheme.Typography.caption)
                                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                        }
                                        
                                        if task.status != .completed {
                                            Button("Mark Completed") {
                                                try? authManager.updateTaskStatus(id: task.id, status: .completed)
                                            }
                                            .font(MatteTheme.Typography.caption)
                                            .foregroundColor(MatteTheme.Colors.success)
                                            .padding(.top, MatteTheme.Spacing.xs)
                                        } else {
                                            Text("Completed")
                                                .font(MatteTheme.Typography.caption2)
                                                .foregroundColor(MatteTheme.Colors.textTertiary)
                                        }
                                        
                                        if task.id != myTasks.last?.id {
                                            Divider().padding(.top, MatteTheme.Spacing.sm)
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
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Floor Ops")
            .navigationBarTitleDisplayMode(.large)
            .profileToolbar(showProfile: $showProfile)
        }
    }

    // MARK: - Cart & Sales Tab

    private var cartTab: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                    infoCard(
                        title: "Boutique Checkout",
                        subtitle: "Create shopping carts and process customer transactions securely.",
                        icon: "creditcard"
                    )

                    sectionCard(title: "Add Item to Cart", icon: "cart.badge.plus") {
                        VStack(spacing: MatteTheme.Spacing.elementSpacing) {
                            Picker("Product", selection: $selectedProductForCart) {
                                ForEach(authManager.products) { product in
                                    Text("\(product.name) - \(product.formattedPrice)").tag(product.id)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Stepper("Quantity: \(cartQuantity)", value: $cartQuantity, in: 1...10)
                            
                            LiquidGlassButton(title: "Add to Cart", action: addToCart)
                        }
                    }

                    sectionCard(title: "Shopping Cart", icon: "cart.fill") {
                        if currentCartItems.isEmpty {
                            Text("Your cart is empty.")
                                .font(MatteTheme.Typography.subheadline)
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, MatteTheme.Spacing.md)
                        } else {
                            VStack(spacing: MatteTheme.Spacing.elementSpacing) {
                                ForEach(currentCartItems) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                                            Text(item.product.name)
                                                .font(MatteTheme.Typography.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(MatteTheme.Colors.textPrimary)
                                            Text("\(item.quantity) x \(item.product.formattedPrice)")
                                                .font(MatteTheme.Typography.caption)
                                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                        }
                                        Spacer()
                                        
                                        Button(action: { removeFromCart(item: item) }) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(MatteTheme.Colors.error)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    Divider().padding(.vertical, MatteTheme.Spacing.xs)
                                }
                                
                                HStack {
                                    Text("Total Price")
                                        .font(MatteTheme.Typography.headline)
                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                    Spacer()
                                    Text("€\(String(format: "%.2f", cartTotal()))")
                                        .font(MatteTheme.Typography.headline)
                                        .foregroundColor(MatteTheme.Colors.accent)
                                }
                                .padding(.vertical, MatteTheme.Spacing.sm)

                                LiquidGlassTextField(
                                    placeholder: "Customer Name",
                                    text: $selectedCustomerForSale
                                )
                                .padding(.vertical, MatteTheme.Spacing.xs)

                                LiquidGlassButton(
                                    title: "Complete Transaction",
                                    action: checkout
                                )
                                .disabled(selectedCustomerForSale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }

                    if let status = checkoutStatusMessage {
                        sectionCard(title: "Status", icon: "bell") {
                            Text(status)
                                .font(MatteTheme.Typography.subheadline)
                                .foregroundColor(MatteTheme.Colors.accent)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.top, MatteTheme.Spacing.lg)
                .padding(.bottom, 96)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.large)
            .profileToolbar(showProfile: $showProfile)
        }
    }

    // MARK: - Customers Tab

    private var customersTab: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                    infoCard(
                        title: "Client Book",
                        subtitle: "View preferences and purchase histories for active high-net-worth clients.",
                        icon: "person.text.rectangle"
                    )

                    sectionCard(title: "Registered HNW Clients", icon: "person.crop.rectangle.stack") {
                        VStack(alignment: .leading, spacing: MatteTheme.Spacing.elementSpacing) {
                            customerRow(name: "Amit Patel", tier: "VVIP", preference: "Watches, Gold", history: "Purchased GMT Master in May 2026")
                            Divider().padding(.vertical, MatteTheme.Spacing.xs)
                            customerRow(name: "Sarah Fernandes", tier: "VIP", preference: "Leather bags, scarves", history: "Purchased Silk Evening Clutch in June 2026")
                        }
                    }
                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.top, MatteTheme.Spacing.lg)
                .padding(.bottom, 96)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Clients")
            .navigationBarTitleDisplayMode(.large)
            .profileToolbar(showProfile: $showProfile)
        }
    }

    // MARK: - Cart Helpers

    private struct CartItem: Identifiable {
        let id = UUID()
        let product: Product
        var quantity: Int
    }

    private func addToCart() {
        guard let product = authManager.products.first(where: { $0.id == selectedProductForCart }) else { return }
        
        if let index = currentCartItems.firstIndex(where: { $0.product.id == product.id }) {
            currentCartItems[index].quantity += cartQuantity
        } else {
            currentCartItems.append(CartItem(product: product, quantity: cartQuantity))
        }
        cartQuantity = 1
    }

    private func removeFromCart(item: CartItem) {
        currentCartItems.removeAll { $0.id == item.id }
    }

    private func cartTotal() -> Double {
        currentCartItems.reduce(0.0) { $0 + ($1.product.basePrice * Double($1.quantity)) }
    }

    private func checkout() {
        checkoutStatusMessage = nil
        let localStoreID = authManager.currentUser?.assignedStoreID ?? SeedData.mumbaiFlagshipID

        // Verify stock levels first and deduct from inventory
        var missingStock = false
        for item in currentCartItems {
            if let recordIndex = authManager.inventoryRecords.firstIndex(where: { $0.productID == item.product.id && $0.storeID == localStoreID }) {
                if authManager.inventoryRecords[recordIndex].quantity < item.quantity {
                    missingStock = true
                }
            } else {
                missingStock = true
            }
        }

        if missingStock {
            checkoutStatusMessage = "Transaction Failed: Insufficient stock available at this boutique."
            return
        }

        // Deduct stock
        for item in currentCartItems {
            if let recordIndex = authManager.inventoryRecords.firstIndex(where: { $0.productID == item.product.id && $0.storeID == localStoreID }) {
                let currentVal = authManager.inventoryRecords[recordIndex].quantity
                try? authManager.updateInventoryQuantity(
                    productID: item.product.id,
                    storeID: localStoreID,
                    newQuantity: currentVal - item.quantity
                )
            }
        }

        checkoutStatusMessage = "Transaction Completed Successfully for \(selectedCustomerForSale)! Total: €\(String(format: "%.2f", cartTotal()))"
        currentCartItems = []
        selectedCustomerForSale = ""
    }

    // MARK: - Reusable Components & Subviews

    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: MatteTheme.Spacing.md) {
            if let user = authManager.currentUser {
                HStack(spacing: MatteTheme.Spacing.md) {
                    VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                        Text("Welcome,")
                            .font(MatteTheme.Typography.subheadline)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                        Text(user.displayName)
                            .font(MatteTheme.Typography.pageTitle)
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                    }
                    Spacer()
                    Circle()
                        .fill(MatteTheme.Colors.roleColor(for: user.role).opacity(0.12))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: user.role.icon)
                                .font(.title3)
                                .foregroundColor(MatteTheme.Colors.roleColor(for: user.role))
                        )
                }

                HStack(spacing: MatteTheme.Spacing.sm) {
                    BadgeView(text: user.role.rawValue, color: MatteTheme.Colors.roleColor(for: user.role))
                    BadgeView(text: user.storeName, color: MatteTheme.Colors.textSecondary)
                }
            }
        }
        .padding(MatteTheme.Spacing.cardPadding)
        .background(MatteTheme.Colors.surface)
        .cornerRadius(MatteTheme.CornerRadius.large)
        .overlay(RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.large).stroke(MatteTheme.Colors.borderLight, lineWidth: 1))
        .shadow(color: MatteTheme.Colors.textPrimary.opacity(0.04), radius: 16, x: 0, y: 4)
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

    private func appointmentRow(client: String, time: String, notes: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                Text(client)
                    .font(MatteTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Text(notes)
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            Spacer()
            Text(time)
                .font(MatteTheme.Typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(MatteTheme.Colors.accent)
                .padding(.horizontal, MatteTheme.Spacing.sm)
                .padding(.vertical, MatteTheme.Spacing.xs)
                .background(MatteTheme.Colors.accent.opacity(0.12))
                .cornerRadius(MatteTheme.CornerRadius.small)
        }
    }

    private func customerRow(name: String, tier: String, preference: String, history: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                HStack {
                    Text(name)
                        .font(MatteTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    BadgeView(text: tier, color: tier == "VVIP" ? MatteTheme.Colors.accent : MatteTheme.Colors.success)
                }
                Text("Preferences: \(preference)")
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                Text("History: \(history)")
                    .font(MatteTheme.Typography.caption2)
                    .foregroundColor(MatteTheme.Colors.textTertiary)
            }
        }
    }

    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return MatteTheme.Colors.error
        case .medium: return MatteTheme.Colors.warning
        case .low: return MatteTheme.Colors.success
        }
    }
}

private struct SeedData {
    static let mumbaiFlagshipID = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
}

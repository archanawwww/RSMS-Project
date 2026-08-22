import SwiftUI

struct EditUserSheet: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    let user: ManagedUser
    var onNavigateToBoutique: ((BoutiqueRoute) -> Void)?
    let onSaved: (ManagedUser) -> Void

    // Profile
    @State private var displayName: String
    @State private var username: String
    
    // Store Assignment
    @State private var selectedStoreID: UUID?
    @State private var storeName: String
    @State private var role: UserRole
    @State private var country: Country
    @State private var region: Region
    @State private var showBoutiqueSheet = false
    
    // Password
    @State private var password = ""
    @State private var isChangingPassword = false
    @State private var showPassword = false
    @State private var passwordError: String? = nil
    @State private var passwordStrength: PasswordStrength = .empty
    
    // Status
    @State private var isActive: Bool
    
    // Feedback
    @State private var statusMessage: String?
    @State private var isSuccess = false

    init(
        user: ManagedUser,
        onNavigateToBoutique: ((BoutiqueRoute) -> Void)? = nil,
        onSaved: @escaping (ManagedUser) -> Void = { _ in }
    ) {
        self.user = user
        self.onNavigateToBoutique = onNavigateToBoutique
        self.onSaved = onSaved
        _displayName = State(initialValue: user.displayName)
        _username = State(initialValue: user.username)
        _selectedStoreID = State(initialValue: user.assignedStoreID)
        _storeName = State(initialValue: user.storeLocation.name)
        _role = State(initialValue: user.role)
        _country = State(initialValue: user.storeLocation.country)
        _region = State(initialValue: user.storeLocation.region)
        _isActive = State(initialValue: user.isActive)
    }
    
    /// All stores (not just available ones) so that re-assignment can include the user's current store
    private var allEditableStores: [SupabaseStore] {
        authManager.supabaseStores.filter { store in
            guard !store.name.contains("Warehouse") && store.name != "Corporate Headquarters" else { return false }
            // Allow the user's current store + any unassigned stores
            if store.id == user.assignedStoreID { return true }
            return !authManager.users.contains(where: { $0.role == .boutiqueManager && $0.assignedStoreID == store.id && $0.isActive && $0.id != user.id })
        }
    }
    
    private var regionsForCountry: [Region] {
        switch country {
        case .india: return [.delhi, .mumbai, .bangalore, .hyderabad, .chennai]
        case .unitedStates: return [.newYork, .losAngeles, .chicago, .miami]
        case .china: return [.beijing, .shanghai, .shenzhen]
        case .germany: return [.berlin, .munich, .frankfurt, .hamburg]
        case .france: return [.paris, .lyon, .marseille]
        }
    }
    
    private func getBoutiqueDetail() -> BoutiqueInventoryView.BoutiqueDetail? {
        let name = selectedStoreName
        for countryData in BoutiqueInventoryView.sharedCountriesData {
            if let boutique = countryData.boutiques.first(where: { $0.name == name }) {
                return boutique
            }
        }
        return nil
    }
    
    private var selectedStoreName: String {
        if let id = selectedStoreID,
           let store = authManager.supabaseStores.first(where: { $0.id == id }) {
            return store.name
        }
        return storeName
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Profile Details
                    VStack(alignment: .leading, spacing: 8) {
                        sectionHeader(title: "Profile Details", icon: "person")
                        
                        cardBackground {
                            EditableRowView(icon: "person.fill", text: $displayName, subtitle: "Full Name", color: MatteTheme.Colors.luxuryGold)
                            Divider().padding(.leading, 48)
                            EditableRowView(icon: "envelope.fill", text: $username, subtitle: "Email Address", color: MatteTheme.Colors.luxuryGold)
                        }
                    }
                    
                    // MARK: - Assigned Store (Editable)
                    VStack(alignment: .leading, spacing: 8) {
                        sectionHeader(title: "Assigned Store", icon: "storefront")
                        
                        cardBackground {
                            // Country Picker
                            HStack(spacing: 12) {
                                circleIcon("globe")
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Country")
                                        .font(MatteTheme.Typography.caption)
                                        .foregroundColor(MatteTheme.Colors.textSecondary)
                                    
                                    Picker("", selection: $country) {
                                        ForEach(Country.allCases) { c in
                                            Text(c.rawValue).tag(c)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(MatteTheme.Colors.textPrimary)
                                    .labelsHidden()
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(MatteTheme.Colors.textTertiary)
                            }
                            
                            if role != .inventoryController {
                                Divider().padding(.leading, 48)
                                
                                // Region Picker
                                HStack(spacing: 12) {
                                    circleIcon("mappin.and.ellipse")
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Region / City")
                                            .font(MatteTheme.Typography.caption)
                                            .foregroundColor(MatteTheme.Colors.textSecondary)
                                        
                                        Picker("", selection: $region) {
                                            ForEach(regionsForCountry) { r in
                                                Text(r.rawValue).tag(r)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .tint(MatteTheme.Colors.textPrimary)
                                        .labelsHidden()
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(MatteTheme.Colors.textTertiary)
                                }
                                
                                Divider().padding(.leading, 48)
                                
                                // Store / Boutique Picker
                                HStack(alignment: .top, spacing: 12) {
                                    circleIcon("storefront.fill")
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Store / Boutique")
                                            .font(MatteTheme.Typography.caption)
                                            .foregroundColor(MatteTheme.Colors.textSecondary)
                                        Text(selectedStoreName)
                                            .font(MatteTheme.Typography.headline)
                                            .foregroundColor(MatteTheme.Colors.textPrimary)
                                        if let address = getBoutiqueDetail()?.address {
                                            Text(address)
                                                .font(.system(size: 11))
                                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showBoutiqueSheet = true
                                    }) {
                                        Text("Change Store")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(MatteTheme.Colors.luxuryGold)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(MatteTheme.Colors.luxuryGold, lineWidth: 1)
                                            )
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .onChange(of: country) { newCountry in
                        // Reset region when country changes
                        let available = regionsForCountry
                        if !available.contains(region), let first = available.first {
                            region = first
                        }
                    }
                    .sheet(isPresented: $showBoutiqueSheet) {
                        BoutiqueSelectionSheet(
                            selectedStoreID: $selectedStoreID,
                            availableStores: allEditableStores
                        )
                        .presentationDetents([.fraction(0.9)])
                    }
                    
                    // MARK: - Password
                    VStack(alignment: .leading, spacing: 8) {
                        sectionHeader(title: "Password", icon: "lock")
                        
                        cardBackground {
                            if isChangingPassword {
                                VStack(alignment: .leading, spacing: 12) {
                                    ZStack(alignment: .trailing) {
                                        if showPassword {
                                            TextField("New Password", text: $password)
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
                                                .font(MatteTheme.Typography.headline)
                                                .padding(12)
                                                .background(MatteTheme.Colors.dashboardBackground)
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(passwordError != nil ? MatteTheme.Colors.error : Color.gray.opacity(0.12), lineWidth: 1)
                                                )
                                        } else {
                                            SecureField("New Password", text: $password)
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
                                                .font(MatteTheme.Typography.headline)
                                                .padding(12)
                                                .background(MatteTheme.Colors.dashboardBackground)
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(passwordError != nil ? MatteTheme.Colors.error : Color.gray.opacity(0.12), lineWidth: 1)
                                                )
                                        }
                                        
                                        Button(action: { showPassword.toggle() }) {
                                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                                .padding(.trailing, 16)
                                        }
                                    }
                                    .onChange(of: password) { _ in validatePassword() }
                                    
                                    if let error = passwordError {
                                        Text(error)
                                            .font(MatteTheme.Typography.caption)
                                            .foregroundColor(MatteTheme.Colors.error)
                                    } else if !password.isEmpty {
                                        HStack(spacing: 6) {
                                            Text("Strength:")
                                                .font(MatteTheme.Typography.caption)
                                                .foregroundColor(MatteTheme.Colors.textSecondary)
                                            Text(passwordStrength.text)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(passwordStrength.color)
                                            
                                            // Strength bar
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.gray.opacity(0.15))
                                                        .frame(height: 4)
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(passwordStrength.color)
                                                        .frame(width: geo.size.width * strengthFraction, height: 4)
                                                        .animation(.easeInOut(duration: 0.3), value: passwordStrength.text)
                                                }
                                            }
                                            .frame(height: 4)
                                        }
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            isChangingPassword = false
                                            password = ""
                                            passwordError = nil
                                            passwordStrength = .empty
                                        }
                                    }) {
                                        Text("Cancel Password Change")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(MatteTheme.Colors.error)
                                    }
                                }
                            } else {
                                HStack(alignment: .center, spacing: 12) {
                                    circleIcon("lock.fill")
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Password")
                                            .font(MatteTheme.Typography.caption)
                                            .foregroundColor(MatteTheme.Colors.textSecondary)
                                        Text("********")
                                            .font(MatteTheme.Typography.headline)
                                            .foregroundColor(MatteTheme.Colors.textPrimary)
                                        Text("Password changes will be logged in the audit trail.")
                                            .font(.system(size: 11))
                                            .foregroundColor(MatteTheme.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation { isChangingPassword = true }
                                    }) {
                                        Text("Change Password")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(MatteTheme.Colors.luxuryGold)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(MatteTheme.Colors.luxuryGold, lineWidth: 1)
                                            )
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // MARK: - Status (Dynamic)
                    VStack(alignment: .leading, spacing: 8) {
                        sectionHeader(title: "Status", icon: "checkmark.shield")
                        
                        cardBackground {
                            HStack(alignment: .center, spacing: 12) {
                                circleIcon(
                                    isActive ? "checkmark" : "xmark",
                                    color: isActive ? MatteTheme.Colors.success : MatteTheme.Colors.error
                                )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(isActive ? "Active Account" : "Inactive Account")
                                        .font(MatteTheme.Typography.headline)
                                        .foregroundColor(MatteTheme.Colors.textPrimary)
                                        .animation(.easeInOut, value: isActive)
                                    Text(isActive
                                         ? "This user account is active and can access the system."
                                         : "This user account is deactivated and cannot log in.")
                                        .font(.system(size: 11))
                                        .foregroundColor(MatteTheme.Colors.textSecondary)
                                        .animation(.easeInOut, value: isActive)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isActive)
                                    .tint(MatteTheme.Colors.primaryGold)
                                    .labelsHidden()
                            }
                            .padding(.vertical, 4)
                            
                            if isActive != user.isActive {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(MatteTheme.Colors.warning)
                                    Text(isActive
                                         ? "Status will be changed from Inactive → Active"
                                         : "Status will be changed from Active → Inactive")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(MatteTheme.Colors.warning)
                                }
                                .padding(.top, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .animation(.spring(response: 0.3), value: isActive)
                    }
                    

                    if let statusMessage {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundColor(isSuccess ? MatteTheme.Colors.success : MatteTheme.Colors.error)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.vertical, MatteTheme.Spacing.lg)
                .padding(.bottom, 40)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Edit User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(MatteTheme.Colors.espresso)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveChanges() }
                        .foregroundColor(MatteTheme.Colors.primaryGold)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    

    
    private var strengthFraction: CGFloat {
        switch passwordStrength {
        case .empty: return 0
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
    
    // MARK: - Subviews
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(MatteTheme.Colors.luxuryGold)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(MatteTheme.Colors.textPrimary)
        }
        .padding(.leading, 8)
    }
    
    private func cardBackground<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 12) {
            content()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(MatteTheme.CornerRadius.large)
    }
    
    private func circleIcon(_ icon: String, color: Color = MatteTheme.Colors.luxuryGold) -> some View {
        Image(systemName: icon)
            .font(.system(size: 16))
            .foregroundColor(color)
            .frame(width: 36, height: 36)
            .background(color.opacity(0.12))
            .clipShape(Circle())
    }
    
    private func editableRowFallback(icon: String, text: Binding<String>, subtitle: String) -> some View {
        EmptyView() // Kept just in case there are hidden calls, but we replaced them all.
    }

    // MARK: - Password Validation
    
    private func validatePassword() {
        let pass = password
        
        // Calculate strength
        var score = 0
        if pass.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if pass.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        if pass.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        let special = CharacterSet.alphanumerics.inverted.subtracting(.whitespaces)
        if pass.rangeOfCharacter(from: special) != nil { score += 1 }
        
        if pass.isEmpty {
            passwordStrength = .empty
        } else if score <= 2 || pass.count < 8 {
            passwordStrength = .weak
        } else if score == 3 {
            passwordStrength = .medium
        } else if score >= 4 && pass.count >= 8 {
            passwordStrength = .strong
        }
        
        if pass.isEmpty {
            passwordError = nil
            return
        }
        if pass.contains(" ") {
            passwordError = "Password cannot contain spaces."
            return
        }
        if pass.count < 8 {
            passwordError = "Password must be at least 8 characters long."
            return
        }
        if pass.count > 20 {
            passwordError = "Password cannot exceed 20 characters."
            return
        }
        if pass.rangeOfCharacter(from: .uppercaseLetters) == nil {
            passwordError = "Password must contain at least one uppercase letter."
            return
        }
        if pass.rangeOfCharacter(from: .lowercaseLetters) == nil {
            passwordError = "Password must contain at least one lowercase letter."
            return
        }
        if pass.rangeOfCharacter(from: .decimalDigits) == nil {
            passwordError = "Password must contain at least one number."
            return
        }
        if pass.rangeOfCharacter(from: special) == nil {
            passwordError = "Password must contain at least one special character."
            return
        }
        passwordError = nil
    }

    // MARK: - Save
    
    private func saveChanges() {
        let countryValue = role == .corporateAdmin ? Country.india : country
        let regionValue = role == .corporateAdmin ? Region.mumbai : region
        let storeNameValue = role == .corporateAdmin ? "Corporate Headquarters" : selectedStoreName

        let targetStore = StoreLocation(
            name: storeNameValue.isEmpty ? "\(regionValue.rawValue) Boutique" : storeNameValue,
            country: countryValue,
            region: regionValue
        )

        Task {
            do {
                if isChangingPassword {
                    validatePassword()
                    if passwordError != nil || password.isEmpty {
                        await MainActor.run {
                            isSuccess = false
                            statusMessage = "Please enter a valid password."
                        }
                        return
                    }
                }
                
                try await authManager.updateManagedUser(
                    id: user.id,
                    displayName: displayName,
                    username: username,
                    password: password.isEmpty ? nil : password,
                    role: role,
                    storeLocation: targetStore,
                    isActive: isActive
                )

                await MainActor.run {
                    isSuccess = true
                    statusMessage = "User updated successfully."
                    if let updatedUser = authManager.users.first(where: { $0.id == user.id }) {
                        onSaved(updatedUser)
                    }
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSuccess = false
                    statusMessage = error.localizedDescription
                }
            }
        }
    }
}

struct EditableRowView: View {
    let icon: String
    @Binding var text: String
    let subtitle: String
    let color: Color
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Button(action: {
            isFocused = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    TextField(subtitle, text: $text)
                        .focused($isFocused)
                        .font(MatteTheme.Typography.headline)
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(subtitle.contains("Email") ? .never : .words)
                    
                    Text(subtitle)
                        .font(MatteTheme.Typography.caption)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "pencil")
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .font(.system(size: 14))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

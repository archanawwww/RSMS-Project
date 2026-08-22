import SwiftUI

// MARK: - Governance View (Tab 1)

/// Tab 1 — Store Managers, Company Policies & Business Rules, Audit Logs.
/// Full CRUD for users and policies with 2FA gating, search, and filter.
struct GovernanceView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    var onNavigateToBoutique: ((BoutiqueRoute) -> Void)?

    // MARK: - User Management State

    @State private var newUsername = ""
    @State private var newPhoneNumber = ""
    @State private var newPassword = ""
    @State private var newFirstName = ""
    @State private var newLastName = ""
    @State private var newStoreID: UUID? = nil
    @State private var newRole: UserRole = .boutiqueManager
    @State private var statusMessage: String?
    
    // Validation State
    @State private var firstNameError: String? = nil
    @State private var lastNameError: String? = nil
    @State private var emailError: String? = nil
    @State private var phoneError: String? = nil
    @State private var passwordError: String? = nil
    @State private var storeError: String? = nil
    @State private var passwordStrength: PasswordStrength = .empty
    @State private var showPassword = false
    @State private var isSubmitting = false

    @State private var editingUser: ManagedUser? = nil
    @State private var userToDelete: ManagedUser? = nil
    @State private var showUserDeleteConfirmation = false
    @State private var userAssignmentNotice: UserAssignmentNotice? = nil

    @State private var userSearchText = ""
    @State private var selectedRoleFilter: UserRole? = nil

    // 2FA gating
    @State private var show2FAForEdit = false
    @State private var show2FAForDelete = false
    @State private var pending2FAUser: ManagedUser? = nil
    @State private var showBoutiqueSheet = false
    @State private var showProfile = false

    // MARK: - Policy Management State

    @State private var editingPolicy: CompanyPolicy? = nil
    @State private var isAddingPolicy = false
    @State private var policyToDelete: CompanyPolicy? = nil
    @State private var showDeleteConfirmation = false

    // MARK: - Audit Log State

    @State private var auditSearchText = ""
    @State private var auditFilterAction: AuditAction? = nil

    // MARK: - Section Expansion

    @State private var expandedSection: GovernanceSection? = .managers

    enum GovernanceSection: String, CaseIterable {
        case managers = "Store Managers"
        case policies = "Company Policies"
        case auditLog = "Audit Logs"
    }

    private var creatableRoles: [UserRole] {
        [.boutiqueManager, .inventoryController]
    }

    private var manageableUserRoles: [UserRole] {
        [.boutiqueManager, .inventoryController]
    }

    private struct UserAssignmentNotice: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    
    private var isFormValid: Bool {
        !newFirstName.isEmpty && firstNameError == nil &&
        !newLastName.isEmpty && lastNameError == nil &&
        !newUsername.isEmpty && emailError == nil &&
        !newPhoneNumber.isEmpty && phoneError == nil &&
        !newPassword.isEmpty && passwordError == nil &&
        (newRole == .corporateAdmin || (newStoreID != nil && storeError == nil))
    }

    // MARK: - Filtered Data

    private var filteredUsers: [ManagedUser] {
        var result = authManager.users.filter { manageableUserRoles.contains($0.role) }
        if let roleFilter = selectedRoleFilter {
            result = result.filter { $0.role == roleFilter }
        }
        guard !userSearchText.isEmpty else { return result }
        let query = userSearchText.lowercased()
        return result.filter {
            $0.displayName.lowercased().contains(query)
            || $0.username.lowercased().contains(query)
            || $0.storeLocation.name.lowercased().contains(query)
            || $0.storeLocation.region.rawValue.lowercased().contains(query)
        }
    }

    private var filteredAuditLogs: [AuditLog] {
        var result = authManager.productAuditLogs
        if let actionFilter = auditFilterAction {
            result = result.filter { $0.action == actionFilter }
        }
        guard !auditSearchText.isEmpty else { return result }
        let query = auditSearchText.lowercased()
        return result.filter {
            $0.tableName.lowercased().contains(query)
            || $0.action.rawValue.lowercased().contains(query)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                    governanceHeader

                    // Create User Section
                    governanceSectionCard(
                        section: .managers,
                        icon: "person.crop.circle.badge.plus",
                        badge: ""
                    ) {
                        createUserCard
                    }
                    
                    // View & Manage Users Navigation Card
                    governanceNavigationCard(
                        title: "View & Manage Users",
                        subtitle: "See all assigned managers and inventory controllers",
                        icon: "person.2.fill",
                        destination: ManageUsersView(onNavigateToBoutique: onNavigateToBoutique)
                    )

                    // Company Policies Section
                    governanceSectionCard(
                        section: .policies,
                        icon: "doc.text.fill",
                        badge: ""
                    ) {
                        companyPoliciesContent
                    }

                    // Audit Logs Navigation Card
                    governanceNavigationCard(
                        title: "Audit Logs",
                        icon: "doc.text.magnifyingglass",
                        badge: "",
                        destination: AuditLogsView()
                    )
                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.top, MatteTheme.Spacing.lg)
                .padding(.bottom, 100)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Governance")
            .navigationBarTitleDisplayMode(.large)
            .profileToolbar(showProfile: $showProfile)
            .task {
                await authManager.refreshUsersFromSupabase()
                await authManager.fetchCompanyPolicies()
            }
            // 2FA → Edit
            .sheet(isPresented: $show2FAForEdit) {
                if let user = pending2FAUser {
                    TwoFactorVerificationSheet(
                        title: "Verify to Edit",
                        subtitle: "2FA required to modify \(user.displayName.isEmpty ? user.username : user.displayName)",
                        onSuccess: {
                            editingUser = user
                        }
                    )
                }
            }
            .sheet(item: $editingUser) { user in
                EditUserSheet(user: user, onNavigateToBoutique: onNavigateToBoutique, onSaved: { updatedUser in
                    showNoticeAfterEditing(original: user, updated: updatedUser)
                })
                .environmentObject(authManager)
            }
            // 2FA → Delete
            .sheet(isPresented: $show2FAForDelete) {
                if let user = pending2FAUser {
                    TwoFactorVerificationSheet(
                        title: "Verify to Delete",
                        subtitle: "2FA required to delete \(user.displayName.isEmpty ? user.username : user.displayName)",
                        onSuccess: {
                            userToDelete = user
                            showUserDeleteConfirmation = true
                        }
                    )
                }
            }
            .alert("Delete User", isPresented: $showUserDeleteConfirmation, presenting: userToDelete) { user in
                Button("Delete", role: .destructive) { deleteUser(user) }
                Button("Cancel", role: .cancel) {}
            } message: { user in
                Text("Delete \(user.displayName.isEmpty ? user.username : user.displayName) from \(user.storeLocation.name)?")
            }
            .alert(item: $userAssignmentNotice) { notice in
                Alert(
                    title: Text(notice.title),
                    message: Text(notice.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Policies
            .sheet(isPresented: $isAddingPolicy) {
                PolicyEditorSheet(policy: nil)
                    .environmentObject(authManager)
            }
            .sheet(item: $editingPolicy) { policy in
                PolicyEditorSheet(policy: policy)
                    .environmentObject(authManager)
            }
            .alert("Delete Policy", isPresented: $showDeleteConfirmation, presenting: policyToDelete) { policy in
                Button("Delete", role: .destructive) {
                    authManager.deleteCompanyPolicy(id: policy.id)
                }
                Button("Cancel", role: .cancel) {}
            } message: { policy in
                Text("Are you sure you want to permanently delete the policy '\(policy.title)'?")
            }
        }
    }

    // MARK: - Header

    private var governanceHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Manage store managers, policies & audit trails")
                .font(MatteTheme.Typography.caption)
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    // MARK: - Section Card Builder

    @ViewBuilder
    private func governanceSectionCard<Content: View>(
        section: GovernanceSection,
        icon: String,
        badge: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header (tap to expand/collapse)
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedSection = expandedSection == section ? nil : section
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                        .frame(width: 38, height: 38)
                        .background(MatteTheme.Colors.luxuryGold.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Text(section.rawValue)
                        .font(MatteTheme.Typography.headline)
                        .foregroundColor(MatteTheme.Colors.textPrimary)

                    Spacer()

                    if !badge.isEmpty {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.luxuryGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(MatteTheme.Colors.luxuryGold.opacity(0.12))
                            .cornerRadius(8)
                    }

                    Image(systemName: expandedSection == section ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
                .padding(MatteTheme.Spacing.cardPadding)
            }
            .buttonStyle(.plain)

            // Content
            if expandedSection == section {
                Divider()
                    .padding(.horizontal, MatteTheme.Spacing.cardPadding)

                content()
                    .padding(MatteTheme.Spacing.cardPadding)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.large))
    }

    private func governanceNavigationCard<Destination: View>(
        title: String,
        subtitle: String? = nil,
        icon: String,
        badge: String? = nil,
        destination: Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                    .frame(width: 38, height: 38)
                    .background(MatteTheme.Colors.luxuryGold.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(MatteTheme.Typography.headline)
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(MatteTheme.Typography.caption)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                }

                Spacer()

                if let badge = badge, !badge.isEmpty {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(MatteTheme.Colors.luxuryGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MatteTheme.Colors.luxuryGold.opacity(0.12))
                        .cornerRadius(8)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(MatteTheme.Colors.textTertiary)
            }
            .padding(MatteTheme.Spacing.cardPadding)
            .glassEffect(.regular, in: .rect(cornerRadius: MatteTheme.CornerRadius.large))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Store Managers Content

    @ViewBuilder
    private var storeManagersContent: some View {
        VStack(spacing: 14) {
            // Search Bar
            HStack(spacing: MatteTheme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(MatteTheme.Colors.textTertiary)
                TextField("Search users by name, email, store…", text: $userSearchText)
                    .font(MatteTheme.Typography.subheadline)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                if !userSearchText.isEmpty {
                    Button { userSearchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(MatteTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(MatteTheme.Colors.dashboardBackground)
            .cornerRadius(12)

            // Role Filter
            HStack(spacing: 8) {
                roleFilterChip(title: "All", role: nil)
                roleFilterChip(title: "Managers", role: .boutiqueManager)
                roleFilterChip(title: "Inventory", role: .inventoryController)
                Spacer()
            }

            // Create User Card
            createUserCard

            // User List
            let managers = filteredUsers.filter { $0.role == .boutiqueManager }
            let controllers = filteredUsers.filter { $0.role == .inventoryController }

            if !managers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("BOUTIQUE MANAGERS")
                        .font(.caption.weight(.bold))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                        .kerning(1)

                    ForEach(managers) { user in
                        userRowWith2FAActions(user: user)
                    }
                }
            }

            if !controllers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("INVENTORY CONTROLLERS")
                        .font(.caption.weight(.bold))
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                        .kerning(1)

                    ForEach(controllers) { user in
                        userRowWith2FAActions(user: user)
                    }
                }
            }

            if managers.isEmpty && controllers.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.slash")
                        .font(.title2)
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                    Text("No users found matching your criteria.")
                        .font(MatteTheme.Typography.subheadline)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
    }

    private func roleFilterChip(title: String, role: UserRole?) -> some View {
        let isSelected = selectedRoleFilter == role
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedRoleFilter = role
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? MatteTheme.Colors.surface : MatteTheme.Colors.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? MatteTheme.Colors.deepBlack : MatteTheme.Colors.subtleAccent)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Create User Card

    private var createUserCard: some View {
        VStack(alignment: .leading, spacing: MatteTheme.Spacing.md) {
            HStack(spacing: MatteTheme.Spacing.sm) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(MatteTheme.Colors.luxuryGold)
                Text("Create User")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
            }

            HStack(spacing: MatteTheme.Spacing.sm) {
                TextField("First Name", text: $newFirstName)
                    .validatedField(error: firstNameError)
                    .onChange(of: newFirstName) { _ in validateFirstName(realtime: true) }
                TextField("Last Name", text: $newLastName)
                    .validatedField(error: lastNameError)
                    .onChange(of: newLastName) { _ in validateLastName(realtime: true) }
            }
            TextField("Email", text: $newUsername)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .validatedField(error: emailError)
                .onChange(of: newUsername) { _ in validateEmail(realtime: true) }
            TextField("Phone Number", text: $newPhoneNumber)
                .keyboardType(.phonePad)
                .validatedField(error: phoneError)
                .onChange(of: newPhoneNumber) { _ in validatePhone(realtime: true) }
            
            VStack(alignment: .trailing, spacing: 4) {
                ZStack(alignment: .trailing) {
                    if showPassword {
                        TextField("Password", text: $newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .validatedField(error: passwordError)
                    } else {
                        SecureField("Password", text: $newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .validatedField(error: passwordError)
                    }
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .padding(.trailing, 16)
                            .padding(.bottom, passwordError != nil ? 20 : 0)
                    }
                }
                .onChange(of: newPassword) { _ in validatePassword(realtime: true) }
                
                if !newPassword.isEmpty {
                    Text("Strength: \(passwordStrength.text)")
                        .font(MatteTheme.Typography.caption)
                        .foregroundColor(passwordStrength.color)
                }
            }

            if newRole != .corporateAdmin {
                VStack(alignment: .leading, spacing: 4) {
                    Button {
                        showBoutiqueSheet = true
                    } label: {
                        HStack {
                            Text(newStoreID == nil ? "Select a Store" : (authManager.availableSupabaseStores.first(where: { $0.id == newStoreID })?.name ?? "Select a Store"))
                                .foregroundColor(newStoreID == nil ? MatteTheme.Colors.textSecondary : MatteTheme.Colors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(storeError != nil ? MatteTheme.Colors.error : Color.gray.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showBoutiqueSheet) {
                        BoutiqueSelectionSheet(
                            selectedStoreID: $newStoreID,
                            availableStores: authManager.availableSupabaseStores
                        )
                        .presentationDetents([.fraction(0.9)])
                    }
                    
                    if let storeError = storeError, !storeError.isEmpty {
                        Text(storeError)
                            .font(MatteTheme.Typography.caption)
                            .foregroundColor(MatteTheme.Colors.error)
                            .padding(.leading, 8)
                    }
                }
            }

            Picker("Role", selection: $newRole) {
                ForEach(creatableRoles) { role in
                    Text(role.rawValue).tag(role)
                }
            }
            .pickerStyle(.menu)
            .tint(MatteTheme.Colors.accent)
            .onChange(of: newRole) { _ in validateStore() }
            .onChange(of: newStoreID) { _ in validateStore() }

            Button(action: {
                createUser()
            }) {
                Text(isSubmitting ? "Creating..." : "Create Account")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.surface)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: MatteTheme.CornerRadius.medium)
                            .fill(MatteTheme.Colors.primaryGold)
                    )
                    .opacity(isFormValid && !isSubmitting ? 1.0 : 0.6)
            }
            .disabled(!isFormValid || isSubmitting)

            if let statusMessage {
                Text(statusMessage)
                    .font(MatteTheme.Typography.footnote)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
        }
        .padding(16)
        .background(MatteTheme.Colors.dashboardBackground)
        .cornerRadius(16)
    }

    // MARK: - User Row with 2FA Actions

    private func userRowWith2FAActions(user: ManagedUser) -> some View {
        HStack(spacing: MatteTheme.Spacing.sm) {
            userRow(user: user)
            Spacer(minLength: MatteTheme.Spacing.xs)

            Button {
                pending2FAUser = user
                show2FAForEdit = true
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.accent)
                    .frame(width: 38, height: 38)
                    .background(MatteTheme.Colors.accent.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button {
                pending2FAUser = user
                show2FAForDelete = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(MatteTheme.Colors.error)
                    .frame(width: 38, height: 38)
                    .background(MatteTheme.Colors.error.opacity(0.10))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private func userRow(user: ManagedUser) -> some View {
        HStack(spacing: MatteTheme.Spacing.md) {
            Circle()
                .fill(MatteTheme.Colors.roleColor(for: user.role).opacity(0.12))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: user.role.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(MatteTheme.Colors.roleColor(for: user.role))
                )

            VStack(alignment: .leading, spacing: MatteTheme.Spacing.xs) {
                Text(user.displayName.isEmpty ? user.username : user.displayName)
                    .font(MatteTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                    .lineLimit(1)
                Text("\(user.role.rawValue) — \(user.storeLocation.region.rawValue)")
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: MatteTheme.Spacing.xs)

            BadgeView(
                text: user.isActive ? "Active" : "Inactive",
                color: user.isActive ? MatteTheme.Colors.success : Color.orange
            )
        }
        .padding(.vertical, MatteTheme.Spacing.xs)
    }

    // MARK: - Company Policies Content

    @ViewBuilder
    private var companyPoliciesContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            if authManager.companyPolicies.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                    Text("No company policies have been created yet.")
                        .font(MatteTheme.Typography.subheadline)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(authManager.companyPolicies) { policy in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(policy.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(MatteTheme.Colors.textPrimary)
                            Spacer()

                            HStack(spacing: 14) {
                                Button {
                                    editingPolicy = policy
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.subheadline)
                                        .foregroundColor(MatteTheme.Colors.primaryGold)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    policyToDelete = policy
                                    showDeleteConfirmation = true
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.subheadline)
                                        .foregroundColor(MatteTheme.Colors.error)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text(policy.content)
                            .font(.caption)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .lineLimit(3)

                        Text("Last updated: \(policy.lastUpdated, style: .date) \(policy.lastUpdated, style: .time)")
                            .font(.system(size: 10))
                            .foregroundColor(MatteTheme.Colors.textTertiary)

                        if policy.id != authManager.companyPolicies.last?.id {
                            Divider().padding(.top, 6)
                        }
                    }
                }
            }

            Button {
                isAddingPolicy = true
            } label: {
                Label("Add Policy", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(MatteTheme.Colors.surface)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(MatteTheme.Colors.deepBlack)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    // MARK: - Audit Logs Content

    @ViewBuilder
    private var auditLogsContent: some View {
        VStack(spacing: 14) {
            // Search & Filter
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                        .font(.caption)
                    TextField("Search logs…", text: $auditSearchText)
                        .font(.caption)
                        .foregroundColor(MatteTheme.Colors.textPrimary)
                }
                .padding(10)
                .background(MatteTheme.Colors.dashboardBackground)
                .cornerRadius(10)

                Menu {
                    Button("All Actions") { auditFilterAction = nil }
                    Button("Create") { auditFilterAction = .create }
                    Button("Update") { auditFilterAction = .update }
                    Button("Delete") { auditFilterAction = .delete }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(auditFilterAction?.rawValue ?? "Filter")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(MatteTheme.Colors.dashboardBackground)
                    .cornerRadius(10)
                }
            }

            let logs = filteredAuditLogs
            if logs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                    Text("No audit entries found.")
                        .font(MatteTheme.Typography.subheadline)
                        .foregroundColor(MatteTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(Array(logs.prefix(15))) { log in
                    HStack(spacing: 12) {
                        Image(systemName: auditIcon(for: log.action))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(auditColor(for: log.action))
                            .frame(width: 30, height: 30)
                            .background(auditColor(for: log.action).opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(log.action.rawValue)
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(auditColor(for: log.action))
                                Text("—")
                                    .font(.caption)
                                    .foregroundColor(MatteTheme.Colors.textTertiary)
                                Text(log.tableName)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(MatteTheme.Colors.textPrimary)
                            }
                            Text(log.modifiedAt, style: .relative)
                                .font(.system(size: 10))
                                .foregroundColor(MatteTheme.Colors.textTertiary)
                        }

                        Spacer()

                        Circle()
                            .fill(auditColor(for: log.action))
                            .frame(width: 6, height: 6)
                    }
                    .padding(.vertical, 3)

                    if log.id != logs.prefix(15).last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func auditIcon(for action: AuditAction) -> String {
        switch action {
        case .create: return "plus.circle.fill"
        case .update: return "pencil.circle.fill"
        case .delete: return "trash.circle.fill"
        }
    }

    private func auditColor(for action: AuditAction) -> Color {
        switch action {
        case .create: return MatteTheme.Colors.success
        case .update: return MatteTheme.Colors.primaryGold
        case .delete: return MatteTheme.Colors.error
        }
    }

    private func createUser() {
        validateFirstName(realtime: false)
        validateLastName(realtime: false)
        validateEmail(realtime: false)
        validatePhone(realtime: false)
        validatePassword(realtime: false)
        validateStore()
        
        if firstNameError != nil || lastNameError != nil || emailError != nil || phoneError != nil || passwordError != nil || storeError != nil {
            return
        }
        
        isSubmitting = true
        statusMessage = nil
        
        let request = NewUserRequest(
            username: newUsername,
            password: newPassword,
            displayName: "\(newFirstName.trimmingCharacters(in: .whitespacesAndNewlines)) \(newLastName.trimmingCharacters(in: .whitespacesAndNewlines))".trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: newPhoneNumber,
            role: newRole,
            storeID: newStoreID
        )
        Task {
            do {
                try await authManager.createUser(request)
                await MainActor.run {
                    isSubmitting = false
                    newUsername = ""
                    newPassword = ""
                    newFirstName = ""
                    newLastName = ""
                    newPhoneNumber = ""
                    newStoreID = nil
                    statusMessage = "Account created successfully."
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    statusMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Validation
    
    private func validateName(text: inout String, realtime: Bool, fieldName: String) -> String? {
        if realtime {
            // Trim leading/multiple spaces, capitalize first letter
            if text.hasPrefix(" ") {
                text = String(text.dropFirst())
            }
            if text.contains("  ") {
                text = text.replacingOccurrences(of: "  ", with: " ")
            }
            if let first = text.first, first.isLowercase {
                text = first.uppercased() + text.dropFirst()
            }
        }
        
        if text.isEmpty {
            return realtime ? nil : "\(fieldName) is required."
        }
        if text.count < 2 {
            return "\(fieldName) must contain at least 2 characters."
        }
        if text.count > 30 {
            return "\(fieldName) cannot exceed 30 characters."
        }
        
        let numbers = CharacterSet.decimalDigits
        if text.rangeOfCharacter(from: numbers) != nil {
            return "\(fieldName) cannot contain numbers."
        }
        
        let lettersAndSpaces = CharacterSet.letters.union(CharacterSet.whitespaces)
        let specialChars = text.unicodeScalars.filter { !lettersAndSpaces.contains($0) }
        if !specialChars.isEmpty {
            return "\(fieldName) cannot contain special characters."
        }
        
        return nil
    }
    
    private func validateFirstName(realtime: Bool) {
        firstNameError = validateName(text: &newFirstName, realtime: realtime, fieldName: "First name")
    }
    
    private func validateLastName(realtime: Bool) {
        lastNameError = validateName(text: &newLastName, realtime: realtime, fieldName: "Last name")
    }
    
    private func validateEmail(realtime: Bool) {
        if realtime {
            newUsername = newUsername.replacingOccurrences(of: " ", with: "").lowercased()
        }
        
        if newUsername.isEmpty {
            emailError = realtime ? nil : "Email is required."
            return
        }
        
        if newUsername.contains(" ") {
            emailError = "Email cannot contain spaces."
            return
        }
        
        if !newUsername.contains("@") {
            emailError = "Email must contain '@gmail.com'."
            return
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailPred.evaluate(with: newUsername) {
            emailError = "Enter a valid email address."
            return
        }
        
        if !newUsername.hasSuffix("@gmail.com") {
            emailError = "Only Gmail addresses are allowed."
            return
        }
        
        if authManager.users.contains(where: { $0.email.lowercased() == newUsername.lowercased() }) {
            emailError = "Email already exists."
            return
        }
        
        emailError = nil
    }
    
    private func validatePhone(realtime: Bool) {
        if realtime {
            newPhoneNumber = newPhoneNumber.replacingOccurrences(of: " ", with: "")
            if newPhoneNumber.count > 10 {
                newPhoneNumber = String(newPhoneNumber.prefix(10))
            }
        }
        
        if newPhoneNumber.isEmpty {
            phoneError = realtime ? nil : "Phone number is required."
            return
        }
        
        if newPhoneNumber.contains(" ") {
            phoneError = "Phone number cannot contain spaces."
            return
        }
        
        let letters = CharacterSet.letters
        if newPhoneNumber.rangeOfCharacter(from: letters) != nil {
            phoneError = "Phone number cannot contain letters."
            return
        }
        
        let nonNumbers = CharacterSet.decimalDigits.inverted
        if newPhoneNumber.rangeOfCharacter(from: nonNumbers) != nil {
            phoneError = "Phone number can contain numbers only."
            return
        }
        
        if newPhoneNumber.count < 10 {
            phoneError = "Phone number must contain exactly 10 digits."
            return
        }
        
        if newPhoneNumber.count > 10 {
            phoneError = "Phone number must contain exactly 10 digits."
            return
        }
        
        if authManager.users.contains(where: { $0.phoneNumber == newPhoneNumber }) {
            phoneError = "Phone number already exists."
            return
        }
        
        phoneError = nil
    }
    
    private func validatePassword(realtime: Bool) {
        let pass = newPassword
        
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
        
        // Hard validation errors
        if pass.isEmpty {
            passwordError = realtime ? nil : "Password is required."
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
        
        let fName = newFirstName.trimmingCharacters(in: .whitespaces).lowercased()
        if !fName.isEmpty && pass.lowercased().contains(fName) {
            passwordError = "Password cannot contain your first name."
            return
        }
        
        let lName = newLastName.trimmingCharacters(in: .whitespaces).lowercased()
        if !lName.isEmpty && pass.lowercased().contains(lName) {
            passwordError = "Password cannot contain your last name."
            return
        }
        
        let emailUsername = newUsername.components(separatedBy: "@").first?.lowercased() ?? ""
        if !emailUsername.isEmpty && pass.lowercased().contains(emailUsername) {
            passwordError = "Password cannot contain your email name."
            return
        }
        
        if !newPhoneNumber.isEmpty && pass == newPhoneNumber {
            passwordError = "Password cannot be your phone number."
            return
        }
        
        passwordError = nil
    }
    
    private func validateStore() {
        if newRole == .corporateAdmin {
            storeError = nil
            return
        }
        
        guard let storeID = newStoreID else {
            storeError = "Store assignment is required."
            return
        }
        
        if newRole == .boutiqueManager {
            let hasManager = authManager.users.contains { user in
                user.role == .boutiqueManager && user.assignedStoreID == storeID && user.isActive
            }
            if hasManager {
                storeError = "This boutique already has an assigned Boutique Manager."
                return
            }
        }
        
        storeError = nil
    }

    private func deleteUser(_ user: ManagedUser) {
        Task {
            do {
                let removedUser = try await authManager.deleteManagedUser(id: user.id)
                await MainActor.run {
                    userAssignmentNotice = replacementNotice(for: removedUser)
                }
            } catch {
                await MainActor.run {
                    userAssignmentNotice = UserAssignmentNotice(
                        title: "Delete Failed",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    private func showNoticeAfterEditing(original: ManagedUser, updated: ManagedUser) {
        let changedAssignment = original.assignedStoreID != updated.assignedStoreID
        let changedRole = original.role != updated.role
        let deactivated = original.isActive && !updated.isActive
        guard changedAssignment || changedRole || deactivated else { return }
        userAssignmentNotice = replacementNotice(for: original)
    }

    private func replacementNotice(for user: ManagedUser) -> UserAssignmentNotice? {
        let replacementRole: String
        switch user.role {
        case .boutiqueManager:
            replacementRole = "Boutique Manager"
        case .inventoryController:
            replacementRole = "Inventory Controller"
        case .corporateAdmin, .salesAssociate:
            return nil
        }
        let person = user.displayName.isEmpty ? user.username : user.displayName
        return UserAssignmentNotice(
            title: "Store Assignment Needed",
            message: "\(person) was related to \(user.storeLocation.name), \(user.storeLocation.region.rawValue). This store will need a new \(replacementRole) now."
        )
    }
}

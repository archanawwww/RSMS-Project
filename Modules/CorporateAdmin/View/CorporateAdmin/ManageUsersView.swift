import SwiftUI

struct ManageUsersView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    var onNavigateToBoutique: ((BoutiqueRoute) -> Void)?
    
    // Manage Users State
    @State private var userSearchText = ""
    @State private var isManagersExpanded = false
    @State private var isControllersExpanded = false
    
    @State private var show2FAForEdit = false
    @State private var show2FAForDelete = false
    @State private var pending2FAUser: ManagedUser? = nil
    @State private var editingUser: ManagedUser? = nil
    
    @State private var userToDelete: ManagedUser? = nil
    @State private var showUserDeleteConfirmation = false
    @State private var userAssignmentNotice: UserAssignmentNotice? = nil
    
    private var filteredUsers: [ManagedUser] {
        let result = authManager.users
        guard !userSearchText.isEmpty else { return result }
        let query = userSearchText.lowercased()
        return result.filter {
            $0.username.lowercased().contains(query)
            || $0.displayName.lowercased().contains(query)
            || $0.storeLocation.name.lowercased().contains(query)
            || $0.storeLocation.region.rawValue.lowercased().contains(query)
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 4) {
                Text("All Users")
                    .font(.title.weight(.bold))
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                Text("Managers & Inventory Controllers")
                    .font(MatteTheme.Typography.subheadline)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
            }
            .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
            .padding(.top, MatteTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            viewManageContent
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.bottom, 100)
        }
        .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        // Sheets & Alerts
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
    }
    
    @ViewBuilder
    private var viewManageContent: some View {
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
            .background(Color.white)
            .cornerRadius(12)
            .padding(.top, 10)



            // User List
            let managers = filteredUsers.filter { $0.role == .boutiqueManager }
            let controllers = filteredUsers.filter { $0.role == .inventoryController }

            if !managers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("STORE MANAGERS")
                            .font(.caption.weight(.bold))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .kerning(1)
                    }
                    .padding(.top, 10)

                    let displayedManagers = isManagersExpanded ? managers : Array(managers.prefix(5))
                    ForEach(displayedManagers) { user in
                        userRowWith2FAActions(user: user)
                    }
                    if managers.count > 5 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isManagersExpanded.toggle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(isManagersExpanded ? "Show Less" : "Show All (\(managers.count))")
                                Image(systemName: isManagersExpanded ? "chevron.up" : "chevron.down")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                }
            }

            if !controllers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("INVENTORY CONTROLLERS")
                            .font(.caption.weight(.bold))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .kerning(1)
                    }
                    .padding(.top, 10)

                    let displayedControllers = isControllersExpanded ? controllers : Array(controllers.prefix(5))
                    ForEach(displayedControllers) { user in
                        userRowWith2FAActions(user: user)
                    }
                    if controllers.count > 5 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isControllersExpanded.toggle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(isControllersExpanded ? "Show Less" : "Show All (\(controllers.count))")
                                Image(systemName: isControllersExpanded ? "chevron.up" : "chevron.down")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
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
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
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

            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName.isEmpty ? user.username : user.displayName)
                    .font(MatteTheme.Typography.headline)
                    .foregroundColor(MatteTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                Text(user.role.rawValue)
                    .font(MatteTheme.Typography.caption)
                    .foregroundColor(MatteTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("Active")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MatteTheme.Colors.surface)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(MatteTheme.Colors.success)
                .cornerRadius(12)
        }
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
                        message: "Could not remove user. \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    private func replacementNotice(for user: ManagedUser) -> UserAssignmentNotice {
        return UserAssignmentNotice(
            title: "User Removed",
            message: "You have removed \(user.displayName.isEmpty ? user.username : user.displayName) from \(user.storeLocation.name)."
        )
    }

    private func showNoticeAfterEditing(original: ManagedUser, updated: ManagedUser) {
        if original.storeLocation.id != updated.storeLocation.id {
            userAssignmentNotice = UserAssignmentNotice(
                title: "User Reassigned",
                message: "\(updated.displayName.isEmpty ? updated.username : updated.displayName) has been moved to \(updated.storeLocation.name)."
            )
        }
    }
}

struct UserAssignmentNotice: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

import SwiftUI

// MARK: - Profile Sheet View

/// Shared profile sheet accessible from the top-right toolbar across all roles.
/// Shows profile details and sign out for everyone.
/// Conditionally shows "Create User" for Corporate Admin and Boutique Manager.
struct ProfileSheetView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    profileCard
                    signOutButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let user = authManager.currentUser {
                HStack(spacing: 14) {
                    Circle()
                        .fill(MatteTheme.Colors.roleColor(for: user.role).opacity(0.14))
                        .frame(width: 58, height: 58)
                        .overlay(
                            Image(systemName: user.role.icon)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(MatteTheme.Colors.roleColor(for: user.role))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.displayName)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(MatteTheme.Colors.textSecondary)
                    }
                }

                Divider().background(MatteTheme.Colors.border)

                profileRow(title: "Role", value: user.role.rawValue)
                profileRow(title: "Store", value: user.storeName)
                profileRow(title: "Region", value: "\(user.region.rawValue), \(user.country.rawValue)")
            }
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }

    private func profileRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(MatteTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(MatteTheme.Colors.textPrimary)
        }
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button(action: {
            withAnimation {
                authManager.logout()
                dismiss()
            }
        }) {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .foregroundColor(MatteTheme.Colors.ivoryMatte)
                .frame(maxWidth: .infinity)
                .padding()
                .background(MatteTheme.Colors.espresso)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(MatteTheme.Colors.primaryGold.opacity(0.22), lineWidth: 1)
                )
        }
    }
}

// MARK: - Matte Field Style

extension View {
    func matteFieldStyle() -> some View {
        self
            .textFieldStyle(.plain)
            .padding(14)
            .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
}

// MARK: - Profile Toolbar Modifier

/// Adds the standard top-right profile button to any view.
struct ProfileToolbar: ViewModifier {
    @Binding var showProfile: Bool

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfileSheetView()) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(MatteTheme.Colors.espresso)
                            .frame(width: 32, height: 32)
                            .background(MatteTheme.Colors.primaryGold.opacity(0.2))
                            .clipShape(Circle())
                            .padding(4)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                    }
                }
            }
    }
}

extension View {
    func profileToolbar(showProfile: Binding<Bool>) -> some View {
        modifier(ProfileToolbar(showProfile: showProfile))
    }
}

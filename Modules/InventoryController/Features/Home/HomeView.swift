import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: InventoryAppState
    @EnvironmentObject var shipmentsViewModel: ShipmentsViewModel
    @State private var isShowingProfile = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HomeHeaderView(
                        userName: "Rahul"
                    )
                    .padding(.bottom, 4)

                    todaySection
                    upcomingDeliveriesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingProfile = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.primary)

                       }
                    }
                }
            }
            .navigationDestination(for: AppDestination.self) { _ in }
            .sheet(isPresented: $isShowingProfile) {
                ProfileView()
            }
            .task {
                await viewModel.loadData()
            }
            .background(Color.theme.background.ignoresSafeArea())
        }
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text("Today")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)

            }

            // 2-column grid of workflow cards
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ],
                spacing: 12
            ) {
                // ── Receive Delivery (Primary / Black icon) ───────────────
                WorkflowCard(
                    icon: "box.truck.fill",
                    iconColor: .primary,
                    title: "Incoming Shipment",
                    subtitle: viewModel.receiveDeliveryBadge > 0 ? "\(viewModel.receiveDeliveryBadge) shipment in transit" : "No shipment today",
                    detail: nil,
                    caption: "",
                    badgeCount: viewModel.receiveDeliveryBadge,
                    isPrimary: true,
                    showPendingLabel: false,
                    action: { appState.selectedTab = 2 }
                )

                // ── Review Low Stock (Warning / Orange) ───────────────
                WorkflowCard(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: Color.theme.warning,
                    title: "Review Low Stock",
                    subtitle: viewModel.lowStockBadge > 0 ? "\(viewModel.lowStockBadge) products below threshold" : "Stock levels optimal",
                    detail: nil,
                    caption: "",
                    badgeCount: viewModel.lowStockBadge,
                    isPrimary: false,
                    showPendingLabel: false,
                    action: { appState.selectedTab = 3 }
                )

                // ── Cycle Count (Monochrome) ───────────────────────────
                WorkflowCard(
                    icon: "barcode.viewfinder",
                    iconColor: .primary,
                    title: "Cycle Count",
                    subtitle: viewModel.cycleCountBadge > 0 ? "\(viewModel.cycleCountBadge) Products" : "No tasks today",
                    detail: nil,
                    caption: "",
                    badgeCount: viewModel.cycleCountBadge,
                    isPrimary: false,
                    showPendingLabel: false,
                    action: { appState.selectedTab = 3 }
                )

                // ── Review Requests (Monochrome + pending label) ───────
                WorkflowCard(
                    icon: "list.bullet.clipboard.fill",
                    iconColor: .primary,
                    title: "Review Requests",
                    subtitle: viewModel.reviewRequestsBadge > 0 ? "\(viewModel.reviewRequestsBadge) Pending Approvals" : "No pending requests",
                    detail: nil,
                    caption: "",
                    badgeCount: viewModel.reviewRequestsBadge,
                    isPrimary: false,
                    showPendingLabel: false,
                    action: { appState.selectedTab = 1 }
                )
            }
        }
    }

    // MARK: - Upcoming Deliveries Section

    private var upcomingDeliveriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text("Upcoming Deliveries")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button("View All") {
                    appState.selectedTab = 2
                    shipmentsViewModel.selectedTab = .active
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.theme.workflowPurple)
            }

            if viewModel.deliveries.isEmpty {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.035), radius: 12, x: 0, y: 6)
                    .frame(height: 64)
                    .overlay(
                        Text("No upcoming deliveries")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.deliveries.enumerated()), id: \.offset) { index, delivery in
                        UpcomingDeliveryRow(
                            vendorName: delivery.vendorName,
                            skuCount: delivery.skuCount
                        )
                        .padding(.horizontal, 20)

                        if index < viewModel.deliveries.count - 1 {
                            Divider()
                                .padding(.leading, 72)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.035), radius: 12, x: 0, y: 6)
                )
            }
        }
    }
}

#Preview {
    HomeView()
}

import SwiftUI
import Charts

// MARK: - Operations View (Tab 3)

/// Tab 3 — Promotions & Campaigns, Planograms, Sales Reports,
/// Inventory Health, Unified Business Reports, Campaign Analytics.
struct OperationsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    // Section expansion
    @State private var expandedSection: OpsSection? = .promotions

    enum OpsSection: String, CaseIterable {
        case promotions = "Promotions & Campaigns"
        case planograms = "Planograms"

    }

    // MARK: - Mock Promotion Data

    private struct MockPromotion: Identifiable {
        let id = UUID()
        let title: String
        let status: String
        let statusColor: Color
        let discount: String
        let dateRange: String
        let reach: String
    }

    private let mockPromotions: [MockPromotion] = [
        .init(title: "Monsoon Luxury Sale", status: "Active", statusColor: MatteTheme.Colors.success, discount: "15% Off", dateRange: "Jun 15 – Jul 31", reach: "2,400"),
        .init(title: "Diwali Celebration", status: "Draft", statusColor: MatteTheme.Colors.warning, discount: "20% Off", dateRange: "Oct 15 – Nov 15", reach: "—"),
        .init(title: "Summer Clearance", status: "Expired", statusColor: MatteTheme.Colors.textTertiary, discount: "₹5,000 Flat", dateRange: "Apr 1 – May 31", reach: "1,850"),
        .init(title: "Heritage Collection Launch", status: "Active", statusColor: MatteTheme.Colors.success, discount: "10% Off", dateRange: "Jun 1 – Aug 31", reach: "3,200")
    ]

    // MARK: - Mock Planogram Data

    private struct MockPlanogram: Identifiable {
        let id = UUID()
        let title: String
        let version: String
        let store: String
        let status: String
        let statusColor: Color
    }

    private let mockPlanograms: [MockPlanogram] = [
        .init(title: "Monsoon Window Display V2", version: "2.0", store: "Mumbai Flagship", status: "Published", statusColor: MatteTheme.Colors.success),
        .init(title: "Heritage Wall Layout", version: "1.0", store: "Delhi Boutique", status: "Pending", statusColor: MatteTheme.Colors.warning),
        .init(title: "Accessories Island Refresh", version: "3.1", store: "Bangalore Store", status: "Compliant", statusColor: MatteTheme.Colors.info),
        .init(title: "Watch Showcase Redesign", version: "1.0", store: "Chennai Mall", status: "Draft", statusColor: MatteTheme.Colors.textTertiary)
    ]


    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MatteTheme.Spacing.sectionSpacing) {
                    operationsHeader

                    // Promotions & Campaigns
                    operationsSectionCard(
                        section: .promotions,
                        icon: "megaphone.fill",
                        iconColor: MatteTheme.Colors.luxuryGold,
                        badge: ""
                    ) {
                        promotionsContent
                    }

                    // Planograms & Merchandising
                    operationsSectionCard(
                        section: .planograms,
                        icon: "rectangle.split.3x3",
                        iconColor: MatteTheme.Colors.info,
                        badge: ""
                    ) {
                        planogramsContent
                    }


                }
                .padding(.horizontal, MatteTheme.Spacing.horizontalMargin)
                .padding(.top, MatteTheme.Spacing.lg)
                .padding(.bottom, 100)
            }
            .background(MatteTheme.Colors.dashboardBackground.ignoresSafeArea())
            .navigationTitle("Operations")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Header

    private var operationsHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Campaigns, reports & business analytics")
                .font(MatteTheme.Typography.caption)
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    // MARK: - Section Card Builder

    @ViewBuilder
    private func operationsSectionCard<Content: View>(
        section: OpsSection,
        icon: String,
        iconColor: Color,
        badge: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedSection = expandedSection == section ? nil : section
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                        .frame(width: 38, height: 38)
                        .background(iconColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.rawValue)
                            .font(MatteTheme.Typography.headline)
                            .foregroundColor(MatteTheme.Colors.textPrimary)
                    }

                    Spacer()

                    if !badge.isEmpty {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(iconColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(iconColor.opacity(0.12))
                            .cornerRadius(8)
                    }

                    Image(systemName: expandedSection == section ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(MatteTheme.Colors.textTertiary)
                }
                .padding(MatteTheme.Spacing.cardPadding)
            }
            .buttonStyle(.plain)

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

    // MARK: - Promotions & Campaigns Content

    @ViewBuilder
    private var promotionsContent: some View {
        VStack(spacing: 14) {
            // Summary Stats
            HStack(spacing: 0) {
                promoStat(value: "4", label: "Total", color: MatteTheme.Colors.textPrimary)
                Divider().frame(height: 32)
                promoStat(value: "2", label: "Active", color: MatteTheme.Colors.success)
                Divider().frame(height: 32)
                promoStat(value: "1", label: "Draft", color: MatteTheme.Colors.warning)
                Divider().frame(height: 32)
                promoStat(value: "1", label: "Expired", color: MatteTheme.Colors.textTertiary)
            }
            .padding(.vertical, 10)
            .background(MatteTheme.Colors.dashboardBackground)
            .cornerRadius(12)

            // Promotion Cards
            ForEach(mockPromotions) { promo in
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(promo.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)

                        HStack(spacing: 8) {
                            Text(promo.discount)
                                .font(.caption.weight(.bold))
                                .foregroundColor(MatteTheme.Colors.luxuryGold)

                            Text("•")
                                .foregroundColor(MatteTheme.Colors.textTertiary)

                            Text(promo.dateRange)
                                .font(.caption)
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }

                        if promo.reach != "—" {
                            Text("Reach: \(promo.reach) customers")
                                .font(.system(size: 10))
                                .foregroundColor(MatteTheme.Colors.textTertiary)
                        }
                    }

                    Spacer()

                    Text(promo.status)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(promo.statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(promo.statusColor.opacity(0.12))
                        .cornerRadius(8)
                }
                .padding(.vertical, 6)

                if promo.id != mockPromotions.last?.id {
                    Divider()
                }
            }
        }
    }

    private func promoStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(MatteTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Planograms Content

    @ViewBuilder
    private var planogramsContent: some View {
        VStack(spacing: 12) {
            ForEach(mockPlanograms) { planogram in
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(planogram.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(MatteTheme.Colors.textPrimary)

                        HStack(spacing: 8) {
                            Text("v\(planogram.version)")
                                .font(.caption.weight(.medium))
                                .foregroundColor(MatteTheme.Colors.luxuryGold)

                            Text("•")
                                .foregroundColor(MatteTheme.Colors.textTertiary)

                            Text(planogram.store)
                                .font(.caption)
                                .foregroundColor(MatteTheme.Colors.textSecondary)
                        }
                    }

                    Spacer()

                    Text(planogram.status)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(planogram.statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(planogram.statusColor.opacity(0.12))
                        .cornerRadius(8)
                }
                .padding(.vertical, 6)

                if planogram.id != mockPlanograms.last?.id {
                    Divider()
                }
            }
        }
    }


}

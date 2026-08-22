import SwiftUI
import Charts

// MARK: - Corporate Admin Tab View (iOS 26 Liquid Glass — 3-Tab Shell)

/// The root tab view for Corporate Admin. Routes to:
/// - Tab 0: BoutiqueInventoryView (Boutiques & Inventory Hub)
/// - Tab 1: GovernanceView (Store Managers, Policies, Audit Logs)
/// - Tab 2: MasterCatalogView (Operations / Product Catalog Hub)
struct CorporateAdminTabView: View {
    enum Tab: Int {
        case governance
        case operations
    }

    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab: Tab = .governance
    @State private var boutiqueNavigationPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab 1: Governance
            GovernanceView(onNavigateToBoutique: { _ in
                // Boutiques tab is hidden, no-op
            })
                .tabItem {
                    Label("Governance", systemImage: "building.columns")
                }
                .tag(Tab.governance)

            // MARK: - Tab 2: Operations (Unified)
            MasterCatalogView()
                .tabItem {
                    Label("Operations", systemImage: "chart.bar.xaxis")
                }
                .tag(Tab.operations)
        }
        .tint(MatteTheme.Colors.luxuryGold)
    }
}

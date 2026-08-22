import SwiftUI

struct OverviewCardsView: View {
    let summary: DashboardSummary
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.standard) {
            MetricCard(title: "Current Stock", value: "\(summary.totalStock)", icon: "shippingbox", color: .primary)
            MetricCard(title: "Low Stock Items", value: "\(summary.lowStockItems)", icon: "exclamationmark.triangle", color: Color.theme.rejected)
            MetricCard(title: "Pending Requests", value: "\(summary.pendingRequests)", icon: "list.bullet.clipboard", color: Color.theme.pending)
            MetricCard(title: "Incoming Shipments", value: "\(summary.incomingShipments)", icon: "box.truck", color: Color.theme.inTransit)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Text(value)
                    .font(Typography.title)
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(title)
                    .font(Typography.caption)
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    OverviewCardsView(summary: DashboardSummary(id: 1, totalStock: 12500, lowStockItems: 42, pendingRequests: 12, incomingShipments: 8))
        .padding()
        .background(Color.theme.background)
}

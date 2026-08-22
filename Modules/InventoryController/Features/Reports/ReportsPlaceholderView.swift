import SwiftUI

struct ReportsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            EmptyStateView(
                iconName: "chart.bar.fill",
                message: "Reporting features arrive in Sprint 3"
            )
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ReportsPlaceholderView()
}

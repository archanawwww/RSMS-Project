import SwiftUI

// MARK: - Completed Cycle Count Summary

/// Shown when the Inventory Controller taps a *Completed* cycle count.
/// Everything is read-only. The primary action is viewing the generated report.
struct CompletedCycleCountSummaryView: View {

    let session: CycleCountSession

    // Look up the matching report record from the shared store
    @ObservedObject private var store = ReportsStore.shared
    @Environment(\.dismiss) private var dismiss

    private var sourceReport: ReportRecord? {
        store.records.first { $0.cycleCountName == session.title && $0.type == .cycleCountCompleted }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Card 1: Status ─────────────────────────────────────────
                sectionLabel("Summary")
                cardGroup {
                    cardRow(label: "Status",       value: "Completed", isFirst: true)
                    cardRow(label: "Completed On", value: session.completedDate ?? session.dateLabel)
                }
                .padding(.horizontal, 16)

                // ── Card 2: Count Results ──────────────────────────────────
                sectionLabel("Count Results")
                cardGroup {
                    cardRow(label: "Products Counted",
                            value: session.total > 0 ? "\(session.total)" : "\(session.counted)",
                            isFirst: true)
                    cardRow(label: "Variances",
                            value: "\(session.variance)",
                            valueColor: session.variance > 0 ? Color(UIColor.systemOrange) : Color(UIColor.label))
                    cardRow(label: "Resolved",
                            value: session.isResolved ? "Yes" : "No")
                }
                .padding(.horizontal, 16)

                if !session.completedResults.filter({ $0.variance != 0 }).isEmpty {
                    sectionLabel("Recorded Variances")
                    varianceList
                        .padding(.horizontal, 16)
                }

                // ── Card 3: System Status ──────────────────────────────────
                sectionLabel("System Status")
                cardGroup {
                    cardRow(label: "Inventory Updated",
                            value: session.inventoryUpdated ? "Yes" : "Pending",
                            isFirst: true)
                }
                .padding(.horizontal, 16)

                // ── Read-only notice ───────────────────────────────────────
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                    Text("This cycle count is complete and cannot be edited.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if let report = sourceReport {
                        NavigationLink(destination: ReportDetailView(record: report)) {
                            Label("View Report", systemImage: "doc.text.magnifyingglass")
                        }
                    }
                    Divider()
                    Button {
                        CycleCountStore.shared.toggleHold(for: session.id)
                    } label: {
                        Label(
                            session.isOnHold ? "Resume" : "Hold",
                            systemImage: session.isOnHold ? "play.fill" : "pause.fill"
                        )
                    }
                    Divider()
                    Button("Delete", role: .destructive) {
                        Task {
                            await CycleCountStore.shared.deleteSessionFromDB(id: session.id)
                            dismiss()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }

    // MARK: - Grouped Card Container

    private func cardGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
        .shadow(
            color: .black.opacity(Spacing.Shadow.opacity),
            radius: Spacing.Shadow.radius,
            x: 0,
            y: Spacing.Shadow.yOffset
        )
    }

    private var varianceList: some View {
        VStack(spacing: 0) {
            ForEach(Array(session.completedResults.filter { $0.variance != 0 }.enumerated()), id: \.element.id) { index, result in
                if index > 0 {
                    Divider().padding(.leading, 16)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(result.productName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(UIColor.label))
                        Spacer()
                        Text(result.variance > 0 ? "+\(result.variance)" : "\(result.variance)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(result.variance < 0 ? Color(UIColor.systemRed) : Color(UIColor.systemOrange))
                    }
                    Text("Expected \(result.expected) | Counted \(result.counted)")
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    if let reason = result.reason {
                        Text(reason)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(UIColor.label))
                    }
                    if let notes = result.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 13))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
        .shadow(
            color: .black.opacity(Spacing.Shadow.opacity),
            radius: Spacing.Shadow.radius,
            x: 0,
            y: Spacing.Shadow.yOffset
        )
    }

    @ViewBuilder
    private func cardRow(
        label: String,
        value: String,
        valueColor: Color = Color(UIColor.label),
        isFirst: Bool = false
    ) -> some View {
        if !isFirst {
            Divider().padding(.leading, 16)
        }
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.secondaryLabel))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

}



#Preview {
    NavigationStack {
        CompletedCycleCountSummaryView(
            session: CycleCountSession(
                title: "Vault B Audit",
                dateLabel: "30 Jun 2025",
                status: .completed,
                counted: 60,
                total: 60,
                variance: 3,
                completedDate: "30 Jun 2025",
                isResolved: true,
                inventoryUpdated: true
            )
        )
    }
}

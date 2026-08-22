import SwiftUI

// MARK: - Report Detail Screen

struct ReportDetailView: View {
    let record: ReportRecord

    @EnvironmentObject var appState: InventoryAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                
                summaryCard

                
                if record.sku != nil || record.category != nil {
                    sectionCard("Product Information") {
                        detailRow("Product", value: record.entityName)
                        if let sku = record.sku {
                            Divider().padding(.leading, 16)
                            detailRow("SKU", value: sku)
                        }
                        if let cat = record.category {
                            Divider().padding(.leading, 16)
                            detailRow("Category", value: cat)
                        }
                        if let loc = record.location {
                            Divider().padding(.leading, 16)
                            detailRow("Location", value: loc)
                        }
                    }
                }

                // ── Count Details ─────────────────────────────────────────
                if record.expectedQty != nil || record.countedQty != nil {
                    sectionCard("Count Details") {
                        if let cc = record.cycleCountName {
                            cycleCountLinkRow(cc)
                            Divider().padding(.leading, 16)
                        }
                        if let exp = record.expectedQty {
                            detailRow("Expected Quantity", value: "\(exp) Units")
                            Divider().padding(.leading, 16)
                        }
                        if let cnt = record.countedQty {
                            detailRow("Counted Quantity", value: "\(cnt) Units")
                        }
                        if let diff = record.difference {
                            Divider().padding(.leading, 16)
                            detailRow(
                                "Difference",
                                value: diff < 0 ? "−\(abs(diff)) Units" :
                                       diff > 0 ? "+\(diff) Units" : "No Variance",
                                valueColor: diff < 0 ? Color(UIColor.systemRed) :
                                            diff > 0 ? Color(UIColor.systemOrange) :
                                                       Color(UIColor.systemGreen)
                            )
                        }
                    }
                }

                
                if record.reason != nil || record.notes != nil {
                    sectionCard("Variance Information") {
                        if let reason = record.reason {
                            detailRow("Reason", value: reason)
                        }
                        if let notes = record.notes {
                            if record.reason != nil { Divider().padding(.leading, 16) }
                            notesRow(notes)
                        }
                    }
                }

                // ── Report Information ────────────────────────────────────
                sectionCard("Report Information") {
                    if let by = record.reportedBy {
                        detailRow("Reported By", value: by)
                        Divider().padding(.leading, 16)
                    }
                    detailRow("Date Reported", value: formattedDate(record.timestamp))
                    Divider().padding(.leading, 16)
                    detailRow("Report ID", value: record.id,
                              valueFont: .system(size: 14, design: .monospaced))
                }

                // ── View Source (Cycle Count) ─────────────────────────────
                if record.cycleCountName != nil {
                    viewSourceCard
                }

                // ── Read-only notice ──────────────────────────────────────
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                    Text("This report is read-only and cannot be edited.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                .padding(.leading, 4)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Report Detail")
            .navigationBarTitleDisplayMode(.inline)
        } // end ScrollView
    } // end body

    // MARK: - Summary Header Card

    private var summaryCard: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(record.type.iconColor.opacity(0.12))
                    .frame(width: 52, height: 52)
                Image(systemName: record.type.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(record.type.iconColor)
            }

            // Labels
            VStack(alignment: .leading, spacing: 4) {
                Text(record.type.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))

                if let reason = record.reason {
                    Text(reason)
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }

                // Difference amount
                if let diff = record.difference {
                    Text(diff < 0 ? "−\(abs(diff)) Units" :
                         diff > 0 ? "+\(diff) Units" :
                                    "No Variance")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(diff < 0 ? Color(UIColor.systemRed) :
                                         diff > 0 ? Color(UIColor.systemOrange) :
                                                    Color(UIColor.systemGreen))
                }
            }

            Spacer()
        }
        .padding(16)
        .groupedCard()
    }

    // MARK: - View Source Card

    private var viewSourceCard: some View {
        Button {
            if let session = record.sourceSession {
                appState.activeCycleCountSession = session
                appState.selectedInventorySegment = 1 // Switch to Cycle Count segment
                appState.selectedTab = 3 // Switch to Inventory Tab
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.theme.accent.opacity(0.10))
                        .frame(width: 40, height: 40)
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(Color.theme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("View Source (Cycle Count)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.theme.accent)
                    Text("See the cycle count and all counted items related to this record.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
            .padding(16)
            .groupedCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section Card Builder

    @ViewBuilder
    private func sectionCard<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .textCase(.uppercase)
                .tracking(0.4)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .groupedCard()
        }
    }

    // MARK: - Row Builders

    private func detailRow(
        _ label: String,
        value: String,
        valueColor: Color = Color(UIColor.label),
        valueFont: Font = .system(size: 15, weight: .medium)
    ) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.secondaryLabel))
            Spacer()
            Text(value)
                .font(valueFont)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // Tappable Cycle Count row — navigates to the source cycle count
    private func cycleCountLinkRow(_ name: String) -> some View {
        Button {
            if let session = record.sourceSession {
                appState.activeCycleCountSession = session
                appState.selectedInventorySegment = 1
                appState.selectedTab = 3
            }
        } label: {
            HStack {
                Text("Cycle Count")
                    .font(.system(size: 15))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                Spacer()
                HStack(spacing: 4) {
                    Text(name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(UIColor.label))
                    if record.sourceSession != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // Report synchronization state intentionally hidden — no status row.

    private func notesRow(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.secondaryLabel))
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.label))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Card ViewModifier (file-private)

private extension View {
    func groupedCard() -> some View {
        self
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(Spacing.Shadow.opacity),
                    radius: Spacing.Shadow.radius, x: 0, y: Spacing.Shadow.yOffset)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReportDetailView(record: ReportRecord.seedData[0])
    }
}

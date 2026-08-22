import SwiftUI

struct ScheduledCycleCountSummaryView: View {
    let session: CycleCountSession

    @State private var navigateToExecution = false
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // ── Header Card ───────────────────────────────────────────
                VStack(spacing: 0) {
                    HStack {
                        Text(session.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)
                        Spacer()
                        statusChip
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    
                    Text("High Value Storage") // Mock warehouse since location might be nil
                        .font(.system(size: 14))
                        .foregroundColor(Color.theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    
                    Divider().background(Color.theme.border)
                    
                    VStack(spacing: 16) {
                        detailRow(label: "Count Type", value: "Full Count")
                        detailRow(label: "Warehouse", value: session.location ?? "High Value Storage")
                        detailRow(label: "Scheduled Date", value: session.dateLabel)
                        detailRowWithDot(label: "Priority", value: "High", color: .red)
                        detailRow(label: "Assigned To", value: "You")
                    }
                    .padding(16)
                }
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.theme.border, lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                // ── Progress Card ─────────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text("Count Progress")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.theme.border)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.theme.brand)
                                .frame(width: geo.size.width * session.progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    HStack {
                        Text("\(session.counted) of \(session.total) items counted")
                            .font(.system(size: 13))
                            .foregroundColor(Color.theme.textSecondary)
                        Spacer()
                        Text("\(Int(session.progress * 100))%")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                }
                .padding(16)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.theme.border, lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                // ── Sync & Notes Card ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.theme.success)
                            .font(.system(size: 16))
                        Text("Sync Status")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    
                    Text("Last synced: \(session.dateLabel)")
                        .font(.system(size: 13))
                        .foregroundColor(Color.theme.textSecondary)
                    
                    Divider().background(Color.theme.border)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Text("Notes")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.theme.textPrimary)
                            .frame(width: 60, alignment: .leading)
                        
                        Text("Please ensure all trays are counted.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                .padding(16)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.theme.border, lineWidth: 1)
                )
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 24)
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Cycle Count Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Delete", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(Color.theme.textPrimary)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToExecution) {
            CycleCountExecutionView(session: inProgressSession)
        }
        .confirmationDialog("Delete Cycle Count?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await CycleCountStore.shared.deleteSessionFromDB(id: session.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .safeAreaInset(edge: .bottom) {
            startButton
        }
    }
    
    // MARK: - Components
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color.theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.theme.textPrimary)
        }
    }
    
    private func detailRowWithDot(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color.theme.textSecondary)
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 6, height: 6)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.theme.textPrimary)
            }
        }
    }
    
    @ViewBuilder
    private var statusChip: some View {
        Text("Scheduled")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.theme.brand)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.theme.brand.opacity(0.1))
            .overlay(
                Capsule().stroke(Color.theme.brand.opacity(0.2), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
    
    private var startButton: some View {
        VStack {
            Button {
                Task {
                    await CycleCountStore.shared.startSession(session)
                    navigateToExecution = true
                }
            } label: {
                Text("Start Count")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.theme.brand)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color.theme.background)
        }
    }
    
    private var inProgressSession: CycleCountSession {
        var copy = session
        copy.status = .inProgress
        return copy
    }
}

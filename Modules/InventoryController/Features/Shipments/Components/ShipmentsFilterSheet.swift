import SwiftUI

enum FilterETA: String, CaseIterable {
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case custom = "Custom Range"
}

enum FilterStatus: String, CaseIterable {
    case inTransit = "In Transit"
    case arrived = "Arrived"
    case completed = "Completed"
}

struct ShipmentsFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedStatuses: Set<FilterStatus>
    @Binding var selectedETA: FilterETA?
    
    // Local state for applying only on save
    @State private var draftStatuses: Set<FilterStatus>
    @State private var draftETA: FilterETA?
    
    init(selectedStatuses: Binding<Set<FilterStatus>>, selectedETA: Binding<FilterETA?>) {
        self._selectedStatuses = selectedStatuses
        self._selectedETA = selectedETA
        self._draftStatuses = State(initialValue: selectedStatuses.wrappedValue)
        self._draftETA = State(initialValue: selectedETA.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(FilterStatus.allCases, id: \.self) { status in
                        Button(action: {
                            if draftStatuses.contains(status) {
                                draftStatuses.remove(status)
                            } else {
                                draftStatuses.insert(status)
                            }
                        }) {
                            HStack {
                                Text(status.rawValue)
                                    .foregroundColor(Color.theme.textPrimary)
                                Spacer()
                                if draftStatuses.contains(status) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.theme.accent)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Shipment Status")
                }
                
                Section {
                    ForEach(FilterETA.allCases, id: \.self) { eta in
                        Button(action: {
                            if draftETA == eta {
                                draftETA = nil
                            } else {
                                draftETA = eta
                            }
                        }) {
                            HStack {
                                Text(eta.rawValue)
                                    .foregroundColor(Color.theme.textPrimary)
                                Spacer()
                                if draftETA == eta {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.theme.accent)
                                }
                            }
                        }
                    }
                } header: {
                    Text("ETA")
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        draftStatuses.removeAll()
                        draftETA = nil
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        selectedStatuses = draftStatuses
                        selectedETA = draftETA
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.accent)
                }
            }
        }
    }
}

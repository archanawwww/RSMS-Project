import SwiftUI

// MARK: - New Cycle Count Form

struct NewCycleCountView: View {
    @Environment(\.dismiss) private var dismiss

    let preselectedProductID: String?

    @State private var name: String = ""
    @State private var selectedProductIDs: Set<String> = []
    @State private var allInventorySelected: Bool = false
    @State private var scheduledDate: Date = Calendar.current.date(
        byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var isCreating = false
    @State private var showError = false
    @State private var errorMessage = ""

    init(preselectedProductID: String? = nil) {
        self.preselectedProductID = preselectedProductID
        if let id = preselectedProductID {
            _selectedProductIDs = State(initialValue: [id])
        }
    }

    // MARK: Derived

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (!selectedProductIDs.isEmpty || allInventorySelected)
    }

    private var productSelectionLabel: String {
        if allInventorySelected              { return "All Inventory" }
        if selectedProductIDs.isEmpty        { return "Select" }
        return "\(selectedProductIDs.count) Selected"
    }

    // MARK: Body

    var body: some View {
        List {

            // ── Section 1: Name ──────────────────────────────────────────
            Section {
                TextField("Enter cycle count name", text: $name)
                    .font(.system(size: 17))
                    .foregroundColor(Color(UIColor.label))
            } header: {
                Text("Name")
            }
            .listRowBackground(Color.theme.surface)

            // ── Section 2: Products ──────────────────────────────────────
            Section {
                NavigationLink {
                    CycleCountProductSelectionView(
                        selectedProductIDs: $selectedProductIDs,
                        allInventorySelected: $allInventorySelected
                    )
                } label: {
                    HStack {
                        Text("Products")
                            .font(.system(size: 17))
                            .foregroundColor(Color(UIColor.label))
                        Spacer()
                        Text(productSelectionLabel)
                            .font(.system(size: 17))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
            } header: {
                Text("Products")
            }
            .listRowBackground(Color.theme.surface)

            // ── Section 3: Scheduled Date ────────────────────────────────
            Section {
                DatePicker(
                    "Scheduled Date",
                    selection: $scheduledDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .tint(Color.theme.accent)
                .font(.system(size: 17))
            } header: {
                Text("Scheduled Date")
            }
            .listRowBackground(Color.theme.surface)

        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.theme.backgroundGrouped.ignoresSafeArea())
        .navigationTitle("New Cycle Count")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    createCycleCount()
                }
                .fontWeight(.semibold)
                .disabled(!isFormValid || isCreating)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { isCreating = false }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Actions

    private func createCycleCount() {
        isCreating = true
        Task {
            do {
                let ids = allInventorySelected ? [] : Array(selectedProductIDs)
                try await CycleCountStore.shared.createCycleCountInDB(
                    title: name.trimmingCharacters(in: .whitespaces),
                    scheduledDate: scheduledDate,
                    warehouseId: nil,
                    productIDs: ids
                )
                await MainActor.run { dismiss() }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isCreating = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NewCycleCountView()
    }
}

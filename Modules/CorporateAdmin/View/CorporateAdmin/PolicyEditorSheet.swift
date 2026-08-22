import SwiftUI

struct PolicyEditorSheet: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    let policy: CompanyPolicy?

    @State private var title: String
    @State private var content: String
    @State private var statusMessage: String?
    @State private var isSuccess = false

    init(policy: CompanyPolicy? = nil) {
        self.policy = policy
        _title = State(initialValue: policy?.title ?? "")
        _content = State(initialValue: policy?.content ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Policy Information") {
                    TextField("Policy Title", text: $title)
                        .autocorrectionDisabled()
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                        .overlay(
                            Group {
                                if content.isEmpty {
                                    Text("Enter policy details here...")
                                        .foregroundColor(Color(uiColor: .placeholderText))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }

                if let statusMessage {
                    Section {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundColor(isSuccess ? MatteTheme.Colors.success : MatteTheme.Colors.error)
                    }
                }
            }
            .navigationTitle(policy == nil ? "Create Policy" : "Edit Policy")
            .navigationBarTitleDisplayMode(.inline)
            .tint(MatteTheme.Colors.primaryGold)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(MatteTheme.Colors.espresso)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(MatteTheme.Colors.primaryGold)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveChanges() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty else {
            isSuccess = false
            statusMessage = "Policy title cannot be empty."
            return
        }

        guard !cleanContent.isEmpty else {
            isSuccess = false
            statusMessage = "Policy content cannot be empty."
            return
        }

        if let existingPolicy = policy {
            var updated = existingPolicy
            updated.title = cleanTitle
            updated.content = cleanContent
            authManager.updateCompanyPolicy(updated)
        } else {
            authManager.addCompanyPolicy(title: cleanTitle, content: cleanContent)
        }

        isSuccess = true
        statusMessage = "Policy saved successfully."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            dismiss()
        }
    }
}

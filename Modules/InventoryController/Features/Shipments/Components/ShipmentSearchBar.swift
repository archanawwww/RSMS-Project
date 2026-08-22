import SwiftUI

struct ShipmentSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {

            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("Search", text: $text)
                .focused($isFocused)
                .font(Typography.body)
                .submitLabel(.search)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused
                    ? Color.theme.accent.opacity(0.4)
                    : Color.black.opacity(0.06),
                    lineWidth: 1
                )
        )
        .shadow(
            color: .black.opacity(0.04),
            radius: 8,
            y: 3
        )
    }
}

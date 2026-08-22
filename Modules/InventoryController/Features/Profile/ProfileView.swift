import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.inventoryLogoutAction) private var logout
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeaderCard()
                    
                    ProfileSection(title: "Work Information") {
                        ProfileRow(icon: "person.text.rectangle", title: "Employee ID", value: "IC-1024")
                        ProfileRow(icon: "envelope", title: "Corporate Email", value: "rahul.sharma@luxuryretail.com")
                        ProfileRow(icon: "phone", title: "Phone Number", value: "+91 98765 43210")
                        ProfileRow(icon: "building.2", title: "Distribution Center", value: "Delhi Distribution Center")
                    }
                   
                }
                
                Button(action: {
                    dismiss()
                    logout()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .navigationTitle("Profile")
            .appScreen()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "multiply")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}


// MARK: - Components

struct ProfileHeaderCard: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSa6wjkopC-2aiyTtZSSnLAD70Y6Yzne2NlFGB6Pxh-uQ&s=10")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(UIColor.systemGray3))
                    } else {
                        ProgressView()
                            .frame(width: 80, height: 80)
                    }
                }
                
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Rahul Sharma")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Inventory Controller")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.035), radius: 12, x: 0, y: 6)
        )
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.035), radius: 12, x: 0, y: 6)
            )
        }
    }
}

struct ProfileRow<CustomValue: View>: View {
    let icon: String
    let title: String
    var value: String? = nil
    var customValue: (() -> CustomValue)? = nil
    var showChevron: Bool = false
    var isLast: Bool = false
    
    init(icon: String, title: String, value: String? = nil, showChevron: Bool = false, isLast: Bool = false) where CustomValue == EmptyView {
        self.icon = icon
        self.title = title
        self.value = value
        self.customValue = nil
        self.showChevron = showChevron
        self.isLast = isLast
    }
    
    init(icon: String, title: String, @ViewBuilder customValue: @escaping () -> CustomValue, showChevron: Bool = false, isLast: Bool = false) {
        self.icon = icon
        self.title = title
        self.value = nil
        self.customValue = customValue
        self.showChevron = showChevron
        self.isLast = isLast
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                ViewThatFits(in: .horizontal) {
                    // Option 1: Horizontal Layout
                    HStack(spacing: 16) {
                        Text(title)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Spacer(minLength: 8)
                        
                        if let customValue = customValue {
                            customValue()
                        } else if let value = value {
                            Text(value)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    
                    // Option 2: Vertical Layout (fallback if horizontal doesn't fit)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        if let customValue = customValue {
                            customValue()
                        } else if let value = value {
                            Text(value)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .padding(.leading, 4)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            
            if !isLast {
                Divider()
                    .padding(.leading, 60)
            }
        }
    }
}

struct ProfileStatusChip: View {
    let title: String
    let isSuccess: Bool
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(isSuccess ? .green : .red)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSuccess ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
    }
}

#Preview {
    ProfileView()
}

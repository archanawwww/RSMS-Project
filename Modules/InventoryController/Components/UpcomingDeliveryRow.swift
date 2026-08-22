import SwiftUI

/// A single row inside the Upcoming Deliveries grouped list card.
///
/// Design spec:
/// - Truck icon in a soft gray rounded square on the left.
/// - Vendor name (semibold) + SKU count below in secondary color.
/// - Right side: SKU count (secondary label) + chevron.
/// - NO ETA, NO time labels, NO capsules.
struct UpcomingDeliveryRow: View {
    let vendorName: String
    let skuCount: Int

    var body: some View {
        HStack(spacing: 12) {
            // Truck icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 40, height: 40)
                Image(systemName: "shippingbox")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }

            // Vendor + SKU count
            VStack(alignment: .leading, spacing: 2) {
                Text(vendorName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(skuCount) SKUs")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Right: SKU count + chevron
            HStack(spacing: 6) {
                Text("\(skuCount) SKUs")
                    .font(.system(size: 13))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
        }
        .padding(.vertical, 14)
    }
}

import SwiftUI

struct ShipmentCardView: View {
    let shipment: Shipment
    
    var body: some View {
        VStack(spacing: 16) {
            // Top Section
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "box.truck")
                        .foregroundColor(Color.theme.accent)
                        .font(.system(size: 16))
                        .frame(width: 40, height: 40)
                        .background(Color.theme.accent.opacity(0.1))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(shipment.id)
                            .font(.system(.headline, design: .default).weight(.semibold))
                            .foregroundColor(Color.theme.textPrimary)
                            
                        Text(shipment.vendorName)
                            .font(.system(.subheadline, design: .default).weight(.regular))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                
                Spacer()
                
                StatusChip(status: shipment.status)
            }
            
            Divider()
                .background(Color.theme.border)
            
            // Bottom Section
            HStack(spacing: 0) {
                // Left Side (ETA / Exception)
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .foregroundColor(Color.theme.textSecondary)
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if shipment.status == .exception {
                            Text("Issue")
                                .font(.system(.caption, design: .default).weight(.medium))
                                .foregroundColor(Color.theme.textSecondary)
                            Text(shipment.exceptionIssue ?? "Delayed Delivery")
                                .font(.system(.subheadline, design: .default).weight(.medium))
                                .foregroundColor(Color.theme.textPrimary)
                                .lineLimit(1)
                        } else {
                            Text("ETA")
                                .font(.system(.caption, design: .default).weight(.medium))
                                .foregroundColor(Color.theme.textSecondary)
                            Text(shipment.expectedDate.formatted(.dateTime.day().month().year()))
                                .font(.system(.subheadline, design: .default).weight(.medium))
                                .foregroundColor(Color.theme.textPrimary)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 36)
                    .background(Color.theme.border)
                
                // Right Side (ASN)
                HStack(spacing: 10) {
                    Image(systemName: "doc.plaintext")
                        .foregroundColor(Color.theme.textSecondary)
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ASN")
                            .font(.system(.caption, design: .default).weight(.medium))
                            .foregroundColor(Color.theme.textSecondary)
                        Text(

                            shipment.status == .completed

                            ? "Matched"

                            : (shipment.asnNumber?.replacingOccurrences(of: "ASN-", with: "") ?? "Pending")

                        )
                            .font(.system(.subheadline, design: .default).weight(.medium))
                            .foregroundColor(Color.theme.textPrimary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 16)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.theme.textTertiary)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.theme.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 2)
    }
}

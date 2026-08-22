import SwiftUI

/// Forecast card — navigation-only, no charts, no graphs.
///
/// Design spec:
/// - Neutral icon (not purple); icon background is soft gray.
/// - "View Forecast →" in blue (system link color) for clear affordance.
/// - Card is pure white, same subtle shadow as other cards.
struct ForecastCard: View {
    let forecastCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon — neutral color
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 48, height: 48)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Replenishment Forecast")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("\(forecastCount) SKUs projected below safety stock tomorrow")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 3) {
                        Text("View Forecast")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(Color.theme.workflowPurple)
                    .padding(.top, 2)
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
        .buttonStyle(ScaleButtonStyle())
    }
}

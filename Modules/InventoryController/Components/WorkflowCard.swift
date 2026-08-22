import SwiftUI

/// Semantic card type — drives color decisions independently of iconColor parameter.
enum WorkflowCardStyle {
    case primary    // Receive Delivery — purple
    case warning    // Review Low Stock — orange
    case neutral    // Everything else — monochrome
}

/// A workflow card for the Today 2-column grid.
///
/// Design rules (Apple HIG / design spec):
/// - Icon: soft tinted square, almost white background.
/// - Number: plain semibold text top-right — no circle, no capsule, no badge.
/// - Color only when it conveys meaning: purple → primary, orange → warning.
/// - Title + chevron on same row.
/// - Subtitle below title.
/// - Detail block (e.g. "Top affected\nLeather Wallet\nSilk Scarf") optional.
/// - Caption at the bottom; or a light gray rounded label when showPendingLabel=true.
/// - Receive Delivery: pure white card with very subtle purple 10%-opacity stroke.
/// - All other cards: pure white, near-invisible shadow.
struct WorkflowCard: View {
    let icon: String
    let cardStyle: WorkflowCardStyle
    let title: String
    let subtitle: String
    let detail: String?
    let caption: String
    let badgeCount: Int
    let badgeText: String?
    let iconColor: Color?
    let showPendingLabel: Bool
    let action: () -> Void

    /// Backward-compatible init that accepts the legacy `iconColor` + `isPrimary` API.
    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        detail: String? = nil,
        caption: String,
        badgeCount: Int,
        badgeText: String? = nil,
        isPrimary: Bool = false,
        showPendingLabel: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.caption = caption
        self.badgeCount = badgeCount
        self.badgeText = badgeText
        self.iconColor = iconColor
        self.showPendingLabel = showPendingLabel
        self.action = action

        // Derive semantic style
        if isPrimary {
            self.cardStyle = .primary
        } else if iconColor == Color.theme.workflowOrange {
            self.cardStyle = .warning
        } else {
            self.cardStyle = .neutral
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Row 1: Icon  +  Number ──────────────────────────────
                HStack(alignment: .top) {
                    iconView
                    Spacer()
                    if let badgeText = badgeText ?? (badgeCount > 0 ? "\(badgeCount)" : nil) {
                        Text(badgeText)
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .foregroundColor(accentColor)
                    }
                }

                Spacer(minLength: 12)

                // ── Row 2: Title + chevron ───────────────────────────────
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }

                // ── Row 3: Subtitle ──────────────────────────────────────
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)

                // ── Row 4 (optional): Detail text block ──────────────────
                if let detail = detail, !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .lineLimit(4)
                        .padding(.top, 8)
                }

                Spacer(minLength: 12)

                // ── Row 5: Caption or Pending label ─────────────────────
                if showPendingLabel && !caption.isEmpty {
                    Text(caption)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemGray5))
                        )
                } else if !caption.isEmpty {
                    Text(caption)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
            .background(cardBackground)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Sub-views

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(iconBackgroundColor)
                .frame(width: 44, height: 44)
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor ?? accentColor)
        }
    }

    @ViewBuilder
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Spacing.cardRadius)
            .fill(Color.theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(Spacing.Shadow.opacity),
                radius: Spacing.Shadow.radius,
                x: 0,
                y: Spacing.Shadow.yOffset
            )
    }

    // MARK: - Color helpers

    /// The single accent color for this card — used on icon, number.
    private var accentColor: Color {
        switch cardStyle {
        case .primary: return Color.theme.workflowPurple
        case .warning: return Color.theme.workflowOrange
        case .neutral: return Color(UIColor.label)
        }
    }

    /// Icon background — almost white, barely tinted.
    private var iconBackgroundColor: Color {
        switch cardStyle {
        case .primary: return Color.theme.workflowPurple.opacity(0.08)
        case .warning: return Color.theme.workflowOrange.opacity(0.08)
        case .neutral: return Color(UIColor.systemGray6)
        }
    }
}

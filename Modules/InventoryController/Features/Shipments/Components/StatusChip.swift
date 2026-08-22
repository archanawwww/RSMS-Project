import SwiftUI

struct StatusChip: View {
    let status: ShipmentStatus
    
    var unifiedState: (title: String, icon: String, background: Color, text: Color) {
        let activeBg = Color(hex: "#F6EEE4")
        let activeText = Color(hex: "#AB793D")
        
        let inactiveBg = Color(hex: "#F3F2F0")
        let inactiveText = Color(hex: "#6B6B6B")
        
//        switch status {
//        case .inTransit, .dispatched:
//            return ("In Transit", "truck.box", activeBg, activeText)
//            
//        case .awaitingReceipt, .processing, .exception, .created, .approved:
//            return ("Arrived", "shippingbox", activeBg, activeText)
//            
//        case .completed, .received, .returned, .cancelled:
//            return ("Completed", "checkmark.circle", inactiveBg, inactiveText)
//        }
        
        switch status {

        case .created:
            return (
                "Created",
                "clock.badge",
                activeBg,
                activeText
            )

        case .dispatched:
            return (
                "Dispatched",
                "box.truck",
                activeBg,
                activeText
            )

        case .inTransit:
            return (
                "In Transit",
                "truck.box",
                activeBg,
                activeText
            )

        case .awaitingReceipt,
             .processing,
             .exception:
            return (
                "Arrived",
                "shippingbox",
                activeBg,
                activeText
            )

        case .completed,
             .received,
             .returned,
             .cancelled:
            return (
                "Completed",
                "checkmark.circle",
                inactiveBg,
                inactiveText
            )

        case .approved:
            return (
                "Approved",
                "checkmark.circle",
                activeBg,
                activeText
            )
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: unifiedState.icon)
                .font(.system(size: 12, weight: .semibold))
            Text(unifiedState.title)
                .font(Typography.caption.weight(.semibold))
        }
        .foregroundColor(unifiedState.text)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .frame(minWidth: 85)
        .background(unifiedState.background)
        .clipShape(Capsule())
    }
}

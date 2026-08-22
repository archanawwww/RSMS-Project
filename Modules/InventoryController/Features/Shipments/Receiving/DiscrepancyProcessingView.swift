import SwiftUI

struct DiscrepancyProcessingView: View {
    let session: ReceivingSession
//    @StateObject private var shipmentsVM = ShipmentsViewModel()
    private let asnRepo = ASNRepository()
    private let shipmentRepo = ShipmentRepository()
    @State private var currentStepIndex = 0
    @State private var navigateToSuccess = false
    @State private var isSpinning = false
    
    let steps = [
        "Recording discrepancy...",
        "Updating shipment...",
        "Creating audit record...",
        "Updating inventory...",
        "Preparing manager review..."
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#FAF8F4").ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                Text("Processing")
                    .font(.title2.weight(.bold))
                    .padding(.top, 20)
                
                // Custom Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#B9823A").opacity(0.2), lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color(hex: "#B9823A"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.8), value: progress)
                    
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 42))
                        .foregroundColor(Color(hex: "#B9823A"))
                }
                .frame(width: 130, height: 130)
                .padding(.top, 16)
                
                Text("Please wait while we\nprocess your report.")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
                
                // Steps List
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        HStack(spacing: 16) {
                            if index < currentStepIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "#B9823A"))
                                    .font(.system(size: 22))
                            } else if index == currentStepIndex {
                                Circle()
                                    .trim(from: 0, to: 0.75)
                                    .stroke(Color(hex: "#B9823A"), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                    .frame(width: 20, height: 20)
                                    .rotationEffect(Angle(degrees: isSpinning ? 360 : 0))
                                    .onAppear {
                                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                            isSpinning = true
                                        }
                                    }
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                    .frame(width: 20, height: 20)
                            }
                            
                            Text(steps[index])
                                .font(.system(size: 15, weight: index == currentStepIndex ? .semibold : .medium))
                                .foregroundColor(index <= currentStepIndex ? Color.theme.textPrimary : Color.theme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToSuccess) {
            DiscrepancySuccessView(session: session)
        }
        .task {
            
            print("========== PROCESSING ==========")
            print("Total Received =", session.asn.totalReceived)

            for item in session.asn.items {
                print("\(item.productName) -> \(item.receivedQuantity)")
            }
            // Simulate background work cycling through statuses
            for index in 0...steps.count {
                currentStepIndex = index
                if index < steps.count {
                    try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 seconds per step
                }
            }
            
            do {

//                try await asnRepo.updateASN(asn: session.asn)

                try await asnRepo.updateASNItems(items: session.asn.items)

                try await shipmentRepo.updateShipmentStatus(
                    shipmentId: session.asn.shipmentId,
                    status: .completed
                )
                
                try await shipmentRepo.updateReceivedTime(
                    shipmentId: session.asn.shipmentId
                )

            } catch {

                print(error)

            }

            try? await Task.sleep(nanoseconds: 500_000_000)

            navigateToSuccess = true
        }
    }
    
    var progress: CGFloat {
        if steps.isEmpty { return 0 }
        return CGFloat(currentStepIndex) / CGFloat(steps.count)
    }
}

#Preview {
    NavigationStack {
        DiscrepancyProcessingView(session: ReceivingSession(asn: ASN(
            id: UUID(),
            shipmentId: "SHP-1",
            vendorName: "Acme",
            expectedDate: Date(),
            status: "Pending",
            totalExpected: 0,
            totalReceived: 0,
            createdAt: Date(),
            items: []
        )))
    }
}

import SwiftUI

struct StockAlertDetailView: View {
    let alert: StockAlert
    @ObservedObject var viewModel: InventoryOverviewViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCreateRequestForm = false
    @State private var managerRemark: String = ""
    @State private var salesAssociateName: String = ""
    @State private var isSubmittingDecline = false
    @State private var isSubmittingAccept = false
    
    var isTransferRequest: Bool {
        alert.alertType == .transferRequested || alert.source == .salesAssociate
    }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Product Header Section
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.themeAccent.opacity(0.1))
                                .frame(width: 72, height: 72)
                            
                            Image(systemName: isTransferRequest ? "arrow.left.arrow.right" : "shippingbox.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.themeAccent)
                        }
                        
                        VStack(spacing: 4) {
                            Text(alert.productName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.themeText)
                                .multilineTextAlignment(.center)
                            
                            Text("SKU: \(alert.sku)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 6)
                    
                    // Alert Specification Details Card
                    DetailSection(title: "Alert Information") {
                        InfoRow(
                            title: "Alert Type",
                            value: alert.alertType.rawValue,
                            isBoldValue: true,
                            valueColor: alert.alertType == .outOfStock ? .red : .themeText
                        )
                        Divider().background(Color.themeText.opacity(0.06))
                        
                        InfoRow(
                            title: "Source",
                            value: isTransferRequest ? (salesAssociateName.isEmpty ? alert.source.rawValue : salesAssociateName) : alert.source.rawValue,
                            isBoldValue: isTransferRequest && !salesAssociateName.isEmpty
                        )
                        Divider().background(Color.themeText.opacity(0.06))
                        
                        InfoRow(
                            title: "Priority",
                            value: alert.priority.rawValue,
                            isBoldValue: true,
                            valueColor: alert.priority == .high ? .red : (alert.priority == .medium ? .orange : .gray)
                        )
                        Divider().background(Color.themeText.opacity(0.06))
                        
                        InfoRow(
                            title: "Current Quantity",
                            value: alert.currentQuantity == 0 ? "Out of Stock" : "\(alert.currentQuantity) units",
                            isBoldValue: true,
                            valueColor: alert.currentQuantity == 0 ? .red : .themeText
                        )
                        Divider().background(Color.themeText.opacity(0.06))
                        
                        // Highlighted Requested Quantity for Transfer Requests
                        if let reqQty = alert.quantityRequested {
                            HStack(alignment: .center) {
                                Text("Requested Quantity")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .frame(width: 140, alignment: .leading)
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up.right.square.fill")
                                        .font(.system(size: 11))
                                    Text("\(reqQty) units")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.themeAccent.opacity(0.15))
                                .foregroundColor(.themeAccent)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.themeAccent.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.vertical, 8)
                            Divider().background(Color.themeText.opacity(0.06))
                        }
                        
                        InfoRow(title: "Request Date", value: alert.generatedAt.formattedString())
                    }
                    
                    // Remarks Text Field Section (Updates SalesAssociateStockRequest.managerremark)
                    DetailSection(title: "Manager Remarks") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextEditor(text: $managerRemark)
                                .font(.system(size: 13))
                                .foregroundColor(.themeText)
                                .frame(minHeight: 65, maxHeight: 95)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(Color.themeBackground.opacity(0.5))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if managerRemark.isEmpty {
                                            Text("Enter remarks for this stock request...")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray.opacity(0.5))
                                                .padding(.leading, 12)
                                                .padding(.top, 14)
                                                .allowsHitTesting(false)
                                        }
                                    },
                                    alignment: .topLeading
                                )
                        }
                        .padding(.vertical, 6)
                    }
                    
                    Spacer(minLength: 16)
                    
                    // Horizontal Action Buttons (No background container behind them)
                    HStack(spacing: 12) {
                        // Decline / Ignore Button
                        Button(action: {
                            Task {
                                isSubmittingDecline = true
                                if isTransferRequest {
                                    await viewModel.declineSalesAssociateRequest(requestId: alert.id, managerRemark: managerRemark)
                                } else {
                                    viewModel.ignoreAlert(id: alert.id)
                                }
                                isSubmittingDecline = false
                                dismiss()
                            }
                        }) {
                            HStack(spacing: 6) {
                                if isSubmittingDecline {
                                    ProgressView()
                                        .tint(.red)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 15))
                                    Text(isTransferRequest ? "Decline" : "Ignore")
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isSubmittingDecline)

                        // Accept Button
                        Button(action: {
                            if isTransferRequest {
                                Task {
                                    isSubmittingAccept = true
                                    await viewModel.acceptSalesAssociateRequest(requestId: alert.id, managerRemark: managerRemark)
                                    isSubmittingAccept = false
                                    dismiss()
                                }
                            } else {
                                showCreateRequestForm = true
                            }
                        }) {
                            HStack(spacing: 6) {
                                if isSubmittingAccept {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 15))
                                    Text("Accept")
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.themeAccent)
                            .cornerRadius(12)
                            .shadow(color: Color.themeAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isSubmittingAccept || isSubmittingDecline)
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 20)
                }
                .padding()
            }
        }
        .navigationTitle("Alert Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if managerRemark.isEmpty {
                managerRemark = alert.managerRemark ?? ""
            }
            if let preloadedName = alert.salesAssociateName, !preloadedName.isEmpty {
                salesAssociateName = preloadedName
            }
        }
        .task {
            if salesAssociateName.isEmpty, let userId = alert.requestedBy {
                salesAssociateName = await viewModel.fetchUserName(userId: userId)
            }
        }
        .sheet(isPresented: $showCreateRequestForm) {
            CreateStoreRequestView(alert: alert, overviewViewModel: viewModel) {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        StockAlertDetailView(
            alert: StockAlert(
                id: UUID(),
                productName: "Signature Fragrance",
                sku: "SKU-PER-001",
                currentQuantity: 17,
                alertType: .transferRequested,
                priority: .high,
                source: .salesAssociate,
                generatedAt: Date(),
                description: "Stock request submitted by Sales Associate",
                quantityRequested: 5,
                requestedBy: UUID(),
                salesAssociateName: "Sarah Jenkins"
            ),
            viewModel: InventoryOverviewViewModel()
        )
    }
}

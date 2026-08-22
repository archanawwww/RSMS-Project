import Foundation

enum AppDestination: Hashable {
    case requestDetail(StoreRequest)
    case vendorRequestDetail(VendorRequest)
    case createVendorRequest(prefilledRequest: StoreRequest?)
    case shipmentTracking(Shipment)
    case asnDetails(String) // shipmentId
    case qrScanner(ASN)
    case receivingSummary(ReceivingSession)
    case reviewVarianceImpact(ReceivingSession)
    case confirmVarianceCompletion(ReceivingSession)
    case receivingComplete(ReceivingSession)
    case optionalVerification(String) // sku
}

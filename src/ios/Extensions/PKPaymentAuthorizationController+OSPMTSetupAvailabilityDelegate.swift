import PassKit

protocol OSPMTSetupAvailabilityDelegate: AnyObject {
    static func isPaymentAvailable() -> Bool
}

protocol OSPMTApplePaySetupAvailabilityDelegate: OSPMTSetupAvailabilityDelegate {
    static func isPaymentAvailable(using networks: [PKPaymentNetwork], and merchantCapabilities: PKMerchantCapability) -> Bool
}

extension PKPaymentAuthorizationController: OSPMTApplePaySetupAvailabilityDelegate {
    static func isPaymentAvailable() -> Bool {
        Self.canMakePayments()
    }
    
    static func isPaymentAvailable(using networks: [PKPaymentNetwork], and merchantCapabilities: PKMerchantCapability) -> Bool {
        Self.canMakePayments(usingNetworks: networks, capabilities: merchantCapabilities)
    }
}

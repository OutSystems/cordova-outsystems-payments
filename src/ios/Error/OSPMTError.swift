/// All plugin errors that can be thrown
enum OSPMTError: Int, CustomNSError, LocalizedError {
    case invalidConfiguration = 1
    case walletNotAvailable = 2
    case paymentNotAvailable = 3
    case setupPaymentNotAvailable = 4
    case invalidDecodeDetails = 6
    case paymentTriggerPresentationFailed = 7
    case paymentTriggerNotCompleted = 8
    case invalidEncodeScope = 9
    
    /// Textual description
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "An invalid configuration was provided to the plugin."
        case .walletNotAvailable:
            return "Wallet is not available on this device."
        case .paymentNotAvailable:
            return "Payment is not available on this device."
        case .setupPaymentNotAvailable:
            return "Payment through the configured networks and capabilities is not available on this device."
        case .invalidDecodeDetails:
            return "Couldn't decode payment details."
        case .paymentTriggerPresentationFailed:
            return "Couldn't present the Apple Pay screen."
        case .paymentTriggerNotCompleted:
            return "Couldn't complete the payment trigger process."
        case .invalidEncodeScope:
            return "Couldn't encode payment scope."
        }
    }
}

/// All plugin errors that can be thrown
enum OSPMTError: Int, CustomNSError, LocalizedError {
    case invalidConfiguration = 1
    case walletNotAvailable = 3
    case paymentNotAvailable = 5
    case setupPaymentNotAvailable = 6
    case invalidDecodeDetails = 8
    case invalidEncodeScope = 9
    case paymentTriggerPresentationFailed = 10
    case paymentCancelled = 11
    
    /// Textual description
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Couldn't obtain the payment's informations from the configurations file."
        case .walletNotAvailable:
            return "The Apple Pay is not available in the device."
        case .paymentNotAvailable:
            return "There is no payment method configured."
        case .setupPaymentNotAvailable:
            return "There are no valid payment cards for the supported networks and/or capabilities."
        case .invalidDecodeDetails:
            return "Couldn't decode the payment details."
        case .invalidEncodeScope:
            return "Couldn't encode the payment scope."
        case .paymentTriggerPresentationFailed:
            return "Couldn't present the Apple Pay screen."
        case .paymentCancelled:
            return "Payment was cancelled by the user."
        }
    }
}

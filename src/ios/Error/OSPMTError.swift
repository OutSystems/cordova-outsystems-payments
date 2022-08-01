enum OSPMTError: Int, CustomNSError, LocalizedError {
    case invalidConfiguration = 1
    case walletNotAvailable = 2
    case paymentNotAvailable = 3
    case setupPaymentNotAvailable = 4
    
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
        }
    }
}

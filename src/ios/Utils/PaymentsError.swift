enum PaymentsError: Int, CustomNSError, LocalizedError {
    
    case setupError = 1
    case displayButtonError = 2
    case configurationsMissingError = 3
    case paymentControllerPresentationError = 4
    case notSuccessfulError = 5
    case invalidTotalInformationError = 6
    case invalidMerchantInformationError = 7
    case invalidShippingInformationError = 8
    case invalidBillingInformationError = 9
    
    var errorDescription: String? {
        switch self {
        case .setupError:
            return "Couldn't setup payments."
        case .displayButtonError:
            return "Couldn't display payments button."
        case .configurationsMissingError:
            return "There are payment configurations misssing."
        case .paymentControllerPresentationError:
            return "Couldn't present the payment view."
        case .notSuccessfulError:
            return "Couldn't successfully complete the payment process."
        case .invalidTotalInformationError:
            return "Couldn't read payment total information."
        case .invalidMerchantInformationError:
            return "Couldn't read merchant information."
        case .invalidShippingInformationError:
            return "Couldn't read shipping information."
        case .invalidBillingInformationError:
            return "Couldn't read billing information."
        }
    }

}

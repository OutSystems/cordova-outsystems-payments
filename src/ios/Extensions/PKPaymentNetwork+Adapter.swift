import PassKit

extension PKPaymentNetwork {
    static func convert(from text: String) -> PKPaymentNetwork? {
        switch text.lowercased() {
        case "amex":
            return .amex
        case "discover":
            return .discover
        case "visa":
            return .visa
        case "mastercard":
            return .masterCard
        default:
            return nil
        }
    }
}

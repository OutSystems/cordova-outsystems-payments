import PassKit

extension PKMerchantCapability {
    static func convert(from text: String) -> PKMerchantCapability? {
        switch text.lowercased() {
        case "debit":
            return .capabilityDebit
        case "credit":
            return .capabilityCredit
        case "3ds":
            return .capability3DS
        case "emv":
            return .capabilityEMV
        default:
            return nil
        }
    }
}

import PassKit

/// Status of the final value to be charged.
enum OSPMTStatus: String, Codable {
    case final
    case pending
}

/// Payment Details to be processed.
struct OSPMTDetailsModel: Decodable {
    let amount: Decimal
    let currency: String
    let status: OSPMTStatus
    let shippingContactArray: [String]?
    let billingContactArray: [String]?
    
    /// Keys used to encode and decode the model.
    enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case status
        case shippingContactArray = "shippingContacts"
        case billingContactArray = "billingContacts"
    }
    
    /// Constructor method.
    /// - Parameters:
    ///   - amount: Amount to be charged.
    ///   - currency: The three-letter ISO 4217 currency code.
    ///   - status: Final value status.
    ///   - shippingContactArray: Shipping properties required for filling.
    ///   - billingContactArray: Billiing properties required for filling.
    init(amount: Decimal, currency: String, status: OSPMTStatus, shippingContactArray: [String]? = nil, billingContactArray: [String]? = nil) {
        self.amount = amount
        self.currency = currency
        self.status = status
        self.shippingContactArray = shippingContactArray
        self.billingContactArray = billingContactArray
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let amount = try container.decode(Decimal.self, forKey: .amount)
        let currency = try container.decode(String.self, forKey: .currency)
        let status = try container.decode(OSPMTStatus.self, forKey: .status)
        let shippingContactArray = try container.decodeIfPresent([String].self, forKey: .shippingContactArray)
        let billingContactArray = try container.decodeIfPresent([String].self, forKey: .billingContactArray)
        self.init(
            amount: amount, currency: currency, status: status, shippingContactArray: shippingContactArray, billingContactArray: billingContactArray
        )
    }
}

// MARK: Apple Pay extension
extension OSPMTDetailsModel {
    var paymentAmount: NSDecimalNumber {
        NSDecimalNumber(decimal: self.amount)
    }
    
    var paymentSummaryItemType: PKPaymentSummaryItemType {
        self.status == .pending ? .pending : .final
    }
}

/// Payment Data Information
struct OSPMTDataModel: Codable {
    let billingInfo: OSPMTContactInfoModel?
    let cardDetails: String
    let cardNetwork: String
    let tokenData: OSPMTTokenInfoModel
    
    /// Keys used to encode and decode the model.
    enum CodingKeys: String, CodingKey {
        case billingInfo, cardDetails, cardNetwork, tokenData
    }
    
    /// Constructor method.
    /// - Parameters:
    ///   - billingInfo: Billing Information.
    ///   - cardDetails: The last four digits of the card used for payment.
    ///   - cardNetwork: The network of the card used for payment.
    ///   - tokenData: The data of the token used for payment.
    init(billingInfo: OSPMTContactInfoModel? = nil, cardDetails: String, cardNetwork: String, tokenData: OSPMTTokenInfoModel) {
        self.billingInfo = billingInfo
        self.cardDetails = cardDetails
        self.cardNetwork = cardNetwork
        self.tokenData = tokenData
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let billingInfo = try container.decodeIfPresent(OSPMTContactInfoModel.self, forKey: .billingInfo)
        let cardDetails = try container.decode(String.self, forKey: .cardDetails)
        let cardNetwork = try container.decode(String.self, forKey: .cardNetwork)
        let tokenData = try container.decode(OSPMTTokenInfoModel.self, forKey: .tokenData)
        self.init(billingInfo: billingInfo, cardDetails: cardDetails, cardNetwork: cardNetwork, tokenData: tokenData)
    }
    
    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(billingInfo, forKey: .billingInfo)
        try container.encode(cardDetails, forKey: .cardDetails)
        try container.encode(cardNetwork, forKey: .cardNetwork)
        try container.encode(tokenData, forKey: .tokenData)
    }
}

extension OSPMTDataModel: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// - Returns: The comparison result.
    static func == (lhs: OSPMTDataModel, rhs: OSPMTDataModel) -> Bool {
        lhs.billingInfo == rhs.billingInfo
        && lhs.cardDetails == rhs.cardDetails
        && lhs.cardNetwork == rhs.cardNetwork
        && lhs.tokenData == rhs.tokenData
    }
}

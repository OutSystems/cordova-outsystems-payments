struct PaymentsTotal {
    let amount: Decimal
    let currency: String
    let discount: Decimal?
}

extension PaymentsTotal: Codable {
    enum CodingKeys: String, CodingKey {
        case amount, currency, discount
    }
    
    // MARK: Encodable Methods
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.currency, forKey: .currency)
        try container.encodeIfPresent(self.discount, forKey: .discount)
    }
    
    // MARK: Decodable Methods
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let amount = try container.decode(Decimal.self, forKey: .amount)
        let currency = try container.decode(String.self, forKey: .currency)
        let discount = try container.decodeIfPresent(Decimal.self, forKey: .discount)
        
        self.init(amount: amount, currency: currency, discount: discount)
    }
}

struct PaymentsDeliveryMethod {
    let labelText: String
    let detailText: String
    let amount: Decimal
    let startDate: Date
    let endDate: Date
}

extension PaymentsDeliveryMethod: Codable {
    enum CodingKeys: String, CodingKey {
        case labelText, detailText, amount, startDate, endDate
    }
    
    // MARK: Encodable Methods
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.labelText, forKey: .labelText)
        try container.encode(self.detailText, forKey: .detailText)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.endDate, forKey: .endDate)
    }
    
    // MARK: Decodable Methods
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let labelText = try container.decode(String.self, forKey: .labelText)
        let detailText = try container.decode(String.self, forKey: .detailText)
        let amount = try container.decode(Decimal.self, forKey: .amount)
        let startDate = try container.decode(Date.self, forKey: .startDate)
        let endDate = try container.decode(Date.self, forKey: .endDate)
        
        self.init(labelText: labelText, detailText: detailText, amount: amount, startDate: startDate, endDate: endDate)
    }
}

struct PaymentsShipping {
    let type: String
    // let allowedCountries: [String]?
    let deliveryMethods: [PaymentsDeliveryMethod]?
    var selectedDeliveryMethod: PaymentsDeliveryMethod?
    let contacts: [String]    
}

extension PaymentsShipping: Codable {
    enum CodingKeys: String, CodingKey {
        case type, allowedCountries, deliveryMethods, selectedDeliveryMethod, contacts
    }
    
    // MARK: Encodable Methods
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
        // try container.encodeIfPresent(self.allowedCountries, forKey: .allowedCountries)
        try container.encodeIfPresent(self.deliveryMethods, forKey: .deliveryMethods)
        try container.encodeIfPresent(self.selectedDeliveryMethod, forKey: .selectedDeliveryMethod)
        try container.encode(self.contacts, forKey: .contacts)
    }
    
    // MARK: Decodable Methods
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        // let allowedCountries = try container.decodeIfPresent([String].self, forKey: .allowedCountries)
        let deliveryMethods = try container.decodeIfPresent([PaymentsDeliveryMethod].self, forKey: .deliveryMethods)
        let selectedDeliveryMethod = try container.decodeIfPresent(PaymentsDeliveryMethod.self, forKey: .selectedDeliveryMethod)
        let contacts = try container.decode([String].self, forKey: .contacts)
        
        self.init(
            type: type,
            // allowedCountries: allowedCountries,
            deliveryMethods: deliveryMethods,
            selectedDeliveryMethod: selectedDeliveryMethod,
            contacts: contacts
        )
    }
}

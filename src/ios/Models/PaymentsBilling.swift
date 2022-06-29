struct PaymentsBilling {
    let contacts: [String]
}

extension PaymentsBilling: Codable {
    enum CodingKeys: String, CodingKey {
        case contacts
    }
    
    // MARK: Encodable Methods
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.contacts, forKey: .contacts)
    }
    
    // MARK: Decodable Methods
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contacts = try container.decode([String].self, forKey: .contacts)
        
        self.init(contacts: contacts)
    }
}

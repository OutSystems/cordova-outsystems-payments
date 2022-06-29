struct PaymentsMerchant {
    let name: String
    let country: String
    let capabilities: String
    let networks: [String]
}

extension PaymentsMerchant: Codable {
    enum CodingKeys: String, CodingKey {
        case name, country, capabilities, networks
    }
    
    // MARK: Encodable Methods
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.country, forKey: .country)
        try container.encode(self.capabilities, forKey: .capabilities)
        try container.encode(self.networks, forKey: .networks)
    }
    
    // MARK: Decodable Methods
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let country = try container.decode(String.self, forKey: .country)
        let capabilities = try container.decode(String.self, forKey: .capabilities)
        let networks = try container.decode([String].self, forKey: .networks)
        
        self.init(name: name, country: country, capabilities: capabilities, networks: networks)
    }
}

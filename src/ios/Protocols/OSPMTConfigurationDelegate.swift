typealias OSPMTConfiguration = [String: Any]

protocol OSPMTConfigurationDelegate: CustomStringConvertible {
    var source: OSPMTConfiguration { get set }
    
    // MARK: Merchant Information
    var merchantID: String? { get }
    var merchantName: String? { get }
    var merchantCountryCode: String? { get }
    
    // MARK: Payment Information
    var paymentAllowedNetworks: [String]? { get }
    var paymentSupportedCapabilities: [String]? { get }
    var paymentSupportedCardCountries: [String]? { get }
    
    // MARK: Shipping Information
    var shippingSupportedContacts: [String]? { get }
    
    // MARK: Billing Information
    var billingSupportedContacts: [String]? { get }
}

extension OSPMTConfigurationDelegate {
    func getTextArrayProperty(for key: String) -> [String]? {
        var result: [String]?
        
        if let valueText = self.source[key] as? String {
            result = valueText.components(separatedBy: ",")
        } else if let valueArray = self.source[key] as? [String] {
            result = valueArray
        }
        
        return result
    }
}

/// `ÒSPMTConfigurationProtocol` implemention for Apple Pay
struct OSPMTApplePayConfiguration: OSPMTConfigurationDelegate {
    struct ConfigurationKeys {
        static let merchantID = "ApplePayMerchantID"
        static let merchantName = "ApplePayMerchantName"
        static let merchantCountryCode = "ApplePayMerchantCountryCode"
        
        static let paymentAllowedNetworks = "ApplePayPaymentAllowedNetworks"
        static let paymentSupportedCapabilities = "ApplePayPaymentSupportedCapabilities"
        static let paymentSupportedCardCountries = "ApplePayPaymentSupportedCardCountries"
        
        static let shippingSupportedContacts = "ApplePayShippingSupportedContacts"
        
        static let billingSupportedContacts = "ApplePayBillingSupportedContacts"
    }
    
    var source: OSPMTConfiguration
    
    // MARK: Merchant Information
    var merchantID: String? {
        self.source[ConfigurationKeys.merchantID] as? String
    }
    var merchantName: String? {
        self.source[ConfigurationKeys.merchantName] as? String
    }
    var merchantCountryCode: String? {
        self.source[ConfigurationKeys.merchantCountryCode] as? String
    }
    
    // MARK: Payment Information
    var paymentAllowedNetworks: [String]? {
        self.getTextArrayProperty(for: ConfigurationKeys.paymentAllowedNetworks)
    }
    var paymentSupportedCapabilities: [String]? {
        self.getTextArrayProperty(for: ConfigurationKeys.paymentSupportedCapabilities)
    }
    var paymentSupportedCardCountries: [String]? {
        self.getTextArrayProperty(for: ConfigurationKeys.paymentSupportedCardCountries)
    }
    
    // MARK: Shipping Information
    var shippingSupportedContacts: [String]? {
        self.getTextArrayProperty(for: ConfigurationKeys.shippingSupportedContacts)
    }
    
    // MARK: Billing Information
    var billingSupportedContacts: [String]? {
        self.getTextArrayProperty(for: ConfigurationKeys.billingSupportedContacts)
    }
    
    // MARK: CustomStringConvertible Property
    var description: String {
        guard let merchantID = self.merchantID,
              let merchantName = self.merchantName,
              let merchantCountryCode = self.merchantCountryCode,
              let paymentAllowedNetworks = self.paymentAllowedNetworks,
              let paymentSupportedCapabilities = self.paymentSupportedCapabilities,
              let paymentSupportedCardCountries = self.paymentSupportedCardCountries
        else { return "" }

        var configurationDict: [String: Any] = [
            ConfigurationKeys.merchantID: merchantID,
            ConfigurationKeys.merchantName: merchantName,
            ConfigurationKeys.merchantCountryCode: merchantCountryCode,
            
            ConfigurationKeys.paymentAllowedNetworks: paymentAllowedNetworks,
            ConfigurationKeys.paymentSupportedCapabilities: paymentSupportedCapabilities,
            ConfigurationKeys.paymentSupportedCardCountries: paymentSupportedCardCountries
        ]
        
        if let shippingSupportedContacts = shippingSupportedContacts {
            configurationDict[ConfigurationKeys.shippingSupportedContacts] = shippingSupportedContacts
        }
        
        if let billingSupportedContacts = self.billingSupportedContacts {
            configurationDict[ConfigurationKeys.billingSupportedContacts] = billingSupportedContacts
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: configurationDict), let result = String(data: data, encoding: .utf8) else { return "" }
        return result
    }
}


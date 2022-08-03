import PassKit

typealias OSPMTConfiguration = [String: Any]

/// Protocol that contains all properties needed to configure a payment service.
protocol OSPMTConfigurationDelegate: AnyObject, CustomStringConvertible {
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

/// Manages all configuration properties required to enable Apple Pay in the plugin.
class OSPMTApplePayConfiguration: OSPMTConfigurationDelegate {
    /// Structures with all configuration property identifiers.
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
    
    /// Constructor method.
    /// - Parameter source: The source to fetch the configuration for (e.g. main bundle).
    init(source: OSPMTConfiguration) {
        self.source = source
    }
    
    // MARK: Merchant Information
    var merchantID: String? {
        self.getRequiredProperty(ofType: String.self, forKey: ConfigurationKeys.merchantID)
    }
    var merchantName: String? {
        self.getRequiredProperty(ofType: String.self, forKey: ConfigurationKeys.merchantName)
    }
    var merchantCountryCode: String? {
        self.getRequiredProperty(ofType: String.self, forKey: ConfigurationKeys.merchantCountryCode)
    }
    
    // MARK: Payment Information
    var paymentAllowedNetworks: [String]? {
        self.getRequiredProperty(ofType: [String].self, forKey: ConfigurationKeys.paymentAllowedNetworks)
    }
    var paymentSupportedCapabilities: [String]? {
        self.getRequiredProperty(ofType: [String].self, forKey: ConfigurationKeys.paymentSupportedCapabilities)
    }
    var paymentSupportedCardCountries: [String]? {
        self.getProperty(ofType: [String].self, forKey: ConfigurationKeys.paymentSupportedCardCountries)
    }
    
    // MARK: Shipping Information
    var shippingSupportedContacts: [String]? {
        self.getProperty(ofType: [String].self, forKey: ConfigurationKeys.shippingSupportedContacts)
    }
    
    // MARK: Billing Information
    var billingSupportedContacts: [String]? {
        self.getProperty(ofType: [String].self, forKey: ConfigurationKeys.billingSupportedContacts)
    }
    
    // MARK: CustomStringConvertible Property
    lazy var description: String = {
        guard let merchantID = self.merchantID,
              let merchantName = self.merchantName,
              let merchantCountryCode = self.merchantCountryCode,
              let paymentAllowedNetworks = self.paymentAllowedNetworks,
              let paymentSupportedCapabilities = self.paymentSupportedCapabilities,
              let shippingSupportedContacts = self.shippingSupportedContacts,
              let billingSupportedContacts = self.billingSupportedContacts
        else { return "" }

        var configurationDict: [String: Any] = [
            ConfigurationKeys.merchantID: merchantID,
            ConfigurationKeys.merchantName: merchantName,
            ConfigurationKeys.merchantCountryCode: merchantCountryCode,
            
            ConfigurationKeys.paymentAllowedNetworks: paymentAllowedNetworks,
            ConfigurationKeys.paymentSupportedCapabilities: paymentSupportedCapabilities
        ]
        
        if let shippingSupportedContacts = self.shippingSupportedContacts {
            configurationDict[ConfigurationKeys.shippingSupportedContacts] = shippingSupportedContacts
        }
        if let billingSupportedContacts = self.billingSupportedContacts {
            configurationDict[ConfigurationKeys.billingSupportedContacts] = billingSupportedContacts
        }
        if let paymentSupportedCardCountries = self.paymentSupportedCardCountries {
            configurationDict[ConfigurationKeys.paymentSupportedCardCountries] = paymentSupportedCardCountries
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: configurationDict), let result = String(data: data, encoding: .utf8)
        else { return "" }
        return result
    }()
}

private extension OSPMTApplePayConfiguration {
    /// Fetches the parameter property, if it exists.
    /// - Parameters:
    ///   - type: Type of variable to return.
    ///   - key: Property key to search from.
    ///   - isRequired: Indicates if the property is mandatory or not.
    /// - Returns: The configuration property, if it exists.
    func getProperty<T: Collection>(ofType type: T.Type, forKey key: String, isRequired: Bool = false) -> T? {
        let result = self.source[key] as? T
        return !isRequired || result?.isEmpty == false ? result : nil
    }
    
    /// An acelerator for `getProperty(ofType:forKey:isRequired:)`, that should be used for mandatory properties.
    /// - Parameters:
    ///   - type: Type of variable to return.
    ///   - key: Property key to search from.
    /// - Returns: The configuration property, if it exists.
    func getRequiredProperty<T: Collection>(ofType type: T.Type, forKey key: String) -> T? {
        self.getProperty(ofType: type, forKey: key, isRequired: true)
    }
}

extension OSPMTApplePayConfiguration {
    var supportedNetworks: [PKPaymentNetwork]? {
        guard let paymentAllowedNetworks = self.paymentAllowedNetworks else { return nil }
        let result = paymentAllowedNetworks.compactMap(PKPaymentNetwork.convert(from:))
        
        return !result.isEmpty ? result : nil
    }
    
    var merchantCapabilities: PKMerchantCapability? {
        guard let paymentSupportedCapabilities = self.paymentSupportedCapabilities else { return nil }
        
        var result: PKMerchantCapability = []
        result = paymentSupportedCapabilities.reduce(into: result) { partialResult, capability in
            let merchantCapability = PKMerchantCapability.convert(from: capability)
            if let merchantCapability = merchantCapability {
                partialResult.insert(merchantCapability)
            }
        }
        
        return !result.isEmpty ? result : nil
    }
    
    var supportedCountries: Set<String>? {
        guard let paymentSupportedCardCountries = self.paymentSupportedCardCountries, !paymentSupportedCardCountries.isEmpty else { return nil }
        return Set(paymentSupportedCardCountries)
    }
}

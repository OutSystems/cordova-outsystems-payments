import PassKit

typealias ProviderConfigurationType = [String: Any]

class ApplePayHandler: NSObject, PaymentsHandlerProtocol {
    let configuration: ProviderConfigurationType?
    
    var paymentsTotal: PaymentsTotal?
    var paymentsMerchant: PaymentsMerchant?
    var paymentsShipping: PaymentsShipping?
    var paymentsBilling: PaymentsBilling?
    var supportsCouponCode = false
    
    var paymentController: PKPaymentAuthorizationController?
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: PaymentCompletionHandler!
    
    init(configuration: ProviderConfigurationType? = Bundle.main.infoDictionary) {
        self.configuration = configuration
        super.init()
    }
}

// MARK: Class Utility Methods
private extension ApplePayHandler {
    struct ConfigurationKeys {
        static let merchantIdentifier = "ApplePayMerchantID"
    }
    
    var merchantIdentifier: String? {
        guard let configuration = self.configuration, let merchantIdentifier = configuration[ConfigurationKeys.merchantIdentifier] as? String
        else { return nil }
        
        return merchantIdentifier
    }
}

extension ApplePayHandler {
    
    func checkAvailability(forCardNetworks supportedNetworks: [String]?) -> (canMakePayments: Bool, canSetupPayments: Bool) {
        let canMakePayments = PKPaymentAuthorizationController.canMakePayments()
        var canSetupPayments = false
        
        if let supportedNetworks = supportedNetworks {
            let networks = supportedNetworks.map { PKPaymentNetwork($0) }
            canSetupPayments = PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
        }
        
        return (canMakePayments, canSetupPayments)
    }
    
    func setupPressed() {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }
    
    func payPressed(_ completion: @escaping PaymentCompletionHandler) {
        guard let merchantIdentifier = self.merchantIdentifier
        else {
            completion(.failure(.configurationsMissingError))
            return
        }
        
        self.completionHandler = completion
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = merchantIdentifier
        if #available(iOS 15.0, *) {
            paymentRequest.supportsCouponCode = self.supportsCouponCode
        }
        if let paymentsTotal = self.paymentsTotal {
            paymentRequest.paymentSummaryItems = paymentsTotal.paymentSummaryItems
            paymentRequest.currencyCode = paymentsTotal.currency
        }
        if let paymentsMerchant = self.paymentsMerchant {
            paymentRequest.merchantCapabilities = paymentsMerchant.merchantCapabilities
            paymentRequest.countryCode = paymentsMerchant.country
            paymentRequest.supportedNetworks = paymentsMerchant.supportedNetworks
        }
        if let paymentsShipping = self.paymentsShipping {
            paymentRequest.shippingType = paymentsShipping.shippingType
            paymentRequest.shippingMethods = paymentsShipping.shippingMethods
            // paymentRequest.supportedCountries = paymentsShipping.supportedCountries
            paymentRequest.requiredShippingContactFields = paymentsShipping.contactFields
        }
        if let paymentsBilling = self.paymentsBilling {
            paymentRequest.requiredBillingContactFields = paymentsBilling.contactFields
        }
        
        self.paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        self.paymentController?.delegate = self
        self.paymentController?.present(completion: { presented in
            self.paymentStatus = .failure
            
            if !presented {
                completion(.failure(.paymentControllerPresentationError))
            }
        })
    }
}

// MARK: - Set up PKPaymentAuthorizationControllerDelegate conformance.
extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            // The payment sheet doesn't automatically dismiss once it has finished. Dismiss the payment sheet.
            DispatchQueue.main.async {
                self.completionHandler!(.success(self.paymentStatus == .success))
            }
        }
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        guard let paymentsTotal = self.paymentsTotal else { return }
        let newDeliveryMethodSelected = self.paymentsShipping?.deliveryMethods?.filter { $0.labelText == shippingMethod.identifier }.first
        self.paymentsShipping?.selectedDeliveryMethod = newDeliveryMethodSelected
        
        completion(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: paymentsTotal.paymentSummaryItems))
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // TODO: payment token can be obtained through the following call
//        let paymentToken = payment.token
        
        // TODO: payment method can be obtained through the following call
//        let paymentMethod = paymentToken.paymentMethod
    }
}

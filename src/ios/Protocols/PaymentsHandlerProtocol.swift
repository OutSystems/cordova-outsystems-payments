typealias PaymentCompletionHandler = (Result<Bool, PaymentsError>) -> Void

protocol PaymentsHandlerProtocol: AnyObject {
    var paymentsTotal: PaymentsTotal? { get set }
    var paymentsMerchant: PaymentsMerchant? { get set }
    var paymentsShipping: PaymentsShipping? { get set }
    var paymentsBilling: PaymentsBilling? { get set }
    func checkAvailability(forCardNetworks supportedNetworks: [String]?) -> (canMakePayments: Bool, canSetupPayments: Bool)
    func setupPressed()
    func payPressed(_ completion: @escaping PaymentCompletionHandler)
}

extension PaymentsHandlerProtocol {
    func checkAvailability() -> (canMakePayments: Bool, canSetupPayments: Bool) {
        return self.checkAvailability(forCardNetworks: nil)
    }
}

protocol PaymentsActionDelegate: AnyObject {
    func displaySetupButton(forNetworks supportedNetworks: [String])
    func displayPayButton()
    func clickSetupButton()
    func clickPayButton()
    func setTotal(_ data: String)
    func getTotal()
    func getMerchant()
    func setMerchant(_ data: String)
    func getShippingInformation()
    func setShippingInformation(_ data: String)
    func getBillingInformation()
    func setBillingInformation(_ data: String)
}

class PaymentsController: NSObject {
    private let delegate: PaymentsCallbackProtocol?
    private let handler: PaymentsHandlerProtocol?
    
    init(delegate: PaymentsCallbackProtocol, handler: PaymentsHandlerProtocol) {
        self.delegate = delegate
        self.handler = handler
    }
    
    convenience init(applePayWithDelegate delegate: PaymentsCallbackProtocol) {
        let applePayHandler = ApplePayHandler()
        self.init(delegate: delegate, handler: applePayHandler)
    }
}

// MARK: - Action Methods to be called by Bridge
extension PaymentsController: PaymentsActionDelegate {
    func displaySetupButton(forNetworks supportedNetworks: [String]) {
        if let canSetup = self.handler?.checkAvailability(forCardNetworks: supportedNetworks).canSetupPayments, canSetup {
            self.delegate?.callbackSuccess()
        } else {
            self.delegate?.callbackError(error: .setupError)
        }
    }
    
    func displayPayButton() {
        if let canDisplay = self.handler?.checkAvailability().canMakePayments, canDisplay {
            self.delegate?.callbackSuccess()
        } else {
            self.delegate?.callbackError(error: .displayButtonError)
        }
    }
    
    func clickSetupButton() {
        self.handler?.setupPressed()
        self.delegate?.callbackSuccess()
    }
    
    func clickPayButton() {
        self.handler?.payPressed { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                if success {
                    self.delegate?.callbackSuccess()
                } else {
                    self.delegate?.callbackError(error: .notSuccessfulError)
                }
            case .failure(let error):
                self.delegate?.callbackError(error: error)
            }
        }
    }
    
    func getTotal() {
        guard let handler = self.handler else { return }
        self.get(variable: &handler.paymentsTotal, error: .invalidTotalInformationError)
    }
    
    func setTotal(_ data: String) {
        guard let handler = self.handler else { return }
        self.set(string: data, for: &handler.paymentsTotal, error: .invalidTotalInformationError)
    }
    
    func getMerchant() {
        guard let handler = self.handler else { return }
        self.get(variable: &handler.paymentsMerchant, error: .invalidMerchantInformationError)
    }
    
    func setMerchant(_ data: String) {
        guard let handler = self.handler else { return }
        self.set(string: data, for: &handler.paymentsMerchant, error: .invalidMerchantInformationError)
    }
    
    func getShippingInformation() {
        guard let handler = self.handler else { return }
        self.get(variable: &handler.paymentsShipping, error: .invalidShippingInformationError)
    }
    
    func setShippingInformation(_ data: String) {
        guard let handler = self.handler else { return }
        self.set(string: data, for: &handler.paymentsShipping, error: .invalidShippingInformationError)
    }
    
    func getBillingInformation() {
        guard let handler = self.handler else { return }
        self.get(variable: &handler.paymentsBilling, error: .invalidBillingInformationError)
    }
    
    func setBillingInformation(_ data: String) {
        guard let handler = self.handler else { return }
        self.set(string: data, for: &handler.paymentsBilling, error: .invalidBillingInformationError)
    }
}

// MARK: Private Methods
private extension PaymentsController {
    func get<T: Encodable>(variable: inout T, error paymentError: PaymentsError) {
        do {
            let jsonData = try JSONEncoder().encode(variable)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                self.delegate?.callback(result: jsonString)
            } else {
                throw paymentError
            }
        } catch {
            self.delegate?.callbackError(error: paymentError)
        }
    }
    
    func set<T: Decodable>(string: String, for variable: inout T, error paymentError: PaymentsError) {
        do {
            if let data = string.data(using: .utf8) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.locale = Locale.current
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                variable = try jsonDecoder.decode(T.self, from: data)
                
                self.delegate?.callbackSuccess()
            } else {
                throw paymentError
            }
        } catch {
            self.delegate?.callbackError(error: paymentError)
        }
    }
}

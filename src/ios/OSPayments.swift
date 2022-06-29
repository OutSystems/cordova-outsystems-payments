import OSCore

@objc(OSPayments)
class OSPayments: CDVPlugin {

    var plugin: PaymentsController?
    var callbackId: String = ""
    
    override func pluginInitialize() {
        self.plugin = PaymentsController(applePayWithDelegate: self)
    }
    
    @objc(displaySetupButton:)
    func displaySetupButton(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        
        guard let networksString = command.arguments.first as? String
        else {
            self.callbackError(error: .setupError)
            return
        }
        
        let networkArray = networksString.components(separatedBy: ",")
        self.plugin?.displaySetupButton(forNetworks: networkArray)
    }
    
    @objc(displayPayButton:)
    func displayPayButton(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        self.plugin?.displayPayButton()
    }
    
    @objc(clickSetupButton:)
    func clickSetupButton(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        self.plugin?.clickSetupButton()
    }
    
    @objc(clickPayButton:)
    func clickPayButton(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        self.plugin?.clickPayButton()
    }
    
    @objc(getTotal:)
    func getTotal(command: CDVInvokedUrlCommand) {
        self.get(command, method: self.plugin?.getTotal)
    }
    
    @objc(setTotal:)
    func setTotal(command: CDVInvokedUrlCommand) {
        self.set(command, error: .invalidTotalInformationError, method: self.plugin?.setTotal(_:))
    }
    
    @objc(getMerchant:)
    func getMerchant(command: CDVInvokedUrlCommand) {
        self.get(command, method: self.plugin?.getMerchant)
    }
    
    @objc(setMerchant:)
    func setMerchant(command: CDVInvokedUrlCommand) {
        self.set(command, error: .invalidMerchantInformationError, method: self.plugin?.setMerchant(_:))
    }
    
    @objc(getShippingInformation:)
    func getShippingInformation(command: CDVInvokedUrlCommand) {
        self.get(command, method: self.plugin?.getShippingInformation)
    }
    
    @objc(setShippingInformation:)
    func setShippingInformation(command: CDVInvokedUrlCommand) {
        self.set(command, error: .invalidShippingInformationError, method: self.plugin?.setShippingInformation(_:))
    }
    
    @objc(getBillingInformation:)
    func getBillingInformation(command: CDVInvokedUrlCommand) {
        self.get(command, method: self.plugin?.getBillingInformation)
    }
    
    @objc(setBillingInformation:)
    func setBillingInformation(command: CDVInvokedUrlCommand) {
        self.set(command, error: .invalidBillingInformationError, method: self.plugin?.setBillingInformation(_:))
    }
}

// MARK: Private Methods
private extension OSPayments {
    func get(_ command: CDVInvokedUrlCommand, method: (() -> Void)?) {
        self.callbackId = command.callbackId
        method?()
    }
    
    func set(_ command: CDVInvokedUrlCommand, error: PaymentsError, method: ((String) -> Void)?) {
        self.callbackId = command.callbackId
        
        guard let data = command.arguments.first as? String
        else {
            self.callbackError(error: error)
            return
        }
        
        method?(data)
    }
}

// MARK: - OSCore's PlatformProtocol Methods
extension OSPayments: PlatformProtocol {
    func sendResult(result: String? = nil, error: NSError? = nil, callBackID: String) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        if let error = error{
            let errorDict: [String: Any] = ["code": error.code, "message": error.localizedDescription]
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: errorDict);
        } else if let result = result {
            pluginResult = result.isEmpty ? CDVPluginResult(status: CDVCommandStatus_OK) : CDVPluginResult(status: CDVCommandStatus_OK, messageAs: result)
        }

        self.commandDelegate.send(pluginResult, callbackId: callBackID);
    }
}

// MARK: - OSPaymentsLib's PaymentsCallbackProtocol Methods
extension OSPayments: PaymentsCallbackProtocol {
    func callback(result: String?, error: PaymentsError?) {
        if let error = error as? NSError {
            self.sendResult(error: error, callBackID: self.callbackId)
        } else if let result = result {
            self.sendResult(result: result, callBackID: self.callbackId)
        }
    }
}

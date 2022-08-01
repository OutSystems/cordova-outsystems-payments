class OSPMTPayments: NSObject {
    private let delegate: OSPMTCallbackDelegate
    private let handler: OSPMTHandlerDelegate
    
    init(delegate: OSPMTCallbackDelegate, handler: OSPMTHandlerDelegate) {
        self.delegate = delegate
        self.handler = handler
    }
    
    convenience init(applePayWithDelegate delegate: OSPMTCallbackDelegate, andConfiguration configurationSource: OSPMTConfiguration =  Bundle.main.infoDictionary!) {
        let applePayHandler = OSPMTApplePayHandler(configurationSource: configurationSource)
        self.init(delegate: delegate, handler: applePayHandler)
    }
}

// MARK: - Action Methods to be called by Bridge
extension OSPMTPayments: OSPMTActionDelegate {
    func setupConfiguration() {
        let result = self.handler.setupConfiguration()
        
        switch result {
        case .success(let message):
            self.delegate.callback(result: message)
        case .failure(let error):
            self.delegate.callback(error: error)
        }
    }
}

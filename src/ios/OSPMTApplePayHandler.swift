class OSPMTApplePayHandler: NSObject {
    let configuration: OSPMTConfigurationDelegate
    let availabilityBehaviour: OSPMTAvailabilityDelegate
    
    init(configuration: OSPMTConfigurationDelegate, availabilityBehaviour: OSPMTAvailabilityDelegate) {
        self.configuration = configuration
        self.availabilityBehaviour = availabilityBehaviour
        super.init()
    }
    
    convenience init(configurationSource: OSPMTConfiguration = Bundle.main.infoDictionary!) {
        let applePayConfiguration = OSPMTApplePayConfiguration(source: configurationSource)
        let applePayAvailabilityBehaviour = OSPMTApplePayAvailabilityBehaviour(configuration: applePayConfiguration)
        self.init(configuration: applePayConfiguration, availabilityBehaviour: applePayAvailabilityBehaviour)
    }
}

// MARK: - OSPMTHandlerProtocol Methods
extension OSPMTApplePayHandler: OSPMTHandlerDelegate {
    func setupConfiguration() -> Result<String, OSPMTError> {
        !self.configuration.description.isEmpty ? .success(self.configuration.description) : .failure(.invalidConfiguration)
    }
    
    func checkWalletAvailability() -> OSPMTError? {
        self.availabilityBehaviour.checkWallet() ?? self.availabilityBehaviour.checkPayment() ?? self.availabilityBehaviour.checkPaymentSetup()
    }
}

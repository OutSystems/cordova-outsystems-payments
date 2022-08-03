/// Class resopnsible to manage the Apple Pay payment service requests. It delegates every operation type to its manager.
class OSPMTApplePayHandler: NSObject {
    let configuration: OSPMTConfigurationDelegate
    let availabilityBehaviour: OSPMTAvailabilityDelegate
    let requestBehaviour: OSPMTRequestDelegate
    
    /// Constructor .method.
    /// - Parameters:
    ///   - configuration: Configuration manager.
    ///   - availabilityBehaviour: Availability manager.
    ///   - requestBehaviour: Request trigger manager.
    init(configuration: OSPMTConfigurationDelegate, availabilityBehaviour: OSPMTAvailabilityDelegate, requestBehaviour: OSPMTRequestDelegate) {
        self.configuration = configuration
        self.availabilityBehaviour = availabilityBehaviour
        self.requestBehaviour = requestBehaviour
        super.init()
    }
    
    /// Constructor method.
    /// - Parameter configurationSource: Configuration source, containing all values needed to configure.
    convenience init(configurationSource: OSPMTConfiguration) {
        let applePayConfiguration = OSPMTApplePayConfiguration(source: configurationSource)
        let applePayAvailabilityBehaviour = OSPMTApplePayAvailabilityBehaviour(configuration: applePayConfiguration)
        let applePayRequestBehaviour = OSPMTApplePayRequestBehaviour(configuration: applePayConfiguration)
        self.init(
            configuration: applePayConfiguration, availabilityBehaviour: applePayAvailabilityBehaviour, requestBehaviour: applePayRequestBehaviour
        )
    }
}

// MARK: - OSPMTHandlerProtocol Methods
extension OSPMTApplePayHandler: OSPMTHandlerDelegate {
    /// Allows the configuration of the payment service.
    /// - Returns: Returns a JSON mapping if successful or an error if anything failed.
    func setupConfiguration() -> Result<String, OSPMTError> {
        !self.configuration.description.isEmpty ? .success(self.configuration.description) : .failure(.invalidConfiguration)
    }
    
    /// Checks for the Wallet and Payment availability.
    /// - Returns: Returns `nil` if successful or an error otherwise.
    func checkWalletAvailability() -> OSPMTError? {
        self.availabilityBehaviour.checkWallet()
        ?? self.availabilityBehaviour.checkPaymentAvailability()
        ?? self.availabilityBehaviour.checkPaymentAvailabilityWithSetup()
    }
    
    /// Sets Payment details and triggers its processing.
    /// - Parameters:
    ///   - detailsModel: payment details information.
    ///   - completion: an async closure that can return a successful Payment Scope Model or an error otherwise.
    func set(_ detailsModel: OSPMTDetailsModel, completion: @escaping OSPMTCompletionHandler) {
        self.requestBehaviour.trigger(with: detailsModel, completion)
    }
}

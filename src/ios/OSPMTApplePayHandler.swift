import PassKit

class OSPMTApplePayHandler: NSObject {
    let configuration: OSPMTApplePayConfiguration
    
    init(configurationSource: OSPMTConfiguration = Bundle.main.infoDictionary!) {
        self.configuration = OSPMTApplePayConfiguration(source: configurationSource)
        super.init()
    }
}

// MARK: - OSPMTHandlerProtocol Methods
extension OSPMTApplePayHandler: OSPMTHandlerDelegate {
    func setupConfiguration() -> Result<String, OSPMTError> {
        !self.configuration.description.isEmpty ? .success(self.configuration.description) : .failure(.invalidConfiguration)
    }
}

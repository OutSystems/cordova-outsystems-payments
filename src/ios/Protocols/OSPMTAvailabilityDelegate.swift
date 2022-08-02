import PassKit

protocol OSPMTAvailabilityDelegate: AnyObject {
    func checkWallet() -> OSPMTError?
    func checkPayment() -> OSPMTError?
    func checkPaymentSetup() -> OSPMTError?
}

class OSPMTApplePayAvailabilityBehaviour: OSPMTAvailabilityDelegate {
    let configuration: OSPMTApplePayConfiguration
    let walletAvailableBehaviour: OSPMTWalletAvailabilityDelegate.Type
    let setupAvailableBehaviour: OSPMTApplePaySetupAvailabilityDelegate.Type
    
    init(configuration: OSPMTApplePayConfiguration, walletAvailableBehaviour: OSPMTWalletAvailabilityDelegate.Type = PKPassLibrary.self, setupAvailableBehaviour: OSPMTApplePaySetupAvailabilityDelegate.Type = PKPaymentAuthorizationController.self) {
        self.configuration = configuration
        self.walletAvailableBehaviour = walletAvailableBehaviour
        self.setupAvailableBehaviour = setupAvailableBehaviour
    }
    
    func checkWallet() -> OSPMTError? {
        return !self.walletAvailableBehaviour.isWalletAvailable() ? .walletNotAvailable : nil
    }
    
    func checkPayment() -> OSPMTError? {
        return !self.setupAvailableBehaviour.isPaymentAvailable() ? .paymentNotAvailable : nil
    }
    
    func checkPaymentSetup() -> OSPMTError? {
        guard let supportedNetworks = self.configuration.supportedNetworks, let merchantCapabilities = self.configuration.merchantCapabilities
        else { return .setupPaymentNotAvailable }
        return !self.setupAvailableBehaviour.isPaymentAvailable(using: supportedNetworks, and: merchantCapabilities) ?
            .setupPaymentNotAvailable : nil
    }
}

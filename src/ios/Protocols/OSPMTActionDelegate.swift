/// Protocol that provides the server actions the plugin provides.
protocol OSPMTActionDelegate: AnyObject {
    /// Sets up the payment configuration.
    func setupConfiguration()
    
    /// Verifies the device is ready to process a payment, considering the configuration provided before.
    func checkWalletSetup()
    
    /// Sets payment details and triggers the request proccess.
    /// - Parameter details: Payment details model serialized into a text field.
    func set(_ details: String)
}

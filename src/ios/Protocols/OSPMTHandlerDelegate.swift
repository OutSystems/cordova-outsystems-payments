typealias OSPMTCompletionHandler = (Result<Bool, OSPMTError>) -> Void

protocol OSPMTHandlerDelegate: AnyObject {
    func setupConfiguration() -> Result<String, OSPMTError>
    func checkWalletAvailability() -> OSPMTError?
}

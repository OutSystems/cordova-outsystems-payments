typealias OSPMTCompletionHandler = (Result<Bool, OSPMTError>) -> Void

protocol OSPMTHandlerDelegate {
    func setupConfiguration() -> Result<String, OSPMTError>
}

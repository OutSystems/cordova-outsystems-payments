protocol OSPMTCallbackDelegate: AnyObject {
    func callback(result: String?, error: OSPMTError?)
}

// MARK: - OSPMTCallbackProtocol Default Implementation
extension OSPMTCallbackDelegate {
    func callback(error: OSPMTError) {
        self.callback(result: nil, error: error)
    }
    
    func callback(result: String) {
        self.callback(result: result, error: nil)
    }
    
    func callbackSuccess() {
        self.callback(result: "")
    }
}

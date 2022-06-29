protocol PaymentsCallbackProtocol {
    func callback(result: String?, error: PaymentsError?)
}

// MARK: - PaymentsProtocol Default Implementation
extension PaymentsCallbackProtocol {
    func callbackError(error: PaymentsError) {
        self.callback(result: nil, error: error)
    }
    
    func callback(result: String) {
        self.callback(result: result, error: nil)
    }
    
    func callbackSuccess() {
        self.callback(result: "", error: nil)
    }
}

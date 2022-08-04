import OSCore

@objc(OSPayments)
class OSPayments: CDVPlugin {
    var plugin: OSPMTPayments?
    var callbackId: String = ""

    override func pluginInitialize() {
        self.plugin = OSPMTPayments(applePayWithDelegate: self)
    }

    @objc(setupConfiguration:)
    func setupConfiguration(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId

        self.plugin?.setupConfiguration()
    }
}

// MARK: - OSCore's PlatformProtocol Methods
extension OSPayments: PlatformProtocol {
    func sendResult(result: String? = nil, error: NSError? = nil, callBackID: String) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        if let error = error {
            let errorDict: [String: Any] = ["code": error.code, "message": error.localizedDescription]
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: errorDict);
        } else if let result = result {
            pluginResult = result.isEmpty ? CDVPluginResult(status: CDVCommandStatus_OK) : CDVPluginResult(status: CDVCommandStatus_OK, messageAs: result)
        }

        self.commandDelegate.send(pluginResult, callbackId: callBackID);
    }
}

// MARK: - OSPaymentsLib's OSPMTCallbackDelegate Methods
extension OSPayments: OSPMTCallbackDelegate {
    func callback(result: String?, error: OSPMTError?) {
        if let error = error as? NSError {
            self.sendResult(error: error, callBackID: self.callbackId)
        } else if let result = result {
            self.sendResult(result: result, callBackID: self.callbackId)
        }
    }
}

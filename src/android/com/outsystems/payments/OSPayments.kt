package com.outsystems.payments

import org.apache.cordova.CallbackContext
import com.outsystems.plugins.oscordova.CordovaImplementation
import com.outsystems.plugins.payments.PaymentsController
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaWebView
import org.json.JSONArray

class OSPayments : CordovaImplementation() {

    override var callbackContext: CallbackContext? = null
    private lateinit var paymentsController: PaymentsController

    companion object {
        private const val ERROR_FORMAT_PREFIX = "OS-PLUG-PMT-"
    }

    override fun initialize(cordova: CordovaInterface, webView: CordovaWebView) {
        super.initialize(cordova, webView)
        paymentsController = PaymentsController()
    }

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        this.callbackContext = callbackContext
        if (action == "setupConfiguration") {
            this.setupConfiguration()
            return true
        }
        return false
    }

    private fun setupConfiguration() {
        paymentsController.setupConfiguration(getActivity(),
            {
                sendPluginResult(it, null)
            },
            {
                sendPluginResult(null, Pair(formatErrorCode(it.code), it.description))
            })
    }

    override fun onRequestPermissionResult(requestCode: Int,
                                           permissions: Array<String>,
                                           grantResults: IntArray) {
        // Does nothing. These permissions are not required on Android.
    }

    override fun areGooglePlayServicesAvailable(): Boolean {
        // Not used in this project.
        return false
    }

    private fun formatErrorCode(code: Int): String {
        return ERROR_FORMAT_PREFIX + code.toString().padStart(4, '0')
    }
}
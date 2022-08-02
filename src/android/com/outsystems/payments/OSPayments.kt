package com.outsystems.payments

import android.content.Intent
import org.apache.cordova.CallbackContext
import com.outsystems.plugins.oscordova.CordovaImplementation
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaWebView
import org.json.JSONArray

class OSPayments : CordovaImplementation() {

    private lateinit var paymentsController: PaymentsController

    override fun initialize(cordova: CordovaInterface, webView: CordovaWebView) {
        super.initialize(cordova, webView)
        paymentsController = PaymentsController()
    }


    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        super.execute(action, args, callbackContext)
        if (action == "setupConfiguration") {
            this.setupConfiguration(callbackContext)
            return true
        }
        return false
    }

    private fun setupConfiguration(callbackContext: CallbackContext) {
        //get configuration data to return
        sendPluginResult(paymentsController.setupConfiguration(getActivity()), null, callbackContext.callbackId)
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent) {
        super.onActivityResult(requestCode, resultCode, intent)
    }

    /*private fun formatErrorCode(code: Int): String {
        return ERROR_FORMAT_PREFIX + code.toString().padStart(4, '0')
    }
     */
}
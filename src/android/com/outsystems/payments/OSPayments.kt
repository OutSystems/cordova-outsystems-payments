package com.outsystems.payments

import org.apache.cordova.CallbackContext
import com.outsystems.plugins.oscordova.CordovaImplementation
import org.json.JSONArray

class OSPayments : CordovaImplementation() {

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        super.execute(action, args, callbackContext)
        if (action == "coolMethod") {
            val message: String = args.getString(0)
            this.coolMethod(message, callbackContext)
            return true
        }
        return false
    }

    private fun coolMethod(message: String?, callbackContext: CallbackContext) {
        if (message != null && message.length > 0) {
            callbackContext.success(message)
        } else {
            callbackContext.error("Expected one non-empty string argument.")
        }
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

}
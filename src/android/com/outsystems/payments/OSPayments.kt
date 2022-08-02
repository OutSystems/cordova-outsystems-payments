package com.outsystems.payments

import android.content.Intent
import org.apache.cordova.CallbackContext
import com.outsystems.plugins.oscordova.CordovaImplementation
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaWebView
import org.json.JSONArray
import org.json.JSONObject

class OSPayments : CordovaImplementation() {

    override fun initialize(cordova: CordovaInterface, webView: CordovaWebView) {
        super.initialize(cordova, webView)
    }


    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        super.execute(action, args, callbackContext)
        if (action == "setupConfiguration") {
            val message: String = args.getString(0)
            this.setupConfiguration(message, callbackContext)
            return true
        }
        return false
    }

    private fun setupConfiguration(message: String?, callbackContext: CallbackContext) {
        //get configuration data to return
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
}
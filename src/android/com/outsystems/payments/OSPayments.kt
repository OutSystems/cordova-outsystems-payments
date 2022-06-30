package com.outsystems.payments

import android.content.Intent
import org.apache.cordova.CallbackContext
import com.outsystems.plugins.oscordova.CordovaImplementation
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaWebView
import org.json.JSONArray
import org.json.JSONObject

class OSPayments : CordovaImplementation() {

    private lateinit var paymentsController: PaymentsController

    private val baseRequest = JSONObject().apply {
        put("apiVersion", 2)
        put("apiVersionMinor", 0)
    }

    private val allowedCardNetworks = JSONArray(listOf(
        "AMEX",
        "DISCOVER",
        "INTERAC",
        "JCB",
        "MASTERCARD",
        "MIR",
        "VISA"))

    private val allowedCardAuthMethods = JSONArray(listOf(
        "PAN_ONLY",
        "CRYPTOGRAM_3DS"))

    override fun initialize(cordova: CordovaInterface, webView: CordovaWebView) {
        super.initialize(cordova, webView)
        paymentsController = PaymentsController(getActivity())
    }


    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        super.execute(action, args, callbackContext)
        if (action == "coolMethod") {
            val message: String = args.getString(0)
            this.doPayment(message, callbackContext)
            return true
        }
        return false
    }

    private fun doPayment(message: String?, callbackContext: CallbackContext) {
        setAsActivityResultCallback()
        paymentsController.requestPayment(getActivity())
    }

    private fun gatewayTokenizationSpecification(): JSONObject {
        return JSONObject().apply {
            put("type", "PAYMENT_GATEWAY")
            put("parameters", JSONObject(mapOf(
                "gateway" to "example",
                "gatewayMerchantId" to "exampleGatewayMerchantId")))
        }
    }


    private fun baseCardPaymentMethod(): JSONObject {
        return JSONObject().apply {

            val parameters = JSONObject().apply {
                put("allowedAuthMethods", allowedCardAuthMethods)
                put("allowedCardNetworks", allowedCardNetworks)
                put("billingAddressRequired", true)
                put("billingAddressParameters", JSONObject().apply {
                    put("format", "FULL")
                })
            }

            put("type", "CARD")
            put("parameters", parameters)
        }
    }

    private fun cardPaymentMethod(): JSONObject {
        val cardPaymentMethod = baseCardPaymentMethod()
        cardPaymentMethod.put("tokenizationSpecification", gatewayTokenizationSpecification())

        return cardPaymentMethod
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
        val s = ""
    }
}
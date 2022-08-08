package com.outsystems.payments

import android.app.Activity
import org.apache.cordova.CallbackContext
import com.outsystems.plugins.oscordova.CordovaImplementation
import com.outsystems.plugins.payments.controller.GooglePayManager
import com.outsystems.plugins.payments.controller.GooglePlayHelper
import com.outsystems.plugins.payments.controller.PaymentsController
import com.outsystems.plugins.payments.model.PaymentConfigurationInfo
import kotlinx.coroutines.runBlocking
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaWebView
import org.json.JSONArray

class OSPayments : CordovaImplementation() {

    override var callbackContext: CallbackContext? = null
    private lateinit var googlePayManager: GooglePayManager
    private lateinit var paymentsController: PaymentsController
    private lateinit var googlePlayHelper: GooglePlayHelper

    companion object {
        private const val ERROR_FORMAT_PREFIX = "OS-PLUG-PMT-"
        private const val MERCHANT_NAME = "merchant_name"
        private const val MERCHANT_COUNTRY_CODE = "merchant_country_code"
        private const val PAYMENT_ALLOWED_NETWORKS = "payment_allowed_networks"
        private const val PAYMENT_SUPPORTED_CAPABILITIES = "payment_supported_capabilities"
        private const val PAYMENT_SUPPORTED_CARD_COUNTRIES = "payment_supported_card_countries"
        private const val SHIPPING_SUPPORTED_CONTACTS = "shipping_supported_contacts"
        private const val BILLING_SUPPORTED_CONTACTS = "billing_supported_contacts"
        private const val TOKENIZATION = "tokenization"
    }

    override fun initialize(cordova: CordovaInterface, webView: CordovaWebView) {
        super.initialize(cordova, webView)
        googlePayManager = GooglePayManager(getActivity())
        googlePlayHelper = GooglePlayHelper()
        paymentsController = PaymentsController(googlePayManager, buildPaymentConfigurationInfo(getActivity()), googlePlayHelper)
    }

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        this.callbackContext = callbackContext
        val result = runBlocking {
            when (action) {
                "setupConfiguration" -> {
                    setupConfiguration()
                }
                "checkWalletSetup" -> {
                    checkWalletSetup()
                }
                else -> false
            }
            true
        }
        return result
    }

    private fun setupConfiguration() {
        paymentsController.setupConfiguration(
            {
                sendPluginResult(it, null)
            },
            {
                sendPluginResult(null, Pair(formatErrorCode(it.code), it.description))
            }
        )
    }

    private fun checkWalletSetup(){
        paymentsController.verifyIfWalletIsSetup(getActivity(),
            {
                sendPluginResult(it, null)
            }, {
                sendPluginResult(null, Pair(formatErrorCode(it.code), it.description))
            }
        )
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

    private fun buildPaymentConfigurationInfo(activity: Activity) : PaymentConfigurationInfo{
        return PaymentConfigurationInfo(
            activity.getString(getStringResourceId(activity, MERCHANT_NAME)),
            activity.getString(getStringResourceId(activity, MERCHANT_COUNTRY_CODE)),
            activity.getString(getStringResourceId(activity, PAYMENT_ALLOWED_NETWORKS)).split(","),
            activity.getString(getStringResourceId(activity, PAYMENT_SUPPORTED_CAPABILITIES)).split(","),
            activity.getString(getStringResourceId(activity, PAYMENT_SUPPORTED_CARD_COUNTRIES)).split(","),
            activity.getString(getStringResourceId(activity, SHIPPING_SUPPORTED_CONTACTS)).split(","),
            activity.getString(getStringResourceId(activity, BILLING_SUPPORTED_CONTACTS)).split(","),
            activity.getString(getStringResourceId(activity, TOKENIZATION))
        )
    }

    private fun getStringResourceId(activity: Activity, typeAndName: String): Int {
        return activity.resources.getIdentifier(typeAndName, "string", activity.packageName)
    }
}
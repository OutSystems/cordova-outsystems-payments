package com.outsystems.payments

import android.app.Activity
import android.content.Intent
import com.google.gson.Gson
import org.apache.cordova.CallbackContext
import com.outsystems.plugins.oscordova.CordovaImplementation
import com.outsystems.plugins.payments.controller.GooglePayManager
import com.outsystems.plugins.payments.controller.GooglePlayHelper
import com.outsystems.plugins.payments.controller.PaymentsController
import com.outsystems.plugins.payments.model.PaymentConfigurationInfo
import com.outsystems.plugins.payments.model.PaymentDetails
import com.outsystems.plugins.payments.model.PaymentsError
import com.outsystems.plugins.payments.model.StripePaymentRequest
import com.stripe.android.ApiResultCallback
import com.stripe.android.Stripe
import com.stripe.android.model.PaymentMethod
import com.stripe.android.model.PaymentMethodCreateParams
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaWebView
import org.json.JSONArray
import org.json.JSONObject
import java.math.BigDecimal
import java.net.HttpURLConnection
import java.net.URL

class OSPayments : CordovaImplementation() {

    override var callbackContext: CallbackContext? = null
    private lateinit var googlePayManager: GooglePayManager
    private lateinit var paymentsController: PaymentsController
    private lateinit var googlePlayHelper: GooglePlayHelper

    //to delete
    private lateinit var paymentDetailsForStripe: PaymentDetails

    val gson by lazy { Gson() }

    companion object {
        private const val ERROR_FORMAT_PREFIX = "OS-PLUG-PAYM-"
        private const val MERCHANT_NAME = "merchant_name"
        private const val MERCHANT_COUNTRY_CODE = "merchant_country_code"
        private const val PAYMENT_ALLOWED_NETWORKS = "payment_allowed_networks"
        private const val PAYMENT_SUPPORTED_CAPABILITIES = "payment_supported_capabilities"
        private const val PAYMENT_SUPPORTED_CARD_COUNTRIES = "payment_supported_card_countries"
        private const val SHIPPING_SUPPORTED_CONTACTS = "shipping_supported_contacts"
        private const val SHIPPING_COUNTRY_CODES = "shipping_country_codes"
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
                    setupConfiguration(args)
                }
                "checkWalletSetup" -> {
                    checkWalletSetup()
                }
                "setDetails" -> {
                    setDetailsAndTriggerPayment(args)
                }
                else -> false
            }
            true
        }
        return result
    }

    private fun setupConfiguration(args: JSONArray) {
        paymentsController.setupConfiguration(getActivity(), args.get(0).toString(),
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

    private fun setDetailsAndTriggerPayment(args: JSONArray){
        setAsActivityResultCallback()

        val paymentDetails = buildPaymentDetails(args)

        //to delete
        if (paymentDetails != null) {
            paymentDetailsForStripe = paymentDetails
        }

        if(paymentDetails != null){
            paymentsController.setDetailsAndTriggerPayment(getActivity(), paymentDetails
            ) {
                sendPluginResult(null, Pair(formatErrorCode(it.code), it.description))
            }
        }
        else{
            sendPluginResult(null, Pair(formatErrorCode(PaymentsError.INVALID_PAYMENT_DETAILS.code), PaymentsError.INVALID_PAYMENT_DETAILS.description))
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent) {
        super.onActivityResult(requestCode, resultCode, intent)
        paymentsController.handleActivityResult(requestCode, resultCode, intent,
            { jsonResult, paymentResponse ->
                //call stripe sdk with GooglePay payment info
                processPaymentStripe(jsonResult,
                    {
                        sendPluginResult(paymentResponse, null)
                    },
                    { error ->
                        sendPluginResult(null, Pair(formatErrorCode(error.code), error.description))
                    }
                )
            },
            {
                sendPluginResult(null, Pair(formatErrorCode(it.code), it.description))
            })
    }

    private fun processPaymentStripe(googlePayObject: JSONObject?, onSuccess: (Boolean) -> Unit, onError : (PaymentsError) -> Unit) {

        val stripe = Stripe(
            getActivity(),
            "pk_test_51KvKHLI1WLTTyI34CsVnUY8UoKGVpeklyySXSMhucxD2fViPCE7kW7KUqZoULMtqav1h2kkaESWeQCAqXLKnszEq00mFN2SGup",
            null,
            true, //should be false when in production
            emptySet()
        )

        try {
            if(googlePayObject != null) {
                val params = PaymentMethodCreateParams.createFromGooglePay(googlePayObject)
                stripe.createPaymentMethod(
                    params,
                    callback = object : ApiResultCallback<PaymentMethod> {
                        override fun onSuccess(result: PaymentMethod) {
                            // handle success
                            sendToServer(result,
                                {
                                    onSuccess(true)
                                },
                                {
                                    onError(it)
                                }
                            )
                        }
                        override fun onError(e: Exception) {
                            onError(PaymentsError.PAYMENT_GENERAL_ERROR) // use general error for now, as this is a PoC
                        }
                    }
                )
            }
        }
        catch (e: Exception){
            onError(PaymentsError.PAYMENT_GENERAL_ERROR) // use general error for now, as this is a PoC
        }

    }

    private fun sendToServer(result: PaymentMethod, onSuccess: (Boolean) -> Unit, onError : (PaymentsError) -> Unit){

        //create object that has a paymentMethod of type PaymentMethod and an Amount of type String, then convert it to JSON using Gson.
        val amount = paymentDetailsForStripe.amount.multiply(BigDecimal(100)).toInt()
        val stripePaymentRequest = StripePaymentRequest(amount, result.id!!)
        val paymentRequestJson = Gson().toJson(stripePaymentRequest)

        val url = URL("http://192.168.1.120:5000/pay")
        val coroutine = CoroutineScope(Dispatchers.IO)
        val openedConnection = url.openConnection()

        coroutine.launch {
            with(openedConnection as HttpURLConnection) {
                requestMethod = "POST"
                setRequestProperty("Content-Type", "application/json")
                doOutput = true;

                outputStream.use { os ->
                    val input: ByteArray = paymentRequestJson.toByteArray()
                    os.write(input, 0, input.size)
                }

                val response = StringBuffer()
                launch {
                    inputStream.bufferedReader().use {
                        it.lines().forEach { line ->
                            response.append(line)
                        }
                    }

                    if (response.toString() == "Success!"){
                        onSuccess(true)
                    } else {
                        onError(PaymentsError.PAYMENT_GENERAL_ERROR) // use general error for now, as this is a PoC
                    }
                }
            }
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

    private fun formatErrorCode(code: Int): String {
        return ERROR_FORMAT_PREFIX + code.toString().padStart(4, '0')
    }

    private fun buildPaymentConfigurationInfo(activity: Activity) : PaymentConfigurationInfo{

        val shippingContacts = activity.getString(getStringResourceId(activity, SHIPPING_SUPPORTED_CONTACTS)).split(",")
        val shippingCountries = activity.getString(getStringResourceId(activity, SHIPPING_COUNTRY_CODES)).split(",")
        val billingContacts = activity.getString(getStringResourceId(activity, BILLING_SUPPORTED_CONTACTS)).split(",")

        return PaymentConfigurationInfo(
            activity.getString(getStringResourceId(activity, MERCHANT_NAME)),
            activity.getString(getStringResourceId(activity, MERCHANT_COUNTRY_CODE)),
            activity.getString(getStringResourceId(activity, PAYMENT_ALLOWED_NETWORKS)).split(","),
            activity.getString(getStringResourceId(activity, PAYMENT_SUPPORTED_CAPABILITIES)).split(","),
            activity.getString(getStringResourceId(activity, PAYMENT_SUPPORTED_CARD_COUNTRIES)).split(","),
            if(shippingContacts.isNotEmpty() && shippingContacts[0].isNotEmpty()) shippingContacts else listOf(),
            if(shippingCountries.isNotEmpty() && shippingCountries[0].isNotEmpty()) shippingCountries else listOf(),
            if(billingContacts.isNotEmpty() && billingContacts[0].isNotEmpty()) billingContacts else listOf(),
            activity.getString(getStringResourceId(activity, TOKENIZATION))
        )
    }

    private fun buildPaymentDetails(args: JSONArray) : PaymentDetails? {
        return try {
            gson.fromJson(args.getString(0), PaymentDetails::class.java)
        } catch (e: Exception){
            null
        }
    }

    private fun getStringResourceId(activity: Activity, typeAndName: String): Int {
        return activity.resources.getIdentifier(typeAndName, "string", activity.packageName)
    }
}
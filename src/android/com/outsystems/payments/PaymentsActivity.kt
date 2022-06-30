package com.outsystems.payments

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.provider.Settings.Global.getString
import android.util.Log
import android.widget.Toast
import androidx.activity.result.ActivityResult
import androidx.activity.result.IntentSenderRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.tasks.Task
import com.google.android.gms.wallet.PaymentData
import com.outsystemsenterprise.enmobile11dev.PaymentsSampleApp.R
import org.json.JSONException
import org.json.JSONObject

class PaymentsActivity() : AppCompatActivity() {

    private val model : PaymentsViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestPayment()
    }

    private fun requestPayment(){
        // The price provided to the API should include taxes and shipping.
        // This price is not displayed to the user.
        val dummyPriceCents = 50L
        val shippingCostCents = 400L
        val task = model.getLoadPaymentDataTask(dummyPriceCents + shippingCostCents)

        task.addOnCompleteListener { completedTask : Task<PaymentData> ->
            if (completedTask.isSuccessful) {
                completedTask.result.let(::handlePaymentSuccess)
            } else {
                when (val exception = completedTask.exception) {
                    is ResolvableApiException -> {
                        resolvePaymentForResult.launch(
                            IntentSenderRequest.Builder(exception.resolution).build()
                        )
                    }
                    is ApiException -> {
                        handleError(exception.statusCode, exception.message)
                    }
                    else -> {
                        handleError(
                            CommonStatusCodes.INTERNAL_ERROR, "Unexpected non API" +
                                    " exception when trying to deliver the task result to an activity!"
                        )
                    }
                }
            }
        }
    }

    private fun handleError(statusCode: Int, message: String?) {
        // to implement
    }

    private fun handlePaymentSuccess(paymentData: PaymentData) {
        val paymentInformation = paymentData.toJson()

        try {
            // Token will be null if PaymentDataRequest was not constructed using fromJson(String).
            val paymentMethodData = JSONObject(paymentInformation).getJSONObject("paymentMethodData")
            val billingName = paymentMethodData.getJSONObject("info")
                .getJSONObject("billingAddress").getString("name")
            Log.d("BillingName", billingName)

            //Toast.makeText(this, getString(R.string.payments_show_name, billingName), Toast.LENGTH_LONG).show()

            val token = paymentMethodData
                .getJSONObject("tokenizationData")
                .getString("token")

            // Logging token string.
            Log.d("Google Pay token", paymentMethodData
                .getJSONObject("tokenizationData")
                .getString("token"))


            val resultBundle = Bundle()
            resultBundle.putString("token", token)

            val resultIntent = Intent()
            resultIntent.putExtras(resultBundle)

            setResult(9, resultIntent)
            finish()

        } catch (error: JSONException) {
            Log.e("handlePaymentSuccess", "Error: $error")
        }
    }

    // Handle potential conflict from calling loadPaymentData
    private val resolvePaymentForResult = registerForActivityResult(ActivityResultContracts.StartIntentSenderForResult()) {
            result: ActivityResult ->
        when (result.resultCode) {
            AppCompatActivity.RESULT_OK ->
                result.data?.let { intent ->
                    PaymentData.getFromIntent(intent)?.let(::handlePaymentSuccess)
                }

            AppCompatActivity.RESULT_CANCELED -> {
                // The user cancelled the payment attempt
                val s = ""
            }
        }
    }


}
package com.outsystems.payments

import android.app.Activity
import android.app.Application
import android.content.Context
import com.google.android.gms.wallet.PaymentsClient
import com.google.android.gms.wallet.Wallet
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.math.BigDecimal
import java.math.RoundingMode

object PaymentsUtil {

    val CENTS = BigDecimal(100)

    private val baseRequest = JSONObject().apply {
        put("apiVersion", 2)
        put("apiVersionMinor", 0)
    }

    private val allowedCardNetworks = JSONArray(Constants.SUPPORTED_NETWORKS)

    private val allowedCardAuthMethods = JSONArray(Constants.SUPPORTED_METHODS)

    private val merchantInfo: JSONObject =
        JSONObject().put("merchantName", "Example Merchant")

    fun createPaymentsClient(context: Context): PaymentsClient {
        val walletOptions = Wallet.WalletOptions.Builder()
            .setEnvironment(Constants.PAYMENTS_ENVIRONMENT)
            .build()

        return Wallet.getPaymentsClient(context, walletOptions)
    }

    fun  getPaymentDataRequest(priceCemts: Long): JSONObject {
        return baseRequest.apply {
            put("allowedPaymentMethods", JSONArray().put(cardPaymentMethod()))
            put("transactionInfo", getTransactionInfo(priceCemts.centsToString()))
            put("merchantInfo", merchantInfo)

            // An optional shipping address requirement is a top-level property of the
            // PaymentDataRequest JSON object.
            val shippingAddressParameters = JSONObject().apply {
                put("phoneNumberRequired", false)
                put("allowedCountryCodes", JSONArray(listOf("US", "GB")))
            }
            put("shippingAddressParameters", shippingAddressParameters)
            put("shippingAddressRequired", true)
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

    private fun gatewayTokenizationSpecification(): JSONObject {
        return JSONObject().apply {
            put("type", "PAYMENT_GATEWAY")
            put("parameters", JSONObject(Constants.PAYMENT_GATEWAY_TOKENIZATION_PARAMETERS))
        }
    }

    @Throws(JSONException::class)
    private fun getTransactionInfo(price: String): JSONObject {
        return JSONObject().apply {
            put("totalPrice", price)
            put("totalPriceStatus", "FINAL")
            put("countryCode", Constants.COUNTRY_CODE)
            put("currencyCode", Constants.CURRENCY_CODE)
        }
    }

    fun Long.centsToString() = BigDecimal(this)
        .divide(PaymentsUtil.CENTS)
        .setScale(2, RoundingMode.HALF_EVEN)
        .toString()

}
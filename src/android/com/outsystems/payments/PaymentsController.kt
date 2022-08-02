package com.outsystems.payments

import android.app.Activity
import com.google.gson.Gson

class PaymentsController() {

    fun setupConfiguration(activity: Activity) : String {

        //get data from resources
        val merchantName = activity.getString(getStringResourceId(activity, "merchant_name"))
        val merchantCountryCode = activity.getString(getStringResourceId(activity, "merchant_country_code"))
        val paymentAllowedNetworks = activity.getString(getStringResourceId(activity, "payment_allowed_networks")).split(",")
        val paymentSupportedCapabilities = activity.getString(getStringResourceId(activity, "payment_supported_capabilities")).split(",")
        val paymentSupportedCardCountries = activity.getString(getStringResourceId(activity, "payment_supported_card_countries")).split(",")
        val shippingSupportedContacts = activity.getString(getStringResourceId(activity, "shipping_supported_contacts")).split(",")
        val billingSupportedContacts = activity.getString(getStringResourceId(activity, "billing_supported_contacts")).split(",")
        val tokenization = activity.getString(getStringResourceId(activity, "tokenization"))

        //create PaymentConfigurationInfo object to return be returned as JSON
        val paymentConfigurationInfo = PaymentConfigurationInfo(
            merchantName,
            merchantCountryCode,
            paymentAllowedNetworks,
            paymentSupportedCapabilities,
            paymentSupportedCardCountries,
            shippingSupportedContacts,
            billingSupportedContacts,
            tokenization
        )

        return Gson().toJson(paymentConfigurationInfo)
    }

    private fun getStringResourceId(activity: Activity, typeAndName: String): Int {
        return activity.resources.getIdentifier(typeAndName, "string", activity.packageName)
    }
}
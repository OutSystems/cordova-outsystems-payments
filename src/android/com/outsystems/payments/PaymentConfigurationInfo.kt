package com.outsystems.payments

data class PaymentConfigurationInfo(val merchantName: String,
                                    val merchantCountryCode: String,
                                    val paymentAllowedNetworks: List<String>,
                                    val paymentSupportedCapabilities: List<String>,
                                    val payment_supported_card_countries: List<String>,
                                    val shipping_supported_contacts: List<String>,
                                    val billing_supported_contacts: List<String>,
                                    val tokenization: String)

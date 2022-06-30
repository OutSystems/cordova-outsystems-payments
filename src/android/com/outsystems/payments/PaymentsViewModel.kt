package com.outsystems.payments

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import com.google.android.gms.tasks.Task
import com.google.android.gms.wallet.PaymentData
import com.google.android.gms.wallet.PaymentDataRequest
import com.google.android.gms.wallet.PaymentsClient

class PaymentsViewModel(application: Application) : AndroidViewModel(application) {

    private val paymentsClient: PaymentsClient = PaymentsUtil.createPaymentsClient(application)

    fun getLoadPaymentDataTask(priceCents: Long): Task<PaymentData> {
        val paymentDataRequestJson = PaymentsUtil.getPaymentDataRequest(priceCents)
        val request = PaymentDataRequest.fromJson(paymentDataRequestJson.toString())
        return paymentsClient.loadPaymentData(request)
    }

}
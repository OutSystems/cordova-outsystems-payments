package com.outsystems.payments

import android.app.Activity
import android.content.Intent

class PaymentsController(activity: Activity) {

    fun requestPayment(activity: Activity){
        val intent = Intent(activity, PaymentsActivity::class.java)
        activity.startActivityForResult(intent, 111)
    }

}
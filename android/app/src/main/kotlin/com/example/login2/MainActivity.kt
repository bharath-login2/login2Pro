package com.login2Pro

import android.content.Context
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.login2Pro/sim_info"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getActiveSims") {
                try {
                    val simList = getActiveSimList()
                    result.success(simList)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", e.localizedMessage, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getActiveSimList(): List<Map<String, Any?>> {
        val list = mutableListOf<Map<String, Any?>>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
            val activeSubscriptionInfoList: List<SubscriptionInfo>? = try {
                subscriptionManager?.activeSubscriptionInfoList
            } catch (e: SecurityException) {
                Log.e("NATIVE_SIM", "SecurityException reading activeSubscriptionInfoList", e)
                null
            }

            Log.d("NATIVE_SIM", "Active Subscription List Count: ${activeSubscriptionInfoList?.size ?: 0}")

            activeSubscriptionInfoList?.forEach { info ->
                val subId = info.subscriptionId
                val slotIdx = info.simSlotIndex
                val dispName = info.displayName?.toString() ?: ""
                val carrier = info.carrierName?.toString() ?: ""
                val num = try { info.number?.toString() ?: "" } catch (e: Exception) { "" }

                Log.d("NATIVE_SIM", "NATIVE SIM:\nsubscriptionId=$subId\nsimSlotIndex=$slotIdx\ndisplayName=$dispName\ncarrierName=$carrier\nnumber=$num")
                println("NATIVE SIM:")
                println("subscriptionId=$subId")
                println("simSlotIndex=$slotIdx")
                println("displayName=$dispName")
                println("carrierName=$carrier")
                println("number=$num")

                val simMap = HashMap<String, Any?>()
                simMap["subscriptionId"] = subId
                simMap["simSlotIndex"] = slotIdx // 0 for SIM 1, 1 for SIM 2
                simMap["displayName"] = dispName
                simMap["carrierName"] = carrier
                simMap["number"] = num
                list.add(simMap)
            }
        }
        return list
    }
}



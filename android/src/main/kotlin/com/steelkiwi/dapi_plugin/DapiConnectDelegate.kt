package com.steelkiwi.dapi_plugin

import android.app.Activity
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.dapi.connect.core.base.DapiClient
import com.dapi.connect.core.callbacks.OnDapiConnectListener
import com.dapi.connect.data.endpoint_models.AccountMetaData
import com.dapi.connect.data.endpoint_models.GetAccounts
import com.dapi.connect.data.models.DapiBeneficiaryInfo
import com.dapi.connect.data.models.DapiConnection
import com.dapi.connect.data.models.DapiError
import com.dapi.connect.data.models.LinesAddress
import com.google.gson.Gson
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class DapiConnectDelegate(private var activity: Activity, val dapiClient: DapiClient)
    : PluginRegistry.ActivityResultListener {
    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())

    private var pendingResult: MethodChannel.Result? = null

    init {
        dapiClient.connect.setOnConnectListener(object : OnDapiConnectListener {
            override fun onConnectionSuccessful(userID: String, bankID: String) = finishWithSuccess(userID)

            override fun onConnectionFailure(error: DapiError, bankID: String) {
            }

            override fun onProceed(userID: String, bankID: String) {
            }

            override fun setBeneficiaryInfoOnConnect(bankID: String): DapiBeneficiaryInfo? {
                val lineAddress = LinesAddress()
                lineAddress.line1 = "line1"
                lineAddress.line2 = "line2"
                lineAddress.line3 = "line3"
                val info = DapiBeneficiaryInfo(
                        linesAddress = lineAddress,
                        accountNumber = "xxxxxxxxx",
                        name = "xxxxx",
                        bankName = "xxxx",
                        swiftCode = "xxxxx",
                        iban = "xxxxxxxxxxxxxxxxxxxxxxxxx",
                        country = "UNITED ARAB EMIRATES",
                        branchAddress = "branchAddress",
                        branchName = "branchName",
                        phoneNumber = "xxxxxxxxxxx"
                )
                return info
            }
        })

    }

    fun openDapiConnect(call: MethodCall, result: MethodChannel.Result?) {
        pendingResult = result
        dapiClient.connect.present()
    }

    fun getActiveConnection(call: MethodCall, result: MethodChannel.Result?) {
        pendingResult = result
        dapiClient.connect.getConnections(onSuccess = { finishActiveConnectionWithSuccess(it); },
                onFailure = {

                })
    }

    fun getCurrentAccount(call: MethodCall, result: MethodChannel.Result?) {
        val sourcePath = call.argument<String>(Consts.PARAMET_USER_ID);
        pendingResult = result
        sourcePath?.let { dapiClient.setUserID(it) };
        dapiClient.data.getAccounts({ finishCurrentAccountWithSuccess(it); }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            finishWithError(error.type.toString(), errorMessage)
        }
    }

    fun getCurrentMetaDataAccount(call: MethodCall, result: MethodChannel.Result?) {
        val sourcePath = call.argument<String>(Consts.PARAMET_USER_ID);
        pendingResult = result
        sourcePath?.let { dapiClient.setUserID(it) };
        dapiClient.metadata.getAccountMetaData(
                { accountMetaData ->
                    finishCurrentAccountMetaDataWithSuccess(accountMetaData)
                }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;

            finishWithError(error.type.toString(), errorMessage)
        }


//        getAccounts({ finishCurrentAccountWithSuccess(it); }
//        ) { error ->
//            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
//            finishCurrentAccountWithWithError(errorCode = error.type.toString(), errorMessage = errorMessage, throwable = Throwable(message = errorMessage));
//        }
    }


    private fun finishCurrentAccountMetaDataWithSuccess(metaData: AccountMetaData) {
        val json = Gson().toJson(metaData)
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(json)
                clearMethodCallAndResult()
            };
        }
    }

    private fun finishWithError(errorCode: String, errorMessage: String) {
        if (pendingResult != null) {
            pendingResult!!.error(errorCode, errorMessage, null);
        }
    }

    private fun finishCurrentAccountWithSuccess(connections: GetAccounts) {
        val json = Gson().toJson(connections)
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(json)
                clearMethodCallAndResult()
            };
        }
    }


    private fun finishActiveConnectionWithSuccess(connections: List<DapiConnection>) {
        val json = Gson().toJson(connections)
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(json)
                clearMethodCallAndResult()
            };
        }
    }

    private fun finishWithSuccess(imagePath: String) {
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(imagePath)
                clearMethodCallAndResult()
            };
        }
    }

    private fun finishWithError(errorCode: String, errorMessage: String, throwable: Throwable) {
        if (pendingResult != null) {
            pendingResult!!.error(errorCode, errorMessage, throwable)
            clearMethodCallAndResult()
        }
    }


    private fun clearMethodCallAndResult() {
        pendingResult = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return true;
    }

}
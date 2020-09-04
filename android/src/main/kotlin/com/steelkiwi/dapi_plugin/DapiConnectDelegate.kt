package com.steelkiwi.dapi_plugin

import android.app.Activity
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.dapi.connect.core.base.DapiClient
import com.dapi.connect.core.callbacks.OnDapiConnectListener
import com.dapi.connect.data.endpoint_models.*
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
                val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
                finishWithError(error.type.toString(), errorMessage)
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
        dapiClient.connect.getConnections(onSuccess = {
            finishActiveConnectionWithSuccess(it);
        },
                onFailure = {
                    val errorMessage: String = if (it?.msg == null) "Get accounts error" else it?.msg!!;
                    finishWithError(it?.type.toString(), errorMessage)
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
    }

    fun getBeneficiaries(call: MethodCall, result: MethodChannel.Result?) {
        val sourcePath = call.argument<String>(Consts.PARAMET_USER_ID);
        pendingResult = result
        sourcePath?.let { dapiClient.setUserID(it) };
        dapiClient.payment.getBeneficiaries(
                { benefs ->
                    finishBeneficiariesWithSuccess(benefs);
                }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            finishWithError(error.type.toString(), errorMessage)
        }
    }

    fun createTransfer(call: MethodCall, result: MethodChannel.Result?) {
        val beneficiaryId = call.argument<String>(Consts.PARAMET_BENEFICIARY_ID);
        val accountId = call.argument<String>(Consts.PARAMET_ACCOUNT_ID);
        val userId = call.argument<String>(Consts.PARAMET_USER_ID);
        val amount = call.argument<Double>(Consts.PARAMET_AMOUNT);
        val remark = call.argument<String>(Consts.PARAMET_REMARK);
        pendingResult = result
        userId?.let { dapiClient.setUserID(it) };
        if (beneficiaryId == null || accountId == null) {
            finishWithError("Param is null", "Param is null")

        } else {
            dapiClient.payment.createTransfer(beneficiaryId!!, accountId!!, amount!!, remark,
                    { createTransfer ->
                        finishCreateTransferWithSuccess(createTransfer);
                    }
            ) { error ->
                val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
                finishWithError(error.type.toString(), errorMessage)
            }
        }

    }

    fun logout(call: MethodCall, result: MethodChannel.Result?) {
        pendingResult = result
        dapiClient.release();
        print("ds");
    }

    fun delink(call: MethodCall, result: MethodChannel.Result?) {
        val sourcePath = call.argument<String>(Consts.PARAMET_USER_ID);
        sourcePath?.let { dapiClient.setUserID(it) };
        pendingResult = result
        dapiClient.auth.delink(
                { delink ->
                    finishDelinkWithSuccess(delink);
                    print("sds");
                }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            finishWithError(error.type.toString(), errorMessage)
        }

    }

    fun createBeneficiary(call: MethodCall, result: MethodChannel.Result?) {
        val sourcePath = call.argument<String>(Consts.PARAMET_USER_ID);
        val addressLine1 = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_LINE_ADDRES1);
        val addressLine2 = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_LINE_ADDRES2);
        val addressLine3 = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_LINE_ADDRES3);
        val accountNumber = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_ACCOUNT_NUMBER);
        val accountName = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_NAME);
        val bankName = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_BANK_NAME);
        val swiftCode = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_SWIFT_CODE);
        val iban = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_IBAN);
        val country = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_COUNTRY);
        val branchAddress = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_BRANCH_ADDRESS);
        val branchName = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_BRANCH_NAME);
        val phone = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_PHONE_NUMBER);

        sourcePath?.let { dapiClient.setUserID(it) };

        pendingResult = result
        dapiClient.payment


        val lineAddress = LinesAddress()
        lineAddress.line1 = addressLine1
        lineAddress.line2 = addressLine2
        lineAddress.line3 = addressLine3
        val info = DapiBeneficiaryInfo(
                linesAddress = lineAddress,
                accountNumber = accountNumber,
                name = accountName,
                bankName = bankName,
                swiftCode = swiftCode,
                iban = iban,
                country = country,
                branchAddress = branchAddress,
                branchName = branchName,
                phoneNumber = phone
        )

        dapiClient.payment.createBeneficiary(info, onSuccess = {
            finishCreateBeneficiariesWithSuccess(it)
            print("")
        }, onFailure = {
            val errorMessage: String = if (it.msg == null) "Get accounts error" else it.msg!!;
            finishWithError(it.type.toString(), errorMessage)
        })

    }


    private fun finishDelinkWithSuccess(beneficiaries: DelinkUser) {
        val json = Gson().toJson(beneficiaries)
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(json)
                clearMethodCallAndResult()
            };
        }
    }


    private fun finishCreateTransferWithSuccess(beneficiaries: CreateTransfer) {
        val json = Gson().toJson(beneficiaries)
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(json)
                clearMethodCallAndResult()
            };
        }
    }


    private fun finishCreateBeneficiariesWithSuccess(beneficiaries: CreateBeneficiary) {
        val json = Gson().toJson(beneficiaries)
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(json)
                clearMethodCallAndResult()
            };
        }
    }

    private fun finishBeneficiariesWithSuccess(beneficiaries: GetBeneficiaries) {
        val json = Gson().toJson(beneficiaries)
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(json)
                clearMethodCallAndResult()
            };
        }
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
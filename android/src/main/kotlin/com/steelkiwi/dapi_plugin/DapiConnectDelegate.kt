package com.steelkiwi.dapi_plugin

import android.app.Activity
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.dapi.connect.core.base.DapiClient
import com.dapi.connect.core.callbacks.OnDapiConnectListener
import com.dapi.connect.core.enums.DapiEnvironment
import com.dapi.connect.data.models.DapiBeneficiaryInfo
import com.dapi.connect.data.models.DapiConfigurations
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
            override fun onConnectionSuccessful(userID: String, bankID: String) = successFinish(userID)
            override fun onConnectionFailure(error: DapiError, bankID: String) {
                val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
                finishWithError(error.type.toString(), errorMessage)
            }

            override fun onProceed(userID: String, bankID: String) {
                print("Test")
            }

            override fun setBeneficiaryInfoOnConnect(bankID: String): DapiBeneficiaryInfo? {
                return null;
            }
        })

    }

    fun openDapiConnect(call: MethodCall, result: MethodChannel.Result?) {
        pendingResult = result
        dapiClient.connect.present()
    }


    fun initDapiEnvironment(call: MethodCall, result: MethodChannel.Result?) {
        val env = call.argument<String>(Consts.PARAMET_ENVIRONMENT);
        //todo change this logic
        if (env == Consts.PARAMET_ENVIRONMENT_SANDBOX) {
            dapiClient.setConfigurations(getDapiConfigurations(environment = DapiEnvironment.SANDBOX, host = "https://api-lune.dev.steel.kiwi:4041"));
        } else {
            dapiClient.setConfigurations(getDapiConfigurations(environment = DapiEnvironment.PRODUCTION, host = "https://api-lune.stg.steel.kiwi:4041"));


        }

    }

    fun getActiveConnection(call: MethodCall, result: MethodChannel.Result?) {
        pendingResult = result
        dapiClient.connect.getConnections(onSuccess = {
            successFinish(it)
        },
                onFailure = {
                    val errorMessage: String = if (it?.msg == null) "Get accounts error" else it?.msg!!;
                    finishWithError(it?.type.toString(), errorMessage)
                })
    }

    fun getConnectionAccounts(call: MethodCall, result: MethodChannel.Result?) {
        val userId = call.argument<String>(Consts.PARAMET_USER_ID);
        pendingResult = result
        userId?.let { dapiClient.userID = it };
        dapiClient.data.getAccounts({ successFinish(it.accounts); }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            finishWithError(error.type.toString(), errorMessage)
        }
    }

    fun getDapiBankMetadata(call: MethodCall, result: MethodChannel.Result?) {
        val userId = call.argument<String>(Consts.PARAMET_USER_ID);
        pendingResult = result
        userId?.let { dapiClient.userID = it };
        dapiClient.metadata.getAccountMetaData(
                { accountMetaData ->
                    successFinish(accountMetaData.accountsMetadata);
                }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            finishWithError(error.type.toString(), errorMessage)
        }
    }

    fun getBeneficiaries(call: MethodCall, result: MethodChannel.Result?) {
        val userId = call.argument<String>(Consts.PARAMET_USER_ID);
        pendingResult = result
        userId?.let { dapiClient.userID = it };
        dapiClient.payment.getBeneficiaries(
                { beneficiaries ->
                    successFinish(beneficiaries.beneficiaries);
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
        val paymentID: String? = (call.argument<String>(Consts.HEADER_VALUE_PAYMENT_ID))
        pendingResult = result
        userId?.let { dapiClient.userID = (it) };
        paymentID?.let {
            val config = getDapiConfigurations(paymentId = it, host = dapiClient.getConfigurations().baseUrl, environment = dapiClient.getConfigurations().environment)
            dapiClient.setConfigurations(config)

        }
        print("Create transfer env: " + dapiClient.getConfigurations().environment.name())
        if (beneficiaryId == null || accountId == null) {
            finishWithError("Param is null", "Param is null")
        } else {
            dapiClient.payment.createTransfer(beneficiaryId, accountId, amount!!, remark,
                    { createTransfer ->
                        successFinish(createTransfer);
                    }
            ) { error ->
                val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
                finishWithError(error.type.toString(), errorMessage)
            }
        }

    }


    fun delink(call: MethodCall, result: MethodChannel.Result?) {
        val userId = call.argument<String>(Consts.PARAMET_USER_ID);
        userId?.let { dapiClient.userID = (it) };
        pendingResult = result
        dapiClient.auth.delink(
                { delink ->
                    successFinish(delink);
                }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            finishWithError(error.type.toString(), errorMessage)
        }

    }

    fun getHistoryTransfers(call: MethodCall, result: MethodChannel.Result?) {

    }

    fun createBeneficiary(call: MethodCall, result: MethodChannel.Result?) {
        val userId = call.argument<String>(Consts.PARAMET_USER_ID);
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

        userId?.let { dapiClient.userID = (it) };

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
            successFinish(it)
        }, onFailure = {
            val errorMessage: String = if (it.msg == null) "Get accounts error" else it.msg!!;
            finishWithError(it.type.toString(), errorMessage)
        })

    }


    private fun <T> successFinish(data: T) {
        var resultData: String = if (data is String) {
            data;
        } else {
            Gson().toJson(data)
        }
        if (pendingResult != null) {
            uiThreadHandler.post {
                pendingResult!!.success(resultData)
                clearMethodCallAndResult()
            };
        }
    }

    private fun finishWithError(errorCode: String, errorMessage: String) {
        if (pendingResult != null) {
            pendingResult!!.error(errorCode, errorMessage, null);
        }
    }

    private fun clearMethodCallAndResult() {
        pendingResult = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return true;
    }

    private fun getDapiConfigurations(paymentId: String? = null, host: String?, environment: DapiEnvironment = DapiEnvironment.PRODUCTION): DapiConfigurations {
        val previousConfigs = dapiClient.getConfigurations();
        var externalHeader: HashMap<String, String> = hashMapOf<String, String>();
        if (paymentId != null)
            externalHeader[Consts.HEADER_KEY_PAYMENT_ID] = paymentId;


        var config = DapiConfigurations(
                previousConfigs.appKey,
                host ?: previousConfigs.baseUrl,
                environment,
                previousConfigs.supportedCountriesCodes,
                previousConfigs.userID,
                previousConfigs.clientUserID,
                extraHeaders = externalHeader
        );

        return config;
    }
}
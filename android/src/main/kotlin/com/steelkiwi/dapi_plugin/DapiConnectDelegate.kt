package com.steelkiwi.dapi_plugin

import android.app.Activity
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.dapi.connect.core.base.DapiClient
import com.dapi.connect.core.callbacks.OnDapiConnectListener
import com.dapi.connect.core.enums.DapiEnvironment
import com.dapi.connect.data.endpoint_models.CreateTransfer
import com.dapi.connect.data.models.DapiBeneficiaryInfo
import com.dapi.connect.data.models.DapiConfigurations
import com.dapi.connect.data.models.DapiError
import com.dapi.connect.data.models.LinesAddress
import com.google.gson.Gson
import com.steelkiwi.dapi_plugin.model.AuthState
import com.steelkiwi.dapi_plugin.model.AuthStatus
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class DapiConnectDelegate(private var activity: Activity, var dapiClient: DapiClient? = null)
    : PluginRegistry.ActivityResultListener {
    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())
    fun action(call: MethodCall, result: MethodChannel.Result, action: DapiActions) {
        if (dapiClient != null) {
            when (action) {
                DapiActions.GET_ACTIVE_CONNECTION -> getActiveConnection(call = call, result = result, dapiClient!!)
                DapiActions.CREATE_TRANSACTION -> createTransfer(call = call, result = result, dapiClient!!)
                DapiActions.GET_BANK_METADATA -> getDapiBankMetadata(call = call, result = result, dapiClient!!);
                DapiActions.CREATE_BENEFICIARY -> createBeneficiary(call = call, result = result, dapiClient!!);
                DapiActions.GET_SUB_ACCOUNTS -> getSubAccounts(call = call, result = result, dapiClient!!)
                DapiActions.GET_BENEFICIARIES -> getBeneficiaries(call = call, result = result, dapiClient!!)
                DapiActions.DELINK -> delink(call = call, result = result, dapiClient!!)
            }
        } else {
            result.error("-1", "Dapi client hasn't inited", null);

        }
    }

    fun action(events: EventChannel.EventSink? = null, action: DapiActions) {
        if (dapiClient != null) {
            when (action) {
                DapiActions.LOGIN -> present(events, dapiClient!!)
                DapiActions.CLEAR_LOGIN_LISTENER -> dapiClient?.connect?.dismiss();

            }
        } else {
            events?.error("-1", "Dapi client hasn't inited", null);
        }
    }


    fun initDpiClient(call: MethodCall, result: MethodChannel.Result) {
        val appKey = call.argument<String>(Consts.PARAM_APP_KEY);
        val host = call.argument<String>(Consts.PARAM_HOST);
        val port = call.argument<Int>(Consts.PARAM_PORT);
        val env = call.argument<String>(Consts.PARAMET_ENVIRONMENT);
        if (appKey == null) {
            result.error("-1", "App key can't be null", null);
            return;
        }
        if (host == null) {
            result.error("-1", "Host  can't be null", null);
            return
        }
        if (port == null) {
            result.error("-1", "Port  can't be null", null);
            return;
        }
        if (env == null) {
            result.error("-1", "Env  can't be null", null);
            return
        }
        if (!(env.contains(Consts.ENVIRONMENT_SANDBOX) || env.contains(Consts.ENVIRONMENT_PRODUCTION))) {
            result.error("-1", "$env environment is not correct", null);
            return
        }


        val environment: DapiEnvironment = if (env == Consts.ENVIRONMENT_SANDBOX)
            DapiEnvironment.SANDBOX;
        else
            DapiEnvironment.PRODUCTION;

        val fullHost = "$host:$port";

        dapiClient = DapiClient(activity.application, getDapiConfiguration(appKey = appKey!!, host = fullHost, env = environment!!))

    }


    private fun getDapiConfiguration(env: DapiEnvironment, host: String, appKey: String, headers: HashMap<String, String>? = null): DapiConfigurations {
        var externalHeader: HashMap<String, String> = headers ?: hashMapOf();
        val dapiConfigurations = DapiConfigurations(
                appKey = appKey,
                baseUrl = host,
                environment = env,
                extraHeaders = externalHeader,
                supportedCountriesCodes = listOf("AE"),
                userID = "",
                clientUserID = ""
        );
        return dapiConfigurations;
    }

    private fun updateHeaderForDapiClient(headers: HashMap<String, String>? = null) {
        dapiClient?.let {
            var dapiCongig = it.getConfigurations();
            val config = getDapiConfiguration(
                    host = dapiCongig.baseUrl,
                    env = dapiCongig.environment,
                    appKey = dapiCongig.appKey,
                    headers = headers ?: hashMapOf())
            it.setConfigurations(config)
        }
    }


    private fun present(events: EventChannel.EventSink?, dapiClient: DapiClient) {
        dapiClient.connect.present()
        dapiClient.connect.setOnConnectListener(object : OnDapiConnectListener {
            override fun onConnectionSuccessful(userID: String, bankID: String) {
                uiThreadHandler.post {
                    val result = Gson().toJson(AuthState(accessId = userID, status = AuthStatus.SUCCESS));
                    events?.success(result)
                    events?.endOfStream();
                }

            }

            override fun onConnectionFailure(error: DapiError, bankID: String) {
                uiThreadHandler.post {
                    val errorMessage: String = if (error.msg == null) "Failure auth" else error.msg!!;
                    events?.error(error.type ?: bankID, errorMessage, null);

                }

            }

            override fun onProceed(userID: String, bankID: String) {
                uiThreadHandler.post {
                    val result = Gson().toJson(AuthState(accessId = userID, status = AuthStatus.PROCEED));
                    events?.success(result)
                }
            }

            override fun setBeneficiaryInfoOnConnect(bankID: String): DapiBeneficiaryInfo? {
                return null;
            }
        })
    }

    private fun getActiveConnection(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        dapiClient.connect.getConnections(onSuccess = {
            successFinish(it, result)
        },
                onFailure = {
                    val errorMessage: String = if (it?.msg == null) "Get accounts error" else it?.msg!!;
                    result.error(it?.type ?: "", errorMessage, null);
                })
    }

    private fun getSubAccounts(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val userId = call.argument<String>(Consts.PARAMET_DAPI_ACCESS_ID);
        userId?.let { dapiClient.userID = it };
        dapiClient.data.getAccounts({
            successFinish(it.accounts, result);
        }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            result.error(error.type ?: "", errorMessage, null);
        }
    }

    private fun getDapiBankMetadata(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val userId = call.argument<String>(Consts.PARAMET_DAPI_ACCESS_ID);
        userId?.let { dapiClient.userID = it };
        dapiClient.metadata.getAccountMetaData(
                { accountMetaData ->
                    successFinish(accountMetaData.accountsMetadata, result);
                }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            result.error(error?.type ?: "", errorMessage, null);
        }
    }

    private fun getBeneficiaries(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val userId = call.argument<String>(Consts.PARAMET_DAPI_ACCESS_ID);
        userId?.let { dapiClient.userID = it };
        dapiClient.payment.getBeneficiaries(
                { beneficiaries ->
                    successFinish(beneficiaries.beneficiaries, result);
                }
        ) { error ->
            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
            result.error(error?.type ?: "", errorMessage, null);
        }
    }


    private fun createTransfer(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val beneficiaryId = call.argument<String>(Consts.PARAMET_BENEFICIARY_ID);
        val accountId = call.argument<String>(Consts.PARAMET_ACCOUNT_ID);
        val userId = call.argument<String>(Consts.PARAMET_DAPI_ACCESS_ID);
        val amount = call.argument<Double>(Consts.PARAMET_AMOUNT);
        val remark = call.argument<String>(Consts.PARAMET_REMARK);
        val paymentID: String? = (call.argument<String>(Consts.HEADER_VALUE_PAYMENT_ID))

        val iban: String? = (call.argument<String>(Consts.PARAMET_IBAN))
        val name: String? = (call.argument<String>(Consts.PARAMET_NAME))
        val accountNumber: String? = (call.argument<String>(Consts.PARAMET_ACCOUNT_NUMBER))


        val successCallback = { value: CreateTransfer ->
            successFinish(value, result);
            updateHeaderForDapiClient()
        };

        val errorCallback = { err: DapiError ->
            updateHeaderForDapiClient()
            result.error(err.type ?: "", err.msg ?: "Error", null);
        };


        userId?.let { dapiClient.userID = (it) };
        paymentID?.let {
            updateHeaderForDapiClient(hashMapOf<String, String>(Consts.HEADER_KEY_PAYMENT_ID to paymentID))
        }

        if (accountId != null && amount != null && beneficiaryId != null && iban == null && name == null) {
            dapiClient.payment.createTransfer(
                    beneficiaryId, accountId, amount, remark, successCallback, errorCallback)
        } else {
            dapiClient.payment.createTransfer(iban!!, name!!, beneficiaryId!!, amount!!, remark, successCallback, errorCallback)

        }


    }


    private fun delink(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val dapiAccessId = call.argument<String>(Consts.PARAMET_DAPI_ACCESS_ID);
        val userId = call.argument<String>(Consts.PARAMET_LUN_PAYMENT_ID);
        dapiAccessId?.let {
            dapiClient.userID = (it)
        };
        userId?.let {
            updateHeaderForDapiClient(hashMapOf<String, String>(Consts.HEADER_KEY_PAYMENT_LUN to it))
        }

        dapiClient.auth.delink({
            successFinish(it, result);
            updateHeaderForDapiClient()

        }
        ) { error ->
            updateHeaderForDapiClient()

            val errorMessage: String = if (error.msg == null) "Delink error" else error.msg!!;
            result.error(error?.type ?: "", errorMessage, null);
        }

    }

    private fun createBeneficiary(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val userId = call.argument<String>(Consts.PARAMET_DAPI_ACCESS_ID);
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

        dapiClient.payment.createBeneficiary(info, {
            successFinish(it, result)
        }, {
            val errorMessage: String = if (it.msg == null) "Get accounts error" else it.msg!!;
            result.error(it?.type ?: "", errorMessage, null);
        })

    }


    private fun <T> successFinish(data: T, pendingResult: MethodChannel.Result) {
        var resultData: String = if (data is String) {
            data;
        } else {
            Gson().toJson(data)
        }
        uiThreadHandler.post {
            pendingResult!!.success(resultData)

        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return true; }
}





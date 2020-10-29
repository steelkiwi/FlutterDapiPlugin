package com.steelkiwi.dapi_plugin

import android.app.Activity
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
import com.steelkiwi.dapi_plugin.configs.ConstHeader
import com.steelkiwi.dapi_plugin.configs.ConstMessage
import com.steelkiwi.dapi_plugin.configs.ConstParameters
import com.steelkiwi.dapi_plugin.model.AuthState
import com.steelkiwi.dapi_plugin.model.AuthStatus
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class DapiConnectDelegate(private var activity: Activity, var client: DapiClient? = null)
    : FlutterEngine.EngineLifecycleListener {
    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())
    fun action(call: MethodCall, result: MethodChannel.Result, action: DapiActions) {
        if (client != null) {
            when (action) {
                DapiActions.GET_ACTIVE_CONNECTION -> getActiveConnection(call = call, result = result, dapiClient = client!!)
                DapiActions.GET_BANK_METADATA -> getDapiBankMetadata(call = call, result = result, dapiClient = client!!);
                DapiActions.CREATE_BENEFICIARY -> createBeneficiary(call = call, result = result, dapiClient = client!!);
                DapiActions.GET_SUB_ACCOUNTS -> getSubAccounts(call = call, result = result, dapiClient = client!!)
                DapiActions.GET_BENEFICIARIES -> getBeneficiaries(call = call, result = result, dapiClient = client!!)
                DapiActions.DELINK -> delink(call = call, result = result, dapiClient = client!!)
                DapiActions.CREATE_TRANSACTION_ID_TO_ID -> createTransferIdToId(call = call, result = result, dapiClient = client!!)
                DapiActions.CREATE_TRANSACTION_ID_TO_I_BAN -> createTransferIdToIBan(call = call, result = result, dapiClient = client!!)
                DapiActions.CREATE_TRANSACTION_ID_TO_NUMBER -> createTransferIdToNumber(call = call, result = result, dapiClient = client!!)

            }
        } else {
            result.error(ConstMessage.CLIENT_IS_NULL_CODE, ConstMessage.CLIENT_IS_NULL, null);

        }
    }

    fun action(events: EventChannel.EventSink? = null, action: DapiActions) {
        if (client != null) {
            when (action) {
                DapiActions.LOGIN -> present(events, client!!)
                DapiActions.CLEAR_LOGIN_LISTENER -> client?.connect?.dismiss();

            }
        } else {
            events?.error(ConstMessage.CLIENT_IS_NULL_CODE, ConstMessage.CLIENT_IS_NULL, null);
        }
    }


    fun initDpiClient(call: MethodCall, result: MethodChannel.Result) {
        val appKey = call.argument<String>(ConstParameters.ENVIRONMENT_APP_KEY);
        val host = call.argument<String>(ConstParameters.ENVIRONMENT_HOST);
        val port = call.argument<Int>(ConstParameters.ENVIRONMENT_PORT);
        val env = call.argument<String>(ConstParameters.ENVIRONMENT_TYPE);


        if (appKey == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.APP_KEY_NULL, null);
            return;
        }
        if (host == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.HOST_NULL, null);
            return
        }
        if (port == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.PORT_NULL, null);
            return;
        }
        if (env == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.ENV_NULL, null);
            return
        }
        if (!(env.contains(Consts.ENVIRONMENT_SANDBOX) || env.contains(Consts.ENVIRONMENT_PRODUCTION))) {
            result.error(ConstMessage.VALIDATION_BY_NULL, "$env environment is not correct", null);
            return
        }


        val environment: DapiEnvironment = if (env == Consts.ENVIRONMENT_SANDBOX)
            DapiEnvironment.SANDBOX;
        else
            DapiEnvironment.PRODUCTION;

        val fullHost = "$host:$port";

        client = DapiClient(activity.application, getDapiConfiguration(appKey = appKey, host = fullHost, env = environment))

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
        client?.let {
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
                    val result = Gson().toJson(AuthState(accessId = userID, bankId = bankID, status = AuthStatus.SUCCESS));
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
        val userId = call.argument<String>(ConstParameters.CURRENT_CONNECT_ID);
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
        val userId = call.argument<String>(ConstParameters.CURRENT_CONNECT_ID);
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
        val userId = call.argument<String>(ConstParameters.CURRENT_CONNECT_ID);
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


    private fun createTransferIdToId(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val beneficiaryId = call.argument<String?>(ConstParameters.TRANSACTION_BENEFICIARY_ID)
        val accountId = call.argument<String?>(ConstParameters.TRANSACTION_BANK_ACCOUNT_ID)
        val userId = call.argument<String?>(ConstParameters.CURRENT_CONNECT_ID)
        val amount = call.argument<Double?>(ConstParameters.TRANSACTION_AMOUNT)
        val remark = call.argument<String?>(ConstParameters.TRANSACTION_REMARK)
        val paymentID: String? = call.argument<String?>(ConstHeader.TRANSACTION_PAYMENT_VALUE)

        if (beneficiaryId == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.BENEFICIARY_ID_NULL, null)
            return
        }
        if (accountId == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.ACCOUNT_ID_NULL, null)
            return;
        }
        if (userId == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.CURRENT_CONNECTION_ID_NULL, null)
            return;
        }
        if (amount == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.AMOUNT_IS_NULL, null)
            return;
        }


        val successCallback = { value: CreateTransfer ->
            successFinish(value, result)
            updateHeaderForDapiClient()
        }

        val errorCallback = { err: DapiError ->
            updateHeaderForDapiClient()
            result.error(err.type ?: "", err.msg
                    ?: ConstMessage.SOMETHING_HAPPENED_DAPI_RESPONSE, null)
        }

        userId?.let { dapiClient.userID = (it) };
        paymentID?.let {
            updateHeaderForDapiClient(hashMapOf<String, String>(ConstHeader.TRANSACTION_PAYMENT_HEADER to paymentID))
        }
        dapiClient.payment.createTransfer(beneficiaryId, accountId, amount!!, remark, successCallback, errorCallback)

    }

    private fun createTransferIdToIBan(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val iBanReceiver = call.argument<String?>(ConstParameters.I_BAN)
        val nameReceiver = call.argument<String?>(ConstParameters.TRANSACTION_RECEIVER_NAME)
        val accountId = call.argument<String?>(ConstParameters.TRANSACTION_BANK_ACCOUNT_ID)
        val userId = call.argument<String?>(ConstParameters.CURRENT_CONNECT_ID)
        val amount = call.argument<Double?>(ConstParameters.TRANSACTION_AMOUNT)
        val remark = call.argument<String?>(ConstParameters.TRANSACTION_REMARK)
        val paymentID: String? = call.argument<String?>(ConstHeader.TRANSACTION_PAYMENT_VALUE)

        if (iBanReceiver == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.I_BAN_NULL, null)
            return
        }
        if (nameReceiver == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.RECEIVER_NAME_NULL, null)
            return
        }
        if (accountId == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.ACCOUNT_ID_NULL, null)
            return;
        }
        if (userId == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.CURRENT_CONNECTION_ID_NULL, null)
            return;
        }
        if (amount == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.AMOUNT_IS_NULL, null)
            return;
        }

        val successCallback = { value: CreateTransfer ->
            successFinish(value, result)
            updateHeaderForDapiClient()
        }

        val errorCallback = { err: DapiError ->
            updateHeaderForDapiClient()
            result.error(err.type ?: "", err.msg
                    ?: ConstMessage.SOMETHING_HAPPENED_DAPI_RESPONSE, null)
        }

        dapiClient.userID = userId
        paymentID?.let {
            updateHeaderForDapiClient(hashMapOf(ConstHeader.TRANSACTION_PAYMENT_HEADER to paymentID))
        }
        dapiClient.payment.createTransfer(iBanReceiver, nameReceiver, accountId, amount, remark, successCallback, errorCallback)

    }

    private fun createTransferIdToNumber(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val receiverAccountNumber = call.argument<String?>(ConstParameters.ACCOUNT_NUMBER)
        val receiverName = call.argument<String?>(ConstParameters.TRANSACTION_RECEIVER_NAME)
        val accountId = call.argument<String?>(ConstParameters.TRANSACTION_BANK_ACCOUNT_ID)
        val userId = call.argument<String?>(ConstParameters.CURRENT_CONNECT_ID)
        val amount = call.argument<Double?>(ConstParameters.TRANSACTION_AMOUNT)
        val remark = call.argument<String?>(ConstParameters.TRANSACTION_REMARK)
        val paymentID: String? = call.argument<String?>(ConstHeader.TRANSACTION_PAYMENT_VALUE)

        if (receiverAccountNumber == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.RECEIVER_ACCOUNT_NUMBER_NULL, null)
            return
        }
        if (receiverName == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.RECEIVER_NAME_NULL, null)
            return
        }
        if (accountId == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.ACCOUNT_ID_NULL, null)
            return;
        }
        if (userId == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.CURRENT_CONNECTION_ID_NULL, null)
            return;
        }
        if (amount == null) {
            result.error(ConstMessage.VALIDATION_BY_NULL, ConstMessage.AMOUNT_IS_NULL, null)
            return;
        }

        val successCallback = { value: CreateTransfer ->
            successFinish(value, result)
            updateHeaderForDapiClient()
        }

        val errorCallback = { err: DapiError ->
            updateHeaderForDapiClient()
            result.error(err.type ?: "", err.msg
                    ?: ConstMessage.SOMETHING_HAPPENED_DAPI_RESPONSE, null)
        }

        dapiClient.userID = userId
        paymentID?.let {
            updateHeaderForDapiClient(hashMapOf(ConstHeader.TRANSACTION_PAYMENT_HEADER to paymentID))
        }
        dapiClient.payment.createTransfer(receiverAccountNumber, receiverName, amount, accountId, remark, successCallback, errorCallback)

    }

    private fun delink(call: MethodCall, result: MethodChannel.Result, dapiClient: DapiClient) {
        val dapiAccessId = call.argument<String>(ConstParameters.CURRENT_CONNECT_ID);
        dapiAccessId?.let {
            dapiClient.userID = (it)
        };


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
        val userId = call.argument<String>(ConstParameters.CURRENT_CONNECT_ID);
        val addressLine1 = call.argument<String>(ConstParameters.BENEFICIARY_ADDRESS_LINE1);
        val addressLine2 = call.argument<String>(ConstParameters.BENEFICIARY_ADDRESS_LINE2);
        val addressLine3 = call.argument<String>(ConstParameters.BENEFICIARY_ADDRESS_LINE3);
        val accountNumber = call.argument<String>(ConstParameters.ACCOUNT_NUMBER);
        val accountName = call.argument<String>(ConstParameters.BENEFICIARY_NAME);
        val bankName = call.argument<String>(ConstParameters.BENEFICIARY_BANK_NAME);
        val swiftCode = call.argument<String>(ConstParameters.SWIFT_CODE);
        val iBan = call.argument<String>(ConstParameters.I_BAN);
        val country = call.argument<String>(ConstParameters.COUNTRY);
        val branchAddress = call.argument<String>(ConstParameters.BENEFICIARY_BRANCH_ADDRESS);
        val branchName = call.argument<String>(ConstParameters.BENEFICIARY_BRANCH_NAME);
        val phone = call.argument<String>(ConstParameters.PHONE_NUMBER);

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
                iban = iBan,
                country = country,
                branchAddress = branchAddress,
                branchName = branchName,
                phoneNumber = phone
        )

        dapiClient.payment.createBeneficiary(info, {
            successFinish(it, result)
        }, {
            val errorMessage: String = if (it.msg == null) ConstMessage.SOMETHING_HAPPENED_DAPI_RESPONSE else it.msg!!;
            result.error(it.type ?: "", errorMessage, null);
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

    override fun onPreEngineRestart() {
        print("onPreEngineRestart");
    }


}





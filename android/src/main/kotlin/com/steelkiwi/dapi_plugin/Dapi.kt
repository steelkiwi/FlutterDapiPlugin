package com.steelkiwi.dapi_plugin

import android.app.Activity
import androidx.annotation.NonNull;

import com.dapi.connect.core.base.DapiClient
import com.dapi.connect.core.enums.DapiEnvironment
import com.dapi.connect.data.models.DapiConfigurations

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** DapiPlugin */
public class Dapi : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var channel: MethodChannel? = null
    private var activityPluginBinding: ActivityPluginBinding? = null

    private var delegate: DapiConnectDelegate? = null


    override fun onAttachedToEngine(@NonNull plugin: FlutterPlugin.FlutterPluginBinding) {
        setupEngine(plugin.binaryMessenger);

    }

    companion object {
        private val CHANNEL = "plugins.steelkiwi.com/dapi"
        private val ACTION_CHANEL_DAPI_CONNECT = "dapi_connect"
        private val ACTION_CHANEL_DAPI_ACTIVE_CONNECTION = "dapi_active_connection"
        private val ACTION_CHANEL_DAPI_USER_ACCOUNT = "dapi_user_accounts"
        private val ACTION_CHANEL_DAPI_USER_META_DATA_ACCOUNT = "dapi_user_accounts_meta_deta"
        private val ACTION_CHANEL_DAPI_BENEFICIARIES = "dapi_beneficiaries"
        private val ACTION_CHANEL_DAPI_CREATE_BENEFICIARY = "dapi_create_beneficiary"
        private val ACTION_CHANEL_CREATE_TRANSFER = "dapi_create_transfer"
        private val ACTION_CHANEL_RELEASE = "dapi_release"
        private val ACTION_CHANEL_DELINK = "dapi_delink"
        private val ACTION_CHANEL_HISTORY_DELEGATE = "dapi_history_transaction"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = Dapi()
            plugin.setupEngine(registrar.messenger())
            val delegate: DapiConnectDelegate = plugin.setupActivity(registrar.activity())!!
            registrar.addActivityResultListener(delegate)


        }
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            ACTION_CHANEL_DAPI_CONNECT -> delegate?.openDapiConnect(call, result);
            ACTION_CHANEL_DAPI_ACTIVE_CONNECTION -> delegate?.getActiveConnection(call, result);
            ACTION_CHANEL_DAPI_USER_ACCOUNT -> delegate?.getCurrentAccount(call, result);
            ACTION_CHANEL_DAPI_USER_META_DATA_ACCOUNT -> delegate?.getCurrentMetaDataAccount(call, result);
            ACTION_CHANEL_DAPI_BENEFICIARIES -> delegate?.getBeneficiaries(call, result);
            ACTION_CHANEL_CREATE_TRANSFER -> delegate?.createTransfer(call, result);
            ACTION_CHANEL_RELEASE -> delegate?.logout(call, result);
            ACTION_CHANEL_DELINK -> delegate?.delink(call, result);
            ACTION_CHANEL_DAPI_CREATE_BENEFICIARY -> delegate?.createBeneficiary(call, result);
            ACTION_CHANEL_HISTORY_DELEGATE -> delegate?.getHistoryTransfers(call, result);
        }


    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        delegate?.let { activityPluginBinding?.removeActivityResultListener(it) };
        activityPluginBinding = null;
        delegate = null; }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
        onAttachedToActivity(p0);
    }

    private fun setupActivity(activity: Activity): DapiConnectDelegate? {
        val appKey = "7805f8fd9f0c67c886ecfe2f48a04b548f70e1146e4f3a58200bec4f201b2dc4"
        val dapiConfigurations = DapiConfigurations(
                appKey,
                "https://api-lune.dev.steel.kiwi:4041",
                DapiEnvironment.SANDBOX,
                listOf("AE"),
                "",
                ""
        );
        val client = DapiClient(activity.application, dapiConfigurations)

        delegate = DapiConnectDelegate(activity, client)

        return delegate
    }

    override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
        setupActivity(activityPluginBinding.activity);
        this.activityPluginBinding = activityPluginBinding;
        delegate?.let { activityPluginBinding.addActivityResultListener(it) }; }

    private fun setupEngine(messenger: BinaryMessenger) {
        val channel = MethodChannel(messenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }
}

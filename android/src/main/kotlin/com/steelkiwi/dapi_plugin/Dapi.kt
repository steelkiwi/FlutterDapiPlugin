package com.steelkiwi.dapi_plugin

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** DapiPlugin */
public class Dapi : FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
    private var channel: MethodChannel? = null
    private var eventChannel: EventChannel? = null;
    private var activityPluginBinding: ActivityPluginBinding? = null

    private var delegate: DapiConnectDelegate? = null


    override fun onAttachedToEngine(@NonNull plugin: FlutterPlugin.FlutterPluginBinding) {
        setupEngine(plugin.binaryMessenger);

    }

    companion object {
        private val CHANNEL = "plugins.steelkiwi.com/dapi"
        private val ACTION_CHANEL_DAPI_SET_ENVIRONMENT = "dapi_connect_set_environment"
        private val ACTION_CHANEL_DAPI_CONNECT = "dapi_connect"
        private val ACTION_CHANEL_DAPI_ACTIVE_CONNECTION = "dapi_active_connection"
        private val ACTION_CHANEL_DAPI_USER_ACCOUNT = "dapi_connection_accounts"
        private val ACTION_CHANEL_DAPI_USER_META_DATA_ACCOUNT = "dapi_user_accounts_meta_data"
        private val ACTION_CHANEL_DAPI_BENEFICIARIES = "dapi_beneficiaries"
        private val ACTION_CHANEL_DAPI_CREATE_BENEFICIARY = "dapi_create_beneficiary"
        private val ACTION_CHANEL_CREATE_TRANSFER = "dapi_create_transfer"
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
            ACTION_CHANEL_DAPI_SET_ENVIRONMENT -> delegate?.initDpiClient(call = call, result);
            ACTION_CHANEL_DAPI_ACTIVE_CONNECTION -> delegate?.action(call = call, result = result, action = DapiActions.GET_ACTIVE_CONNECTION);
            ACTION_CHANEL_DAPI_USER_ACCOUNT -> delegate?.action(call = call, result = result, action = DapiActions.GET_SUB_ACCOUNTS)
            ACTION_CHANEL_DAPI_USER_META_DATA_ACCOUNT -> delegate?.action(call = call, result = result, action = DapiActions.GET_BANK_METADATA)
            ACTION_CHANEL_DAPI_BENEFICIARIES -> delegate?.action(call = call, result = result, action = DapiActions.GET_BENEFICIARIES)
            ACTION_CHANEL_CREATE_TRANSFER -> delegate?.action(call = call, result = result, action = DapiActions.CREATE_TRANSACTION)
            ACTION_CHANEL_DELINK -> delegate?.action(call = call, result = result, action = DapiActions.DELINK)
            ACTION_CHANEL_DAPI_CREATE_BENEFICIARY -> delegate?.action(call = call, result = result, action = DapiActions.CREATE_BENEFICIARY)
        }


    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }

    override fun onDetachedFromActivity() {
        delegate?.let { activityPluginBinding?.removeActivityResultListener(it) };
        activityPluginBinding = null;
        delegate = null; }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
        onAttachedToActivity(p0);
    }


    private fun setupActivity(activity: Activity): DapiConnectDelegate? {
        delegate = DapiConnectDelegate(activity)
        return delegate
    }

    override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
        setupActivity(activityPluginBinding.activity);
        this.activityPluginBinding = activityPluginBinding;
        delegate?.let { activityPluginBinding.addActivityResultListener(it) }; }

    private fun setupEngine(messenger: BinaryMessenger) {
        val channel = MethodChannel(messenger, CHANNEL)
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(messenger, "plugins.steelkiwi.com/dapi/connect")
        eventChannel?.setStreamHandler(this)

    }

    override fun onDetachedFromActivityForConfigChanges() {
        delegate?.dapiClient?.release()
        onDetachedFromActivity();
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        events?.let {
            delegate?.action(events = events, action = DapiActions.LOGIN);
        }
    }

    override fun onCancel(arguments: Any?) {
        delegate?.action(action = DapiActions.CLEAR_LOGIN_LISTENER)
    }

}

package com.steelkiwi.dapi_plugin

import android.app.Activity
import androidx.annotation.NonNull
import com.steelkiwi.dapi_plugin.configs.ConstActions
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

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = Dapi()
            plugin.setupEngine(registrar.messenger())

        }
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            ConstActions.INIT_ENVIRONMENT -> delegate?.initDpiClient(call = call, result);
            ConstActions.ACTIVE_CONNECTION -> delegate?.action(call = call, result = result, action = DapiActions.GET_ACTIVE_CONNECTION);
            ConstActions.CONNECTION_ACCOUNTS -> delegate?.action(call = call, result = result, action = DapiActions.GET_SUB_ACCOUNTS)
            ConstActions.BANK_METADATA -> delegate?.action(call = call, result = result, action = DapiActions.GET_BANK_METADATA)
            ConstActions.BENEFICIARIES -> delegate?.action(call = call, result = result, action = DapiActions.GET_BENEFICIARIES)
            ConstActions.DE_LINK -> delegate?.action(call = call, result = result, action = DapiActions.DELINK)
            ConstActions.CREATE_BENEFICIARY -> delegate?.action(call = call, result = result, action = DapiActions.CREATE_BENEFICIARY)
            ConstActions.CREATE_TRANSFER_ID_TO_ID -> delegate?.action(call = call, result = result, action = DapiActions.CREATE_TRANSACTION_ID_TO_ID)
            ConstActions.CREATE_TRANSFER_ID_TO_I_BAN -> delegate?.action(call = call, result = result, action = DapiActions.CREATE_TRANSACTION_ID_TO_I_BAN)
            ConstActions.CREATE_TRANSFER_ID_TO_NUMBER -> delegate?.action(call = call, result = result, action = DapiActions.CREATE_TRANSACTION_ID_TO_NUMBER)

        }


    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }

    override fun onDetachedFromActivity() {
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
    }

    private fun setupEngine(messenger: BinaryMessenger) {
        val channel = MethodChannel(messenger, CHANNEL)
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(messenger, ConstActions.CONNECT)
        eventChannel?.setStreamHandler(this)

    }

    override fun onDetachedFromActivityForConfigChanges() {
        delegate?.client?.release()
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

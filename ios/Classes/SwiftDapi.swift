import Flutter
import UIKit

public class SwiftDapi: NSObject, FlutterPlugin {
    
    let channelName = "plugins.steelkiwi.com/dapi"
    
    var connectDelegate: DapiConnectDelegate?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.steelkiwi.com/dapi", binaryMessenger: registrar.messenger())
        let instance = SwiftDapi()
        instance.connectDelegate = DapiConnectDelegate()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        connectDelegate?.executeAction(call, result)
    }

}




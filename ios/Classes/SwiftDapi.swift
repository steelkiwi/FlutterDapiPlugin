import Flutter
import UIKit

public class SwiftDapi: NSObject, FlutterPlugin {
    
    var connectDelegate: DapiConnectDelegate?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.steelkiwi.com/dapi", binaryMessenger: registrar.messenger())
        let instance = SwiftDapi()
        instance.connectDelegate = DapiConnectDelegate()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = ActionChanel(rawValue: call.method) else { return } // just return without actions if wrong method, so far without errors
        connectDelegate?.execute(method, result: result)
        //result(FlutterMethodNotImplemented)
        return
    }

}





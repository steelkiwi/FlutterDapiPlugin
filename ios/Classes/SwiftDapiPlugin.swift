import Flutter
import UIKit

public class SwiftDapiPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.steelkiwi.com/dapi", binaryMessenger: registrar.messenger())
    let instance = SwiftDapiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }


  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          guard call.method == "dapi_connect" else {
              result(FlutterMethodNotImplemented)
              return
          }



      }

}

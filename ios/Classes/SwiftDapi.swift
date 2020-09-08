import Flutter
import UIKit

public class SwiftDapi: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.steelkiwi.com/dapi", binaryMessenger: registrar.messenger())
    let instance = SwiftDapi()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          guard call.method == "dapi_connect" else {
              result(FlutterMethodNotImplemented)
              return
          }



      }

}

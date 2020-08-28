import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dapi_plugin/dapi_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('dapi_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
   // expect(await DapiPlugin.platformVersion, '42');
  });
}

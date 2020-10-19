import 'package:flutter/services.dart';

class Channels {
  MethodChannel baseChannel = const MethodChannel('plugins.steelkiwi.com/dapi');
  EventChannel eventsConnect = const EventChannel('plugins.steelkiwi.com/dapi/connect');
}

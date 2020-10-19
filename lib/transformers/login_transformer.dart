import 'dart:async';
import 'dart:convert';

import 'package:dapi/configs/const_messages.dart';
import 'package:dapi/models/auth_state.dart';
import 'package:dapi/models/auth_status.dart';

class LoginTransformer {
  static const String statusProceed = "PROCEED";
  static const String statusSuccess = "SUCCESS";

  var streamTransformer = StreamTransformer<dynamic, AuthState>.fromHandlers(
    handleData: (dynamic data, EventSink sink) {
      if (data is String) {
        Map map = jsonDecode(data);
        var obj = AuthState(
            accessID: map["accessId"],
            bankId: map["bankId"],
            error: map["error"],
            status: map["status"] == statusProceed
                ? AuthStatus.PROCEED
                : map["status"] == statusSuccess
                    ? AuthStatus.SUCCESS
                    : AuthStatus.FAILURE);
        sink.add(obj);
      }
    },
    handleError: (Object error, StackTrace stacktrace, EventSink sink) {
      sink.addError(ConstMessages.somethingWrong + '$error');
    },
    handleDone: (EventSink sink) => sink.close(),
  );
}

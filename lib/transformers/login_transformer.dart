import 'dart:async';
import 'dart:convert';

import 'package:dapi/models/auth_state.dart';
import 'package:dapi/models/auth_status.dart';

class LoginTransformer {
  var streamTransformer = StreamTransformer<dynamic, AuthState>.fromHandlers(
    handleData: (dynamic data, EventSink sink) {
      if (data is String) {
        Map map = jsonDecode(data);
        var obj = AuthState(
            accessID: map["accessId"],
            bankId: map["bankId"],
            error: map["error"],
            status: map["status"] == "PROCEED"
                ? AuthStatus.PROCEED
                : map["status"] == "SUCCESS"
                    ? AuthStatus.SUCCESS
                    : AuthStatus.FAILURE);
        sink.add(obj);
      }
    },
    handleError: (Object error, StackTrace stacktrace, EventSink sink) {
      sink.addError('Something went wrong: $error');
    },
    handleDone: (EventSink sink) => sink.close(),
  );
}

import 'package:flutter/cupertino.dart';

import 'auth_status.dart';

class AuthState {
  final String accessID;
  final AuthStatus status;

  AuthState({this.accessID, @required this.status});
}

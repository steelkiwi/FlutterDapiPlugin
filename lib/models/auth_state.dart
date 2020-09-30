import 'package:flutter/cupertino.dart';

import 'auth_status.dart';

class AuthState {
  final String accessID;
  final AuthStatus status;
  final String error;

  AuthState({this.accessID, @required this.status,this.error});
}

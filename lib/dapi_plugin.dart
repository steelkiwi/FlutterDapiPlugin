import 'dart:async';
import 'dart:convert';

import 'package:dapi_plugin/models/account.dart';
import 'package:dapi_plugin/models/AccountsMetaData.dart';
import 'package:flutter/services.dart';

import 'models/Connections.dart';
import 'models/beneficiaries.dart';

class DapiPlugin {
  static const MethodChannel _channel =
      const MethodChannel('plugins.steelkiwi.com/dapi');
  static const KEY_DAPI_CONNECT = "dapi_connect";
  static const KEY_DAPI_ACTIVE_CONNECTION = "dapi_active_connection";
  static const KEY_DAPI_CURRENT_ACCOUNT = "dapi_user_accounts";
  static const KEY_DAPI_ACCOUNT_META_DATE = "dapi_user_accounts_meta_deta";
  static const KEY_DAPI_CREATED_TRANSFER = "dapi_create_transfer";
  static const KEY_DAPI_BENEFICIARIES = "dapi_beneficiaries";

  static const PARAM_USER_ID = "user_id";
  static const PARAM_BENEFICIARIES_ID = "beneficiary_id";
  static const PARAM_ACCOUNT_ID = "account_id";

  static Future<String> dapiConnect() async {
    final String resultPath = await _channel.invokeMethod(KEY_DAPI_CONNECT);
    return resultPath;
  }

  static Future<List<Connections>> getActiveConnect() async {
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_ACTIVE_CONNECTION);

    List<dynamic> list = jsonDecode(resultPath);

    var connection = (list).map((i) => Connections.fromJson(i)).toList();

    return connection;
  }

  static Future<Beneficiaries> getBeneficiaries({String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_BENEFICIARIES, arguments);

    Map map = jsonDecode(resultPath);

    var beneficiaries = Beneficiaries.fromJson(map);
    return beneficiaries;
  }

  static Future<List<Account>> getUserAccounts({String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_CURRENT_ACCOUNT, arguments);

    List list = jsonDecode(resultPath)["accounts"];

    var accounts = list.map((i) => Account.fromJson(i)).toList();

    return accounts;
  }

  static Future<AccountsMetadata> createTransfer(
      {String userId, String beneficiaryId, String accountId}) async {
    final arguments = <String, dynamic>{
      PARAM_BENEFICIARIES_ID: beneficiaryId,
      PARAM_ACCOUNT_ID: accountId,
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_CREATED_TRANSFER, arguments);

    Map map = jsonDecode(resultPath)["accountsMetadata"];

    var account = AccountsMetadata.fromJson(map);

    return account;
  }

  static Future<AccountsMetadata> getUserAccountsMetaData(
      {String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_ACCOUNT_META_DATE, arguments);

    Map map = jsonDecode(resultPath)["accountsMetadata"];

    var account = AccountsMetadata.fromJson(map);

    return account;
  }
}

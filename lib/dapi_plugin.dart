import 'dart:async';
import 'dart:convert';

import 'package:dapi/models/create_transfer_response.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'models/account.dart';
import 'models/accounts_metadata.dart';
import 'models/beneficiaries.dart';
import 'models/connections.dart';

class Dapi {
  static const MethodChannel _channel =
      const MethodChannel('plugins.steelkiwi.com/dapi');
  static const KEY_DAPI_CONNECT = "dapi_connect";
  static const KEY_DAPI_ACTIVE_CONNECTION = "dapi_active_connection";
  static const KEY_DAPI_CURRENT_ACCOUNT = "dapi_user_accounts";
  static const KEY_DAPI_ACCOUNT_META_DATE = "dapi_user_accounts_meta_deta";
  static const KEY_DAPI_CREATED_TRANSFER = "dapi_create_transfer";
  static const KEY_DAPI_BENEFICIARIES = "dapi_beneficiaries";
  static const KEY_DAPI_CREATE_BENEFICIARY = "dapi_beneficiary";

  static const PARAM_AMOUNT = "param_amount";
  static const PARAM_USER_ID = "user_id";
  static const PARAM_BENEFICIARIES_ID = "beneficiary_id";
  static const PARAM_ACCOUNT_ID = "account_id";
  static const PARAM_REMARK = "transfer_remark";

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

  static Future<Beneficiaries> getBeneficiaries(
      {@required String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_BENEFICIARIES, arguments);

    Map map = jsonDecode(resultPath);

    var beneficiaries = Beneficiaries.fromJson(map);
    return beneficiaries;
  }

  static Future<List<Account>> getUserAccounts(
      {@required String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_CURRENT_ACCOUNT, arguments);

    List list = jsonDecode(resultPath)["accounts"];

    var accounts = list.map((i) => Account.fromJson(i)).toList();

    return accounts;
  }

  static Future<CreateTransferResponse> createTransfer({
    @required String userId,
    @required String beneficiaryId,
    @required String accountId,
    @required double amount,
    @required String remark,
  }) async {
    final arguments = <String, dynamic>{
      PARAM_AMOUNT: amount,
      PARAM_BENEFICIARIES_ID: beneficiaryId,
      PARAM_ACCOUNT_ID: accountId,
      PARAM_USER_ID: userId,
      PARAM_REMARK: remark,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_CREATED_TRANSFER, arguments);
    Map map = jsonDecode(resultPath);
    var account = CreateTransferResponse.fromJson(map);
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

  static Future<AccountsMetadata> createBeneficiary({
    String userId,



  }) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_CREATE_BENEFICIARY, arguments);

    Map map = jsonDecode(resultPath)["accountsMetadata"];

    var account = AccountsMetadata.fromJson(map);

    return account;
  }
}

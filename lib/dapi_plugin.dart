import 'dart:async';
import 'dart:convert';

import 'package:dapi/models/beneficiary.dart';
import 'package:dapi/models/create_transfer_response.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'models/account.dart';
import 'models/auth_state.dart';
import 'models/auth_status.dart';
import 'models/beneficiary_request_success.dart';
import 'models/connections.dart';
import 'models/dapi_bank_metadata.dart';
import 'models/delink_user.dart';

enum DapiEnvironment { PRODUCTION, SANDBOX }

typedef void Listener(AuthState msg);
typedef void CancelListening();

class Dapi {
  static const MethodChannel _channel =
      const MethodChannel('plugins.steelkiwi.com/dapi');
  static const EventChannel _events =
      const EventChannel('plugins.steelkiwi.com/dapi/connect');

  static const KEY_DAPI_CONNECT = "dapi_connect";
  static const KEY_DAPI_ACTIVE_CONNECTION = "dapi_active_connection";
  static const KEY_CONNECTION_ACCOUNTS = "dapi_connection_accounts";
  static const KEY_BANK_METADATA = "dapi_user_accounts_meta_data";
  static const KEY_DAPI_CREATED_TRANSFER = "dapi_create_transfer";
  static const KEY_DAPI_BENEFICIARIES = "dapi_beneficiaries";
  static const KEY_DAPI_CREATE_BENEFICIARY = "dapi_create_beneficiary";
  static const KEY_DAPI_DELINK = "dapi_delink";
  static const KEY_DAPI_HISTORY_TRANSACTION = "dapi_history_transaction";
  static const KEY_DAPI_INIT_ENVIRONMENT = "dapi_connect_set_environment";

  static const PARAM_AMOUNT = "param_amount";
  static const PARAM_USER_ID = "user_id";
  static const LUN_PAYMENT_ID = "lun_payment_id";
  static const PARAM_ENVIRONMENT = "dapi_environment";
  static const PARAM_BENEFICIARIES_ID = "beneficiary_id";
  static const PARAM_ACCOUNT_ID = "account_id";
  static const PARAM_REMARK = "transfer_remark";
  static const PARAM_HOST = "PARAM_HOST";
  static const PARAM_PORT = "PARAM_PORT";
  static const PARAM_APP_KEY = "PARAM_APP_KEY";

  static const PARAMET_CREATE_BENEFICIARY_LINE_ADDRES1 =
      "create_beneficiary_line_addres1";
  static const PARAMET_CREATE_BENEFICIARY_LINE_ADDRES2 =
      "create_beneficiary_line_addres2";
  static const PARAMET_CREATE_BENEFICIARY_LINE_ADDRES3 =
      "create_beneficiary_line_addres3";
  static const PARAMET_CREATE_BENEFICIARY_ACCOUNT_NUMBER =
      "create_beneficiary_account_number";
  static const PARAMET_CREATE_BENEFICIARY_NAME = "create_beneficiary_name";
  static const PARAMET_CREATE_BENEFICIARY_BANK_NAME =
      "create_beneficiary_bank_name";
  static const PARAMET_CREATE_BENEFICIARY_SWIFT_CODE =
      "create_beneficiary_swift_code";
  static const PARAMET_CREATE_BENEFICIARY_IBAN = "create_beneficiary_iban";
  static const PARAMET_CREATE_BENEFICIARY_COUNTRY =
      "create_beneficiary_country";
  static const PARAMET_CREATE_BENEFICIARY_BRANCH_ADDRESS =
      "create_beneficiary_branch_address";
  static const PARAMET_CREATE_BENEFICIARY_BRANCH_NAME =
      "create_beneficiary_branch_name";
  static const PARAMET_CREATE_BENEFICIARY_PHONE_NUMBER =
      "create_beneficiary_phone_number";

  static const HEADER_PAYMENT_ID = "header_payment_id";

  static Future<String> initEnvironment(
      {@required DapiEnvironment dapiEnvironment,
      String host,
      int port,
      String appKey}) async {
    var env =
        dapiEnvironment == DapiEnvironment.SANDBOX ? "sandbox" : "production";
    final arguments = <String, dynamic>{
      PARAM_ENVIRONMENT: env,
      PARAM_HOST: host,
      PARAM_PORT: port,
      PARAM_APP_KEY: appKey
    };
    _channel.invokeMethod(KEY_DAPI_INIT_ENVIRONMENT, arguments);

    return Future.value("Ok");
  }

  static int nextListenerId = 1;
  static var streamTransformer =
      StreamTransformer<dynamic, AuthState>.fromHandlers(
    handleData: (dynamic data, EventSink sink) {
      if (data is String) {
        Map map = jsonDecode(data);
        var obj = AuthState(
            accessID: map["accessId"],
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

  static CancelListening dapiConnect(Listener listener) {
    var subscription = _events
        .receiveBroadcastStream(nextListenerId++)
        .transform(streamTransformer)
        .listen(listener, cancelOnError: true);
    return () {
      subscription.cancel();
    };
  }

  static Future<List<Connections>> getActiveConnect() async {
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_ACTIVE_CONNECTION);

    List<dynamic> list = jsonDecode(resultPath);

    var connection = (list).map((i) => Connections.fromJson(i)).toList();

    return connection;
  }

  static Future<List<Beneficiary>> getBeneficiaries(
      {@required String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_BENEFICIARIES, arguments);

    List list = jsonDecode(resultPath);

    // Map map = jsonDecode(resultPath);

    var beneficiaries = list.map((i) => Beneficiary.fromJson(i)).toList();
    return beneficiaries;
  }

  static Future<List<Account>> getConnectionAccounts(
      {@required String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_CONNECTION_ACCOUNTS, arguments);

    List list = jsonDecode(resultPath);

    var accounts = list.map((i) => Account.fromJson(i)).toList();

    return accounts;
  }

  static Future<CreateTransferResponse> createTransfer(
      {@required String userId,
      @required String beneficiaryId,
      @required String accountId,
      @required double amount,
      @required String remark,
      String paymentId}) async {
    final arguments = <String, dynamic>{
      PARAM_AMOUNT: amount,
      PARAM_BENEFICIARIES_ID: beneficiaryId,
      PARAM_ACCOUNT_ID: accountId,
      PARAM_USER_ID: userId,
      PARAM_REMARK: remark,
      HEADER_PAYMENT_ID: paymentId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_CREATED_TRANSFER, arguments);
    Map map = jsonDecode(resultPath);
    var account = CreateTransferResponse.fromJson(map);
    return account;
  }

  static Future<DapiBankMetadata> getBankMetadata({String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_BANK_METADATA, arguments);

    Map map = jsonDecode(resultPath);

    var account = DapiBankMetadata.fromJson(map);

    return account;
  }

  static Future<BeneficiaryRequestSuccess> createBeneficiary(
      {@required String userId,
      @required String addres1,
      @required String addres2,
      @required String addres3,
      @required String accountNumber,
      @required String name,
      @required String bankName,
      @required String swiftCode,
      @required String iban,
      @required String country,
      @required String branchAddress,
      @required String branchName,
      @required String phoneNumber}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
      PARAMET_CREATE_BENEFICIARY_LINE_ADDRES1: addres1,
      PARAMET_CREATE_BENEFICIARY_LINE_ADDRES2: addres2,
      PARAMET_CREATE_BENEFICIARY_LINE_ADDRES3: addres3,
      PARAMET_CREATE_BENEFICIARY_ACCOUNT_NUMBER: accountNumber,
      PARAMET_CREATE_BENEFICIARY_NAME: name,
      PARAMET_CREATE_BENEFICIARY_BANK_NAME: branchName,
      PARAMET_CREATE_BENEFICIARY_SWIFT_CODE: swiftCode,
      PARAMET_CREATE_BENEFICIARY_IBAN: iban,
      PARAMET_CREATE_BENEFICIARY_COUNTRY: country,
      PARAMET_CREATE_BENEFICIARY_BRANCH_ADDRESS: branchAddress,
      PARAMET_CREATE_BENEFICIARY_BRANCH_NAME: branchName,
      PARAMET_CREATE_BENEFICIARY_PHONE_NUMBER: phoneNumber
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_CREATE_BENEFICIARY, arguments);
    Map map = jsonDecode(resultPath);
    var account = BeneficiaryRequestSuccess.fromJson(map);
    return account;
  }

  static Future<DelinkUser> delink(
      {@required String dapiAccessId, @required String lunPaymentId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: dapiAccessId,
      LUN_PAYMENT_ID: lunPaymentId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_DELINK, arguments);
    Map map = jsonDecode(resultPath);
    var account = DelinkUser.fromJson(map);
    return account;
  }

  static Future<DelinkUser> getHistoryTransaction(
      {@required String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_HISTORY_TRANSACTION, arguments);
    Map map = jsonDecode(resultPath);
    var account = DelinkUser.fromJson(map);
    return account;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:dapi/models/create_transfer_response.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'models/account.dart';
import 'models/accounts_metadata.dart';
import 'models/beneficiaries.dart';
import 'models/beneficiary_request_success.dart';
import 'models/connections.dart';
import 'models/delink_user.dart';

class Dapi {
  static const MethodChannel _channel =
      const MethodChannel('plugins.steelkiwi.com/dapi');
  static const KEY_DAPI_CONNECT = "dapi_connect";
  static const KEY_DAPI_ACTIVE_CONNECTION = "dapi_active_connection";
  static const KEY_DAPI_CURRENT_ACCOUNT = "dapi_user_accounts";
  static const KEY_DAPI_ACCOUNT_META_DATA = "dapi_user_accounts_meta_data";
  static const KEY_DAPI_CREATED_TRANSFER = "dapi_create_transfer";
  static const KEY_DAPI_BENEFICIARIES = "dapi_beneficiaries";
  static const KEY_DAPI_CREATE_BENEFICIARY = "dapi_create_beneficiary";
  static const KEY_DAPI_RELEASE = "dapi_release";
  static const KEY_DAPI_DELINK = "dapi_delink";
  static const KEY_DAPI_HISTORY_TRANSACTION = "dapi_history_transaction";

  static const PARAM_AMOUNT = "param_amount";
  static const PARAM_USER_ID = "user_id";
  static const PARAM_BENEFICIARIES_ID = "beneficiary_id";
  static const PARAM_ACCOUNT_ID = "account_id";
  static const PARAM_REMARK = "transfer_remark";

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

  static Future<AccountsMetadata> getUserAccountsMetaData(
      {String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
    };
    final String resultPath =
        await _channel.invokeMethod(KEY_DAPI_ACCOUNT_META_DATA, arguments);

    Map map = jsonDecode(resultPath)["accountsMetadata"];

    var account = AccountsMetadata.fromJson(map);

    return account;
  }

  static Future<BeneficiaryRequestSuccess> createBeneficiary(
      {String userId,
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

  static Future<bool> release() async {
    await _channel.invokeMethod(KEY_DAPI_RELEASE);
    return true;
  }

  static Future<DelinkUser> delink({@required String userId}) async {
    final arguments = <String, dynamic>{
      PARAM_USER_ID: userId,
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

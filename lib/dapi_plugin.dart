import 'dart:async';
import 'dart:convert';

import 'package:dapi/configs/const_headers.dart';
import 'package:dapi/configs/const_parametrs.dart';
import 'package:dapi/models/beneficiary.dart';
import 'package:dapi/models/create_transfer_response.dart';
import 'package:flutter/widgets.dart';

import 'configs/channels.dart';
import 'configs/const_actions.dart';
import 'configs/const_messages.dart';
import 'configs/consts_env.dart';
import 'configs/environment.dart';
import 'models/account.dart';
import 'models/auth_state.dart';
import 'models/beneficiary_request_success.dart';
import 'models/connections.dart';
import 'models/dapi_bank_metadata.dart';
import 'models/delink_user.dart';
import 'transformers/login_transformer.dart';

typedef void Listener(AuthState msg);
typedef void CancelListening();

class Dapi {
  static Channels _channels = Channels();
  static int nextListenerId = 1;
  static LoginTransformer _loginTransformer = LoginTransformer();

  static Future<String> initEnvironment(
      {@required Environment environment,
      String host,
      int port,
      String appKey}) async {
    var env = environment == Environment.SANDBOX
        ? ConstEnv.sandbox
        : ConstEnv.production;
    final arguments = <String, dynamic>{
      ConstParameters.environmentType: env,
      ConstParameters.environmentHost: host,
      ConstParameters.environmentPort: port,
      ConstParameters.environmentAppKey: appKey
    };
    _channels.baseChannel.invokeMethod(ConstAction.initEnvironment, arguments);

    return Future.value(ConstMessages.success);
  }

  static CancelListening dapiConnect(Listener listener) {
    var subscription = _channels.eventsConnect
        .receiveBroadcastStream(nextListenerId++)
        .transform(_loginTransformer.streamTransformer)
        .listen(listener, cancelOnError: true);
    return () {
      subscription.cancel();
    };
  }

  static Future<List<Connections>> getActiveConnect() async {
    final String resultPath =
        await _channels.baseChannel.invokeMethod(ConstAction.activeConnection);
    List<dynamic> list = jsonDecode(resultPath);
    var connection = (list).map((i) => Connections.fromJson(i)).toList();
    return connection;
  }

  static Future<List<Beneficiary>> getBeneficiaries(
      {@required String userId}) async {
    final arguments = <String, dynamic>{
      ConstParameters.currentConnectId: userId,
    };
    final String resultPath = await _channels.baseChannel
        .invokeMethod(ConstAction.beneficiaries, arguments);

    List list = jsonDecode(resultPath);

    var beneficiaries = list.map((i) => Beneficiary.fromJson(i)).toList();
    return beneficiaries;
  }

  static Future<List<Account>> getConnectionAccounts(
      {@required String userId}) async {
    final arguments = <String, dynamic>{
      ConstParameters.currentConnectId: userId,
    };
    final String resultPath = await _channels.baseChannel
        .invokeMethod(ConstAction.connectionAccounts, arguments);

    List list = jsonDecode(resultPath);

    var accounts = list.map((i) => Account.fromJson(i)).toList();

    return accounts;
  }

  static Future<CreateTransferResponse> createTransferIDToID(
      {@required String userId,
      @required String accountId,
      @required double amount,
      @required String beneficiaryId,
      String remark,
      String paymentId}) async {
    final arguments = <String, dynamic>{
      ConstParameters.currentConnectId: userId,
      ConstParameters.transactionAmount: amount,
      ConstParameters.transactionBeneficiaryId: beneficiaryId,
      ConstParameters.transactionBankAccountId: accountId,
      ConstParameters.transactionRemark: remark,
      ConstHeaders.transactionPaymentId: paymentId,
    };
    final String resultPath = await _channels.baseChannel
        .invokeMethod(ConstAction.createTransferIdToId, arguments);
    Map map = jsonDecode(resultPath);
    var account = CreateTransferResponse.fromJson(map);
    return account;
  }

  static Future<CreateTransferResponse> createTransferIDToIBan({
    @required String userId,
    @required String accountId,
    @required double amount,
    @required String iban,
    @required String name,
    String paymentId,
    String remark,
  }) async {
    final arguments = <String, dynamic>{
      ConstParameters.currentConnectId: userId,
      ConstParameters.transactionAmount: amount,
      ConstParameters.transactionBankAccountId: accountId,
      ConstParameters.transactionRemark: remark,
      ConstHeaders.transactionPaymentId: paymentId,
      ConstParameters.iBan: iban,
      ConstParameters.transactionReceiverName: name,
    };
    final String resultPath = await _channels.baseChannel
        .invokeMethod(ConstAction.createTransferIdToIBan, arguments);
    Map map = jsonDecode(resultPath);
    var account = CreateTransferResponse.fromJson(map);
    return account;
  }

  static Future<CreateTransferResponse> createTransferIdToAccountNumber(
      {@required String userId,
      @required String accountId,
      @required double amount,
      @required String accountNumber,
      @required String name,
      String remark,
      String paymentId}) async {
    final arguments = <String, dynamic>{
      ConstParameters.currentConnectId: userId,
      ConstParameters.transactionAmount: amount,
      ConstParameters.transactionBankAccountId: accountId,
      ConstParameters.transactionRemark: remark,
      ConstHeaders.transactionPaymentId: paymentId,
      ConstParameters.transactionReceiverName: name,
    };
    final String resultPath = await _channels.baseChannel
        .invokeMethod(ConstAction.createTransferIDToNumber, arguments);
    Map map = jsonDecode(resultPath);
    var account = CreateTransferResponse.fromJson(map);
    return account;
  }

  static Future<DapiBankMetadata> getBankMetadata({String userId}) async {
    final arguments = <String, dynamic>{
      ConstParameters.currentConnectId: userId,
    };
    final String resultPath = await _channels.baseChannel
        .invokeMethod(ConstAction.bankMetaData, arguments);

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
      ConstParameters.currentConnectId: userId,
      ConstParameters.beneficiaryAddressLine1: addres1,
      ConstParameters.beneficiaryAddressLine2: addres2,
      ConstParameters.beneficiaryAddressLine3: addres3,
      ConstParameters.accountNumber: accountNumber,
      ConstParameters.beneficiaryName: name,
      ConstParameters.beneficiaryBankName: branchName,
      ConstParameters.swiftCode: swiftCode,
      ConstParameters.iBan: iban,
      ConstParameters.country: country,
      ConstParameters.beneficiaryBranchAddress: branchAddress,
      ConstParameters.beneficiaryBranchName: branchName,
      ConstParameters.phoneNumber: phoneNumber
    };
    final String resultPath = await _channels.baseChannel
        .invokeMethod(ConstAction.createBeneficiary, arguments);
    Map map = jsonDecode(resultPath);
    var account = BeneficiaryRequestSuccess.fromJson(map);
    return account;
  }

  static Future<DelinkUser> delink({@required String dapiAccessId}) async {
    final arguments = <String, dynamic>{
      ConstParameters.currentConnectId: dapiAccessId,
    };
    final String resultPath =
        await _channels.baseChannel.invokeMethod(ConstAction.deLink, arguments);
    Map map = jsonDecode(resultPath);
    var account = DelinkUser.fromJson(map);
    return account;
  }
}

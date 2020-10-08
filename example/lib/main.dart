import 'package:dapi/dapi_plugin.dart';
import 'package:dapi/models/auth_state.dart';
import 'package:dapi/models/auth_status.dart';
import 'package:dapi/models/beneficiary.dart';
import 'package:dapi/models/connections.dart';
import 'package:dapi/models/dapi_bank_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _accessId = 'null';
  String _account = 'null';
  String _activeConnection = 'null';
  String _acountMetaData = 'null';
  String _beneficiaries = 'null';
  String _beneficiariarId = 'null';
  String _accountId = 'null';
  String _transferStatus = 'null';
  String _createBeneficiariesStatus = 'null';

  List<Beneficiary> _beneficiariesList;
  List<Connections> connections;

  DapiBankMetadata accountsMetadata;

  @override
  void initState() {
    Dapi.initEnvironment(
      dapiEnvironment: DapiEnvironment.SANDBOX,
      appKey:
          "7805f8fd9f0c67c886ecfe2f48a04b548f70e1146e4f3a58200bec4f201b2dc4",
      host: "https://api-lune.dev.steel.kiwi",
      port: 4041,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "AccessId/UserId: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_accessId),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Current account: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_account),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Active connection: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_activeConnection),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Account META DATA: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_acountMetaData),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Beneficiaries ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_beneficiaries),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "beneficiariar Id ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_beneficiariarId),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Account Id ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_accountId),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Transfer status ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_transferStatus),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "create beneficiary  status ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_createBeneficiariesStatus),
                  ],
                ),
                Divider(),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Open connect"),
                    onPressed: () async {
                      var cancel = Dapi.dapiConnect((AuthState msg) {
                        try {
                          _accessId = msg.status == AuthStatus.SUCCESS
                              ? msg.accessID
                              : msg.status.toString();

                          setState(() {});
                        } on PlatformException catch (e) {
                          setState(() {
                            _accessId = e.message;
                          });
                        }
                      });
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Get active connection"),
                    onPressed: () async {
                      try {
                        var connections = await Dapi.getActiveConnect();
                        if (connections.isNotEmpty) {
                          _activeConnection = connections.first.toString();
                          _accessId = connections.first.userID;
                          this.connections = connections;
                        } else {
                          _activeConnection = "No active connection";
                        }
                        setState(() {});
                      } on PlatformException catch (e) {
                        setState(() {
                          _accessId = e.message;
                        });
                      }
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Delink"),
                    onPressed: () async {
                      var result = await Dapi.delink(dapiAccessId: _accessId);
                      if (result.success) {
                        _accessId = 'null';
                        _account = 'null';
                        _activeConnection = 'null';
                        _acountMetaData = 'null';
                        _beneficiaries = 'null';
                        _beneficiariarId = 'null';
                        _accountId = 'null';
                        _transferStatus = 'null';
                        _createBeneficiariesStatus = 'null';
                      }
                      setState(() {});
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Get connection accounts"),
                    onPressed: () async {
                      try {
                        var result =
                            await Dapi.getConnectionAccounts(userId: _accessId);
                        if (result.isNotEmpty) {
                          _account = result.first.toString();
                          _accountId = result.first.id;
                        } else {
                          _account = "No accounts";
                        }
                        setState(() {});
                      } on PlatformException catch (e) {
                        setState(() {
                          _accountId = e.message;
                        });
                      }
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Get account META DATA"),
                    onPressed: () async {
                      try {
                        var result =
                            await Dapi.getBankMetadata(userId: _accessId);
                        accountsMetadata = result;
                        _acountMetaData = result.toString();

                        setState(() {});
                      } on PlatformException catch (e) {
                        setState(() {
                          _acountMetaData = e.message;
                        });
                      }
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Get beneficiaries"),
                    onPressed: () async {
                      try {
                        var result =
                            await Dapi.getBeneficiaries(userId: _accessId);
                        _beneficiaries = result.toString();
                        _beneficiariarId = result.first?.id;
                        _beneficiariesList = result;
                        setState(() {});
                      } on PlatformException catch (e) {
                        _beneficiaries = e.message;
                        _beneficiariarId = e.message;
                        setState(() {});
                      }
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text(
                        "Create transfer for first available beneficiaries"),
                    onPressed: () async {
                      try {
                        var result = await Dapi.createTransfer(
                            userId: _accessId,
                            accountId:
                                "wsqFM5oD+etNQSXx1N2s4I4NBiOkFElBU2cxIX2Yb9CWQsTWMo/wnfqTVQhbKDui6xgP7eCx91j/N0SEQsy+6g==",
                            name: "DAPI Sandbox Account",
                             beneficiaryId: "Test",
                            remark:
                                "{ \"name\":\"John\", \"age\":30, \"car\":null }",
                            amount: 1.0,
                            iban: "GB33BAEDB20201555555893",
                            paymentId: "83515136-9146-523a-9936-3229d51fd49d");
                        // _beneficiaries = result.toString();
                        // _beneficiariarId = result.beneficiaries.first?.id;
                        _transferStatus = result.toString();
                        setState(() {});
                      } on PlatformException catch (e) {
                        setState(() {
                          _account = e.message;
                        });
                      }
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Create beneficiary "),
                    onPressed: () async {
                      var conn = connections[1]; //USER2 aTnjMu4
                      try {
                        var result = await Dapi.createBeneficiary(
                            userId: _accessId,
                            addres1: accountsMetadata.address.line1,
                            addres2: accountsMetadata.address.line2,
                            addres3: accountsMetadata.address.line3,
                            accountNumber: "1xxxxxxxxx",
                            name: "1xxxxx",
                            bankName: "1xxxx",
                            swiftCode: "1xxxx",
                            // iban: conn.subAccounts.first.iban,
                            iban: "xxxxxxxxxxxxxxxxxxxxxxxxx",
                            country: "UNITED ARAB EMIRATES",
                            branchAddress: accountsMetadata.branchAddress,
                            branchName: accountsMetadata.branchName,
                            phoneNumber: "xxxxxxxxxxx");
                      } on PlatformException catch (e) {
                        _createBeneficiariesStatus = e.message;
                      }
                      setState(() {});
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Get history "),
                    onPressed: () async {
                      await Dapi.getHistoryTransaction(userId: _accountId);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

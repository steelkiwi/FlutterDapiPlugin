import 'package:dapi/dapi_plugin.dart';
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
  String _transferStatus = 'No actions';

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.

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
                Divider(),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Open connect"),
                    onPressed: () async {
                      _accessId = await Dapi.dapiConnect();
                      setState(() {});
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Get active connection"),
                    onPressed: () async {
                      var connections = await Dapi.getActiveConnect();
                      if (connections.isNotEmpty) {
                        _activeConnection = connections.first.toString();
                        _accessId = connections.first.userID;
                      }
                      setState(() {});
                    },
                  ),
                ),
                InkWell(
                  child: FlatButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Get account"),
                    onPressed: () async {
                      try {
                        var result =
                            await Dapi.getUserAccounts(userId: _accessId);

                        if (result.isNotEmpty) {
                          _account = result.first.toString();
                          _accountId = result.first.id;
                        } else {
                          _account = "No accounts";
                        }
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
                    child: Text("Get account META DATA"),
                    onPressed: () async {
                      try {
                        var result = await Dapi.getUserAccountsMetaData(
                            userId: _accessId);

                        _acountMetaData = result.toString();

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
                    child: Text("Get beneficiaries"),
                    onPressed: () async {
                      try {
                        var result =
                            await Dapi.getBeneficiaries(userId: _accessId);
                        _beneficiaries = result.toString();
                        _beneficiariarId = result.beneficiaries.first?.id;

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
                    child: Text(
                        "Create transfer for first available beneficiaries"),
                    onPressed: () async {
                      try {
                        var result = await Dapi.createTransfer(
                            userId: _accessId,
                            accountId: _accountId,
                            beneficiaryId: _beneficiariarId,
                            amount: 1.0);
                        // _beneficiaries = result.toString();
                        // _beneficiariarId = result.beneficiaries.first?.id;

                        setState(() {});
                      } on PlatformException catch (e) {
                        setState(() {
                          _account = e.message;
                        });
                      }
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

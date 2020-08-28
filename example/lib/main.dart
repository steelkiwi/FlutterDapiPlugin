import 'package:dapi_plugin/dapi_plugin.dart';
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
        body: Container(
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
              Divider(),
              InkWell(
                child: FlatButton(
                  color: Colors.green.withOpacity(0.5),
                  child: Text("Open connect"),
                  onPressed: () async {
                    _accessId = await DapiPlugin.dapiConnect();
                    setState(() {});
                  },
                ),
              ),
              InkWell(
                child: FlatButton(
                  color: Colors.green.withOpacity(0.5),
                  child: Text("Get active connection"),
                  onPressed: () async {
                    var connections = await DapiPlugin.getActiveConnect();
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
                          await DapiPlugin.getCurrentAccount(userId: _accessId);

                      if (result.isNotEmpty) {
                        _account = result.first.toString();
                      } else {
                        _account = "No accounts";
                      }
                      setState(() {

                      });
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
    );
  }
}

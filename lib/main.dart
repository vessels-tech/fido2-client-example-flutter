import 'dart:convert';

import 'package:fido2_client/fido2_client.dart';
import 'package:flutter/material.dart';

import 'auth_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _tc = TextEditingController();
  AuthApi _api = AuthApi();
  String keyHandle;
  RegisterOptions _registerOptions;
  SigningOptions _signingOptions;

  Widget buildTextField() {
    return TextField(
      controller: _tc,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter a username',
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildTextField(),
            RaisedButton(
              child: Text('Press to login'),
              onPressed: () async {
                String username = _tc.text;
                String user = await _api.username(username);
              },
            ),
            RaisedButton(
              child: Text('Press to request registration options'),
              onPressed: () async {
                String username = _tc.text;
                _registerOptions = await _api.registerRequest(username);
                print('${_registerOptions.challenge} ${_registerOptions.username} ${_registerOptions.userId} ${_registerOptions.rpId} ${_registerOptions.rpName}');
              }
            ),
            RaisedButton(
                child: Text('Press to register credentials'),
                onPressed: () async {
                  String username = _tc.text;
                  Fido2Client f = Fido2Client();
                  f.addRegistrationResultListener((keyHandle, clientData, attestationObj) async {
                    var clientDataJSON = base64Url.decode(clientData);
                    var str = utf8.decode(clientDataJSON);
                    print(str);
                    this.keyHandle = keyHandle;
                    User u = await _api.registerResponse(username, _registerOptions.challenge, keyHandle, clientData, attestationObj); // TODO: get this response
                  });
                  f.initiateRegistrationProcess(_registerOptions.challenge, _registerOptions.userId, _registerOptions.username, _registerOptions.rpId, _registerOptions.rpName);
                }
            ),
            RaisedButton(
                child: Text('Press to request signing options'),
                onPressed: () async {
                  String username = _tc.text;
                  SigningOptions response = await _api.signingRequest(username, keyHandle);
                  _signingOptions = response;
                }
            ),
            RaisedButton(
                child: Text('Press to sign using cred'),
                onPressed: () async {
                }
            )
          ],
        ),
      ),
    );
  }
}

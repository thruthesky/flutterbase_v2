import 'package:fchat/flutterbase_v2/flutterbase.auth.service.dart';
import 'package:fchat/flutterbase_v2/flutterbase.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  FlutterbaseAuthService auth = FlutterbaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GetBuilder<FlutterbaseController>(
            id: 'auth',
            builder: (_) => _.loggedIn
                ? Column(
                    children: [
                      Text('Logged in as ${_.user.displayName}'),
                      RaisedButton(
                        child: Text('Logout'),
                        onPressed: () => FlutterbaseAuthService().logout(),
                      ),
                    ],
                  )
                : Text('Not logged in'),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: () async {
                  auth.loginWithGoogleAccount();
                  setState(() {});
                },
                child: Text('Google'),
              ),
              RaisedButton(
                onPressed: () async {
                  auth.loginWithFacebookAccount(context: context);
                  setState(() {});
                },
                child: Text('Facebook'),
              ),
              RaisedButton(
                onPressed: () async {
                  auth.loginWithGoogleAccount();
                  setState(() {});
                },
                child: Text('Kakaotalk'),
              ),
              RaisedButton(
                onPressed: () async {
                  auth.loginWithGoogleAccount();
                  setState(() {});
                },
                child: Text('Apple'),
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}

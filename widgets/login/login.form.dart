import 'package:flutterpress/services/app.service.dart';

import '../../flutterbase.auth.service.dart';
import '../../flutterbase.controller.dart';
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
            // id: 'user',
            builder: (_) => _.loggedIn
                ? Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: Image.network(
                              _.user.photoURL,
                              width: 64,
                              height: 64,
                            ).image,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(blurRadius: 7)],
                          color: Colors.white30,
                        ),
                      ),
                      SizedBox(height: 20),
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
                  try {
                    await auth.loginWithKakaotalkAccount();
                  } catch (e) {
                    print('e: $e');
                    AppService.alertError(e);
                  }
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

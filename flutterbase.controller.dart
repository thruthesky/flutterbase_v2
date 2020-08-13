import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class FlutterbaseController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// FirebaseUser
  ///
  /// - `auth.currentUser()` is `Future` function.
  /// - FirebaseUser will be updated on `onAuthStateChanged`
  ///
  /// - `user` will be `Anonymouse` if the user didn't login.
  /// - `user` must be changed by `onAuthStateChanged` only.
  ///   To handle user login.obs
  ///   When user logs out or didn't logged in, the user will login as `Anonymouse` by `onAuthStateChagned`
  FirebaseUser _user;
  FirebaseUser get user => _user;

  FlutterbaseController() {
    _initAuthChange();
  }

  int facebookAppId;
  String facebookRedirectUrl;
  setLoginForFacebook({@required int appId, @required String redirectUrl}) {
    facebookAppId = appId;
    facebookRedirectUrl = redirectUrl;
  }

  /// When user logged in, it return true.
  ///
  /// @note if the user logged in as `Anonymous`, then it return false.
  ///
  bool get loggedIn {
    return user != null && user.isAnonymous == false;
  }

  /// Return true when user didn't logged in.
  bool get notLoggedIn {
    return loggedIn == false;
  }

  _initAuthChange() async {
    _auth.onAuthStateChanged.listen(
      (FirebaseUser u) async {
        _user = u;
        if (u == null) {
          // print('EngineModel::onAuthStateChanged() user logged out');
          _auth.signInAnonymously();
        } else {
          // print('EngineModel::onAuthStateChanged() user logged in: $u');
          // print('Anonymous: ${u.isAnonymous}, ${u.email}');

          /// 실제 사용자로 로그인을 한 경우, Anonymous 는 제외
          if (loggedIn) {
            try {
              // userDocument = await profile();
              // print('userDocument: $userDocument, email: ${user.email}');
              // notify();
              // await setUserToken();
            } catch (e) {
              print('got profile error: ');
              print(e);
              // alert(e);
            }
          } else {
            print('User has logged in anonymouse');
            print('isAnonymous: ${user.isAnonymous}');

            /// 로그 아웃을 한 경우 (Anonymous 로 로그인 한 경우 포함)
            // userDocument = FlutterbaseUser();
            // notify();
          }
          update(['auth']);
        }
      },
    );
  }
}

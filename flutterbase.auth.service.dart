import 'package:fchat/flutterbase_v2/flutterbase.controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// This class handles `Firebase User Login`
class FlutterbaseAuthService {
  final FlutterbaseController _controller = Get.find();

  /// Google Account Login
  ///

  ///
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Login with Google account.
  ///
  /// @note If the user cancels, then `null` is returned
  Future<FirebaseUser> loginWithGoogleAccount() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);

      /// 파이어베이스에서 이미 로그인을 했으므로, GoogleSignIn 에서는 바로 로그아웃을 한다.
      /// GoogleSignIn 에서 로그아웃을 안하면, 다음에 로그인을 할 때, 다른 계정으로 로그인을 못한다.
      /// Logout immediately from `Google` so, the user can choose another
      /// Google account on next login.
      await _googleSignIn.signOut();
      return user;
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      throw code;
    } catch (e) {
      print('loginWithGoogleAccount::');
      print(e);
      throw e.message;
    }
  }

  /// 사용자 로그아웃을 하고 `notifyListeners()` 를 한다. `user` 는 Listeners 에서 자동 업데이트된다.
  logout() async {
    await _auth.signOut();
    _controller.update(['auth']);
  }
}

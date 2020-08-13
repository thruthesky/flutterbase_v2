import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fchat/flutterbase_v2/flutterbase.controller.dart';
import 'package:fchat/flutterbase_v2/flutterbase.defines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
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
      print(user);

      saveOrUpdateFirebaseUser(user, account: 'google');

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

  /// When user logs in, the app can save extra information of the user.
  /// - The app may ask user to input his address.
  saveOrUpdateFirebaseUser(FirebaseUser user, {String account = ''}) async {
    if (user == null) return;

    // Check is already sign up
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Update data to server if new user
      var data = {
        'email': user.email,
        'nickname': user.displayName,
        'photoUrl': user.photoUrl,
        'id': user.uid,
        'account': account
      };
      Firestore.instance.collection('users').document(user.uid).setData(data);
    }

    // SharedPreferences prefs;
    // prefs = await SharedPreferences.getInstance();
    // await prefs.setString('uid', user.uid);
    // await prefs.setString('nickname', user.displayName);
    // await prefs.setString('aboutMe', user.photoUrl);
  }

  /// Login with Facebook Account
  ///
  ///
  Future<FirebaseUser> loginWithFacebookAccount(
      {@required BuildContext context}) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CustomWebViewForFacebookLogin(
                selectedUrl:
                    'https://www.facebook.com/dialog/oauth?client_id=${_controller.facebookAppId}&redirect_uri=${_controller.facebookRedirectUrl}&response_type=token&scope=email,public_profile,',
              ),
          maintainState: true),
    );

    if (result == null) throw FAILED_ON_FACEBOOK_LOGIN;
    try {
      final facebookAuthCred =
          FacebookAuthProvider.getCredential(accessToken: result);
      final AuthResult authResult =
          await _auth.signInWithCredential(facebookAuthCred);
      saveOrUpdateFirebaseUser(authResult.user, account: 'facebook');
      print(authResult.user);

      return authResult.user;
    } catch (e) {
      throw e;
    }
  }
}

/// A Custom WebView Widget For Facebook Login
///
/// - When a user touches on the facebook login button, this webview will open
/// - Then the user inputs facebook credentials,
/// - If login sucess, then it will get the token and return it to parent.
///
/// 페이스북 로그인을 위한 커스텀 웹 뷰
///
/// - 사용자가 로그인 버튼을 클릭하면, 이 웹 뷰가 열리고,
/// - 이메일/비밀번호를 입력하고,
/// - 로그인이 성공하면, token 을 받아서, 부모 위젯으로 리턴한다.
class CustomWebViewForFacebookLogin extends StatefulWidget {
  final String selectedUrl;

  CustomWebViewForFacebookLogin({this.selectedUrl});

  @override
  _CustomWebViewForFacebookLoginState createState() =>
      _CustomWebViewForFacebookLoginState();
}

class _CustomWebViewForFacebookLoginState
    extends State<CustomWebViewForFacebookLogin> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains("#access_token")) {
        succeed(url);
      }

      if (url.contains(
          "https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied")) {
        denied();
      }
    });
  }

  denied() {
    Navigator.pop(context);
  }

  succeed(String url) {
    var params = url.split("access_token=");

    var endparam = params[1].split("&");

    /// Return the facebook login token to parent.
    Navigator.pop(context, endparam[0]);
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        url: widget.selectedUrl,
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(66, 103, 178, 1),
          title: new Text("Facebook login"),
        ));
  }
}

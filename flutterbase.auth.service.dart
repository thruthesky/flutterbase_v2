import 'package:apple_sign_in/apple_sign_in.dart';

import '../flutter_library/library.dart';
import '../flutterbase_v2/flutterbase.controller.dart';
import '../flutterbase_v2/flutterbase.defines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/all.dart' as kakao;
import 'package:kakao_flutter_sdk/auth.dart';

/// Firebase Auth Service
///
/// This class handles `Firebase User Login`.
///
///
///
class FlutterbaseAuthService {
  final FlutterbaseController _controller = Get.find();

  /// Firebase Auth
  ///

  ///
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //////////////////////////////////////////////////////////////////////////////
  ///
  ///
  /// Apple Sign in
  ///
  ///
  //////////////////////////////////////////////////////////////////////////////

  /// Determine if Apple SignIn is available.
  /// Android may not provide Apple Sign In.
  Future<bool> get appleSignInAvailable => AppleSignIn.isAvailable();

  /// Sign in with Apple
  Future<User> loginWithAppleAccount() async {
    try {
      final AuthorizationResult appleResult =
          await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (appleResult.error != null) {
        print('Got apple login error:');
        print(appleResult.error);
        throw appleResult.error;
      }

      final AuthCredential credential = OAuthProvider('apple.com').credential(
        accessToken:
            String.fromCharCodes(appleResult.credential.authorizationCode),
        idToken: String.fromCharCodes(appleResult.credential.identityToken),
      );

      UserCredential firebaseResult =
          await _auth.signInWithCredential(credential);
      User user = firebaseResult.user;

      // Optional, Update user data in Firestore
      // updateUserData(user);
      return user;
    } catch (error) {
      // print(error);
      throw (error);
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  ///
  ///
  /// Google Sign in
  ///
  ///

  //////////////////////////////////////////////////////////////////////////////
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Login with Google account.
  ///
  /// @note If the user cancels, then `null` is returned
  Future<User> loginWithGoogleAccount() async {
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

      UserCredential authResult = await _auth.signInWithCredential(credential);

      final User user = authResult.user;

      print("signed in " + user.displayName);
      print(user);

      // saveOrUpdateFirebaseUser(user);

      /// 파이어베이스에서 이미 로그인을 했으므로, GoogleSignIn 에서는 바로 로그아웃을 한다.
      /// GoogleSignIn 에서 로그아웃을 안하면, 다음에 로그인을 할 때, 다른 계정으로 로그인을 못한다.
      /// Logout immediately from `Google` so, the user can choose another
      /// Google account on next login.
      await _googleSignIn.signOut();

      return user;
    } on PlatformException catch (e) {
      await onPlatformException(e);
      // print('ecode: ${e.code}');
      // final code = e.code.toLowerCase();
      // throw code;
    } catch (e) {
      // print('loginWithGoogleAccount::');
      // print(e);
      // throw e.message;
      throw e;
    }
    return null;
  }

  /// Login with Facebook Account
  ///
  /// ```dart
  /// ```
  ///
  Future<User> loginWithFacebookAccount(
      {@required BuildContext context}) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebViewForFacebookLogin(
          selectedUrl:
              'https://www.facebook.com/dialog/oauth?client_id=${_controller.facebookAppId}&redirect_uri=${_controller.facebookRedirectUrl}&response_type=token&scope=email,public_profile,',
        ),
        maintainState: true,
      ),
    );

    if (result == null) throw FAILED_ON_FACEBOOK_LOGIN;
    try {
      final facebookAuthCred = FacebookAuthProvider.credential(result);
      final UserCredential authResult =
          await _auth.signInWithCredential(facebookAuthCred);
      print(authResult.user);
      return authResult.user;
    } on PlatformException catch (e) {
      await onPlatformException(e);
    } catch (e) {
      throw e;
      // await onCatch(e);
    }
    return null;
  }

  //////////////////////////////////////////////////////////////////////////////
  ///
  /// Kakaotalk Login
  /// 카카오톡 로그인
  ///
  ///
  Future<User> loginWithKakaotalkAccount() async {
    KakaoContext.clientId = _controller.kakaotalkClientId;
    KakaoContext.javascriptClientId = _controller.kakaotalkJavascriptClientId;

    /// 카카오톡 로그인을 경우, 상황에 따라 메일 주소가 없을 수 있다. 메일 주소가 필수 항목이 아닌 경우,
    /// 따라서, id 로 메일 주소를 만들어서, 자동 회원 가입을 한다.
    ///
    try {
      /// 카카오톡 앱이 핸드폰에 설치되었는가?
      /// See if kakaotalk is installed on the phone.
      final installed = await isKakaoTalkInstalled();

      /// login with kakaotalk.
      /// - If Kakotalk app is installed, then login with the Kakaotalk App.
      /// - Otherwise, login with webview.
      /// 카카오톡 앱이 설치 되었으면, 앱으로 로그인, 아니면 OAuth 로 로그인.
      final authCode = installed
          ? await AuthCodeClient.instance.requestWithTalk()
          : await AuthCodeClient.instance.request();

      AccessTokenResponse token =
          await AuthApi.instance.issueAccessToken(authCode);

      /// Store access token in AccessTokenStore for future API requests.
      /// 이걸 해야지, 아래에서 UserApi.instance.me() 와 같이 호출을 할 수 있나??
      AccessTokenStore.instance.toStore(token);

      ////
      String refreshedToken = token.refreshToken;
      print('----> refreshedToken: $refreshedToken');

      /// Get Kakaotalk user info
      kakao.User user = await kakao.UserApi.instance.me();
      print(user.properties);
      Map<String, String> data = {
        'email': 'kakaotalk${user.id}@kakao.com',
        'password': 'Settings.secretKey+${user.id}',
        'displayName': user.properties['nickname'],
        'photoUrl': user.properties['profile_image'],
      };

      print('----> kakaotalk login success: $data');

      /// login or register.
      return loginOrRegister(data);
      // _controller.update(['user']);

    } on KakaoAuthException catch (e) {
      throw e;
    } on KakaoClientException catch (e) {
      throw e;
    } catch (e) {
      /// 카카오톡 로그인에서 에러가 발생하는 경우,
      /// 에러 메시지가 로그인 창에 표시가 되므로, 상단 위젯에서는 에러를 무시를 해도 된다.
      /// 예를 들어, 비밀번호 오류나, 로그인 취소 등.
      print('error: =====> ');
      print(e);
      throw e;
    }
  }

  /// 사용자 로그아웃을 하고 `notifyListeners()` 를 한다. `user` 는 Listeners 에서 자동 업데이트된다.
  logout() async {
    _controller.logout();

    // await _auth.signOut();
    // _controller.update(['auth']);
  }

  /// Logs in with Email/Password into Firebase Auth.
  /// 로그인을 한다.
  ///
  /// @return FirebaseUser
  ///
  ///
  /// `Firebase Auth` 에 직접 로그인을 한다.
  /// 에러가 있으면 에러를 throw 하고,
  /// 로그인이 성공하면 `notifiyListeners()`를 한 다음, `FirebaseUser` 객체를 리턴한다.
  ///
  /// 주의 할 것은
  /// - `user` 변수는 이 함수에서 직접 업데이트 하지 않고 `onAuthStateChanged()`에서 자동 감지를 해서 업데이트 한다.
  ///
  ///
  Future<User> login(String email, String password) async {
    if (email == null || email == '') throw INPUT_EMAIL;
    if (password == null || password == '') throw INPUT_PASSWORD;
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  /// Registers with Email/Password into Firebase.
  /// 회원 가입을 한다.
  ///
  /// `users` collection 에 비밀번호는 저장하지 않는다.
  Future<User> register(Map<String, dynamic> data) async {
    if (data == null) throw INVALID_PARAMETER;
    if (isEmpty(data['email'])) throw EMAIL_IS_EMPTY;
    if (isEmpty(data['password'])) throw PASSWORD_IS_EMPTY;
    if (isEmpty(data['displayName'])) throw DISPLAYNAME_IS_EMPTY;

    UserCredential re = await _auth.createUserWithEmailAndPassword(
      email: data['email'],
      password: data['password'],
    );

    if (re == null || re.user == null) throw FAILED_TO_REGISTER;

    _controller.user = re.user;
    data.remove('password');

    data.remove('email');
    data.remove('password');
    data['uid'] = re.user.uid;

    return await profileUpdate(data);

    // data['uid'] = re.user.uid;
    // await _userDoc(user.uid).setData(data);
  }

  /// 사용자 정보 업데이트
  ///
  /// `Firebase Auth` 에도 등록하고, `Firestore users` Collection 에도 등록한다.
  ///
  /// @warning The user must log in before calling the method.
  ///
  Future<User> profileUpdate(Map<String, dynamic> data) async {
    /// 이메일 변경 불가
    if (data['email'] != null) throw EMAIL_CANNOT_BY_CHANGED;

    /// null 값이 저장되면 안된다.
    if (data.containsKey('email')) data.remove('email');

    /// 닉네임, 사진은 `Firebase Auth` 에 업데이트
    if (data['displayName'] != null || data['photoUrl'] != null) {
      await _controller.user.updateProfile(
        displayName: data['displayName'] ?? '',
        photoURL: data['photoUrl'] ?? '',
      );

      /// Reload updated user information.
      /// Firebase Auth 정보 갱신
      await _controller.user.reload();
      _controller.user = _auth.currentUser;

      print('profileUpdate success');
    }

    /// 사용자 도큐먼트 정보 업데이트
    // await _userDoc(user.uid).setData(data, merge: true);

    /// 사용자 도큐먼트 정보 갱신
    // userDocument = await profile();

    return _controller.user;
  }

  /// Display `ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL` in snackbar.
  /// Other errors will be thrown to parent.
  onPlatformException(e) async {
    print('onPlatformException():');
    print(e.code);
    if (e.code == ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL) {
      Get.snackbar('중복 소셜 로그인',
          '동일한 메일 주소의 다른 소셜 아이디로 이미 로그인되어져 있습니다. 다른 소셜아이디로 로그인을 하세요.',
          duration: Duration(seconds: 10));
    }
    print(e);
    throw e;
  }

  // onCatch(e) async {
  //   throw e;
  // }

  /// 회원 로그인을 먼저 시도하고, 가입이 되어져 있지 않으면 가입을 한다.
  ///
  ///
  /// - 먼저, 로그인을 한다.
  /// - 만약, 로그인이 안되면, 회원 가입을 한다.
  /// - 회원 정보를 업데이트한다.
  Future<User> loginOrRegister(Map<String, String> data) async {
    print('data: $data');

    try {
      await login(data['email'], data['password']);
      print('loggedIn!');
      data.remove('email');
      data.remove('password');

      // print('Going to update profile');
      return await profileUpdate(data);
    } on PlatformException catch (e) {
      if (e.code == ERROR_USER_NOT_FOUND) {
        /// Not regisgtered? then register
        print('Not registered. Going to register');
        return await register(data);
      } else {
        await onPlatformException(e);
      }
    } catch (e) {
      throw (e);
      // await onCatch(e);
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

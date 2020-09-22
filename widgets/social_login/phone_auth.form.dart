import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpress/flutterbase_v2/flutterbase.auth.service.dart';
import 'package:flutterpress/flutterbase_v2/widgets/social_login/country_code_select.dart';

class PhoneAuthForm extends StatefulWidget {
  final Function onVerified;
  final Function onError;

  PhoneAuthForm({this.onVerified(String phoneNo), this.onError(dynamic error)});

  @override
  _PhoneAuthFormState createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  final FlutterbaseAuthService _auth = FlutterbaseAuthService();

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _phoneController = TextEditingController();

  bool isCodeSent = false;
  String verificationID;

  String code = '+82';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select country code'),
              CountryCodeSelect(
                enabled: !isCodeSent,
                initialSelection: code,
                onChanged: (_) {
                  code = _.dialCode;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                readOnly: isCodeSent,
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Mobile number'),
              ),
              SizedBox(height: isCodeSent ? 20 : 10),
              if (isCodeSent)
                TextFormField(
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  controller: _codeController,
                  decoration: InputDecoration(labelText: 'Verification Code'),
                ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    isCodeSent ? 'Verify Code' : 'Send Code',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  color: Colors.blueAccent,
                  onPressed: isCodeSent
                      ? () => verifyCode(verificationID, _codeController.text)
                      : () =>
                          verifyPhoneNumber('$code${_phoneController.text}'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  verifyCode(String verificationID, String code) async {
    AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: code,
    );

    print('credential');
    print(credential);
    linkPhoneAuthCredentials(credential);
  }

  linkPhoneAuthCredentials(AuthCredential credential) async {
    try {
      UserCredential authResult = await _auth.linkCredential(credential);
      print('verify::authResult ===>');
      print(authResult);
      widget.onVerified(authResult.user.phoneNumber);
    } catch (e) {
      print('verify Error');
      widget.onError(e);
    }
  }

  verifyPhoneNumber(String phoneNumber) {
    print('phoneNumber');
    print(phoneNumber);

    _fbAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      /// this will only be called after the automatic code retrieval is performed.
      /// some phone may have the automatic code retrieval. some may not.
      verificationCompleted: (PhoneAuthCredential credential) async {
        print(
          'automatic verification code retrieval from received sms happened!',
        );
        print('credential :');
        print(credential);
        linkPhoneAuthCredentials(credential);
      },

      /// called whenever error happens
      verificationFailed: (FirebaseAuthException e) {
        print('verificationFailed');
        print(e);
        widget.onError(e);
      },

      /// called after the user submitted the phone number.
      codeSent: (String verId, [int forceResend]) {
        print('codesent!!');
        print('verification ID: $verId');
        print('forceSend: $forceResend');

        verificationID = verId;
        setState(() {
          isCodeSent = true;
        });
      },

      codeAutoRetrievalTimeout: (String verID) {
        print('codeAutoRetrievalTimeout');
        print('$verID');
        verificationID = verID;
      },
    );
  }
}

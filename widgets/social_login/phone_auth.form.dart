import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpress/flutterbase_v2/flutterbase.auth.service.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneAuthForm extends StatefulWidget {
  final Function onVerified;

  PhoneAuthForm({this.onVerified(String phoneNo)});

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
            children: [
              Row(
                children: [
                  CountryCodePicker(
                    onChanged: (_) {
                      code = _.dialCode;
                      print(code);
                    },
                    initialSelection: code,
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      readOnly: isCodeSent,
                      controller: _phoneController,
                      decoration:
                          InputDecoration(labelText: 'Input phone number'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isCodeSent ? 20 : 10),
              if (isCodeSent)
                TextFormField(
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  controller: _codeController,
                  decoration: InputDecoration(labelText: 'Verification Code'),
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red[500]),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text(
                      isCodeSent ? 'Verify' : 'Submit',
                      style: TextStyle(color: Colors.green[500]),
                    ),
                    onPressed: isCodeSent
                        ? () => verifyCode(verificationID, _codeController.text)
                        : () =>
                            verifyPhoneNumber('$code${_phoneController.text}'),
                  )
                ],
              )
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

    try {
      UserCredential authResult = await _auth.linkCredential(credential);
      print('verify::authResult ===>');
      print(authResult);
      widget.onVerified(authResult.user.phoneNumber);
    } catch (e) {
      print('verify Error');
      print(e);
    }
  }

  verifyPhoneNumber(String phoneNumber) {
    print('phoneNumber');
    print(phoneNumber);

    _fbAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      /// called after the verification process is complete
      verificationCompleted: (PhoneAuthCredential credential) async {
        print(
          'automatic verification code retrieval from received sms happened!',
        );
        print('credential :');
        print(credential);
      },

      /// called whenever error happens
      verificationFailed: (FirebaseAuthException e) {
        print('verificationFailed');
        print(e);
        // onError(e);
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

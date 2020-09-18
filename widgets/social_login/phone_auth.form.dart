import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpress/flutterbase_v2/flutterbase.auth.service.dart';
import 'package:get/get.dart';

class PhoneAuthForm extends StatefulWidget {
  final String phoneNo;
  final Function onVerified;

  PhoneAuthForm({@required this.phoneNo, this.onVerified()});

  @override
  _PhoneAuthFormState createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  final FlutterbaseAuthService _auth = FlutterbaseAuthService();

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool isCodeSent = false;
  String verificationID;

  @override
  void initState() {
    verifyPhoneNumber(widget.phoneNo);
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
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '${widget.phoneNo}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // TextFormField(
              //   readOnly: isCodeSent,
              //   controller: _phoneController,
              //   decoration: InputDecoration(
              //     labelText: 'Input phone number',
              //   ),
              // ),
              SizedBox(height: isCodeSent ? 10 : 0),
              if (isCodeSent)
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(labelText: 'Input Code (OTP)'),
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
                        : null,
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
      widget.onVerified();
    } catch (e) {
      print('verify Error');
      print(e);
    }
  }

  verifyPhoneNumber(String phoneNumber) {
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

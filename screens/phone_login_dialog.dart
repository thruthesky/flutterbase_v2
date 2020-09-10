import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneLoginDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Login with Phone number'),
      content: Container(
        child: PhoneLoginForm(),
      ),
    );
  }
}

class PhoneLoginForm extends StatefulWidget {
  @override
  _PhoneLoginFormState createState() => _PhoneLoginFormState();
}

class _PhoneLoginFormState extends State<PhoneLoginForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  bool isCodeSent = false;
  String verificationID;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: isCodeSent,
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Input phone number',
                ),
              ),
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
                      onPressed: () {
                        isCodeSent
                            ? signInWithOTP(
                                verificationID,
                                _codeController.text,
                              )
                            : loginWithPhoneNumber(_phoneController.text);
                      })
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  onError(FirebaseAuthException error) {
    Get.snackbar(
      error.code.toString(),
      error.message,
      backgroundColor: Colors.red[400],
    );
  }

  signIn(AuthCredential credential) async {
    try {
      UserCredential authResult = await _auth.signInWithCredential(credential);
      Get.back(result: authResult.user);
    } catch (e) {
      onError(e);
    }
  }

  signInWithOTP(String verificationID, String code) {
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: code);
    signIn(credential);
  }

  Future<void> loginWithPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      /// called after the verification process is complete
      verificationCompleted: (PhoneAuthCredential credential) async {
        signIn(credential);
      },

      /// called whenever error happens
      verificationFailed: (FirebaseAuthException e) {
        onError(e);
      },

      /// called after the user submitted the phone number.
      codeSent: (String verId, [int forceResend]) {
        verificationID = verId;
        setState(() {
          isCodeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verID) {
        verificationID = verID;
      },
    );
  }
}

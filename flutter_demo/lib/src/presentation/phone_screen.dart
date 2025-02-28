import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namer_app/core/router/router.dart';
import 'package:namer_app/src/presentation/otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String verificationId = '';

  FirebaseAuth auth = FirebaseAuth.instance;

  // Step 1: Request OTP
  void sendOTP() async {
    print('I was here');
    try {
      print('I was here 2');
      await auth.verifyPhoneNumber(
        phoneNumber: "+919090909090", // Ensure correct E.164 format
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          print("User signed in automatically.");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.message} ${e.code}");
          if (e.code == 'invalid-phone-number') {
            print("The phone number entered is invalid.");
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => OTPScreen(navigateToHome: true)));
          // setState(() {
          //   this.verificationId = verificationId;
          // });
          // context.push(RoutePaths.otpScreen);
          print("OTP sent successfully. $verificationId");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
      print('I was here 4');
    } catch (e) {
      print('I was here 3');
      print("Error sending OTP: $e");
    }
  }

  // Step 2: Verify OTP
  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpController.text,
    );

    try {
      await auth.signInWithCredential(credential);
      print("User signed in successfully.");
    } catch (e) {
      print("Failed to sign in: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Firebase OTP Authentication")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Enter Phone Number"),
              ),
              ElevatedButton(
                onPressed: sendOTP,
                child: Text("Send OTP"),
              ),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Enter OTP"),
              ),
              ElevatedButton(
                onPressed: verifyOTP,
                child: Text("Verify OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

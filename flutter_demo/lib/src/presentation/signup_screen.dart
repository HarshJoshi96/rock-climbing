import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:namer_app/src/presentation/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signature_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  String? signatureImage;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = mobileController.text.trim();
      String email = emailController.text.trim();
      String fullName = fullNameController.text.trim();

      if (phoneNumber.isEmpty) {
        showAlert("Please enter a phone number.");
        return;
      }

      String updatedNumber = '91$phoneNumber';

      // Check if the user already exists
      var userDoc =
          await _firestore.collection("users").doc(updatedNumber).get();

      if (userDoc.exists) {
        showAlert("This phone number is already registered.");
      } else {
        // Add new user with phone number as document ID
        await _firestore.collection("users").doc(updatedNumber).set({
          "name": fullName,
          "email": email
          // "createdAt": FieldValue.serverTimestamp(),
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('phoneNumber', updatedNumber);
        showAlert("User registered successfully!", isRegistered: true);
      }
      // checkAndAddUser;
      // if (_formKey.currentState!.validate()) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Signup successful!")),
      //   );
      // }
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkAndAddUser() async {
    String phoneNumber = mobileController.text.trim();

    if (phoneNumber.isEmpty) {
      showAlert("Please enter a phone number.");
      return;
    }

    // Check if the user already exists
    var userDoc = await _firestore.collection("users").doc(phoneNumber).get();

    if (userDoc.exists) {
      showAlert("This phone number is already registered.");
    } else {
      // Add new user with phone number as document ID
      await _firestore.collection("users").doc(phoneNumber).set({
        "phone": phoneNumber,
        "createdAt": FieldValue.serverTimestamp(),
      });

      showAlert("User registered successfully!", isRegistered: true);
    }
  }

  void showAlert(String message, {bool isRegistered = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert", style: TextStyle(fontFamily: 'Nunito')),
          content: Text(message, style: TextStyle(fontFamily: 'Nunito')),
          actions: [
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(ColorPalette.primaryColor)),
              onPressed: () async => {
                if (isRegistered)
                  {
                    await prefs.setBool('isLoggedIn', true),
                    context.pop(context),
                    context.pop(context),
                  },
                context.pop(context)
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontFamily: 'Nunito'),
              ),
            ),
          ],
        );
      },
    );
  }

  Uint8List? _signatureImage;
  Future<void> _navigateToSignatureScreen() async {
    final Uint8List? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignatureScreen(testString: '')),
    );

    if (result != null) {
      setState(() {
        _signatureImage = result;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
        cursorColor: ColorPalette.primaryColor,
        decoration: InputDecoration(
          fillColor: Colors.white,
          labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Nunito',
              color: Colors.black),
          labelText: label,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey, width: 1.0)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: Colors.grey,
                width: 1.0), // Border when field is not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: ColorPalette.primaryColor,
                width: 1.0), // Border when field is focused
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: Colors.red, width: 2.0), // Border when there's an error
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: Colors.red,
                width: 1.0), // Border when focused with an error
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (!isOptional && value!.isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Sign up"),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: "Nunito-Bold",
            fontSize: 15,
            fontWeight: FontWeight.bold),
        backgroundColor: ColorPalette.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                  label: "Full Name", controller: fullNameController),
              CustomTextField(
                labelText: "Mobile",
                hintText: "Enter mobile number ",
                controller: mobileController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                prefix: "+91-",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter mobile number";
                  }
                  if (!RegExp(
                    r"^(\d{10}|\w+@\w+\.\w{2,3})$",
                  ).hasMatch(value)) {
                    return "Enter a valid mobile number or email";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              _buildTextField(
                  label: "Email Address (Optional)",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  isOptional: true),
              _buildTextField(
                  label: "Referral Code (Optional)",
                  controller: referralCodeController,
                  isOptional: true),
              SizedBox(height: 20),
              Text("Digital Signature",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Colors.black)),
              SizedBox(height: 10),
              _signatureImage != null
                  ? Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.memory(
                        _signatureImage!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : GestureDetector(
                      onTap: _navigateToSignatureScreen,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Tap to capture signature",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 30),
              _signatureImage != null
                  ? ElevatedButton(
                      onPressed: _navigateToSignatureScreen,
                      child: Text(
                        "Edit Signature",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Nunito',
                            fontSize: 10),
                      ),
                    )
                  : SizedBox(height: 0),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:namer_app/core/colors/colors.dart';
// import 'package:namer_app/core/router/router.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();

//   TextEditingController mobileOrEmailController = TextEditingController();

//   Future<void> _login(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', true);
//     // Go back after login
//     context.pop(RoutePaths.activityDetails);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: Colors.white,
//         title: Text("Login"),
//         titleTextStyle: TextStyle(
//             color: Colors.white,
//             fontFamily: "Nunito-Bold",
//             fontSize: 15,
//             fontWeight: FontWeight.bold),
//         backgroundColor: ColorPalette.primaryColor,
//       ),
//       body: Container(
//         color: Colors.white,
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: mobileOrEmailController,
//                   style: TextStyle(
//                     fontFamily: "Nunito",
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                   cursorErrorColor: Colors.red,
//                   cursorColor: Colors.black,
//                   decoration: InputDecoration(
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black,
//                           width: 2.0), // Default bottom line color
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black,
//                           width: 2.0), // Bottom line color when focused
//                     ),
//                     errorBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black,
//                           width: 2.0), // Bottom line color on error
//                     ),
//                     focusedErrorBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black,
//                           width:
//                               2.0), // Bottom line color when focused with error
//                     ),
//                     labelText: "Mobile Number or Email",
//                     errorStyle: TextStyle(color: Colors.red),
//                     labelStyle: TextStyle(
//                       fontFamily: "Nunito",
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                   ),
//                   keyboardType: TextInputType.text,
//                   validator: (value) {
//                     if (value!.isEmpty)
//                       return "Please enter mobile number or email";
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 100),
//                 ElevatedButton(
//                   onPressed: () => _login(context),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: Size(double.infinity, 50),
//                     backgroundColor: ColorPalette.primaryColor,
//                   ),
//                   child: Text("LOGIN",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontFamily: 'Nunito',
//                           fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:namer_app/core/router/router.dart';
import 'package:namer_app/src/presentation/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mobileOrEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      var userDoc = await _firestore
          .collection("users")
          .doc('91${mobileOrEmailController.text.trim()}')
          .get();
      if (userDoc.exists) {
        context.push(RoutePaths.otpScreen, extra: false);
      } else {
        showAlert("This phone number is not registered.");
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: "Nunito-Bold",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: ColorPalette.primaryColor,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                CustomTextField(
                  labelText: "Mobile",
                  hintText: "Enter mobile number ",
                  controller: mobileOrEmailController,
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
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Nunito-Bold',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final String? prefix;

  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField(
      {super.key,
      required this.labelText,
      this.hintText,
      required this.controller,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.isPassword = false,
      this.prefix,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: validator,
      inputFormatters: inputFormatters,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixText: prefix,
        prefixStyle: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito',
          color: Colors.black,
        ),
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
    );
  }
}

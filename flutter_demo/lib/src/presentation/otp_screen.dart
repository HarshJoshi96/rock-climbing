import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:namer_app/core/router/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final bool navigateToHome;

  const OTPScreen({super.key, required this.navigateToHome});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // Create a controller for each input field
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  // Define the correct OTP for verification
  final String correctOTP = "1234";

  // Function to verify the entered OTP
  void _verifyOTP() async {
    String enteredOTP =
        _controllers.map((controller) => controller.text).join();
    if (enteredOTP == correctOTP) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("OTP Verified Successfully!"),
        backgroundColor: Colors.green,
      ));
      if (widget.navigateToHome) {
        context.push(RoutePaths.home);
      } else {
        Navigator.popUntil(context,
            (route) => route.settings.name == RoutePaths.activityDetails);
      }
      // Navigate to next screen here
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("OTP Verification",
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Nunito-Bold',
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: ColorPalette.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            const Text(
              "Enter the 4-digit OTP sent to your mobile number",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 60, // Width of each input box
                  height: 60, // Height of each input box
                  child: TextField(
                    controller: _controllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1, // Only allow a single character
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: "", // Hide counter below the input box
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      // Move focus to the next field
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                      // Move focus to the previous field if backspace is pressed
                      if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _verifyOTP,
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, 50), // Full-width button
                backgroundColor: ColorPalette.primaryColor,
              ),
              child: const Text(
                "VERIFY OTP",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Nunito'),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Handle resend OTP logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("OTP Resent", textAlign: TextAlign.center),
                    backgroundColor: ColorPalette.primaryColor,
                  ),
                );
              },
              child: const Text(
                "Resend OTP",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:namer_app/core/colors/colors.dart';

class PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        title: Text(
          'Payment Successful',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito-Bold',
              fontSize: 16),
        ),
        backgroundColor: ColorPalette.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: ColorPalette.primaryColor,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Your booking has been confirmed.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Pop two screens off the navigation stack
                Navigator.popUntil(
                    context, (route) => route.settings.name == '/');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor),
              child: Text('Okay',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito-Bold',
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

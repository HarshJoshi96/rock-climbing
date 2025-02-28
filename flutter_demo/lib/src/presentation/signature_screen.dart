import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatelessWidget {
  final String testString;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5.0,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  SignatureScreen({super.key, required this.testString});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Signature"),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: "Nunito-Bold",
            fontSize: 15,
            fontWeight: FontWeight.bold),
        backgroundColor: ColorPalette.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Text("Please sign in below box",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito')),
            Signature(
              controller: _controller,
              height: 450,
              backgroundColor: Colors.grey,
            ),
            // SizedBox(height: 50),s
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _controller.clear();
                  },
                  child: Text('Clear', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final signature = await _controller.toPngBytes();
                    // Handle signature (save, share, etc.)
                    if (signature != null) {
                      // Convert Uint8List to Base64 string
                      context.pop(signature);
                      String base64String = base64Encode(signature);
                      print("BASE64 ==== $base64String");
                    } else {
                      throw Exception("Signature bytes are null");
                    }
                    print(" signature === $signature");
                  },
                  child: Text('Save Signature',
                      style: TextStyle(color: ColorPalette.primaryColor)),
                ),
              ],
            ),
            SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}

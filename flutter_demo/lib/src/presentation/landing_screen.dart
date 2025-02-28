// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:namer_app/core/colors/colors.dart';
// import 'package:namer_app/core/router/router.dart';

// class LandingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.white,
//       ),
//       body: Container(
//         color: Colors.white,
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // App Logo
//                 Image.asset(
//                   'assets/images/climbing.jpg', // Add your logo image in assets folder
//                   height: 120,
//                 ),
//                 SizedBox(height: 40),

//                 // Signup Button
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: Size(double.infinity, 50),
//                     backgroundColor: ColorPalette.primaryColor,
//                   ),
//                   onPressed: () {
//                     context.push(RoutePaths.signupScreen);
//                   },
//                   child: Text("SIGN UP",
//                       style: TextStyle(
//                           fontFamily: 'Nunito-Bold',
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold)),
//                 ),

//                 SizedBox(height: 20),

//                 // Already have an account? Login
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Already have an account? ",
//                         style: TextStyle(
//                             color: Colors.black,
//                             fontFamily: 'Nunito-Bold',
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold)),
//                     TextButton(
//                       onPressed: () {
//                         context.push(RoutePaths.loginScreen);
//                       },
//                       child: Text("Login",
//                           style: TextStyle(
//                               color: ColorPalette.primaryColor,
//                               fontFamily: 'Nunito-Bold',
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:namer_app/core/router/router.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with reduced opacity
          Opacity(
            opacity: 0.3, // Adjust the opacity value as needed
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/bgImge.jpg'), // Your background image
                  fit: BoxFit.cover, // Adjust the fit to fill the screen
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 50, left: 10),
                child: TextButton(
                  onPressed: () {
                    // context.go(RoutePaths.home);
                    Navigator.of(context).pop();

                    // context.pop(RoutePaths.home);
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(
                      color: ColorPalette.primaryColor,
                      fontFamily: 'Nunito-Bold',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
          // Foreground content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  // Image.asset(
                  //   'assets/images/climbing.jpg', // Add your logo image in the assets folder
                  //   height: 120,
                  // ),
                  SizedBox(height: 500),

                  // Signup Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: ColorPalette.primaryColor,
                    ),
                    onPressed: () {
                      context.push(RoutePaths.signupScreen);
                    },
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontFamily: 'Nunito-Bold',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Nunito-Bold',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(RoutePaths.loginScreen);
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: ColorPalette.primaryColor,
                            fontFamily: 'Nunito-Bold',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

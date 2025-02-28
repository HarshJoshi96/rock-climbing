import 'package:flutter/material.dart';
import 'package:namer_app/core/colors/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.teal[50],
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/user.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: ColorPalette.primaryColor,
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            profileCard('Demo User', Icons.person),
            profileCard('+91 90909 90909', Icons.phone),
            profileCard('demo.user@gmail.com', Icons.email),
          ],
        ),
      ),
    );
  }

  Widget profileCard(String text, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: ColorPalette.primaryColor),
        title: Text(text, style: TextStyle(fontSize: 14, fontFamily: 'Nunito')),
      ),
    );
  }
}

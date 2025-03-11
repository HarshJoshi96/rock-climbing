import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Demo User";
  String phoneNumber = "+91 90909 90909";
  String email = "demo.user@gmail.com";
  String profileImage = 'assets/images/user.png'; // Default profile image
  bool isLoading = true; // Show loader until data is fetched

  @override
  void initState() {
    super.initState();
    updateProfilePicture();
  }

  void updateProfilePicture() async {
    // Logic to update profile picture (e.g., using ImagePicker)

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phoneNumber') ?? '';
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (phone == null || phone.isEmpty) {
      print("Error: Phone number cannot be empty.");
      return;
    }
    print(phone);
    DocumentReference userRef = firestore.collection("users").doc('91$phone');

    try {
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        setState(() {
          if (userData != null && userData.containsKey("name")) {
            userName = userData["name"];
            phoneNumber = '+91 $phone';
            email = userData["email"] ?? '';
            isLoading = false;
          } else {
            isLoading = false;
            print("Profile image field is missing.");
          }
        });
        if (userData != null && userData.containsKey("name")) {
          String username = userData["name"];
          print("Username: $username");
        } else {
          print("Username field is missing.");
        }
      } else {
        print("No user found with this phone number.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String phone = prefs.getString('phoneNumber') ?? '';
    // String user = prefs.getString('userName') ?? '';
    // setState(() {
    //   phoneNumber = '+91 $phone';
    //   userName = user;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: ColorPalette.primaryColor,
              ))
            : Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(profileImage),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap:
                                updateProfilePicture, // Trigger profile update
                            child: CircleAvatar(
                              backgroundColor: ColorPalette.primaryColor,
                              child:
                                  const Icon(Icons.edit, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  profileCard(userName, Icons.person),
                  profileCard(phoneNumber, Icons.phone),
                  profileCard(email, Icons.email),
                ],
              ),
      ),
    );
  }

  Widget profileCard(String text, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: ColorPalette.primaryColor),
        title: Text(text,
            style: const TextStyle(fontSize: 14, fontFamily: 'Nunito')),
      ),
    );
  }
}

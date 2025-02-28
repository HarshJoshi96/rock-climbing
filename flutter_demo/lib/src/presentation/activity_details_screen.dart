import 'package:flutter/material.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:namer_app/src/data/models/activity_data.dart';
import 'package:namer_app/src/presentation/booking_screen.dart';
import 'package:namer_app/src/presentation/details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class ActivityDetailsScreen extends StatelessWidget {
  const ActivityDetailsScreen({super.key, required this.activityData});
  final ActivityData activityData;
  final double latitude = 37.7749; // Example latitude (San Francisco)
  final double longitude = -122.4194; // Example longitude

  Future<void> _openGoogleMaps() async {
    String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&destination=${activityData.latitude},${activityData.longitude}";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw "Could not open Google Maps.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text('Activity Details'),
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: "Nunito-Bold",
              fontSize: 15,
              fontWeight: FontWeight.bold),
          backgroundColor: ColorPalette.primaryColor,
        ),
        body: Column(
          children: [
            Expanded(
                child: Stack(
              children: [
                Container(
                  // color: Colors.black,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/background1.jpg"),
                          fit: BoxFit.cover),
                      color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10, sigmaY: 10), // Blur effect
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  activityData.name ?? "",
                                  style: TextStyle(
                                    color: ColorPalette.primaryColor,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Nunito-bold",
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  activityData.placeName ?? "",
                                  style: TextStyle(
                                      color: ColorPalette.primaryColor,
                                      fontSize: 12,
                                      fontFamily: "Nunito"),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.directions),
                              style: ButtonStyle(
                                textStyle:
                                    WidgetStateProperty.resolveWith<TextStyle?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Nunito");
                                    }
                                    if (states.contains(WidgetState.hovered)) {
                                      return TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Nunito");
                                    }
                                    return TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Nunito");
                                  },
                                ),
                              ),
                              onPressed: _openGoogleMaps,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: ColorPalette.primaryColor,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                      // TextStyle(
                      //     color: Colors.black,
                      //     fontFamily: 'Nunito-Bold',
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.bold),
                      tabs: <Widget>[
                        Tab(
                          text: "BOOK A SLOT",
                        ),
                        Tab(
                          text: "DETAILS",
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          BookingStepsScreen(activityData: activityData),
                          DetailsScreen(
                              activityDetailText: activityData.details ?? ""),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// bottom: 





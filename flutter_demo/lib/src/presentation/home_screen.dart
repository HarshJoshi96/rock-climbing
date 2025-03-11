import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:namer_app/core/router/router.dart';
import 'package:namer_app/src/data/models/activity_data.dart';
import 'package:namer_app/src/presentation/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [HomeScreenContent(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // This hides the back button

        backgroundColor: ColorPalette.primaryColor,
        title: Text(
          _getTitle(_selectedIndex),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito-Bold',
          ),
        ),
      ),
      body: _screens[_selectedIndex], // Switch between screens
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          // BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: ColorPalette.primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Activities';
      case 1:
        return 'Profile';
      default:
        return 'App';
    }
  }
}

class HomeScreenContent extends StatelessWidget {
  List<AssetImage> imagesArray = [
    AssetImage('assets/images/bg2.jpg'),
    AssetImage('assets/images/background1.jpg'),
  ];

  List<String> titleArray = [
    'Climb City',
    'Boulder Box',
  ];

  List<String> locationArray = [
    'Delhi, India',
    'Delhi, India',
  ];

  List<String> priceArray = [
    '₹1200 onwards',
    '₹900 onwards',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection("activities").snapshots(),
          builder: (context, activitiesSnapshot) {
            if (activitiesSnapshot.connectionState == ConnectionState.active) {
              if (activitiesSnapshot.hasData) {
                return ListView.builder(
                  itemCount: activitiesSnapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    var activity = ActivityData.fromJson(
                        activitiesSnapshot.data?.docs[index].data() ?? {});
                    return ActivityCard(
                      imageUrl:
                          activity.url ?? 'https://via.placeholder.com/300',
                      title: activity.name ?? 'No Name',
                      location: activity.placeName ?? 'Unknown Location',
                      price: activity.price ?? 'N/A',
                      onTap: () {
                        context.push(RoutePaths.activityDetails,
                            extra: activity);
                        print("Tapped on ${activity.name}");
                      },
                    );
                  },
                );

                // return ListView.builder(
                //   padding: const EdgeInsets.all(10),
                //   itemCount: activitiesSnapshot.data?.docs.length ?? 0,
                //   itemBuilder: (context, index) {
                //     final currentActivityData = ActivityData.fromJson(
                //         activitiesSnapshot.data?.docs[index].data() ?? {});
                //     return Padding(
                //       padding: const EdgeInsets.only(bottom: 20),
                //       child: SizedBox(
                //         height: MediaQuery.sizeOf(context).height * 0.5,
                //         child: Container(
                //             decoration: BoxDecoration(
                //               boxShadow: [
                //                 BoxShadow(
                //                   color: Colors.black.withOpacity(0.5),
                //                   spreadRadius: 2,
                //                   blurRadius: 7,
                //                   offset: const Offset(0, 3),
                //                 )
                //               ],
                //               image: DecorationImage(
                //                 opacity: 0.75,
                //                 image: imagesArray[1],
                //                 fit: BoxFit.cover,
                //               ),
                //               borderRadius: BorderRadius.circular(10),
                //               // color: ColorPalette.primaryColor,
                //             ),
                //             child: ListTile(
                //               title: Padding(
                //                 padding:
                //                     const EdgeInsets.symmetric(vertical: 15.0),
                //                 child: Column(
                //                   mainAxisAlignment: MainAxisAlignment.end,
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: [
                //                     SizedBox(
                //                       height: 10,
                //                     ),
                //                     Text(
                //                       currentActivityData.name ?? "",
                //                       style: TextStyle(
                //                         fontSize: 27,
                //                         fontFamily: 'Nunito',
                //                         fontWeight: FontWeight.bold,
                //                         color: Colors.white,
                //                         shadows: [
                //                           Shadow(
                //                             blurRadius: 2.0,
                //                             color: ColorPalette.primaryColor,
                //                             offset: Offset(1.0, 2.0),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 0,
                //                     ),
                //                     Text(
                //                       currentActivityData.placeName ?? "",
                //                       style: TextStyle(
                //                         fontSize: 17,
                //                         fontFamily: 'Nunito',
                //                         color: Colors.white,
                //                         shadows: [
                //                           Shadow(
                //                             blurRadius: 5.0,
                //                             color: ColorPalette.primaryColor,
                //                             offset: Offset(1.0, 2.0),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                     Row(
                //                       children: [
                //                         Text(currentActivityData.price ?? "",
                //                             style: TextStyle(
                //                               fontSize: 12,
                //                               color: Colors.white,
                //                               shadows: [
                //                                 Shadow(
                //                                   blurRadius: 5.0,
                //                                   color: Colors.black,
                //                                   offset: Offset(1.0, 2.0),
                //                                 ),
                //                               ],
                //                             )),
                //                         Text(" onwards",
                //                             style: TextStyle(
                //                               fontSize: 12,
                //                               color: Colors.white,
                //                               shadows: [
                //                                 Shadow(
                //                                   blurRadius: 5.0,
                //                                   color:
                //                                       ColorPalette.primaryColor,
                //                                   offset: Offset(1.0, 2.0),
                //                                 ),
                //                               ],
                //                             )),
                //                       ],
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               onTap: () {
                //                 context.push(RoutePaths.activityDetails,
                //                     extra: currentActivityData);
                //               },
                //             )),
                //       ),
                //     );
                //   },
                // );
              } else if (activitiesSnapshot.hasError) {
                return Center(
                  child: Text(activitiesSnapshot.error.toString()),
                );
              } else {
                return Center(
                  child: Text(
                      "No activities found. Please contact with organiser."),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: ColorPalette.primaryColor,
                ),
              );
            }
          }),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Home extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Activities")),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: StreamBuilder(
//           stream:
//               FirebaseFirestore.instance.collection("activities").snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(child: Text("No activities available."));
//             }

//             var activities = snapshot.data!.docs;

//             return ListView.builder(
//               itemCount: activities.length,
//               itemBuilder: (context, index) {
//                 var activity = activities[index].data();
//                 return ActivityCard(
//                   imageUrl:
//                       activity['url'] ?? 'https://via.placeholder.com/300',
//                   title: activity['name'] ?? 'No Name',
//                   location: activity['placeName'] ?? 'Unknown Location',
//                   price: activity['price'] ?? 'N/A',
//                   onTap: () {
//                     print("Tapped on ${activity['name']}");
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

class ActivityCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final VoidCallback onTap;

  const ActivityCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: ColorPalette.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),

            // Text Section
            Container(
              // color: ColorPalette.primaryColor,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito'),
                    ),
                    SizedBox(height: 1),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Price: $price onwards",
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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

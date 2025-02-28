import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/core/colors/colors.dart';
import 'package:namer_app/core/router/router.dart';
import 'package:namer_app/core/utils/text_styles.dart';
import 'package:namer_app/src/data/models/activity_data.dart';
import 'package:namer_app/src/presentation/date_time_slots_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_js/flutter_js.dart';

// import 'dart:js' as js;

class BookingStepsScreen extends StatefulWidget {
  final ActivityData activityData;

  const BookingStepsScreen({super.key, required this.activityData});
  @override
  BookingStepsScreenState createState() => BookingStepsScreenState();
}

class BookingStepsScreenState extends State<BookingStepsScreen> {
  int _currentStep = 0;
  String? _selectedActivity;
  String? _selectedFacility;
  String? _selectedSlot;
  bool? _isSlotSelected;
  DateTime _selectedDate = DateTime.now();
  int _calendarOffset = 0;
  Map<DateTime, List<String>>? dateslots;
  List<DateTime> confirmedDates = [];
  late Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Handle Payment Success, Failure, and External Wallet
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // void openRazorpay() async {
  //   final JavascriptRuntime jsRuntime = getJavascriptRuntime();

  //   final String script = '''
  //     var options = {
  //       "key": "rzp_test_LuX7NvprmzgXmA",  // Replace with your Razorpay key
  //       "amount": 1000,  // Amount in smallest currency unit
  //       "currency": "INR",
  //       "name": "My Shop",
  //       "description": "Payment for items",
  //       "handler": function(response) {
  //         console.log("Payment successful: ", response);
  //       },
  //       "prefill": {
  //         "name": "John Doe",
  //         "email": "john.doe@example.com",
  //         "contact": "1234567890"
  //       }
  //     };
  //     var rzp = new Razorpay(options);
  //     rzp.open();
  //   ''';

  //   // Run the JavaScript code
  //   await jsRuntime.evaluate(script);
  // }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_LuX7NvprmzgXmA',
      'amount': 1000, // Amount in paise (e.g., 1000 = ₹10)
      'name': 'Rock climbing',
      'description': 'Test Payment',
      'prefill': {'email': 'test@example.com', 'contact': '9999999999'}
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment data: ${response.data}");
    print("Payment orderId: ${response.orderId}");
    print("Payment paymentId: ${response.paymentId}");
    print("Payment signature: ${response.signature}");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone') ?? '';
    phone = '910000000000';

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userRef = firestore.collection("users").doc(phone);

    var userDoc = await userRef.get();

    List<dynamic> bookings = [];
    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey("bookings")) {
        bookings = List.from(userData["bookings"]);
      }
    }

    // Find existing booking object (if any)
    Map<String, dynamic>? existingBooking;
    for (var booking in bookings) {
      if (booking.containsKey("dateSlots")) {
        existingBooking = booking;
        break;
      }
    }
    // Convert DateTime keys to String (Firestore stores keys as strings)
    Map<String, List<String>> stringConfirmedSlots = {};
    dateslots?.forEach((date, timeList) {
      stringConfirmedSlots[date.toIso8601String()] = timeList;
    });

    if (existingBooking != null) {
      Map<String, dynamic> dateSlots = existingBooking["dateSlots"];

      // Merge confirmedSlots into existing dateSlots
      stringConfirmedSlots.forEach((date, timeList) {
        if (dateSlots.containsKey(date)) {
          List<String> existingTimes = List<String>.from(dateSlots[date]);

          for (String time in timeList) {
            if (!existingTimes.contains(time)) {
              existingTimes.add(time); // Add only if not present
            }
          }
          dateSlots[date] = existingTimes;
        } else {
          dateSlots[date] = timeList;
        }
      });

      existingBooking["dateSlots"] = dateSlots;
    } else {
      // Create a new booking entry if none exists
      int newId = bookings.length;
      Map<String, dynamic> newBooking = {
        "id": newId,
        "dateSlots": stringConfirmedSlots,
        "activityName": _selectedActivity,
        "facilityName": _selectedFacility,
        "facility": "test",
        "paymentReason": "success",
        "paymentStatus": "success",
        "paymentTimestamp": DateTime.now().toString(),
        "placeName": "delhi",
        "price": "1200",
        "time": "test",
        "transactionID": response.paymentId,
        "type": "test",
      };
      bookings.add(newBooking);
    }

    // Update Firestore
    await userRef.set({"bookings": bookings}, SetOptions(merge: true));

    print("Booking added successfully!");
    context.push(RoutePaths.paymentSuccessScreen);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failed: ${response.code} - ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed! Error: ${response.message}")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("External Wallet Selected: ${response.walletName}")));
  }

  @override
  void dispose() {
    _razorpay
        .clear(); // Clean up the Razorpay instance when the widget is disposed
    super.dispose();
  }

  Future<bool> _isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List<String>> selectedBookings = {
      DateTime(2025, 2, 11): ["09:00 AM"],
      DateTime(2025, 2, 12): ["10:00 AM"],
    };
    List<DateTime> selectedDates = [
      DateTime(2025, 2, 11),
      DateTime(2025, 2, 12),
    ];
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Theme(
              data: ThemeData(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Colors.black,
                    ),
              ),
              child: Stepper(
                connectorColor: WidgetStatePropertyAll(Colors.black),
                currentStep: _currentStep,
                onStepContinue: () async {
                  if (_currentStep == 0 && _selectedActivity == null) {
                    _showError('Please select an activity first.');
                  } else if (_currentStep == 1 && _selectedFacility == null) {
                    _showError('Please select a facility first.');
                  } else if (_currentStep == 2 && _isSlotSelected == null) {
                    _showError('Please select a slot first.');
                  } else {
                    if (_currentStep < 2) {
                      setState(() => _currentStep += 1);
                    } else {
                      // DocumentReference userRef =
                      //     _firestore.collection("users").doc(phone);

                      // var userDoc = await userRef.get();

                      // List<dynamic> bookings = [];
                      // if (userDoc.exists) {
                      //   // ✅ Fix: Cast userDoc.data() to a Map<String, dynamic>
                      //   Map<String, dynamic>? userData =
                      //       userDoc.data() as Map<String, dynamic>?;

                      //   if (userData != null &&
                      //       userData.containsKey("bookings")) {
                      //     bookings = List.from(userData["bookings"]);
                      //   }
                      // }

                      // // Add new booking with an index (id)
                      // int newId = bookings.length;
                      // Map<String, dynamic> newBooking = {
                      //   "id": newId,
                      //   "activityName": _selectedActivity,
                      //   "facilityName": _selectedFacility,
                      //   "date": "test",
                      //   "facility": "test",
                      //   "paymentReason": "success",
                      //   "paymentStatus": "success",
                      //   "paymentTimestamp": "",
                      //   "placeName": "delhi",
                      //   "price": "1200",
                      //   "time": "test",
                      //   "transactionID": "",
                      //   "type": "test",
                      // };

                      // bookings.add(newBooking);

                      // // Update the user document with new bookings array
                      // await userRef
                      //     .set({"bookings": bookings}, SetOptions(merge: true));

                      _navigateToPaymentScreen();
                    }
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  }
                },
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.primaryColor,
                            minimumSize: Size(100, 40),
                          ),
                          onPressed: details.onStepContinue,
                          child: Text(
                            _currentStep == 2 ? "Book now" : "Continue",
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Nunito'),
                          ),
                        ),
                        SizedBox(width: 10),
                        if (_currentStep > 0)
                          TextButton(
                            style: TextButton.styleFrom(
                                textStyle: TextStyle(fontFamily: 'Nunito')),
                            onPressed: details.onStepCancel,
                            child: Text("Back"),
                          ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: Text(
                      'Choose an Activity',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: "Nunito",
                      ),
                    ),
                    subtitle: Text(
                      ' ${_selectedActivity ?? ''}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: _selectedActivity != null ? 10 : 0,
                        fontFamily: "Nunito",
                      ),
                    ),
                    content: _buildActivitySelection(),
                    isActive: _currentStep >= 0,
                  ),
                  Step(
                    title: Text(
                      'Choose a Facility',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: "Nunito",
                      ),
                    ),
                    subtitle: Text(
                      ' ${_selectedFacility ?? ''}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: _selectedFacility != null ? 10 : 0,
                        fontFamily: "Nunito",
                      ),
                    ),
                    content: _buildFacilitySelection(),
                    isActive: _currentStep >= 1,
                  ),
                  Step(
                    title: Text(
                      'Select a Slot',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: "Nunito",
                      ),
                    ),
                    content: _isSlotSelected == false
                        ? Column(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: ColorPalette.primaryColor,
                                  minimumSize: Size(100, 40),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  print("Selected Slot: $_isSlotSelected");
                                  dateslots = await showDialog<
                                      Map<DateTime, List<String>>>(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          child:
                                              DateTimeSlotsScreen(), // Your booking UI
                                        ),
                                      );
                                    },
                                  );
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      _isSlotSelected = true;
                                    });
                                  });
                                  print('dates recieved === $dateslots');
                                  confirmedDates = dateslots!.keys.toList();

                                  // context.go(RoutePaths.dateTimeSlotsScreen);
                                },
                                child: Text('Select Date and Slots',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Nunito')),
                              )

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     IconButton(
                              //       icon: Icon(Icons.arrow_back),
                              //       onPressed: _calendarOffset > 0
                              //           ? () {
                              //               setState(() {
                              //                 _calendarOffset--;
                              //               });
                              //             }
                              //           : null,
                              //     ),
                              //     Text(
                              //       'Select a Date',
                              //       style: TextStyle(
                              //           fontSize: 16, fontWeight: FontWeight.bold),
                              //     ),
                              //     IconButton(
                              //       icon: Icon(Icons.arrow_forward),
                              //       onPressed: () {
                              //         setState(() {
                              //           _calendarOffset++;
                              //         });
                              //       },
                              //     ),
                              //   ],
                              // ),
                              // SingleChildScrollView(
                              //   scrollDirection: Axis.horizontal,
                              //   child: Row(
                              //     children: List.generate(3, (index) {
                              //       DateTime date = DateTime.now()
                              //           .add(Duration(days: index + _calendarOffset));
                              //       bool isSelected = _selectedDate.day == date.day &&
                              //           _selectedDate.month == date.month &&
                              //           _selectedDate.year == date.year;
                              //       return GestureDetector(
                              //         onTap: () {
                              //           setState(() {
                              //             _selectedDate = date;
                              //             _selectedSlot = date.toString();
                              //           });
                              //         },
                              //         child: Card(
                              //           color: isSelected
                              //               ? ColorPalette.primaryColor
                              //               : Colors.white,
                              //           child: Padding(
                              //             padding: const EdgeInsets.all(16.0),
                              //             child: Column(
                              //               children: [
                              //                 Text(
                              //                   DateFormat('EEE')
                              //                       .format(date), // Weekday
                              //                   style: TextStyle(
                              //                     color: isSelected
                              //                         ? Colors.white
                              //                         : Colors.black,
                              //                     fontSize: 14,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   DateFormat('dd MMM')
                              //                       .format(date), // Date
                              //                   style: TextStyle(
                              //                     color: isSelected
                              //                         ? Colors.white
                              //                         : Colors.black,
                              //                     fontSize: 14,
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   '09:00 AM - 09:30 AM', // Date
                              //                   style: TextStyle(
                              //                     color: isSelected
                              //                         ? Colors.white
                              //                         : Colors.black,
                              //                     fontSize: 8,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     }),
                              //   ),
                              // ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: (confirmedDates.map((date) {
                                  return ListTile(
                                    title: Text(
                                        DateFormat('EEE, MMM d').format(date)),
                                    subtitle: Text(
                                        dateslots![date]?.join(", ") ??
                                            "No Slots"),
                                  );
                                }).toList()) ??
                                [],
                          ),
                    isActive: _currentStep >= 2,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildActivitySelection() {
    List<String> activities = (widget.activityData.type ?? []).map((element) {
      return element.name ?? "";
    }).toList();

    List<String> subTitlesForActivities =
        (widget.activityData.type ?? []).map((element) {
      return element.description ?? "";
    }).toList();

    List<String> prices = (widget.activityData.type ?? []).map((element) {
      return element.price ?? "";
    }).toList();

    void handleButtonClick(BuildContext context, String activity) async {
      bool isLoggedIn = await _isUserLoggedIn();
      if (isLoggedIn) {
        setState(() {
          _selectedActivity = activity;
          _selectedFacility = null;
          _selectedSlot = null;
          _isSlotSelected = false;
        });
      } else {
        setState(() {
          _selectedActivity = activity;
          _selectedFacility = null;
          _selectedSlot = null;
          _isSlotSelected = false;
        });
        context.push(RoutePaths.landingScreen).then((_) async {
          bool isLoggedIn = await _isUserLoggedIn();
          if (!isLoggedIn) {
            _selectedActivity = null;
            _selectedFacility = null;
            _selectedSlot = null;
            _isSlotSelected = false;
          }
          print("its poped");
        });
        // Navigate to the login screen
      }
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activities.length,
        itemBuilder: (context, index) {
          String activity = activities[index];
          bool isSelected = _selectedActivity == activity;

          return GestureDetector(
            onTap: () {
              handleButtonClick(context, activity);
            },
            child: Card(
              color: isSelected ? ColorPalette.primaryColor : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: 190,
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: AppTextStyles.title.fontSize,
                            fontFamily: "Nunito",
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          subTitlesForActivities[index],
                          style: TextStyle(
                            fontStyle: AppTextStyles.subtitle.fontStyle,
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: AppTextStyles.subtitle.fontSize,
                            fontFamily: "Nunito",
                          ),
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Maximizes spacing
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prices[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: AppTextStyles.price.fontSize,
                                fontFamily: "Nunito",
                              ),
                            ),
                            Text(
                              'onwards',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: AppTextStyles.price.fontSize,
                                fontFamily: "Nunito",
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFacilitySelection() {
    List<String> activities =
        (widget.activityData.facility ?? []).map((element) {
      return element.name ?? "";
    }).toList();

    // List<String> subTitlesForActivities =
    //     (widget.activityData.facility ?? []).map((element) {
    //   return element.time ?? "";
    // }).toList();

    List<String> prices = (widget.activityData.facility ?? []).map((element) {
      return element.price ?? "";
    }).toList();

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activities.length,
        itemBuilder: (context, index) {
          String activity = activities[index];
          bool isSelected = _selectedFacility == activity;

          return GestureDetector(
            onTap: () {
              setState(() {
                // _selectedActivity = null;
                _selectedFacility = activity;
                _selectedSlot = null;
              });
            },
            child: Card(
              color: isSelected ? ColorPalette.primaryColor : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: 190,
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: AppTextStyles.title.fontSize,
                            fontFamily: "Nunito",
                          ),
                        ),
                        // SizedBox(height: 15),
                        // Text(
                        //   subTitlesForActivities[index],
                        //   style: TextStyle(
                        //     color: isSelected ? Colors.white : Colors.black,
                        //     fontSize: AppTextStyles.subtitle.fontSize,
                        //     fontStyle: AppTextStyles.subtitle.fontStyle,
                        //     fontFamily: "Nunito",
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Maximizes spacing
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prices[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: AppTextStyles.price.fontSize,
                                fontFamily: "Nunito",
                              ),
                            ),
                            Text(
                              'onwards',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: AppTextStyles.price.fontSize,
                                fontFamily: "Nunito",
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
            message,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white),
    );
  }

  void _navigateToPaymentScreen() {
    if (kIsWeb) {
      // Web platform: Use flutter_js to invoke Razorpay JavaScript
      // openRazorpay(); // Web-specific function
    } else {
      // Mobile platform: Use razorpay_flutter package for Android/iOS
      // openCheckout(); // Mobile-specific function
    }
    openCheckout();
    // openRazorpayCheckout();
  }
}

// void openRazorpayCheckout() {
//   js.context.callMethod('eval', [
//     """
//     var options = {
//       "key": "rzp_test_LuX7NvprmzgXmA",
//       "amount": 50000,
//       "currency": "INR",
//       "name": "Rock climbing",
//       "description": "Payment for Order #12345",
//       "handler": function(response) {
//         window.postMessage(response.razorpay_payment_id, "*");
//       },
//       "prefill": {
//         "name": "John Doe",
//         "email": "john@example.com",
//         "contact": "9876543210"
//       },
//       "theme": {
//         "color": "#3399cc"
//       }
//     };
//     var rzp1 = new Razorpay(options);
//     rzp1.open();
//   """
//   ]);

//     // Listen for success message from JavaScript
  // js.context.callMethod('addEventListener', [
  //   'message',
  //   (event) {
  //     print("Payment Successful! Payment ID: ${event['data']}");
  //   }
  // ]);
// }



// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// void main() {
//   runApp(MaterialApp(
//     home: BookingStepsScreen(),
//   ));
// }

// class BookingStepsScreen extends StatefulWidget {
//   @override
//   _StepperScreenState createState() => _StepperScreenState();
// }

// class _StepperScreenState extends State<BookingStepsScreen> {
//   int _currentStep = 0;
//   Set<DateTime> selectedDates = {};
//   Map<DateTime, Set<String>> selectedSlots = {};

//   final List<String> timeSlots = [
//     "8:00 AM - 9:00 AM",
//     "9:00 AM - 10:00 AM",
//     "10:00 AM - 11:00 AM",
//     "11:00 AM - 12:00 PM",
//     "1:00 PM - 2:00 PM",
//     "2:00 PM - 3:00 PM",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Appointment Stepper")),
//       body: Stepper(
//         currentStep: _currentStep,
//         onStepContinue: () {
//           if (_currentStep < 2) {
//             setState(() => _currentStep++);
//           }
//         },
//         onStepCancel: () {
//           if (_currentStep > 0) {
//             setState(() => _currentStep--);
//           }
//         },
//         steps: [
//           Step(
//             title: Text("Step 1"),
//             content: Text("User Information"),
//             isActive: _currentStep >= 0,
//           ),
//           Step(
//             title: Text("Step 2"),
//             content: Text("Additional Details"),
//             isActive: _currentStep >= 1,
//           ),
//           Step(
//             title: Text("Step 3 - Select Date & Slots"),
//             content: Column(
//               children: [
//                 _buildDateSelector(),
//                 Divider(),
//                 _buildSlotSelection(),
//                 Divider(),
//                 _buildSummaryCard(),
//               ],
//             ),
//             isActive: _currentStep >= 2,
//           ),
//         ],
//       ),
//     );
//   }

//   /// ✅ **Modern Horizontal Date Picker**
//   Widget _buildDateSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Select Dates",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         SizedBox(height: 10),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: List.generate(7, (index) {
//               DateTime date = DateTime.now().add(Duration(days: index));
//               bool isSelected = selectedDates.contains(date);

//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     if (isSelected) {
//                       selectedDates.remove(date);
//                       selectedSlots.remove(date);
//                     } else {
//                       selectedDates.add(date);
//                     }
//                   });
//                 },
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 5),
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: isSelected ? Colors.blue : Colors.grey[300],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         DateFormat('E').format(date), // Day of the week
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: isSelected ? Colors.white : Colors.black),
//                       ),
//                       Text(
//                         DateFormat('d MMM').format(date), // Date
//                         style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected ? Colors.white : Colors.black),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }

//   /// ✅ **Grid-Based Slot Selection**
//   Widget _buildSlotSelection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: selectedDates.map((date) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Slots for ${DateFormat("yyyy-MM-dd").format(date)}:",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             SizedBox(height: 10),
//             GridView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, // Two slots per row
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//                 childAspectRatio: 3,
//               ),
//               itemCount: timeSlots.length,
//               itemBuilder: (context, index) {
//                 String slot = timeSlots[index];
//                 bool isSelected = selectedSlots[date]?.contains(slot) ?? false;

//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       if (isSelected) {
//                         selectedSlots[date]?.remove(slot);
//                         if (selectedSlots[date]?.isEmpty ?? false) {
//                           selectedSlots.remove(date);
//                         }
//                       } else {
//                         selectedSlots.putIfAbsent(date, () => {}).add(slot);
//                       }
//                     });
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 10),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.green : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       slot,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   /// ✅ **Summary Card**
//   Widget _buildSummaryCard() {
//     return selectedSlots.isEmpty
//         ? Container()
//         : Card(
//             elevation: 4,
//             margin: EdgeInsets.all(10),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Selected Slots",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: selectedSlots.entries.expand((entry) {
//                       DateTime date = entry.key;
//                       return entry.value.map((slot) {
//                         return Chip(
//                           label: Text(
//                               "${DateFormat("yyyy-MM-dd").format(date)} | $slot"),
//                           onDeleted: () {
//                             setState(() {
//                               selectedSlots[date]?.remove(slot);
//                               if (selectedSlots[date]?.isEmpty ?? false) {
//                                 selectedSlots.remove(date);
//                                 selectedDates.remove(date);
//                               }
//                             });
//                           },
//                         );
//                       });
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//           );
//   }
// }


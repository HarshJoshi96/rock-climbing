import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/core/colors/colors.dart';

void main() {
  runApp(MaterialApp(
    home: DateTimeSlotsScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class DateTimeSlotsScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<DateTimeSlotsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _selectedDates = [];
  Map<DateTime, List<String>> selectedSlots = {};

  final List<String> _timeSlots = [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
    "05:00 PM"
  ];

  // void _toggleDateSelection(DateTime date) {
  //   DateTime selectedDate =
  //       DateTime(date.year, date.month, date.day); // Normalize date
  //   setState(() {
  //     if (_selectedDates.contains(selectedDate)) {
  //       _selectedDates.remove(selectedDate);
  //       selectedSlots.remove(selectedDate);
  //     } else {
  //       _selectedDates.add(selectedDate);
  //       selectedSlots[selectedDate] = [];
  //     }
  //   });
  // }
  void _toggleDateSelection(DateTime date) {
    DateTime selectedDate =
        DateTime(date.year, date.month, date.day); // Normalize date
    setState(() {
      if (_selectedDates.contains(selectedDate)) {
        _selectedDates.remove(selectedDate);
        selectedSlots.remove(selectedDate);
      } else {
        _selectedDates.add(selectedDate);
        selectedSlots[selectedDate] = [];
      }

      // Move the last selected date to the top
      _selectedDates.sort((a, b) => b.compareTo(a));
    });
  }

  void _toggleSlotSelection(DateTime date, String slot) {
    setState(() {
      if (selectedSlots[date]?.contains(slot) ?? false) {
        selectedSlots[date]?.remove(slot);
      } else {
        selectedSlots[date]?.add(slot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: AppBar(title: Text("Book Your Activity")),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0), // Uniform radius
        ),
        child: Column(
          children: [
            _buildDateSelector(),
            Expanded(
              child: _selectedDates.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                          child: Text("Select a date to view available slots",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Nunito',
                              ))),
                    )
                  : ListView.builder(
                      itemCount: _selectedDates.length,
                      itemBuilder: (context, index) {
                        DateTime date = _selectedDates[index];
                        return _buildSlotSelector(date);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColorPalette.primaryColor,
        onPressed: () {
          _showConfirmationDialog();
        },
        label: Text("Confirm",
            style: TextStyle(fontFamily: 'Nunito', color: Colors.white)),
        icon: Icon(
          Icons.check,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show next 14 days
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          DateTime normalizedDate =
              DateTime(date.year, date.month, date.day); // Normalize

          bool isSelected = _selectedDates.any((d) =>
              d.year == normalizedDate.year &&
              d.month == normalizedDate.month &&
              d.day == normalizedDate.day);

          return GestureDetector(
            onTap: () => _toggleDateSelection(normalizedDate),
            child: Container(
              width: 80,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorPalette.primaryColor
                    : Colors.grey[300], // Change color for selected dates
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? ColorPalette.primaryColor
                      : Colors.transparent, // Border for selected
                  width: isSelected ? 2.0 : 0.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: isSelected ? Colors.white : Colors.black,
                        // Change text color
                      )),
                  Text(DateFormat('dd').format(date),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        color: isSelected
                            ? Colors.white
                            : Colors.black, // Change text color
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotSelector(DateTime date) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              DateFormat('EEE, MMM d').format(date),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
            Wrap(
              spacing: 10,
              children: _timeSlots.map((slot) {
                bool isSelected = selectedSlots[date]?.contains(slot) ?? false;
                return ChoiceChip(
                  checkmarkColor: isSelected ? Colors.white : Colors.black,
                  label: Text(slot,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Nunito',
                          color: isSelected ? Colors.white : Colors.black)),
                  selected: isSelected,
                  selectedColor: ColorPalette.primaryColor,
                  onSelected: (selected) => _toggleSlotSelection(date, slot),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Confirm Selection",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _selectedDates
                .where((date) =>
                    selectedSlots[date] != null &&
                    selectedSlots[date]!.isNotEmpty)
                .map((date) {
              return ListTile(
                title: Text(DateFormat('EEE, MMM d').format(date)),
                subtitle: Text(selectedSlots[date]!.join(", ")),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
              ),
              onPressed: () {
                print("Selected slots $selectedSlots");

                // Filter only confirmed slots that have values
                Map<DateTime, List<String>> confirmedSlots = Map.fromEntries(
                  selectedSlots.entries
                      .where((entry) => entry.value.isNotEmpty),
                );
                print("Selected conf slots $confirmedSlots");
                context.pop(confirmedSlots);
                context.pop(confirmedSlots);

                // First pop to close the dialog
                // Navigator.pop(context);

                // // Then pop the screen and send data back
                // Navigator.pop(context, confirmedSlots);
              },
              child: Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

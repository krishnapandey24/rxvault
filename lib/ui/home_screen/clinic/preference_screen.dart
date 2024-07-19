import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../enums/day.dart';
import '../../../models/setting.dart';
import '../../../models/user_info.dart';
import '../../../utils/colors.dart';
import '../../widgets/responsive.dart';

class PreferencesScreen extends StatefulWidget {
  final User user;
  final Setting setting;

  const PreferencesScreen(
      {super.key, required this.user, required this.setting});

  @override
  PreferencesScreenState createState() => PreferencesScreenState();
}

class PreferencesScreenState extends State<PreferencesScreen> {
  late Size size;
  late List<bool> selectedDays;
  String openingTime = "--Select--";
  String closingTime = "--Select--";
  String openingTime2 = "--Select--";
  String closingTime2 = "--Select--";
  late TextEditingController addressController;
  late Setting setting;
  late User user;

  @override
  void initState() {
    super.initState();
    loadData();
    setting = widget.setting;
    user = widget.user;
  }

  void loadData() {
    selectedDays = List<bool>.from(widget.setting.getDaySelection());
    openingTime = widget.setting.openTime1 ?? "--Select--";
    closingTime = widget.setting.closeTime2 ?? "--Select--";
    // openingTime2 = widget.setting.openTime2 ?? "--Select--";
    // closingTime2 = widget.setting.closeTime2 ?? "--Select--";
    addressController =
        TextEditingController(text: widget.setting.clinicAddress ?? "");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Responsive(
        desktop: buildMainColumn(true),
        mobile: buildMainColumn(false),
        tablet: buildMainColumn(false),
      ),
    );
  }

  Column buildMainColumn(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Open/Close (Select working day)",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: Day.values.map((day) => buildDaySelector(day)).toList(),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Opening and Closing Time (Slot 1): ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        buildFromToSelector(isDesktop, true),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Opening and Closing Time (Slot 2): ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        buildFromToSelector(isDesktop, false),
        const SizedBox(height: 20),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(size.width * 0.5, 30),
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: updateSettings,
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDaySelector(Day day) {
    int index = day.index;
    return InkWell(
      onTap: () => onDayClick(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: selectedDays[index]
              ? null
              : Border.all(color: Colors.black, width: 0),
          color: selectedDays[index] ? primary : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Text(
          " ${day.text} ",
          style: TextStyle(
            fontSize: 11,
            color: selectedDays[index] ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  String getDaySelectionMap() {
    return selectedDays.map((bool value) => value ? '1' : '0').join('');
  }

  Widget buildFromToSelector(bool isDesktop, bool forSlot1) {
    return isDesktop
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              fromSelector(forSlot1),
              const SizedBox(width: 20),
              toSelector(forSlot1),
            ],
          )
        : Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: fromSelector(forSlot1),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: toSelector(forSlot1),
              ),
            ],
          );
  }

  Widget fromSelector(bool forSlot1) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text("Opening Time: "),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => pickTime(true, forSlot1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              forSlot1 ? openingTime : openingTime2,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget toSelector(bool forSlot1) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text("Closing Time: "),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => pickTime(false, forSlot1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              forSlot1 ? closingTime : closingTime2,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Future<void> pickTime(bool isFrom, bool forSlot1) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final DateTime selectedTime = DateTime(
        0,
        1,
        1,
        pickedTime.hour,
        pickedTime.minute,
      );

      final String formattedTime = DateFormat('hh:mm a').format(selectedTime);

      setState(() {
        if (forSlot1) {
          isFrom ? openingTime = formattedTime : closingTime = formattedTime;
        } else {
          isFrom ? openingTime2 = formattedTime : closingTime2 = formattedTime;
        }
      });
    }
  }

  void updateSettings() {
    setting.openClose = getDaySelectionMap();
    setting.openTime1 = openingTime;
    setting.closeTime2 = closingTime;
    setting.clinicAddress = addressController.text;

    // Add logic to update the settings
  }

  void onDayClick(int index) {
    setState(() {
      selectedDays[index] = !selectedDays[index];
    });
  }
}

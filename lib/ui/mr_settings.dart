import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/ui/widgets/responsive.dart';
import 'package:rxvault/ui/widgets/time_picker.dart';

import '../../../enums/day.dart';
import '../../../models/setting.dart';
import '../../../network/api_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/utils.dart';
import '../models/mr_list_response.dart';
import '../models/user_info.dart';

class MrSettingsScreen extends StatefulWidget {
  final String userId;

  const MrSettingsScreen({super.key, required this.userId});

  @override
  State<MrSettingsScreen> createState() => MrSettingsScreenState();
}

class MrSettingsScreenState extends State<MrSettingsScreen> {
  late Size size;
  Map<String, String> services = {};
  String? openingTime;
  String? closingTime;
  late List<bool> selectedDays;
  late Future<Setting> settingFuture;
  late Setting setting;
  final API api = API();
  var isLoading = true;
  late Future<List<MR>> mrListFuture;
  bool mrOnOff = true;
  late User user;

  @override
  void initState() {
    super.initState();

    mrListFuture = api.getMRList(widget.userId, getTodayWeekday());
    loadData();
  }

  void loadData() async {
    setting = await api.getMrSettings(widget.userId);
    setState(() {
      mrOnOff = setting.status == "open";
      selectedDays = List<bool>.from(setting.getDaySelection());
      openingTime = setting.openTime1;
      closingTime = setting.closeTime1;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : buildPreferences(),
            SizedBox(
              width: size.width * 0.3,
              child: ElevatedButton(
                onPressed: () => updateSettings(false),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(18.0),
              child: Center(
                child: Text(
                  "Today's Special Request",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            FutureBuilder<List<MR>>(
              future: mrListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('No Data Found'));
                } else {
                  List<MR> data = snapshot.data!;
                  return Column(
                    children: _getMrList(data),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  _getMrList(List<MR> list) {
    List<Widget> children = [];
    for (int i = 0; i < list.length; i++) {
      MR mr = list[i];
      children.add(
        Container(
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: transparentBlue,
            border: Border.all(color: darkBlue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("MR: ${Utils.capitalizeFirstLetter(mr.mrName)}"),
              Text("Company: ${Utils.capitalizeFirstLetter(mr.company)}"),
              Row(
                children: [
                  const Text("Products: "),
                  if (mr.products != null)
                    Expanded(
                      child: _buildProductsChips(
                        mr.products!.split(","),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return children;
  }

  Widget _buildProductsChips(List<String> products) {
    if (products.length == 1) {
      return Text(products[0]);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            products.map((product) => _buildProductChip(product)).toList(),
      ),
    );
  }

  Widget _buildProductChip(String product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Text(
        product,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  buildPreferences() {
    return Responsive(
      desktop: buildMainColumn(true),
      mobile: buildMainColumn(false),
      tablet: buildMainColumn(false),
    );
  }

  Column buildMainColumn(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Mr On/Off",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 5),
            Switch(
              value: mrOnOff,
              onChanged: (value) {
                if (user.isStaff) {
                  Utils.noPermission();
                  return;
                }
                setState(() {
                  mrOnOff = !mrOnOff;
                });
                setting.status = mrOnOff ? "open" : "close";
                updateSettings(true);
              },
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Open/Close",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDaySelector(Day.monday),
            buildDaySelector(Day.tuesday),
            buildDaySelector(Day.wednesday),
            buildDaySelector(Day.thursday),
            buildDaySelector(Day.friday),
            buildDaySelector(Day.saturday),
            buildDaySelector(Day.sunday),
          ],
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Clinic Timing: ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const SizedBox(width: 25),
            TimePicker(
                title: "From",
                time: openingTime,
                isStaff: user.isStaff,
                onPicked: (time) {
                  openingTime = time;
                }),
            const SizedBox(width: 25),
            TimePicker(
                title: "To",
                time: closingTime,
                isStaff: user.isStaff,
                onPicked: (time) {
                  closingTime = time;
                }),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildDaySelector(Day day) {
    int index = day.index;
    return InkWell(
      onTap: () {
        if (user.isStaff) {
          Utils.noPermission();
          return;
        }
        setState(() {
          selectedDays[index] = !selectedDays[index];
        });
      },
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

  Future<void> pickTime(bool isFrom) async {
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

      (context as Element).markNeedsBuild();
      if (isFrom) {
        openingTime = formattedTime;
      } else {
        closingTime = formattedTime;
      }
    }
  }

  void updateSettings(bool forOnOff) {
    if (user.isStaff) {
      Utils.noPermission();
      return;
    }
    Utils.showLoader(context);
    setting.openClose =
        selectedDays.map((bool value) => value ? '1' : '0').join('');
    setting.openTime1 = openingTime;
    setting.closeTime2 = closingTime;
    setting.itemDetails = jsonEncode(services);
    setting.doctorId = widget.userId;
    api.updateMr(setting).then((value) {
      Navigator.pop(context);
      Utils.toast(forOnOff
          ? "Mr ${mrOnOff ? "On" : "Off"}"
          : "Mr Settings Updated Successfully!");
    }).catchError((e) {
      Navigator.pop(context);
      Utils.toast(e.toString());
    });
  }

  Day getTodayWeekday() {
    int todayIndex = DateTime.now().weekday - 1;
    return Day.values[todayIndex];
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/ui/home_screen/clinic/service_screen.dart';
import 'package:rxvault/ui/home_screen/clinic/staff_screen.dart';
import 'package:rxvault/ui/widgets/responsive.dart';
import 'package:rxvault/ui/widgets/time_picker.dart';

import '../../../enums/day.dart';
import '../../../models/setting.dart';
import '../../../models/user_info.dart';
import '../../../network/api_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/utils.dart';

class ClinicScreen extends StatefulWidget {
  final String userId;
  final Setting setting;
  final Function(Setting) updateSettingObject;

  const ClinicScreen({
    super.key,
    required this.userId,
    required this.setting,
    required this.updateSettingObject,
  });

  @override
  State<ClinicScreen> createState() => ClinicScreenState();
}

class ClinicScreenState extends State<ClinicScreen> {
  late Size size;
  late User user;
  String? openingTime;
  String? closingTime;
  String? openingTime2;
  String? closingTime2;
  late List<bool> selectedDays;
  late TextEditingController addressController;
  List<DataRow> serviceTableRows = [];
  late Setting setting;
  final API api = API();
  var isLoading = true;
  Map<String, String> services = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    if (widget.setting.itemDetails != null) {
      setting = widget.setting;
    } else {
      setting = await api.getSettings(widget.userId);
    }

    setState(() {
      selectedDays = List<bool>.from(setting.getDaySelection());
      openingTime = setting.openTime1;
      closingTime = setting.closeTime2;
      openingTime2 = setting.openTime2;
      closingTime2 = setting.closeTime2;
      addressController = TextEditingController(text: setting.clinicAddress);

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildMainBody(),
    );
  }

  DefaultTabController _buildMainBody() {
    List<Widget> pages = [
      buildPreferences(),
      StaffScreen(userId: widget.userId)
    ];
    if (user.isDoctor) {
      pages.add(
        ServiceScreen(
          setting: setting,
          userId: widget.userId,
          isStaff: user.isStaff,
          updateSettings: updateSettings,
        ),
      );
    }
    return DefaultTabController(
      length: user.isStaff ? 2 : 3,
      child: Column(
        children: [
          buildTabBar(),
          const SizedBox(height: 10),
          Expanded(
            child: SizedBox(
              height: double.maxFinite,
              width: double.maxFinite,
              child: TabBarView(children: pages),
            ),
          )
        ],
      ),
    );
  }

  Widget buildTabBar() {
    final tabs = [
      const Tab(
        text: "Preference",
      ),
      const Tab(
        text: "Staff",
      ),
    ];

    if (user.isDoctor) {
      tabs.add(
        const Tab(
          text: "Services",
        ),
      );
    }

    return TabBar(
      indicatorColor: darkBlue,
      labelStyle: const TextStyle(color: darkBlue),
      tabs: tabs,
    );
  }

  buildPreferences() {
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
            "Select working days: ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 7),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: Day.values.map((day) => buildDaySelector(day)).toList(),
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Opening and Closing Time (Slot 1): ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 25),
            TimePicker(
                title: "Opens At",
                time: openingTime,
                isStaff: user.isStaff,
                onPicked: (time) {
                  openingTime = time;
                }),
            const SizedBox(width: 25),
            TimePicker(
                title: "Closes At",
                time: closingTime,
                isStaff: user.isStaff,
                onPicked: (time) {
                  closingTime = time;
                }),
          ],
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Opening and Closing Time (Slot 2): ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 25),
            TimePicker(
                title: "Opens At",
                time: openingTime2,
                isStaff: user.isStaff,
                onPicked: (time) {
                  openingTime2 = time;
                }),
            const SizedBox(width: 25),
            TimePicker(
                title: "Closes At",
                time: closingTime2,
                isStaff: user.isStaff,
                onPicked: (time) {
                  closingTime2 = time;
                }),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(size.width * 0.5, 30),
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Border radius
                ),
              ),
              onPressed: () => updateSettings(forDelete: false),
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

  void onDayClick(int index) {
    if (user.isStaff) {
      Utils.noPermission();
      return;
    }
    setState(() {
      selectedDays[index] = !selectedDays[index];
    });
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
            fontSize: 12,
            color: selectedDays[index] ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  String getDaySelectionMap() {
    return selectedDays.map((bool value) => value ? '1' : '0').join('');
  }

  void updateSettings({
    required bool forDelete,
    bool? forService,
    bool? isUpdate,
    Map<String, String>? givenServices,
  }) async {
    if (givenServices != null) {
      services = givenServices;
    }
    if (user.isStaff) {
      Utils.noPermission();
      return;
    }
    if (forService == null) {
      Utils.showLoader(context, "Updating settings...");
    }
    setting.openClose =
        selectedDays.map((bool value) => value ? '1' : '0').join('');
    setting.openTime1 = openingTime;
    setting.closeTime1 = closingTime;
    setting.closeTime2 = closingTime2;
    setting.openTime2 = openingTime2;
    setting.clinicAddress = addressController.text;
    setting.itemDetails = jsonEncode(services);
    setting.doctorId = widget.userId;

    try {
      await api.updateSettings(setting);
      setState(() {
        widget.updateSettingObject(setting);
        Utils.toast("Settings updated successfully");
      });
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) {
        if (forService != null) Navigator.pop(context);
        if (!forDelete) Navigator.pop(context);
      }
    }
  }
}

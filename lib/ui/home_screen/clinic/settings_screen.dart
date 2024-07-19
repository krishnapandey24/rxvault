import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/ui/dialogs/add_staff_dialog.dart';
import 'package:rxvault/ui/widgets/responsive.dart';
import 'package:rxvault/utils/constants.dart';

import '../../../enums/day.dart';
import '../../../models/setting.dart';
import '../../../models/staff.dart';
import '../../../models/user_info.dart';
import '../../../network/api_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/utils.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;
  final Setting setting;
  final Function(Setting) updateSettingObject;

  const SettingsScreen(
      {super.key,
      required this.userId,
      required this.setting,
      required this.updateSettingObject});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late Size size;
  late User user;
  Map<String, String> services = {};
  String openingTime = "--Select--";
  String closingTime = "--Select--";
  String openingTime2 = "--Select--";
  String closingTime2 = "--Select--";
  late List<bool> selectedDays;
  late TextEditingController addressController;
  List<DataRow> serviceTableRows = [];
  List<DataRow> staffTableRows = [];
  late Future<Setting> settingFuture;
  late Setting setting;
  List<Staff> staffList = [];
  final API api = API();
  var isLoading = true;

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

    staffList = await api.getStaff(widget.userId);

    setState(() {
      selectedDays = List<bool>.from(setting.getDaySelection());
      openingTime = setting.openTime ?? defaultOpeningString;
      closingTime = setting.closeTime ?? defaultClosingString;
      addressController =
          TextEditingController(text: setting.clinicAddress ?? "");
      services = Utils.getServicesFromString(setting.itemDetails);
      serviceTableRows = services.entries.map((entry) {
        return DataRow(cells: [
          DataCell(Text(entry.key)),
          DataCell(Text(entry.value)),
          DataCell(getActionsForService(entry.key)),
        ]);
      }).toList();

      refreshStaff();
      isLoading = false;
    });
  }

  void refreshStaff() {
    int index = -1;
    staffTableRows = staffList.map((staff) {
      index++;
      return DataRow(cells: [
        DataCell(Text(staff.name)),
        DataCell(Text(staff.role)),
        DataCell(getStaffActionsForService(staff, index)),
      ]);
    }).toList();
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
          : mainView(),
    );
  }

  DefaultTabController mainView() {
    List<Widget> pages = [buildPreferences(), buildServices()];
    if (user.isDoctor) {
      pages.add(buildStaff());
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
        text: "Preferences",
      ),
      const Tab(
        text: "Services",
      ),
    ];

    if (user.isDoctor) {
      tabs.add(
        const Tab(
          text: "Staff",
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

  buildServices() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: showAddUpdateServiceDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5),
                const Icon(
                  Icons.add,
                  color: darkBlue,
                ),
                const SizedBox(width: 5),
                Text(
                  "Add${(serviceTableRows.isNotEmpty) ? " More" : ""}",
                  style: const TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: DataTable(
              border: const TableBorder(
                horizontalInside: BorderSide(width: 1, color: Colors.grey),
                verticalInside: BorderSide(width: 1, color: Colors.grey),
              ),
              columnSpacing: 60,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => Colors.grey.shade200),
              columns: const [
                DataColumn(
                  label: Text('Service'),
                ),
                DataColumn(
                  label: Text('Amount'),
                ),
                DataColumn(
                  label: Text('Action'),
                ),
              ],
              rows: serviceTableRows,
            ),
          )
        ],
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
            "Opening and Closing Time (Slot 1): ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        buildFromToSelector(isDesktop, true),
        const SizedBox(height: 20),
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
                  borderRadius: BorderRadius.circular(16), // Border radius
                ),
              ),
              onPressed: () => updateSettings(false),
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

  void deleteStaff(Staff staff, int index) async {
    Utils.showLoader(context, "Deleting staff...");
    try {
      await api.deleteStaff("delete_staff", staff.id);
      Utils.toast("Staff Delete Successfully");
      setState(() {
        staffList.removeAt(index);
        refreshStaff();
      });
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) Navigator.pop(context);
    }
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

  buildFromToSelector(bool isDesktop, bool forSlot1) {
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

  Column toSelector(bool forSlot1) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text("Closing Time: "),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            if (user.isStaff) {
              Utils.noPermission();
              return;
            }
            pickTime(false, forSlot1);
          },
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

  Column fromSelector(bool forSlot1) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text("Opening Time: "),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            if (user.isStaff) {
              Utils.noPermission();
              return;
            }
            pickTime(true, forSlot1);
          },
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

      (context as Element).markNeedsBuild();
      if (forSlot1) {
        isFrom ? openingTime = formattedTime : closingTime = formattedTime;
      } else {
        isFrom ? openingTime2 = formattedTime : closingTime2 = formattedTime;
      }
    }
  }

  Future<void> showAddUpdateServiceDialog([String? key]) async {
    if (user.isStaff) {
      Utils.noPermission();
      return;
    }
    bool isUpdate = key != null;
    String addOrUpdate = isUpdate ? "Update" : "Add";
    String name;
    String value;
    if (isUpdate) {
      name = key;
      value = services[key]!;
    } else {
      name = "";
      value = "";
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$addOrUpdate Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                onChanged: (input) {
                  name = input;
                },
              ),
              TextFormField(
                initialValue: value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.currency_rupee),
                  labelText: 'Amount',
                ),
                onChanged: (input) {
                  value = input;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && value.isNotEmpty) {
                  if (key != name) {
                    services.remove(key);
                  }
                  addUpdateService(name, value, isUpdate);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter both service name and value.'),
                  ));
                }
              },
              child: Text(addOrUpdate),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAddUpdateStaffDialog([Staff? staff]) async {
    if (user.isStaff) {
      Utils.noPermission();
      return;
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Responsive(
          mobile: buildAppUpdateStaffDialog(const EdgeInsets.all(15), staff),
          desktop: buildAppUpdateStaffDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 15,
            ),
            staff,
          ),
          tablet: buildAppUpdateStaffDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 50,
            ),
            staff,
          ),
        );
      },
    );
  }

  Dialog buildAppUpdateStaffDialog(EdgeInsets insetPadding, Staff? staff) {
    return Dialog(
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: AddStaffDialog(
        staff: staff,
        userId: widget.userId,
        addStaff: (staff) {
          setState(() {
            staffTableRows.add(DataRow(cells: [
              DataCell(Text(staff.name)),
              DataCell(Text(staff.role)),
              DataCell(getStaffActionsForService(staff, staffList.length)),
            ]));
          });
        },
        updateStaff: (staff) {
          setState(() {
            refreshStaff();
          });
        },
      ),
    );
  }

  void addUpdateService(String name, String value, bool isUpdate) {
    name = Utils.capitalizeFirstLetter(name);
    Utils.showLoader(
        context, "${isUpdate ? "Updating" : "Adding new"} service...");

    setState(() {
      services[name] = value;
      if (!isUpdate) {
        serviceTableRows.add(DataRow(cells: [
          DataCell(Text(name)),
          DataCell(Text(value)),
          DataCell(getActionsForService(name))
        ]));
      }
    });
    updateSettings(false, true);
  }

  getActionsForService(String key) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => showAddUpdateServiceDialog(key),
          icon: const Icon(
            Icons.edit,
            color: darkBlue,
          ),
        ),
        IconButton(
          onPressed: () {
            if (user.isStaff) {
              Utils.noPermission();
              return;
            }
            Utils.showLoader(context, "Deleting service...");
            setState(() {
              services.remove(key);
            });
            updateSettings(true, true, true);
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  getStaffActionsForService(Staff staff, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => showAddUpdateStaffDialog(staff),
          icon: const Icon(
            Icons.edit,
            color: darkBlue,
          ),
        ),
        IconButton(
          onPressed: () {
            deleteStaff(staff, index);
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  void updateSettings(bool forDelete,
      [bool? forService, bool? isUpdate]) async {
    if (user.isStaff) {
      Utils.noPermission();
      return;
    }
    if (forService == null) {
      Utils.showLoader(context, "Updating settings...");
    }
    setting.openClose =
        selectedDays.map((bool value) => value ? '1' : '0').join('');
    setting.openTime = openingTime;
    setting.closeTime = closingTime;
    setting.clinicAddress = addressController.text;
    setting.itemDetails = jsonEncode(services);
    setting.doctorId = widget.userId;

    try {
      await api.updateSettings(setting);
      setState(() {
        serviceTableRows = services.entries.map((entry) {
          return DataRow(cells: [
            DataCell(Text(entry.key)),
            DataCell(Text(entry.value)),
            DataCell(getActionsForService(entry.key)),
          ]);
        }).toList();
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

  buildStaff() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: showAddUpdateStaffDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5),
                const Icon(
                  Icons.add,
                  color: darkBlue,
                ),
                const SizedBox(width: 5),
                Text(
                  "Add${(serviceTableRows.isNotEmpty) ? " More" : ""}",
                  style: const TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: DataTable(
              border: const TableBorder(
                horizontalInside: BorderSide(width: 1, color: Colors.grey),
                verticalInside: BorderSide(width: 1, color: Colors.grey),
              ),
              columnSpacing: 20,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => Colors.grey.shade200),
              columns: const [
                DataColumn(
                  label: Text('Name'),
                ),
                DataColumn(
                  label: Text('Role'),
                ),
                DataColumn(
                  label: Text('Actions'),
                ),
              ],
              rows: staffTableRows,
            ),
          )
        ],
      ),
    );
  }
}

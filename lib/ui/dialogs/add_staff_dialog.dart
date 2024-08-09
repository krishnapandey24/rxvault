import 'package:flutter/material.dart';
import 'package:rxvault/utils/colors.dart';

import '../../enums/permission.dart';
import '../../models/staff.dart';
import '../../network/api_service.dart';
import '../../utils/utils.dart';

class AddStaffDialog extends StatefulWidget {
  final String userId;
  final Staff? staff;
  final Function(Staff) addStaff;
  final Function(Staff) updateStaff;

  const AddStaffDialog(
      {super.key,
      required this.userId,
      this.staff,
      required this.addStaff,
      required this.updateStaff});

  @override
  State<AddStaffDialog> createState() => AddStaffDialogState();
}

class AddStaffDialogState extends State<AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedGender;
  final api = API();
  late Staff staff;

  late List<Permission> selectedPermissions;

  List<Permission> allPermissions = [
    Permission.addPatient,
    Permission.updatePatient,
    Permission.addAppointment,
    Permission.addPatientService,
    Permission.updatePatientService,
    Permission.deletePatient,
    Permission.addImage,
  ];

  get isUpdate => widget.staff != null;

  @override
  void initState() {
    super.initState();
    staff = widget.staff ?? Staff.empty();
    staff.doctorId = widget.userId;
    selectedPermissions = staff.permissions;
    _selectedGender = widget.staff?.gender ?? "Male";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Utils.getDefaultAppBar(
        "${isUpdate ? "Update" : "Add"} New Staff",
        [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.cancel,
              color: darkBlue,
            ),
          )
        ],
        const SizedBox(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Staff Name",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  maxLength: 30,
                  maxLines: 1,
                  initialValue: staff.name,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.all(15),
                    labelText: "Enter Full Staff Name",
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    fillColor: transparentBlue,
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter a valid name";
                    }
                    staff.name = value;
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  "Role",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  maxLength: 50,
                  maxLines: 1,
                  initialValue: staff.role,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.all(15),
                    labelText: "Enter Staff's Role",
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    fillColor: transparentBlue,
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter a valid role";
                    }
                    staff.role = value;
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  "Phone number",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  maxLength: 10,
                  maxLines: 1,
                  initialValue: staff.mobile,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.all(15),
                    labelText: "Enter Staff's Mobile Number",
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    fillColor: transparentBlue,
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isEmpty || !Utils.isValidPhoneNumber(value)) {
                      return "Please Enter a valid phone number";
                    }
                    staff.mobile = value;
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  "Email",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  maxLength: 50,
                  maxLines: 1,
                  initialValue: staff.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.all(15),
                    labelText: "Enter Staff's E-Mail",
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    fillColor: transparentBlue,
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isNotEmpty && !Utils.isEmailValid(value)) {
                      return "Please Enter a valid email";
                    }
                    staff.email = value;
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  "Gender",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                buildGenderSelector(),
                const SizedBox(height: 20),
                const Text(
                  "Select Permissions",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: allPermissions.map((permission) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ChoiceChip(
                        label: Text(permission.text),
                        selected: selectedPermissions.contains(permission),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedPermissions.add(permission);
                            } else {
                              selectedPermissions.remove(permission);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 45),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.maxFinite, 30),
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Border radius
                    ),
                  ),
                  onPressed: handleContinue,
                  child: Text(
                    isUpdate ? "Update" : "Continue",
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleContinue() async {
    if (_formKey.currentState!.validate()) {
      Utils.showLoader(
          context, isUpdate ? "Updating Staff..." : "Adding Staff...");

      try {
        if (isUpdate) {
          await api.updateStaff(staff.toJson(), true);
          widget.updateStaff(staff);
          Utils.toast("Staff Updated Successfully!");
        } else {
          final json = staff.toJson();
          json.remove("id");
          String staffId = await api.createStaff(json);
          staff.id = staffId;
          widget.addStaff(staff);
          Utils.toast("Staff Added Successfully!");
        }
      } catch (e) {
        Utils.toast("$e \n Please try again");
      } finally {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    }
  }

  buildGenderSelector() {
    return Wrap(
      children: [
        _buildGenderOption('Male'),
        const SizedBox(width: 10),
        _buildGenderOption('Female'),
        const SizedBox(width: 10),
        _buildGenderOption('Others'),
      ],
    );
  }

  void _selectGender(String gender) {
    staff.gender = gender;
    setState(() {
      _selectedGender = gender;
    });
  }

  Widget _buildGenderOption(String gender) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? darkBlue : transparentBlue,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}

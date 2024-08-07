import 'package:flutter/material.dart';

import '../../../models/staff.dart';
import '../../../network/api_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/utils.dart';
import '../../dialogs/add_staff_dialog.dart';
import '../../widgets/responsive.dart';

class StaffScreen extends StatefulWidget {
  final String userId;

  const StaffScreen({super.key, required this.userId});

  @override
  State<StaffScreen> createState() => StaffScreenState();
}

class StaffScreenState extends State<StaffScreen> {
  late Size size;
  late Future<List<Staff>> _staffFuture;
  List<Staff> _staffList = [];
  final api = API();

  @override
  void initState() {
    super.initState();
    _staffFuture = api.getStaff(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUpdateStaffDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: FutureBuilder<List<Staff>>(
        future: _staffFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _staffList = snapshot.data!;
            return _buildStaffView(_staffList.length);
          }
        },
      ),
    );
  }

  _buildStaffView(int length) {
    if (length == 0) {
      return const Center(
        child: Text("Click on Add Button (+) to Add Staff"),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Responsive(
        desktop: _buildStaffGridView(length),
        mobile: _buildStaffListView(length),
        tablet: _buildStaffGridView(length),
      ),
    );
  }

  ListView _buildStaffListView(int length) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: length,
      itemBuilder: (context, index) => _buildStaffItem(context, index, false),
    );
  }

  GridView _buildStaffGridView(int length) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 65,
        crossAxisSpacing: 20,
      ),
      itemCount: length,
      itemBuilder: (context, index) => _buildStaffItem(context, index, true),
    );
  }

  Widget _buildStaffItem(BuildContext context, int index, bool isGrid) {
    Staff staff = _staffList[index];
    return Container(
      height: isGrid ? 65 : 60,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      width: double.maxFinite,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: darkBlue, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(
            staff.gender == "Male"
                ? "assets/images/ic_male.png"
                : "assets/images/ic_female.png",
            height: 40,
            width: 40,
          ),
          const SizedBox(width: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                staff.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: darkBlue,
                  fontSize: 16,
                ),
              ),
              Text(
                staff.role,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showAddUpdateStaffDialog(staff),
            icon: const Icon(
              Icons.edit,
              color: darkBlue,
            ),
          ),
          IconButton(
            onPressed: () {
              _deleteStaff(staff, index);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUpdateStaffDialog([Staff? staff, int? index]) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Responsive(
          mobile: _buildAppUpdateStaffDialog(
            const EdgeInsets.all(15),
            staff,
            index,
          ),
          desktop: _buildAppUpdateStaffDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 15,
            ),
            staff,
            index,
          ),
          tablet: _buildAppUpdateStaffDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 50,
            ),
            staff,
            index,
          ),
        );
      },
    );
  }

  Dialog _buildAppUpdateStaffDialog(
      EdgeInsets insetPadding, Staff? staff, int? index) {
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
            _staffList.add(staff);
          });
        },
        updateStaff: (staff) {
          setState(() {
            if (index != null) {
              _staffList[index] = staff;
            }
          });
        },
      ),
    );
  }

  void _deleteStaff(Staff staff, int index) async {
    Utils.showLoader(context, "Deleting staff...");
    try {
      await api.deleteStaff("delete_staff", staff.id);
      Utils.toast("Staff Delete Successfully");
      setState(() {
        setState(() {
          _staffList.removeAt(index);
        });
      });
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }
}

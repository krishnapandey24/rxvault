import 'package:flutter/material.dart';

import '../../../enums/permission.dart';
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
        desktop: _buildStaffGridView(length, 4),
        mobile: _buildStaffGridView(length, 2),
        tablet: _buildStaffGridView(length, 3),
      ),
    );
  }

  GridView _buildStaffGridView(int length, int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 250),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 220,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: length,
      itemBuilder: (context, index) => _buildStaffItem(context, index, true),
    );
  }

  Widget _buildStaffItem(BuildContext context, int index, bool isGrid) {
    Staff staff = _staffList[index];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            staff.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Mobile: ",
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    "Role: ",
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    staff.mobile,
                    style: const TextStyle(fontSize: 11, color: darkBlue),
                  ),
                  Text(
                    staff.role,
                    style: const TextStyle(fontSize: 11, color: darkBlue),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPermissionsChips(staff.permissions),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                backgroundColor: primary,
                radius: iconSize,
                child: IconButton(
                  iconSize: iconSize,
                  onPressed: () => _showAddUpdateStaffDialog(staff),
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: iconSize,
                child: IconButton(
                  iconSize: iconSize,
                  onPressed: () {
                    _deleteStaff(staff, index);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPermissionsChips(List<Permission> permissions) {
    return Wrap(
      children: permissions
          .map((permission) => _buildPermissionChip(permission.text))
          .toList(),
    );
  }

  Widget _buildPermissionChip(String product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      child: Text(
        product,
        style: const TextStyle(color: Colors.white, fontSize: 8),
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

const iconSize = 18.0;

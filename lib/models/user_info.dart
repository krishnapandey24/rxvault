import 'package:flutter/cupertino.dart';
import 'package:rxvault/enums/permission.dart';

class User extends ChangeNotifier {
  String permissions;
  bool isStaff;
  String userName;

  User(this.permissions, this.isStaff, this.userName);

  get isDoctor => !isStaff;

  bool doNotHavePermission(Permission permission) {
    return isStaff && !permissions.contains(permission.name);
  }

  void updateName(String newName) {
    userName = newName;
    notifyListeners();
  }

  // Method to update permissions and notify listeners
  void updatePermissions(String newPermissions) {
    permissions = newPermissions;
    notifyListeners();
  }

  // Method to update isStaff and notify listeners
  void updateIsStaff(bool newIsStaff) {
    isStaff = newIsStaff;
    notifyListeners();
  }

  void updateIsStaffAndPermission(bool newIsStaff, String newPermissions) {
    isStaff = newIsStaff;
    permissions = newPermissions;
    notifyListeners();
  }
}

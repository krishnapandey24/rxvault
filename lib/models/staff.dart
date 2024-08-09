import 'package:flutter/cupertino.dart';

import '../enums/permission.dart';

class StaffResponse {
  final String status;
  final List<Staff> staff;

  StaffResponse({
    required this.status,
    required this.staff,
  });

  factory StaffResponse.fromJson(Map<String, dynamic> json) {
    return StaffResponse(
      status: json['status'] as String,
      staff: ((json['data']) as List<dynamic>)
          .map((e) => Staff.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Staff {
  String id;
  String name;
  String? email;
  String mobile;
  String? gender;
  String role;
  String doctorId;
  String? clinicName;
  List<Permission> permissions;
  String? image;

  Staff(this.id, this.name, this.email, this.mobile, this.gender, this.role,
      this.doctorId, this.permissions, this.image, this.clinicName);

  Staff.empty()
      : id = '',
        name = '',
        email = '',
        mobile = '',
        gender = 'Male',
        role = '',
        doctorId = "1",
        permissions = [],
        image = '';

  Map<String, dynamic> toJson() {
    String permissionsString;
    try {
      permissionsString = permissions
          .map((p) => p.toString().split('.').last)
          .toList()
          .join(',');
    } catch (e) {
      permissionsString = "";
    }

    return {
      'staff_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'gender': gender,
      'role': role,
      'doctor_id': doctorId,
      'permissions': permissionsString,
    };
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    List<Permission> permission = [];
    try {
      permission = (json['permissions'] as String)
          .split(',')
          .map(
            (p) => Permission.values
                .firstWhere((e) => e.toString() == 'Permission.$p'),
          )
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    return Staff(
        json['staff_id'] as String,
        json['name'] as String,
        json['email'] as String?,
        json['mobile'] as String,
        json['gender'] as String?,
        json['role'] as String,
        json['doctor_id'] as String,
        permission,
        json['image'] as String?,
        json['clinic_name'] as String?);
  }

  List<Permission> getPermissionsFromJson(dynamic json) {
    try {
      return json
          .split(',')
          .map(
            (p) => Permission.values
                .firstWhere((e) => e.toString() == 'Permission.$p'),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}

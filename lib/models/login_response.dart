import 'package:rxvault/models/staff.dart';
import 'package:rxvault/models/doctor_info.dart';

class LoginResponse {
  final bool? success;
  final String? status;
  final String message;
  final int? otp;
  final DoctorInfo? userInfo;
  final Staff? staff;

  LoginResponse({
    this.success,
    required this.message,
    required this.otp,
    required this.userInfo,
    this.status,
    this.staff,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json, bool isStaff) {
    return LoginResponse(
      success: json['success'] as bool?,
      status: json['status'] as String?,
      message: json['message'] as String,
      otp: json['otp'] as int?,
      userInfo: json['data'] == null
          ? null
          : DoctorInfo.fromJson(json['data'] as Map<String, dynamic>, isStaff),
    );
  }
}

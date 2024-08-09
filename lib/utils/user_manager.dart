import 'dart:convert';
import 'dart:core';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/doctor_info.dart';

class UserManager {
  static const String _userInfoKey = 'userInfo';
  static const String isLoggedIn = "isLoggedIn";
  static const String userId = "userId";
  static const String profileImageUrl = "profileImageUrl";
  static const String isFirstTime = "isFirstTime";
  static const String clinicName = "clinicName";
  static const String name = "name";
  static const String isStaff = "isStaff";
  static const String permissions = "permissions";

  static Future<void> saveUserInfo(DoctorInfo userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = userInfo.toJson();
    final userInfoString = jsonEncode(userInfoJson);
    await prefs.setString(_userInfoKey, userInfoString);
    await prefs.setBool(isLoggedIn, true);
    await prefs.setString(userId, userInfo.doctorId ?? "1");
    await prefs.setString(clinicName, userInfo.clinicName ?? "Clinic");
    await prefs.setBool(isStaff, userInfo.isStaff ?? false);
    await prefs.setString(permissions, userInfo.permissions ?? "");
    await prefs.setString(name, userInfo.name ?? "");
  }

  static Future<String> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(permissions) ?? "";
  }

  static Future<DoctorInfo?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString(_userInfoKey);
    if (userInfoString == null) {
      return null;
    }
    final userInfoJson = jsonDecode(userInfoString);
    final res = DoctorInfo.fromJson(userInfoJson, null);
    return res;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(UserManager.userId);
  }

  static Future<String> getName() async {
    final userInfo = await getUserInfo();
    return userInfo?.name ?? '';
  }

  static Future<String> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(profileImageUrl) ?? "";
  }

  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> updateUserInfo(DoctorInfo updatedUserInfo) async {
    await saveUserInfo(updatedUserInfo);
  }
}

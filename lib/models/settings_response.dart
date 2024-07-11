import 'package:rxvault/models/setting.dart';

class SettingResponse {
  String success;
  String message;
  List<Setting> doctorsSetting;

  SettingResponse({
    required this.success,
    required this.message,
    required this.doctorsSetting,
  });

  factory SettingResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['DoctorsSetting'] ?? json['mr_settings']) as List;
    List<Setting> settingsList = list.map((i) => Setting.fromJson(i)).toList();

    return SettingResponse(
      success: json['success'] ?? json['status'],
      message: json['message'],
      doctorsSetting: settingsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'DoctorsSetting':
          doctorsSetting.map((setting) => setting.toJson()).toList(),
    };
  }
}

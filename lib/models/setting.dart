import 'package:rxvault/utils/constants.dart';

class Setting {
  String? patientId;
  String? settingId;
  String? doctorId;
  String? openClose;
  String? openTime;
  String? closeTime;
  String? clinicAddress;
  String? itemDetails;
  String? status;
  String? created;

  Setting({
    this.patientId,
    this.settingId,
    this.doctorId,
    this.openClose,
    this.openTime,
    this.closeTime,
    this.clinicAddress,
    this.itemDetails,
    this.status,
    this.created,
  });

  Setting.empty();

  factory Setting.fromJson(Map<String, dynamic> json) {
    final setting = Setting(
      settingId: json['setting_id'] ?? json['mr_setting_id'],
      doctorId: json['user_id'],
      openClose: json['open_close'] ?? json['mr_open_close'],
      openTime: json['open_time'] ?? json['mr_open_time'],
      closeTime: json['close_time'] ?? json['mr_close_time'],
      clinicAddress: json['clinic_address'],
      itemDetails: json['item_details'],
      status: json['status'],
      created: json['created'],
    );

    return setting;
  }

  Map<String, dynamic> toJson() {
    return {
      'setting_id': settingId ?? "",
      'user_id': doctorId,
      'open_close': openClose ?? "",
      'open_time': openTime ?? "",
      'close_time': closeTime ?? "",
      'clinic_address': clinicAddress ?? "",
      'item_details': itemDetails ?? "",
      'status': status ?? "",
      'created': created ?? "",
    };
  }

  List<bool> getDaySelection() {
    if (openClose?.isEmpty ?? true) {
      return defaultSelection;
    }

    try {
      return openClose!.split('').map((char) => char == '1').toList();
    } catch (e) {
      return defaultSelection;
    }
  }

  void setData(Setting setting) {
    patientId = setting.patientId;
    settingId = setting.settingId;
    doctorId = setting.doctorId;
    openClose = setting.openClose;
    openTime = setting.openTime;
    closeTime = setting.closeTime;
    clinicAddress = setting.clinicAddress;
    itemDetails = setting.itemDetails;
    status = setting.status;
    created = setting.created;
  }
}

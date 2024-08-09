import 'package:rxvault/utils/constants.dart';

class Setting {
  String? patientId;
  String? settingId;
  String? doctorId;
  String? openClose;
  String? openTime1;
  String? closeTime2;
  String? openTime2;
  String? closeTime1;
  String? clinicAddress;
  String? itemDetails;
  String? status;
  String? created;

  Setting({
    this.patientId,
    this.settingId,
    this.doctorId,
    this.openClose,
    this.openTime1,
    this.closeTime2,
    this.openTime2,
    this.closeTime1,
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
      openTime1: json['open_time'] ?? json['mr_open_time'],
      closeTime1: json['close_time'] ?? json['mr_close_time'],
      openTime2: json['open_time_slot2'],
      closeTime2: json['close_time_slot2'],
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
      'open_time': openTime1 ?? "",
      'open_time_slot2': openTime2 ?? "",
      'close_time': closeTime1 ?? "",
      'close_time_slot2': closeTime2 ?? "",
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
    openTime1 = setting.openTime1;
    openTime2 = setting.openTime2;
    closeTime1 = setting.closeTime1;
    closeTime2 = setting.closeTime2;
    clinicAddress = setting.clinicAddress;
    itemDetails = setting.itemDetails;
    status = setting.status;
    created = setting.created;
  }
}

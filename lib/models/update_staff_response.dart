import '../../models/staff.dart'; // Import Staff class or replace with correct path

class UpdateStaffResponse {
  String success;
  String message;
  Staff? staff;

  UpdateStaffResponse({
    required this.success,
    required this.message,
    required this.staff,
  });

  factory UpdateStaffResponse.fromJson(Map<String, dynamic> json) {
    String success = json['status'];
    String message = json['message'];

    Staff? staff;
    if (json['data'] != null) {
      try {
        staff = Staff.fromJson(json['data']);
      } catch (e) {
        staff = null;
      }
    }

    return UpdateStaffResponse(
      success: success,
      message: message,
      staff: staff,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': success,
      'message': message,
      'staff': staff?.toJson(),
    };
  }
}

class CreateStaffResponse {
  String success;
  String message;
  String? staffId;

  CreateStaffResponse({
    required this.success,
    required this.message,
    required this.staffId,
  });

  factory CreateStaffResponse.fromJson(Map<String, dynamic> json) {
    String success = json['status'];
    String message = json['message'];
    String? staffId = json['staff_id'];

    return CreateStaffResponse(
      success: success,
      message: message,
      staffId: staffId,
    );
  }
}

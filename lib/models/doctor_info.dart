class DoctorInfo {
  String? name;
  String? mobile;
  String? email;
  String? address;
  String? clinicName;
  String? speciality;
  String? doctorId;
  String? staffId;
  String? image;
  String? role;
  String? gender;
  String? permissions;
  bool? isStaff;
  String? playerId;

  DoctorInfo({
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
    required this.clinicName,
    required this.speciality,
    required this.image,
    required this.isStaff,
    required this.doctorId,
    this.staffId,
    this.permissions,
  });

  DoctorInfo.empty({
    this.name = "",
    this.mobile = "",
    this.clinicName = "",
    this.doctorId = "",
    this.isStaff = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": doctorId,
      "staff_id": staffId,
      "name": name,
      "mobile": mobile,
      "email": email,
      "address": address,
      "hospital_name": clinicName,
      "speciality": speciality,
      "image": image,
      "app_id": playerId
    };
  }

  factory DoctorInfo.fromJson(Map<String, dynamic> json, bool? isStaff) {
    return DoctorInfo(
        isStaff: isStaff ?? json['isStaff'],
        doctorId: json['user_id'] ?? json['doctor_id'],
        name: json['name'],
        mobile: json['mobile'],
        staffId: json['staff_id'],
        email: json['email'],
        address: json['address'],
        clinicName: json['hospital_name'],
        permissions: json['permissions'],
        speciality: json['speciality'],
        image: json['image']);
  }
}

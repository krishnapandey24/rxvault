class Patient {
  String patientId;
  String name;
  String age;
  String mobile;
  String gender;
  String? allergic;
  String? diagnosis;
  String? userId;
  String? date;
  String? selectedServices;
  String? totalAmount;
  String? doctorPatientId;
  String? createdBy;

  get isAllergic => allergic == "Yes";

  get getTotalAmount {
    if (totalAmount == null || totalAmount == "") return "0";
    return totalAmount;
  }

  factory Patient.newPatient(String userId) {
    return Patient(
      patientId: "",
      name: "",
      age: "",
      mobile: "",
      gender: "Male",
      allergic: "No",
      diagnosis: "",
      userId: userId,
    );
  }

  Patient({
    required this.patientId,
    required this.name,
    required this.age,
    required this.mobile,
    required this.gender,
    required this.allergic,
    required this.diagnosis,
    this.userId,
    this.date,
    this.doctorPatientId,
    this.totalAmount,
    this.selectedServices,
    this.createdBy,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patient_id'],
      name: json['patient_name'] ?? "",
      age: json['patient_age'] ?? "",
      mobile: json['patient_mobile'] ?? "",
      gender: json['patient_gender'] ?? "",
      allergic: json['patient_allergic'] ?? "",
      diagnosis: json['diagnosis'] ?? "",
      doctorPatientId: json['doctor_patient_id'],
      selectedServices: json['selected_services'],
      totalAmount: json['total_amount'],
      date: json['date'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'user_id': userId,
      'patient_name': name,
      'patient_age': age,
      'patient_mobile': mobile,
      'patient_gender': gender,
      'patient_allergic': allergic,
      'diagnosis': diagnosis,
      "selected_services": selectedServices,
      "total_amount": totalAmount,
    };
  }

  void copyFrom(Patient other) {
    patientId = other.patientId;
    name = other.name;
    age = other.age;
    mobile = other.mobile;
    gender = other.gender;
    allergic = other.allergic;
    diagnosis = other.diagnosis;
    userId = other.userId;
    date = other.date;
    selectedServices = other.selectedServices;
    totalAmount = other.totalAmount;
    doctorPatientId = other.doctorPatientId;
  }
}

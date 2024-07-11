import 'patient.dart';

class PatientListResponse {
  final String success;
  final String message;
  final List<Patient> patientList;

  PatientListResponse({
    required this.success,
    required this.message,
    required this.patientList,
  });

  factory PatientListResponse.fromJson(Map<String, dynamic> json) {
    return PatientListResponse(
      success: json['success'] as String,
      message: json['message'] as String,
      patientList:
          ((json['PatientList'] ?? json['DoctorsPatientList']) as List<dynamic>)
              .map((e) => Patient.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

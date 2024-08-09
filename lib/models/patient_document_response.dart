import 'package:intl/intl.dart';

class PatientDocumentResponse {
  List<Document> allDocuments;
  String success;
  String message;

  PatientDocumentResponse({
    required this.allDocuments,
    required this.success,
    required this.message,
  });

  factory PatientDocumentResponse.fromJson(Map<String, dynamic> json) {
    return PatientDocumentResponse(
      allDocuments: (json['AllDocuments'] as List<dynamic>)
          .map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList(),
      success: json['success'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AllDocuments': allDocuments.map((e) => e.toJson()).toList(),
      'success': success,
      'message': message,
    };
  }
}

class Document {
  String id;
  String doctorId;
  String patientId;
  String doctorPatientId;
  String title;
  String imageUrl;
  String created;
  DateTime? date;

  Document({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorPatientId,
    required this.title,
    required this.imageUrl,
    required this.created,
    this.date,
  }) {
    date ??= parseCreatedDate(created);
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['document_id'] as String,
      doctorId: json['doctor_id'] as String,
      patientId: json['patient_id'] as String,
      doctorPatientId: json['doctor_patient_id'] as String,
      title: json['title'] as String,
      imageUrl: json['document'] as String,
      created: json['created'] as String,
      date: parseCreatedDate(json['created'] as String),
    );
  }

  static DateTime parseCreatedDate(String created) {
    final dateFormat = DateFormat('MM-dd-yyyy hh:mm a');
    return dateFormat.parse(created);
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'doctor_patient_id': doctorPatientId,
      'title': title,
      'document': imageUrl,
      'created': created,
    };
  }
}

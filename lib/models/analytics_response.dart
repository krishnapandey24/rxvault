import 'package:rxvault/models/patient.dart';

class AnalyticsResponse {
  String success;
  String message;
  List<AnalyticsData> analytics;

  AnalyticsResponse({
    required this.success,
    required this.message,
    required this.analytics,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      success: json['success'],
      message: json['message'],
      analytics: List<AnalyticsData>.from(
          json['data'].map((x) => AnalyticsData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': List<dynamic>.from(analytics.map((x) => x.toJson())),
    };
  }
}

class AnalyticsData {
  String date;
  double count;
  double amount;
  List<Patient> patients;

  AnalyticsData({
    required this.date,
    required this.count,
    required this.amount,
    required this.patients,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      date: json['date'],
      count: json['count'].toDouble(),
      amount: json['amount'].toDouble(),
      patients:
          List<Patient>.from(json['patients'].map((x) => Patient.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'count': count,
      'amount': amount,
      'patients': List<dynamic>.from(patients.map((x) => x.toJson())),
    };
  }
}

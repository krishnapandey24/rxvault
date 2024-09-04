
class OtpResponse {
  final String success;
  final String message;
  final int? otp;

  OtpResponse({
    required this.success,
    required this.message,
    required this.otp,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] as String,
      message: json['message'] as String,
      otp: json['otp'] as int?,
    );
  }
}

class RegisterResponse {
  final String success;
  final String message;
  final int? userId;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.userId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as String,
      message: json['message'] as String,
      userId: json['user_id'] == null ? null : json['user_id'] as int,
    );
  }
}

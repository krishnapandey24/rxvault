class AddDocumentResponse {
  String success;
  String message;

  AddDocumentResponse({
    required this.success,
    required this.message,
  });

  factory AddDocumentResponse.fromJson(Map<String, dynamic> json) {
    return AddDocumentResponse(
      success: json['success'] as String,
      message: json['message'] as String,
    );
  }
}

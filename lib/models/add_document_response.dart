class AddDocumentResponse {
  String success;
  String message;
  // int imageId;
  // String documentImage;

  AddDocumentResponse({
    required this.success,
    required this.message,
    // required this.imageId,
    // required this.documentImage,
  });

  factory AddDocumentResponse.fromJson(Map<String, dynamic> json) {
    return AddDocumentResponse(
      success: json['success'] as String,
      message: json['message'] as String,
      // imageId: json['image_id'] as int,
      // documentImage: json['document_image'] as String,
    );
  }
}

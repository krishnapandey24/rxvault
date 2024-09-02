class NotificationListResponse {
  String? success;
  String? message;
  List<Message> notificationModels = [];

  NotificationListResponse(
      {this.success, this.message, required this.notificationModels});

  NotificationListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['notifications'] != null) {
      notificationModels = <Message>[];
      json['notifications'].forEach((v) {
        notificationModels.add(Message.fromJson(v));
      });
    }
  }
}

class Message {
  final String senderName;
  final String messageTitle;
  final String message;
  final String created;

  Message({
    required this.senderName,
    required this.messageTitle,
    required this.message,
    required this.created,
  });

  // Factory method to create a Message instance from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderName: json['sender_name'] as String,
      messageTitle: json['message_title'] as String,
      message: json['message'] as String,
      created: json['created'] as String,
    );
  }

  // Optional: Method to convert the Message instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'sender_name': senderName,
      'message_title': messageTitle,
      'message': message,
    };
  }
}

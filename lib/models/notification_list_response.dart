class NotificationListResponse {
  String? success;
  String? message;
  List<NotificationModel> notificationModels = [];

  NotificationListResponse(
      {this.success, this.message, required this.notificationModels});

  NotificationListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['NotificationModels'] != null) {
      notificationModels = <NotificationModel>[];
      json['NotificationModels'].forEach((v) {
        notificationModels.add(NotificationModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['NotificationModels'] =
        notificationModels.map((v) => v.toJson()).toList();
    return data;
  }
}

class NotificationModel {
  String? notificationModelId;
  String? title;
  String? notification;
  String? date;
  String? created;

  NotificationModel(
      {this.notificationModelId,
      this.title,
      this.notification,
      this.date,
      this.created});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    notificationModelId = json['notificationModel_id'];
    title = json['title'];
    notification = json['notificationModel'];
    date = json['date'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notificationModel_id'] = notificationModelId;
    data['title'] = title;
    data['notificationModel'] = notification;
    data['date'] = date;
    data['created'] = created;
    return data;
  }
}

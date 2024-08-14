class MrListResponse {
  String? success;
  String? message;
  List<MR>? mrList;

  MrListResponse({this.success, this.message, this.mrList});

  MrListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['MrList'] != null) {
      mrList = <MR>[];
      json['MrList'].forEach((v) {
        mrList!.add(MR.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (mrList != null) {
      data['MrList'] = mrList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MR {
  String? doctorMrId;
  String? userId;
  String? mrId;
  String? mrName;
  String? company;
  String? products;
  String? date;
  String? status;
  String? created;

  MR({
    this.doctorMrId,
    this.userId,
    this.mrId,
    this.mrName,
    this.products,
    this.date,
    this.status,
    this.created,
    this.company,
  });

  MR.fromJson(Map<String, dynamic> json) {
    doctorMrId = json['doctor_mr_id'];
    userId = json['user_id'];
    mrId = json['mr_id'];
    products = json['products'];
    date = json['date'];
    mrName = json['mr_name'];
    status = json['status'];
    company = json['mr_company'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['doctor_mr_id'] = doctorMrId;
    data['user_id'] = userId;
    data['mr_id'] = mrId;
    data['products'] = products;
    data['date'] = date;
    data['status'] = status;
    data['created'] = created;
    data['company'] = company;
    return data;
  }
}

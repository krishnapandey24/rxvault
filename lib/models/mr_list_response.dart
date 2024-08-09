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
  String? products;
  String? date;
  String? status;
  String? created;
  List<DoctorsList>? doctorsList;

  MR(
      {this.doctorMrId,
      this.userId,
      this.mrId,
      this.mrName,
      this.products,
      this.date,
      this.status,
      this.created,
      this.doctorsList});

  MR.fromJson(Map<String, dynamic> json) {
    doctorMrId = json['doctor_mr_id'];
    userId = json['user_id'];
    mrId = json['mr_id'];
    products = json['products'];
    date = json['date'];
    mrName = json['mr_name'];
    status = json['status'];
    created = json['created'];
    if (json['DoctorsList'] != null) {
      doctorsList = <DoctorsList>[];
      json['DoctorsList'].forEach((v) {
        doctorsList!.add(DoctorsList.fromJson(v));
      });
    }
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
    if (doctorsList != null) {
      data['DoctorsList'] = doctorsList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DoctorsList {
  String? userId;
  String? role;
  String? name;
  String? email;
  String? mobile;
  String? address;
  String? gender;
  String? hospitalName;
  String? speciality;
  String? paidStatus;
  String? image;
  String? status;

  DoctorsList(
      {this.userId,
      this.role,
      this.name,
      this.email,
      this.mobile,
      this.address,
      this.gender,
      this.hospitalName,
      this.speciality,
      this.paidStatus,
      this.image,
      this.status});

  DoctorsList.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    address = json['address'];
    gender = json['gender'];
    hospitalName = json['hospital_name'];
    speciality = json['speciality'];
    paidStatus = json['paid_status'];
    image = json['image'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['role'] = role;
    data['name'] = name;
    data['email'] = email;
    data['mobile'] = mobile;
    data['address'] = address;
    data['gender'] = gender;
    data['hospital_name'] = hospitalName;
    data['speciality'] = speciality;
    data['paid_status'] = paidStatus;
    data['image'] = image;
    data['status'] = status;
    return data;
  }
}

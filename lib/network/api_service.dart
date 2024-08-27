import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:rxvault/models/add_document_response.dart';
import 'package:rxvault/models/analytics_response.dart';
import 'package:rxvault/models/doctor_info.dart';
import 'package:rxvault/models/patient_document_response.dart';
import 'package:rxvault/models/update_staff_response.dart';
import 'package:rxvault/utils/user_manager.dart';

import '../enums/day.dart';
import '../models/login_response.dart';
import '../models/mr_list_response.dart';
import '../models/notification_list_response.dart';
import '../models/patient.dart';
import '../models/patient_list_response.dart';
import '../models/register_response.dart';
import '../models/setting.dart';
import '../models/settings_response.dart';
import '../models/staff.dart';
import '../utils/constants.dart';
import '../utils/exceptions/custom_exception.dart';
import '../utils/exceptions/registration_required.dart';
import '../utils/utils.dart';

class API {
  static const baseUrl = 'https://ensivosolutions.com/rxvault/api/';
  // static const baseUrl = 'http://122.170.7.173/RxVault/Api/';

  static CustomException swwException =
      CustomException("Something went wrong, Please try again");

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'X-API-KEY': '3d628cf8204cff3d5a8e64b22419dd76dc83df6b',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('rxvault:rxvaultdb2cd70d00bc0a8baee06103ee5f9cb6'))}',
      },
    ),
  );

  Future<AddDocumentResponse> addDocument(
      String patientId,
      String doctorPatientId,
      String doctorId,
      String title,
      List<Uint8List> imageBytesList,
      String date) async {
    final formData = FormData();
    formData.fields.add(MapEntry('patient_id', patientId));
    formData.fields.add(MapEntry('doctor_id', doctorId));
    formData.fields.add(MapEntry('title', title));
    formData.fields.add(MapEntry('doctor_patient_id', doctorPatientId));
    formData.fields.add(MapEntry('date', date));
    formData.fields.add(const MapEntry('created_by', 'Doctor'));

    for (int i = 0; i < imageBytesList.length; i++) {
      final compressedImage =
          kIsWeb ? imageBytesList[i] : await compressList(imageBytesList[i]);
      formData.files.add(MapEntry(
        'document[]',
        MultipartFile.fromBytes(compressedImage, filename: '$title-$i'),
      ));
    }

    final response = await _dio.post(
      'AddDocuments',
      data: formData,
    );

    final addDocumentResponse = AddDocumentResponse.fromJson(response.data);

    if (addDocumentResponse.success == failure) {
      throw CustomException(addDocumentResponse.message);
    }

    return addDocumentResponse;
  }

  Future<void> registerUser(DoctorInfo requestBody) async {
    final response = await _dio.post("Register",
        data: FormData.fromMap(requestBody.toJson()));

    final registerResponse = RegisterResponse.fromJson(response.data);
    if (registerResponse.success != success) {
      throw CustomException(registerResponse.message);
    }
  }

  Future<void> updateUser(DoctorInfo userInfo) async {
    final response = await _dio.post("UpdateProfile",
        data: FormData.fromMap(userInfo.toJson()));

    final updateResponse = RegisterResponse.fromJson(response.data);
    if (updateResponse.success != "Success") {
      throw CustomException(updateResponse.message);
    }

    await UserManager.updateUserInfo(userInfo);
  }

  Future<DoctorInfo> login(
      String phoneNumber, String loginType, String? appId) async {
    try {
      print("there there is : $appId");
      final isStaffLogin = loginType == "staff";
      final endpoint = isStaffLogin ? "staff_login" : "Login";
      appId = appId?.isEmpty == true ? "aaa" : appId;
      final response = await _dio.post(endpoint,
          data: FormData.fromMap({
            "mobile": phoneNumber,
            "password": "1234",
            "app_id": appId,
          }));

      final loginResponse = LoginResponse.fromJson(response.data, isStaffLogin);

      if (loginResponse.success == false || loginResponse.status == failure) {
        throw loginResponse.message == newUser
            ? RegistrationRequired()
            : CustomException(loginResponse.message);
      }

      loginResponse.userInfo!.isStaff = isStaffLogin;
      UserManager.saveUserInfo(loginResponse.userInfo!);
      return loginResponse.userInfo!;
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 404) {
        throw CustomException(staffNotFound);
      } else {
        throw CustomException(e.response?.data?["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Patient>> getPatientList(String userId, String search) async {
    try {
      final response = await _dio.post(
        "PatientList",
        data: FormData.fromMap({"user_id": userId, "search": search}),
      );
      return PatientListResponse.fromJson(response.data).patientList;
    } catch (e) {
      return [];
    }
  }

  Future<List<Patient>> getSelectedPatientList(String userId,
      [String? date]) async {
    try {
      final response = await _dio.post(
        "DoctorsPatientList",
        data: FormData.fromMap(
          {
            "user_id": userId,
            "date": date ?? Utils.getCurrentDate(),
          },
        ),
      );
      List<Patient> patients =
          PatientListResponse.fromJson(response.data).patientList;
      List<Patient> filteredPatients = [];
      for (var patient in patients) {
        if (patient.createdBy != "patient") {
          filteredPatients.add(patient);
        }
      }
      return filteredPatients;
    } catch (e) {
      return [];
    }
  }

  Future<List<Patient>> getPatientAmountDetails(
      String doctorId, String patientId) async {
    try {
      final response = await _dio.post("DoctorsPatientList",
          data:
              FormData.fromMap({"user_id": doctorId, "patient_id": patientId}));
      return PatientListResponse.fromJson(response.data).patientList;
    } catch (e) {
      return [];
    }
  }

  Future<void> addDoctorsPatient(String userId, String patientId,
      [String? selectedServices, String? totalAmount]) async {
    final responseData = (await _dio.post("AddDoctorsPatient",
            data: FormData.fromMap({
              "user_id": userId,
              "patient_id": patientId,
              "selected_services": selectedServices ?? "",
              "total_amount": totalAmount ?? "0",
              "date": Utils.getCurrentDate(),
              "created_by": "doctor",
            })))
        .data;

    String success = responseData["success"];
    String message = responseData["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<void> updateDoctorPatient(
      String doctorPatientId, String userId, String patientId,
      [String? selectedServices, String? totalAmount]) async {
    final responseData = (await _dio.post("UpdateDoctorsPatient",
            data: FormData.fromMap({
              "user_id": userId,
              "patient_id": patientId,
              "doctor_patient_id": doctorPatientId,
              "selected_services": selectedServices ?? "",
              "total_amount": totalAmount ?? "0",
              "date": Utils.getCurrentDate(),
              "created_by": "doctor",
            })))
        .data;

    String success = responseData["success"];
    String message = responseData["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<void> deleteDoctorsPatientDocument(String documentId) async {
    final responseData = (await _dio.post(
      "DeleteDocument",
      data: FormData.fromMap(
        {
          "document_id": documentId,
        },
      ),
    ))
        .data;

    String success = responseData["success"];
    String message = responseData["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<void> deleteDoctorsPatientDocuments(
      String patientId, String doctorId) async {
    final responseData = (await _dio.post(
      "DeletePatientDocuments",
      data: FormData.fromMap(
        {"patient_id": patientId, "doctor_id": doctorId},
      ),
    ))
        .data;

    String success = responseData["success"];
    String message = responseData["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<List<Patient>?> checkPatient(String mobile) async {
    final response = await _dio.post(
      "ChkPatient",
      data: FormData.fromMap(
        {
          "patient_mobile": mobile,
        },
      ),
    );

    PatientListResponse patientListResponse =
        PatientListResponse.fromJson(response.data);
    if (patientListResponse.success == failure) {
      if (patientListResponse.message == "Patient not available!") {
        return null;
      } else {
        throw CustomException("Patient Not Found");
      }
    }

    return patientListResponse.patientList;
  }

  Future<void> deleteSelectedPatient(
      String doctorPatientId, String doctorId) async {
    final responseData = (await _dio.post(
      "DeletePatientDoctor",
      data: FormData.fromMap(
        {"user_id": doctorId, "doctor_patient_id": doctorPatientId},
      ),
    ))
        .data;

    String success = responseData["success"];
    String message = responseData["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<int?> addPatient(Patient patient, String userId) async {
    final map = patient.toJson();
    map['user_id'] = userId;
    FormData formData = FormData.fromMap(map);
    final response = (await _dio.post("AddPatient", data: formData)).data;
    String success = response["success"];
    String message = response["message"];
    if (success == failure && message != "Patient already exists!") {
      throw CustomException(message);
    }
    return response["patient_id"] as int?;
  }

  Future<void> updatePatient(Patient patient) async {
    FormData formData = FormData.fromMap(patient.toJson());
    final response = (await _dio.post("UpdatePatient", data: formData)).data;
    String success = response["success"];
    String message = response["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<void> staffOperation(
      String operation, Map<String, dynamic> staff) async {
    FormData formData = FormData.fromMap(staff);
    final response = (await _dio.post(operation, data: formData)).data;
    String success = response["status"];
    String message = response["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<String> createStaff(Map<String, dynamic> staff) async {
    FormData formData = FormData.fromMap(staff);
    final response = await _dio.post("create_staff", data: formData);
    UpdateStaffResponse createStaffResponse =
        UpdateStaffResponse.fromJson(response.data);
    if (createStaffResponse.success == failure ||
        createStaffResponse.staff == null) {
      throw CustomException(createStaffResponse.message);
    }
    return createStaffResponse.staff!.id;
  }

  Future<Staff> updateStaff(Map<String, dynamic> staff, bool imDoctor) async {
    FormData formData = FormData.fromMap(staff);
    final response = await _dio.post("update_staff", data: formData);
    UpdateStaffResponse updateStaffResponse =
        UpdateStaffResponse.fromJson(response.data);
    if (updateStaffResponse.success == failure ||
        updateStaffResponse.staff == null) {
      throw CustomException(updateStaffResponse.message);
    }

    if (!imDoctor) {
      UserManager.updateUserInfo(
          DoctorInfo.fromJson(updateStaffResponse.staff!.toJson(), true));
    }

    return updateStaffResponse.staff!;
  }

  Future<String> updateStaffImage(String staffId,
      [String? filePath, Uint8List? imageBytes]) async {
    final formData = FormData.fromMap({
      'user_id': staffId,
      'image': kIsWeb
          ? MultipartFile.fromBytes(imageBytes!)
          : await MultipartFile.fromFile(filePath!),
    });

    try {
      Response response = await _dio.post(
        "update_staff",
        data: formData,
      );
      UpdateStaffResponse updateStaffResponse =
          UpdateStaffResponse.fromJson(response.data);
      if (updateStaffResponse.success == failure ||
          updateStaffResponse.staff == null) {
        throw CustomException(updateStaffResponse.message);
      }

      return updateStaffResponse.staff?.image ?? "";
    } catch (e) {
      throw CustomException("Unable to upload image");
    }
  }

  Future<void> deleteStaff(String operation, String id) async {
    FormData formData = FormData.fromMap({"id": id});
    final response = (await _dio.post("delete_staff", data: formData)).data;
    String success = response["status"];
    String message = response["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<List<Staff>> getStaff(String doctorId) async {
    try {
      FormData formData = FormData.fromMap({"doctor_id": doctorId});
      final response = await _dio.post("get_all_staff", data: formData);
      final staffListResponse = StaffResponse.fromJson(response.data);
      if (staffListResponse.status == failure) {
        throw CustomException("Something went wrong");
      }
      return staffListResponse.staff;
    } catch (e) {
      return [];
    }
  }

  Future<bool> doesStuffExists(String phoneNumber) async {
    FormData formData = FormData.fromMap({"doctor_id": phoneNumber});
    return (await _dio.post("check_staff", data: formData)).data as bool;
  }

  Future<String> updateImage(String doctorId,
      [String? filePath, Uint8List? imageBytes]) async {
    final formData = FormData.fromMap({
      'user_id': doctorId,
      'image': kIsWeb
          ? MultipartFile.fromBytes(imageBytes!)
          : await MultipartFile.fromFile(filePath!),
    });

    final response = (await _dio.post(
      'update_image',
      data: formData,
    ))
        .data;
    String success = response["success"];
    String message = response["message"];

    if (success == failure) throw CustomException(message);

    return response['image_url'];
  }

  Future<List<Document>> getPatientDocuments(
      String patientId, String doctorId, String? date) async {
    try {
      final map = {
        'patient_id': patientId,
        'doctor_id': doctorId,
      };

      if (date != null) {
        map['date'] = date;
      }
      final formData = FormData.fromMap(map);

      final response = await _dio.post(
        'PatientDocuments',
        data: formData,
      );

      final pdr = PatientDocumentResponse.fromJson(response.data);

      if (pdr.success == failure) [];
      return pdr.allDocuments;
    } catch (e) {
      return [];
    }
  }

  Future<Setting> getSettings(String doctorId) async {
    try {
      final formData = FormData.fromMap({
        'user_id': doctorId,
      });

      final response = await _dio.post(
        'getSettings',
        data: formData,
      );

      final settingsResponse = SettingResponse.fromJson(response.data);

      return settingsResponse.doctorsSetting.first;
    } catch (e) {
      final emptySettings = Setting.empty();
      emptySettings.doctorId = doctorId;
      return emptySettings;
    }
  }

  Future<Setting> getMrSettings(String doctorId) async {
    try {
      final formData = FormData.fromMap({
        'doctor_id': doctorId,
      });

      final response = await _dio.post(
        'getMrSettings',
        data: formData,
      );

      final settingsResponse = SettingResponse.fromJson(response.data);
      return settingsResponse.doctorsSetting.first;
    } catch (e) {
      return Setting.empty();
    }
  }

  Future<void> updateSettings(Setting setting) async {
    final formData = FormData.fromMap(setting.toJson());
    final response = await _dio.post(
      'Settings',
      data: formData,
    );

    if (response.data["success"] == failure) {
      throw CustomException(response.data["failure"]);
    }
  }

  Future<void> updateMr(Setting setting) async {
    final formData = FormData.fromMap({
      "doctor_id": setting.doctorId,
      "mr_open_close": setting.openClose,
      "mr_open_time": setting.openTime1,
      "mr_close_time": setting.closeTime2,
      "status": setting.status,
    });
    final response = await _dio.post(
      'MRSettings',
      data: formData,
    );

    if (response.data["success"] == failure) {
      throw CustomException(response.data["failure"]);
    }
  }

  Future<List<MR>> getMRList(String doctorId, Day day) async {
    final formData = FormData.fromMap({
      "user_id": doctorId,
      "days": day.name,
    });
    final response = await _dio.post(
      'MrDoctorList',
      data: formData,
    );

    MrListResponse mrListResponse = MrListResponse.fromJson(response.data);

    if (response.data["success"] == failure) {
      return [];
    }

    return mrListResponse.mrList ?? [];
  }

  Future<List<AnalyticsData>> getAnalytics(String userId,
      [String? startDate, String? endDate]) async {
    FormData formData;
    if (startDate != null) {
      formData = FormData.fromMap({
        "user_id": userId,
        "startdate": startDate,
        "enddate": endDate,
      });
    } else {
      formData = FormData.fromMap({
        "user_id": userId,
      });
    }
    final response = await _dio.post(
      'Analytics',
      data: formData,
    );

    AnalyticsResponse analyticsResponse =
        AnalyticsResponse.fromJson(response.data);

    if (response.data["success"] == failure) {
      throw CustomException("No Data Available");
    }

    return analyticsResponse.analytics;
  }

  void makeRequest(BuildContext context, Function apiFunction,
      [String? loaderText]) async {
    Utils.showLoader(context, loaderText);
    try {
      await apiFunction();
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    FormData formData = FormData.fromMap({
      "user_id": userId,
    });

    try {
      Response response = await _dio.post(
        "NotificationsList",
        data: formData,
      );

      NotificationListResponse notificationListResponse =
          NotificationListResponse.fromJson(response.data);
      final json = response.data;
      if (json["success"] == failure) return [];
      return notificationListResponse.notificationModels;
    } catch (t) {
      return [];
    }
  }

  Future clearNotifications(String userId) async {
    FormData formData = FormData.fromMap({
      "user_id": userId,
    });

    try {
      Response response = await _dio.post(
        "ClearNotifications",
        data: formData,
      );

      final json = response.data;
      if (json["success"] == failure) {
        throw Exception((json["message"].toString()));
      }
    } catch (e) {
      throw Exception((e.toString()));
    }
  }

  submitFeedback(String text, String userId, String type) async {
    FormData formData = FormData.fromMap(
        {"user_id": userId, "message": text, "type": type, "subject": type});
    final response = (await _dio.post("SubmitFeedback", data: formData)).data;
    String success = response["success"];
    String message = response["message"];
    if (success == failure) {
      throw CustomException(message);
    }
  }

  Future<Uint8List> compressList(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      quality: 50,
    );
    return result;
  }
}

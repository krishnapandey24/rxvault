import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:rxvault/models/add_document_response.dart';
import 'package:rxvault/models/analytics_response.dart';
import 'package:rxvault/models/doctor_info.dart';
import 'package:rxvault/models/mr_list_response.dart';
import 'package:rxvault/models/patient_document_response.dart';
import 'package:rxvault/models/update_staff_response.dart';
import 'package:rxvault/utils/user_manager.dart';

import '../models/login_response.dart';
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
  static const baseUrl = 'http://122.170.7.173/RxVault/Api/';
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
      String patientId, String doctorPatientId, String doctorId, String title,
      [String? filePath, Uint8List? imageBytes]) async {
    final formData = FormData.fromMap({
      'patient_id': patientId,
      'doctor_id': doctorId,
      'title': title,
      'document': kIsWeb
          ? MultipartFile.fromBytes(imageBytes!, filename: title)
          : await MultipartFile.fromFile(filePath!, filename: title),
      'doctor_patient_id': doctorPatientId
    });

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

  Future<DoctorInfo> login(String phoneNumber, String loginType) async {
    try {
      final isStaffLogin = loginType == "staff";
      final endpoint = isStaffLogin ? "staff_login" : "Login";

      final response = await _dio.post(endpoint,
          data: FormData.fromMap({
            "mobile": phoneNumber,
            "password": "1234",
          }));

      final loginResponse = LoginResponse.fromJson(response.data, isStaffLogin);

      if (loginResponse.status == failure) {
        throw loginResponse.message == newUser
            ? RegistrationRequired()
            : CustomException(loginResponse.message);
      }

      loginResponse.userInfo!.isStaff = isStaffLogin;
      UserManager.saveUserInfo(loginResponse.userInfo!);

      return loginResponse.userInfo!;
    } on DioException catch (e, t) {
      print("$e $t");
      if (e.response != null && e.response?.statusCode == 404) {
        throw CustomException(staffNotFound);
      } else {
        rethrow;
      }
    } catch (e, t) {
      print("$e $t");
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
            "date": date ?? getCurrentDate(),
          },
        ),
      );
      return PatientListResponse.fromJson(response.data).patientList;
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
              "date": getCurrentDate()
            })))
        .data;

    String success = responseData["success"];
    String message = responseData["message"];
    if (success == failure) throw CustomException(message);
  }

  Future<void> deleteDoctorsPatientDocument(String documentId) async {
    final responseData = (await _dio.post(
      "DeletePatientDocument",
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

  Future<Patient?> checkPatient(String mobile) async {
    try {
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

      return patientListResponse.patientList.first;
    } catch (e) {
      throw CustomException("Patient Not Found");
    }
  }

  Future<void> deletePatientDoctor(
      String userId, String doctorPatientId) async {
    try {
      Dio dio = Dio();

      // Replace with your actual API endpoint
      String url = 'http://122.170.7.173/RxVault/Api/DeletePatientDoctor';

      // Replace with your actual headers
      Map<String, dynamic> headers = {
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
        'Authorization':
            'Basic cnh2YXVsdDpyeHZhdWx0ZGIyY2Q3MGQwMGJjMGE4YmFlZTA2MTAzZWU1ZjljYjY=',
        'Connection': 'keep-alive',
        'Referer': 'http://localhost:57608/',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0',
        'X-API-KEY': '3d628cf8204cff3d5a8e64b22419dd76dc83df6b',
        'Cookie': 'ci_session=5npo3vv1vm58uik3fo237asojlf93en6',
      };

      // Replace with your form data
      FormData formData = FormData.fromMap({
        'user_id': userId,
        'doctor_patient_id': doctorPatientId,
      });

      // Perform the HTTP POST request
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      // Handle success
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      // Handle any other logic here based on response
    } catch (e) {
      // Handle error
      print('Error: $e');
      // Handle error UI or other logic
    }
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
        map['date'] = Utils.reverseDate(date);
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
      return Setting.empty();
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
      "mr_open_time": setting.openTime,
      "mr_close_time": setting.closeTime,
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

  Future<List<MR>> getMRList(String doctorId) async {
    final formData = FormData.fromMap({
      "user_id": doctorId,
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

  String getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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
}

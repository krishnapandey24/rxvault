import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxvault/utils/utils.dart';
import 'package:universal_html/html.dart' as html;

import '../models/analytics_response.dart';
import '../models/patient.dart';

class ExcelGenerator {
  final BuildContext context;
  final List<AnalyticsData> analytics;
  final String fromTo;
  late Excel excel;

  ExcelGenerator(this.context, this.analytics, this.fromTo);

  Future<void> generateAndSavePatientExcel() async {
    excel = Excel.createExcel();
    for (var analytic in analytics) {
      addSheet(analytic.date, analytic.patients);
    }
    await saveExcelFile(excel);
  }

  void addSheet(DateTime date, List<Patient> patients) {
    Sheet sheetObject = excel[getDateTimeAsString(date)];
    CellStyle boldStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      bold: true,
    );
    sheetObject.cell(CellIndex.indexByString("A1")).value =
        const TextCellValue("Name");
    sheetObject.cell(CellIndex.indexByString("A1")).cellStyle = boldStyle;

    sheetObject.cell(CellIndex.indexByString("B1")).value =
        const TextCellValue("Age");
    sheetObject.cell(CellIndex.indexByString("C1")).value =
        const TextCellValue("Mobile");
    sheetObject.cell(CellIndex.indexByString("D1")).value =
        const TextCellValue("Allergic");
    sheetObject.cell(CellIndex.indexByString("A1")).cellStyle = boldStyle;
    sheetObject.cell(CellIndex.indexByString("B1")).cellStyle = boldStyle;
    sheetObject.cell(CellIndex.indexByString("C1")).cellStyle = boldStyle;
    sheetObject.cell(CellIndex.indexByString("D1")).cellStyle = boldStyle;

    for (int i = 0; i < patients.length; i++) {
      Patient patient = patients[i];
      sheetObject.cell(CellIndex.indexByString("A${i + 2}")).value =
          TextCellValue(patient.name);
      sheetObject.cell(CellIndex.indexByString("B${i + 2}")).value =
          TextCellValue(patient.age);
      sheetObject.cell(CellIndex.indexByString("C${i + 2}")).value =
          TextCellValue(patient.mobile);
      String isAllergic =
          (patient.allergic == null || patient.allergic == "No") ? "No" : "Yes";
      sheetObject.cell(CellIndex.indexByString("D${i + 2}")).value =
          TextCellValue(isAllergic);
    }
  }

  Future saveForPhone(String fileName, List<int> bytes) async {
    if (await isAndroidVersionLessThan10()) {
      bool havePermission = await requestWriteExternalStoragePermission();
      if (!havePermission) return;
    }
    Directory? directory;
    File? file;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      bool hasExisted = await directory.exists();
      if (!hasExisted) {
        directory.create();
      }

      file = File("${directory.path}${Platform.pathSeparator}$fileName.xlsx");
      if (!file.existsSync()) {
        await file.create();
      }
      await file.writeAsBytes(bytes);
      Utils.toast("File saved in the Downloads!");
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (file != null && file.existsSync()) {
        file.deleteSync();
      }
      Utils.toast("Unable to save excel file!");
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> saveExcelFile(Excel excel) async {
    List<int> bytes = excel.encode()!;
    String filename = "patients_$fromTo";
    if (kIsWeb) {
      saveForWeb(filename, bytes);
    } else {
      saveForPhone(filename, bytes);
    }
  }

  saveForWeb(String filename, List<int> bytes) {
    String outputPath = '$filename.xlsx';
    final blob = html.Blob([bytes],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', outputPath)
      ..click();
    html.Url.revokeObjectUrl(url);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<bool> isAndroidVersionLessThan10() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    int sdkInt = androidInfo.version.sdkInt;
    return sdkInt < 29;
  }

  Future<bool> requestWriteExternalStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        openAppSettings();
        return false;
      } else {
        Utils.toast("Permission denied");
        return false;
      }
    }
  }

  String getDateTimeAsString(DateTime date) {
    try {
      DateFormat dateFormat = DateFormat('MM/dd/yy');
      return dateFormat.format(date);
    } catch (e) {
      return "?";
    }
  }
}

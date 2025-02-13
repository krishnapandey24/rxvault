import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxvault/utils/excel_generator.dart';

import '../../models/analytics_response.dart';
import '../../network/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';

class GenerateExcelDialog extends StatefulWidget {
  final String userId;
  final String fromTo;

  const GenerateExcelDialog(
      {super.key, required this.userId, required this.fromTo});

  @override
  State<GenerateExcelDialog> createState() => GenerateExcelDialogState();
}

class GenerateExcelDialogState extends State<GenerateExcelDialog> {
  late Size size;
  String startDate = "Select Start Date";
  String endDate = " Select End Date ";
  bool startSelected = false;
  bool endSelected = false;
  late final userId = widget.userId;
  final api = API();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Choose Range "),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("From: "),
              InkWell(
                onTap: () {
                  pickDate(true);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    Utils.formatDateString(startDate),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 25),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("To:     "),
              InkWell(
                onTap: () {
                  pickDate(false);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    Utils.formatDateString(endDate),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 25),
            ],
          ),
          const SizedBox(height: 45),
          SizedBox(
            width: 200,
            child: ElevatedButton(
                onPressed: () {
                  if (startSelected && endSelected) {
                    _fetchPatients();
                  } else {
                    Utils.toast("choose start and end date");
                  }
                },
                child: const Text(
                  "Generate Excel",
                  style: TextStyle(color: Colors.white),
                )),
          )
        ],
      ),
    );
  }

  Future<void> pickDate(bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      setState(() {
        if (isStart) {
          if (endSelected) {
            DateTime endDateParsed = DateFormat('yyyy-MM-dd').parse(endDate);
            if (pickedDate.isAfter(endDateParsed)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Start date must be before the end date and within a week.'),
                ),
              );
              return; // Exit the function if the condition is not met
            }
          }
          startDate = formattedDate;
          startSelected = true;
        } else {
          if (startSelected) {
            DateTime startDateParsed =
                DateFormat('yyyy-MM-dd').parse(startDate);
            if (pickedDate.isBefore(startDateParsed)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'End date must be after the start date and within a week.'),
                ),
              );
              return;
            }
          }
          endDate = formattedDate;
          endSelected = true;
        }
      });
    }
  }

  void _fetchPatients() async {
    try {
      Utils.showLoader(context, "Generating Excel...");
      List<AnalyticsData> analyticsData = await api.getAnalytics(
        userId,
        startDate,
        endDate,
      );
      if (!mounted) return;
      ExcelGenerator excelGenerator =
          ExcelGenerator(context, analyticsData, widget.fromTo);
      excelGenerator.generateAndSavePatientExcel();
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }
}

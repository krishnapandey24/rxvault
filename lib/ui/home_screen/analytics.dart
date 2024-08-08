import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:rxvault/models/analytics_response.dart';
import 'package:rxvault/ui/dialogs/generate_excel_dialog.dart';
import 'package:rxvault/ui/widgets/analytics_bar_chart.dart';
import 'package:rxvault/ui/widgets/responsive.dart';

import '../../models/patient.dart';
import '../../network/api_service.dart';
import '../../utils/colors.dart';

class Analytics extends StatefulWidget {
  final String userId;

  const Analytics({super.key, required this.userId});

  @override
  State<Analytics> createState() => AnalyticsState();
}

class AnalyticsState extends State<Analytics> {
  late Size size;
  late Future analyticsFuture;
  final api = API();
  List<AnalyticsData> data = [];
  String _startDate = "Select Start Date";
  String _endDate = " Select End Date ";
  bool startSelected = false;
  bool endSelected = false;
  bool showAmount = true;
  double totalPatients = 0;
  double totalAmount = 0;
  double maxAmount = 0;
  double maxPatientCount = 0;
  bool isChartLoading = true;
  bool isError = false;
  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime.now();
    DateTime sevenDaysBefore = today.subtract(const Duration(days: 7));
    String endDate = DateFormat('yyyy-MM-dd').format(today);
    String startDate = DateFormat('yyyy-MM-dd').format(sevenDaysBefore);

    refreshData(startDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Responsive(
            mobile: _buildMainColumn(true),
            tablet: _buildMainColumn(false),
            desktop: _buildMainColumn(false),
          ),
        ),
      ),
    );
  }

  refreshData(String? startDate, String? endDate) async {
    setState(() {
      isChartLoading = true;
      isError = false;
    });
    try {
      List<AnalyticsData> analyticsData =
          await api.getAnalytics(widget.userId, startDate, endDate);
      determineData(analyticsData);
      setState(() {
        data = analyticsData;
        totalAmount = totalAmount;
        totalPatients = totalPatients;
        maxAmount = maxAmount;
        maxPatientCount = maxPatientCount;
        isChartLoading = false;
        isError = false;
        patients = getPatientsList(analyticsData);
      });
    } catch (e) {
      setState(() {
        isError = true;
        isChartLoading = false;
      });
    }
  }

  _buildAnalytics(bool isMobile) {
    if (isError) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(8),
          color: transparentBlue,
          height: size.height * 0.4,
          width: size.width * 0.75,
          child: const Center(
            child: Text(
              'No Data Available',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (isChartLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) return const SizedBox.shrink();

    return isMobile
        ? AnalyticsBarChart(
            data: data,
            showAmount: showAmount,
            maxAmount: maxAmount,
            maxPatientCount: maxPatientCount,
          )
        : Row(
            children: [
              buildGraph(data, true),
              buildGraph(data, false),
            ],
          );
  }

  Column _buildMainColumn(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnalytics(isMobile),
        const SizedBox(height: 10),
        if (isMobile) buildSwitch(),
        const SizedBox(height: 30),
        const Text("Data Range: "),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("From: "),
            isMobile ? const Spacer() : const SizedBox(width: 25),
            InkWell(
              onTap: () {
                pickDate(true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _startDate,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 25),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("To:  "),
            isMobile ? const Spacer() : const SizedBox(width: 35),
            InkWell(
              onTap: () {
                pickDate(false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _endDate,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 25),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total No. of patients: $totalPatients"),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Amount: $totalAmount"),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: _generateAndDownloadExcelSheet,
            child: Container(
              constraints: BoxConstraints(minWidth: size.width * 0.5),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: transparentBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  SvgPicture.asset(
                    "assets/icons/excel.svg",
                    height: 21,
                    width: 21,
                    colorFilter: const ColorFilter.mode(
                      excelGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("Download Excel Sheet"),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Expanded buildGraph(List<AnalyticsData> data, bool showAmount) {
    return Expanded(
      child: SizedBox(
        height: size.height * 0.6,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnalyticsBarChart(
                data: data,
                showAmount: showAmount,
                maxAmount: maxAmount,
                maxPatientCount: maxPatientCount,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -5,
              child: Text(
                showAmount ? "Amount" : "Patient count",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
            DateTime endDateParsed = DateFormat('yyyy-MM-dd').parse(_endDate);
            if (pickedDate.isAfter(endDateParsed) ||
                endDateParsed.difference(pickedDate).inDays > daysDifference) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Start date must be before the end date and within a week.'),
                ),
              );
              return;
            }
          }
          _startDate = formattedDate;
          startSelected = true;
        } else {
          if (startSelected) {
            DateTime startDateParsed =
                DateFormat('yyyy-MM-dd').parse(_startDate);
            if (pickedDate.isBefore(startDateParsed) ||
                pickedDate.difference(startDateParsed).inDays >
                    daysDifference) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'End date must be after the start date and within a week.'),
                ),
              );
              return;
            }
          }
          _endDate = formattedDate;
          endSelected = true;
        }

        if (startSelected && endSelected) {
          refreshData(_startDate, _endDate);
        }
      });
    }
  }

  Widget buildSwitch() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: switchAmountCount,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: showAmount ? primary : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  "Amount",
                  style: TextStyle(
                    color: showAmount ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: switchAmountCount,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: !showAmount ? primary : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  "Patients",
                  style: TextStyle(
                    color: !showAmount ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  switchAmountCount() {
    setState(() {
      showAmount = !showAmount;
    });
  }

  _generateAndDownloadExcelSheet() {
    showDialog(
      context: context,
      builder: (b) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.1, vertical: size.height * 0.3),
          child: GenerateExcelDialog(
            userId: widget.userId,
            fromTo: "doc",
          ),
        );
      },
    );
  }

  void determineData(List<AnalyticsData> analyticsData) {
    double totalPatientCount = 0;
    double totalAmountCount = 0;
    for (var analytic in analyticsData) {
      double count = analytic.count;
      double amount = analytic.amount;
      totalPatientCount += count;
      totalAmountCount += amount;
      if (count > maxPatientCount) maxPatientCount = count;
      if (amount > maxAmount) maxAmount = amount;
    }
    totalPatients = totalPatientCount;
    totalAmount = totalAmountCount;
  }

  List<Patient> getPatientsList(List<AnalyticsData> analyticsData) {
    List<Patient> patients = [];
    for (var analytic in analyticsData) {
      patients.addAll(analytic.patients);
    }
    return patients;
  }
}

const daysDifference = 30;

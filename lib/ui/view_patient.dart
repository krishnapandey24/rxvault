import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rxvault/models/patient.dart';
import 'package:rxvault/ui/view_all_documents.dart';
import 'package:rxvault/utils/colors.dart';
import 'package:rxvault/utils/constants.dart';

import '../models/patient_document_response.dart';
import '../network/api_service.dart';
import '../utils/utils.dart';

class ViewPatient extends StatefulWidget {
  final Patient patient;
  final String doctorId;

  const ViewPatient({super.key, required this.patient, required this.doctorId});

  @override
  State<ViewPatient> createState() => _ViewPatientState();
}

class _ViewPatientState extends State<ViewPatient> with WidgetsBindingObserver {
  late Size size;
  final labelTextStyle = const TextStyle(fontWeight: FontWeight.w500);

  final valueTextStyle =
      const TextStyle(fontWeight: FontWeight.w500, color: darkBlue);

  final api = API();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Utils.getDefaultAppBar("Patient Details"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            getProfileImage(null, widget.patient.gender == "Male"),
            const SizedBox(height: 10),
            buildPatientDetails(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionsButton(
                  "Download\nAll Documents",
                  Icons.download,
                  _generatePdf,
                ),
                _buildOptionsButton(
                  "Delete\nAll Documents",
                  Icons.delete,
                  _confirmDelete,
                ),
              ],
            ),
            const SizedBox(height: 20),
            buildDetailsTable(),
          ],
        ),
      ),
    );
  }

  Container buildPatientDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: transparentBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 35),
          buildKeyValueLabel("Patient ID: ", widget.patient.patientId),
          buildKeyValueLabel("Name: ", widget.patient.name),
          buildKeyValueLabel("Age: ", widget.patient.age),
          buildKeyValueLabel("Gender: ", widget.patient.gender),
          buildKeyValueLabel("Mobile No.: ", widget.patient.mobile),
          buildKeyValueLabel(
              "Allergic: ", getAllergic(widget.patient.allergic)),
        ],
      ),
    );
  }

  Widget buildKeyValueLabel(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 0.35,
            child: Text(
              label,
              style: labelTextStyle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: valueTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _generatePdf() async {
    Utils.showLoader(context, "Generating PDFs, Please wait...");
    final documents = await api.getPatientDocuments(
        widget.patient.patientId, widget.doctorId, null);

    if (documents.isEmpty && mounted) {
      Utils.toast("No Document Found!");
      Navigator.pop(context);
      return;
    }

    List<String> imageUrls = _getSortedImageUrls(documents);

    _createPdfFromListOfImages(imageUrls);
  }

  List<String> _getSortedImageUrls(List<Document> documents) {
    if (documents.isEmpty) return [];
    List<String> imageUrls = [];
    List<String> tempUrls = [];
    DateTime prev = documents.first.date!;

    for (var document in documents) {
      DateTime currDate = document.date!;
      String currUrl = document.imageUrl;
      if (!areDatesEqual(currDate, prev)) {
        int size = tempUrls.length;
        for (int i = size - 1; i >= 0; i--) {
          imageUrls.add(tempUrls[i]);
        }
        tempUrls.clear();
      }
      tempUrls.add(currUrl);
      prev = currDate;
    }
    imageUrls.addAll(tempUrls.reversed);

    return imageUrls;
  }

  bool areDatesEqual(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _createPdfFromListOfImages(List<String> imageUrls) async {
    final pdf = pw.Document();

    for (final url in imageUrls) {
      final response = await http.get(Uri.parse(url));

      final image = pw.MemoryImage(response.bodyBytes);
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }
    await Printing.layoutPdf(
      name: "RxVault Doc - ",
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    Utils.toast("Pdf generated successfully");
    if (mounted) Navigator.pop(context);
  }

  _confirmDelete() async {
    Utils.showAlertDialog(
        context,
        "Are you sure, you want to delete all documents?",
        _deleteAllDocuments, () {
      Navigator.pop(context);
    });
  }

  _deleteAllDocuments() async {
    Navigator.pop(context);
    Utils.showLoader(context, "Deleting all documents...");
    try {
      await api.deleteDoctorsPatientDocuments(
          widget.patient.patientId, widget.doctorId);
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  _buildOptionsButton(String text, IconData iconData, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
          border: Border.all(color: darkBlue),
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(iconData),
            Text(
              text,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String getAllergic(String? allergic) {
    if (allergic != null && allergic != "") return allergic;
    return "No";
  }

  buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: labelTextStyle),
    );
  }

  buildValue(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: valueTextStyle),
    );
  }

  buildDetailsTable() {
    return FutureBuilder<List<Patient>>(
      future: api.getPatientAmountDetails(
        widget.doctorId,
        widget.patient.patientId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Patient> data = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: DataTable(
              border: const TableBorder(
                horizontalInside: BorderSide(width: 1, color: Colors.grey),
                verticalInside: BorderSide(width: 1, color: Colors.grey),
              ),
              columnSpacing: 30,
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => Colors.grey.shade200,
              ),
              columns: [
                const DataColumn(
                  label: Text('Date'),
                ),
                const DataColumn(
                  label: Text('Amount'),
                ),
                DataColumn(
                  label: InkWell(
                    onTap: () {},
                    child: const Text('Prescriptions'),
                  ),
                ),
              ],
              rows: _buildRows(data),
            ),
          );
        }
      },
    );
  }

  getProfileImage(String? imageUrl, bool isMale) {
    return Center(
      child: Container(
        width: profileImageSize,
        height: profileImageSize,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageUrl == null
                ? AssetImage(
                    isMale
                        ? "assets/images/ic_male.png"
                        : "assets/images/ic_female.png",
                  )
                : NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  _buildRows(List<Patient> data) {
    List<DataRow> rows = [];
    int size = data.length;
    for (int i = size - 1; i >= 0; i--) {
      Patient patient = data[i];
      rows.add(
        DataRow(cells: [
          DataCell(
            Text(formatDateTime(patient.date)),
          ),
          DataCell(
            Text("$rupee${patient.getTotalAmount}"),
          ),
          DataCell(
            InkWell(
              onTap: () =>
                  _showDocumentsDialog(patient.patientId, patient.date),
              child: const Icon(
                CupertinoIcons.arrow_down_doc_fill,
                color: primary,
              ),
            ),
          ),
        ]),
      );
    }
    return rows;
  }

  String formatDateTime(String? input) {
    if (input == null || input.isEmpty) {
      return '--';
    }

    try {
      // Parse the input date string
      DateTime dateTime = DateTime.parse(input);

      // Define the output format
      DateFormat outputFormat = DateFormat('d MMM yyyy', 'en_US');

      // Format the parsed DateTime
      return outputFormat.format(dateTime);
    } catch (e) {
      // Handle parsing error by returning the first 10 characters of the input
      return input.substring(0, 10);
    }
  }

  void _showDocumentsDialog(String patientId, String? date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: ViewAllDocuments(
            patientId: patientId,
            doctorId: widget.doctorId,
            date: date,
            refresh: () {},
          ),
        );
      },
    );
  }
}

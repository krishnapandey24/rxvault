import 'package:flutter/material.dart';

import '../../models/patient.dart';
import '../../models/patient_document_response.dart';
import '../../network/api_service.dart';
import '../view_all_documents.dart';

class ViewDocumentIcon extends StatefulWidget {
  final Patient patient;
  final String patientId, doctorId, date;
  final Function() refresh;

  const ViewDocumentIcon(
      {super.key,
      required this.date,
      required this.patientId,
      required this.doctorId,
      required this.patient,
      required this.refresh});

  @override
  State<ViewDocumentIcon> createState() => ViewDocumentIconState();
}

class ViewDocumentIconState extends State<ViewDocumentIcon> {
  late Size size;
  late Patient patient;
  List<Document> _documents = [];
  final api = API();
  late Future<List<Document>> documentsFuture;

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
    loadData();
  }

  void loadData() async {
    try {
      List<Document> documents = await api.getPatientDocuments(
          widget.patientId, widget.doctorId, widget.date);
      setState(() {
        _documents = documents;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                _showDocumentsDialog(widget.patientId, widget.doctorId,
                    patient.doctorPatientId ?? '', true, patient.date ?? "");
              },
              child: Image.asset(
                "assets/images/as15.png",
                height: 26,
                width: 26,
              ),
            ),
          ),
          if (_documents.isNotEmpty)
            Positioned(
              right: 3,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red, // Background color of the container
                  shape: BoxShape.circle, // Makes the container circular
                ),
                child: Center(
                  child: Text(
                    _documents.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDocumentsDialog(
      patientId, doctorId, doctorPatientId, bool isViewOnly, String date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: ViewAllDocuments(
            documents: _documents,
            patientId: patientId,
            doctorId: widget.doctorId,
            date: widget.date,
            refresh: widget.refresh,
          ),
        );
      },
    );
  }
}

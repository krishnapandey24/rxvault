import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:rxvault/ui/view_image.dart';
import 'package:rxvault/utils/utils.dart';

import '../../../network/api_service.dart';
import '../models/patient_document_response.dart';

class ViewAllDocuments extends StatefulWidget {
  final String patientId;
  final String doctorId;

  const ViewAllDocuments(
      {super.key, required this.patientId, required this.doctorId});

  @override
  State<ViewAllDocuments> createState() => _ViewAllDocumentsState();
}

class _ViewAllDocumentsState extends State<ViewAllDocuments> {
  String title = "";
  late PageController controller;
  late Future<List<Document>> documentsFuture;
  List<Document> documents = [];
  final api = API();
  int _currentIndex = 0;
  late Size size;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);
    documentsFuture =
        api.getPatientDocuments(widget.patientId, widget.doctorId, null);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const SizedBox.shrink(),
        actions: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Document>>(
        future: documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            documents = snapshot.data!;
            if (documents.isEmpty) {
              Utils.toast("No Documents Found");
              Navigator.pop(context);
              return const SizedBox();
            }
            title = documents.first.title;
            return buildSwiper();
          }
        },
      ),
    );
  }

  buildSwiper() {
    Widget emptyAreaWidget = emptyArea();
    return Column(
      children: [
        emptyAreaWidget,
        Expanded(
          child: Swiper(
            loop: documents.length > 3,
            onIndexChanged: (index) {
              _currentIndex = index;
            },
            itemBuilder: (BuildContext context, int index) {
              Document document = documents[index];
              return InkWell(
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => ViewImage(document.imageUrl),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      bottom: 0,
                      left: 0,
                      right: 10,
                      child: CachedNetworkImage(
                        placeholder: Utils.imagePlaceHolder,
                        imageUrl: document.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (_currentIndex == index)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 20,
                          child: IconButton(
                            onPressed: () => Utils.showAlertDialog(context,
                                "Are you sure you want delete this document?",
                                () {
                              _deleteDocument(document.id);
                            }, () {
                              Navigator.pop(context);
                            }),
                            iconSize: 24,
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            itemCount: documents.length,
            viewportFraction: 0.8,
            scale: 0.9,
          ),
        ),
        emptyAreaWidget
      ],
    );
  }

  InkWell emptyArea() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: SizedBox(height: size.height * 0.2),
    );
  }

  InteractiveViewer buildInteractiveViewer(BuildContext context, int index) {
    Document document = documents[index];
    return InteractiveViewer(
      child: CachedNetworkImage(
        imageUrl: document.imageUrl,
        fit: BoxFit.contain,
        height: double.maxFinite,
        width: double.maxFinite,
      ),
    );
  }

  void _deleteDocument(String documentId) async {
    try {
      Utils.showLoader(context);
      await api.deleteDoctorsPatientDocument(documentId);
      Utils.toast("Document Delete Successfully");
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }
}

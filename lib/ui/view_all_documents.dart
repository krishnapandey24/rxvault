import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rxvault/ui/view_image.dart';
import 'package:rxvault/utils/utils.dart';

import '../../../network/api_service.dart';
import '../models/patient_document_response.dart';

class ViewAllDocuments extends StatefulWidget {
  final List<Document>? documents;
  final String patientId;
  final String doctorId;
  final String? date;
  final Function() refresh;

  const ViewAllDocuments(
      {super.key,
      required this.patientId,
      required this.doctorId,
      this.date,
      this.documents,
      required this.refresh});

  @override
  State<ViewAllDocuments> createState() => _ViewAllDocumentsState();
}

class _ViewAllDocumentsState extends State<ViewAllDocuments> {
  String title = "";
  late PageController controller;
  late Future<List<Document>> documentsFuture;
  List<Document> _documents = [];
  final api = API();
  int _currentIndex = 0;
  int _documentsCount = 0;
  late Size size;
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.documents != null && widget.documents!.isNotEmpty) {
      _documents = widget.documents!;
      isLoading = false;
    } else {
      loadDocuments();
    }
    controller = PageController(initialPage: 0);
  }

  void loadDocuments() async {
    List<Document> documents = await api.getPatientDocuments(
        widget.patientId, widget.doctorId, widget.date);
    setState(() {
      _documents = documents;
      isLoading = false;
    });
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
        centerTitle: true,
        title: widget.date != null
            ? ElevatedButton(
                onPressed: _generatePdf,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Download All",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              )
            : null,
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _showDocuments(),
    );
  }

  Widget _showDocuments() {
    if (_documents.isEmpty) {
      Utils.toast("No Documents Found");
      Navigator.pop(context);
      return const SizedBox();
    }
    _documentsCount = _documents.length;
    _currentIndex = _documentsCount - 1;
    title = _documents.first.title;
    return buildSwiper();
  }

  buildSwiper() {
    Widget emptyAreaWidget = emptyArea();
    return Column(
      children: [
        emptyAreaWidget,
        Expanded(
          child: Swiper(
            loop: false,
            onIndexChanged: (index) {
              index = _documentsCount - 1 - index;
              _currentIndex = index;
            },
            itemBuilder: (BuildContext context, int index) {
              index = _documentsCount - 1 - index;
              Document document = _documents[index];
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
            itemCount: _documents.length,
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
    Document document = _documents[index];
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
      Utils.toast("Document Deleted Successfully");
      if (mounted) Navigator.pop(context);
      if (mounted) Navigator.pop(context);
      widget.refresh();
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  void _generatePdf() async {
    Utils.showLoader(context, "Generating PDFs, Please wait...");
    if (_documents.isEmpty && mounted) {
      Utils.toast("No Document Found!");
      Navigator.pop(context);
      return;
    }

    List<String> imageUrls = [];

    for (var document in _documents) {
      imageUrls.insert(0, document.imageUrl);
    }

    _createPdfFromListOfImages(imageUrls);
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
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rxvault/ui/view_image.dart';
import 'package:rxvault/ui/widgets/responsive.dart';
import 'package:rxvault/utils/utils.dart';

import '../../../network/api_service.dart';
import '../models/patient_document_response.dart';

class ViewAllDocuments extends StatefulWidget {
  final List<Document>? documents;
  final String patientId;
  final String doctorId;
  final String? date;
  final Function() refresh;

  const ViewAllDocuments({
    super.key,
    required this.patientId,
    required this.doctorId,
    this.date,
    this.documents,
    required this.refresh,
  });

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
  late Size size;
  var isLoading = true;
  int _currentFocusIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final double _scrollOffset = 300.0;

  @override
  void initState() {
    super.initState();
    if (widget.documents != null && widget.documents!.isNotEmpty) {
      _documents = widget.documents!.reversed.toList();
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
      _documents = documents.reversed.toList();
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
            ? SizedBox(
                width: 200,
                child: ElevatedButton(
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
                ),
              )
            : null,
        actions: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black12,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
          const SizedBox(width: 25),
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
    _currentIndex = 0;
    title = _documents.first.title;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.transparent,
        child:
            Responsive.isMobile(context) ? buildSwiper() : buildDesktopSlider(),
      ),
    );
  }

  Column buildSwiper() {
    Widget emptyAreaWidget = emptyArea();
    return Column(
      children: [
        emptyAreaWidget,
        Expanded(
          child: Swiper(
            loop: false,
            onIndexChanged: (index) {
              _currentIndex = index;
            },
            itemBuilder: (BuildContext context, int index) {
              Document document = _documents[index];
              return InkWell(
                onTap: () => onImageClick(document.imageUrl),
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

  void onImageClick(String url) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ViewImage(url),
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

  void scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - _scrollOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + _scrollOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildDesktopSlider() {
    return Stack(
      children: [
        Positioned(
          left: 80,
          right: 0,
          top: 80,
          bottom: 80,
          child: ListView.builder(
            padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.4,
            ),
            controller: _scrollController,
            itemCount: _documents.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              Document document = _documents[index];
              return InkWell(
                onTap: () => onImageClick(document.imageUrl),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(_currentFocusIndex == index ? 0 : 16),
                  child: AspectRatio(
                    aspectRatio: 9 / 12, // Aspect ratio of 9:12
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: _documents[index].imageUrl,
                            fit:
                                BoxFit.cover, // Adjust this based on your needs
                          ),
                        ),
                        if (_currentFocusIndex == index)
                          buildDeleteIcon(document.id),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 30,
          right: 10,
          child: FloatingActionButton(
            onPressed: () {
              scrollRight();
              setState(() {
                if (_currentFocusIndex < _documents.length - 1) {
                  _currentFocusIndex++;
                }
              });
            },
            child: const Icon(Icons.arrow_forward),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 30,
          left: 10,
          child: FloatingActionButton(
            onPressed: () {
              scrollLeft();
              setState(() {
                if (_currentFocusIndex > 0) {
                  _currentFocusIndex--;
                }
              });
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
      ],
    );
  }

  buildDeleteIcon(String id) {
    return Positioned(
      top: 0,
      right: 0,
      child: CircleAvatar(
        backgroundColor: Colors.red,
        radius: 20,
        child: IconButton(
          onPressed: () => Utils.showAlertDialog(
              context, "Are you sure you want delete this document?", () {
            _deleteDocument(id);
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
    );
  }
}

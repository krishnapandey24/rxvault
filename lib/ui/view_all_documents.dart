import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rxvault/utils/colors.dart';

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
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);
    documentsFuture =
        api.getPatientDocuments(widget.patientId, widget.doctorId, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
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
              return const Center(
                child: Text(
                  "No Document Found!",
                  style: TextStyle(color: Colors.black),
                ),
              );
            }
            title = documents.first.title;
            return buildMainColumn();
          }
        },
      ),
    );
  }

  Column buildMainColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                itemCount: documents.length,
                itemBuilder: buildInteractiveViewer,
                controller: controller,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                    title = documents[index].title;
                  });
                },
              ),
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: InkWell(
                    onTap: () {
                      controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 30,
                    )),
              ),
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: InkWell(
                  onTap: () {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(
          height: 85,
          child: Center(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: documents.length,
              itemBuilder: buildListViewItem,
            ),
          ),
        )
      ],
    );
  }

  Widget? buildListViewItem(BuildContext context, int index) {
    bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () {
        controller.jumpToPage(index);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: primary, width: 2) : null,
        ),
        child: AspectRatio(
          aspectRatio: 9.0 / 16.0,
          child: CachedNetworkImage(
            imageUrl: documents[index].imageUrl,
            fit: BoxFit.fill,
          ),
        ),
      ),
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
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxvault/models/patient_document_response.dart';
import 'package:rxvault/utils/colors.dart';
import 'package:rxvault/utils/utils.dart';

import '../../network/api_service.dart';
import '../widgets/responsive.dart';

class UploadImageDialogs extends StatefulWidget {
  final bool isMobile;
  final double screenWidth;
  final BuildContext parentContext;
  final String userId;
  final String patientId;
  final String doctorPatientId;
  final bool fromViewDocuments;
  final Function(Document)? addDocument;

  const UploadImageDialogs({
    super.key,
    required this.isMobile,
    required this.screenWidth,
    required this.parentContext,
    required this.userId,
    required this.patientId,
    this.fromViewDocuments = false,
    this.addDocument,
    required this.doctorPatientId,
  });

  @override
  State<UploadImageDialogs> createState() => UploadImageDialogsState();
}

class UploadImageDialogsState extends State<UploadImageDialogs> {
  late Size size;

  get isMobile => widget.isMobile;

  get screenWidth => widget.screenWidth;

  get doctorId => widget.userId;

  get patientId => widget.patientId;

  get doctorPatientId => widget.doctorPatientId;

  BuildContext get parentContext => widget.parentContext;

  List<Uint8List> imagesBytes = [];
  late Uint8List imageBytes;
  List<String> imagesFileNames = [];
  String imageFileName = "";
  double progressValue = 0.0;
  List<String> filesPath = [];
  String filePath = "";

  final api = API();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.all(5),
      child: Container(
        width: isMobile ? null : screenWidth * 0.5,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => _handleCamera(),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/camera.png",
                        height: 135,
                        width: 135,
                      ),
                      const Text("Open Camera")
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _handleGalleryImageSelection(),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/add_image.png",
                        height: 135,
                        width: 135,
                      ),
                      const Text("From Gallery")
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleGalleryImageSelection() async {
    List<XFile> results = await ImagePicker().pickMultiImage();
    if (!mounted) return;
    _handleResults(results);
  }

  void _handleResults(List<XFile> results) async {
    imagesBytes.clear();
    imagesFileNames.clear();
    filesPath.clear();
    for (var result in results) {
      imagesBytes.add(await result.readAsBytes());
      imagesFileNames.add(result.name);
      filesPath.add(result.path);
    }

    _uploadImageArray();
  }

  void _handleCamera() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (result != null && mounted) {
      imageBytes = await result.readAsBytes();
      imageFileName = result.name;
      filePath = result.path;
      imagesBytes.clear();
      imagesFileNames.clear();
      filesPath.clear();
      imagesBytes.add(imageBytes);
      imagesFileNames.add(imageFileName);
      filesPath.add(filePath);
      showSelectedImage();
    }
  }

  void _uploadImageArray() async {
    Utils.showLoader(context, "uploading images...");

    api
        .addDocument(patientId, doctorPatientId, doctorId, "doc", imagesBytes)
        .then((value) {
      Utils.toast("Images uploaded");
      closeDialogs(1, "");
    }).catchError((e) {
      Utils.toast(e.toString());
      closeDialogs(1, "");
    });
  }

  void showSelectedImage() {
    showDialog(
        context: context,
        builder: (b) {
          return Responsive(
            desktop: buildShowSelectedImageDialog(false),
            mobile: buildShowSelectedImageDialog(true),
            tablet: buildShowSelectedImageDialog(false),
          );
        });
  }

  Dialog buildShowSelectedImageDialog(bool isMobile) {
    final fileNameController = TextEditingController(text: imageFileName);
    return Dialog(
      insetPadding: const EdgeInsets.all(4),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: isMobile ? null : screenWidth * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Image.memory(
                imageBytes,
                height: 135,
                width: 135,
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                " Filename: ",
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              maxLength: 50,
              maxLines: 1,
              autofocus: true,
              keyboardType: TextInputType.text,
              controller: fileNameController,
              decoration: InputDecoration(
                counterText: '',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      fileNameController.text = "";
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.black,
                    ),
                  ),
                ),
                labelText: "File name",
                labelStyle:
                    TextStyle(color: Colors.grey.shade500, fontSize: 11),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                fillColor: Colors.grey.shade200,
                filled: true,
              ),
              style: const TextStyle(color: Colors.black, fontSize: 11),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: isMobile
                  ? const EdgeInsets.all(0)
                  : EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                    ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _uploadImageArray();
                },
                child: const Text(
                  "Upload Image",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showDocumentUploadingDialog() {
    showDialog(
        context: context,
        builder: (b) {
          return Responsive(
            desktop: buildDocumentUploadingDialog(false),
            mobile: buildDocumentUploadingDialog(true),
            tablet: buildDocumentUploadingDialog(false),
          );
        });
  }

  Dialog buildDocumentUploadingDialog(bool isMobile) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: isMobile ? null : screenWidth * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircularProgressIndicator(
              value: progressValue,
              color: primary,
            ),
            const Text("Your Image is uploading please wait...")
          ],
        ),
      ),
    );
  }

  closeDialogs(int id, String imageUrl) {
    Navigator.pop(parentContext);
    Navigator.pop(parentContext);
  }
// if (widget.fromViewDocuments) {
//   widget.addDocument!(
//     Document(
//       id: id.toString(),
//       doctorId: doctorId,
//       patientId: patientId,
//       doctorPatientId: '1',
//       title: "doc",
//       imageUrl: imageUrl,
//       created: "",
//     ),
//   );
//   return;
// }
// Navigator.of(parentContext, rootNavigator: true).push(
//   MaterialPageRoute(
//     builder: (context) =>
//         ViewAllDocuments(doctorId: doctorId, patientId: patientId),
//   ),
// );
}

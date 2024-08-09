import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rxvault/utils/colors.dart';
import 'package:rxvault/utils/user_manager.dart';

import '../network/api_service.dart';
import '../utils/utils.dart';

class NewImagePreview extends StatefulWidget {
  final String doctorId;
  final Uint8List imageBytes;
  final String filePath;

  const NewImagePreview(
      {super.key,
      required this.imageBytes,
      required this.filePath,
      required this.doctorId});

  @override
  State<NewImagePreview> createState() => NewImagePreviewState();
}

class NewImagePreviewState extends State<NewImagePreview> {
  final api = API();
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Utils.getDefaultAppBar("Upload Image"),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: _handleImageUpload,
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: primary,
                    child: Icon(
                      size: 30,
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    size: 65,
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleImageUpload() async {
    Utils.showLoader(context, "Uploading Image...");

    try {
      final value = await api.updateImage(
          widget.doctorId, widget.filePath, widget.imageBytes);

      final userInfo = await UserManager.getUserInfo();
      if (userInfo != null) {
        userInfo.image = value;
        UserManager.updateUserInfo(userInfo);
      }

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, value);
      }
    } catch (e) {
      Utils.toast(e.toString());
      if (mounted) Navigator.pop(context);
    }
  }
}

import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class UserImagePreview extends StatefulWidget {
  final bool isStaff;
  const UserImagePreview(
      {super.key, required this.imageUrl, required this.isStaff});

  final String? imageUrl;

  @override
  State<UserImagePreview> createState() => UserImagePreviewState();
}

class UserImagePreviewState extends State<UserImagePreview> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Stack(
      children: [
        if (widget.imageUrl == null || widget.imageUrl == "")
          Image.asset(
            "assets/images/doctor.png",
            height: 85,
            width: 85,
          )
        else
          ClipOval(
            child: Image.network(
              widget.imageUrl!,
              height: 85,
              width: 85,
              fit: BoxFit.cover,
            ),
          ),
        if (!widget.isStaff) ...[
          const Positioned(
            bottom: 5,
            right: 0,
            child: Icon(
              Icons.circle,
              size: 32,
              color: darkBlue,
            ),
          ),
          const Positioned(
            bottom: 12,
            right: 6,
            child: Icon(
              Icons.edit,
              size: 18,
              color: Colors.white,
            ),
          ),
        ]
      ],
    );
  }
}

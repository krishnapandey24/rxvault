import 'package:flutter/material.dart';
import 'package:rxvault/ui/login/create_update_user.dart';
import 'package:rxvault/ui/login/register.dart';

import '../../../models/doctor_info.dart';
import '../../../models/setting.dart';
import '../../../models/user_info.dart';
import '../../../utils/colors.dart';
import '../../../utils/user_manager.dart';
import '../../../utils/utils.dart';
import '../../widgets/user_image_preview.dart';

class RxDrawer extends StatefulWidget {
  final Setting setting;
  final User user;
  final Function() resetBack;

  const RxDrawer(
      {super.key,
      required this.setting,
      required this.resetBack,
      required this.user});

  @override
  State<RxDrawer> createState() => _RxDrawerState();
}

class _RxDrawerState extends State<RxDrawer> {
  late String name;
  late String email;
  late Future<DoctorInfo?> userInfoFuture;
  late DoctorInfo? userInfo;
  var switchIcon = Icons.toggle_on_rounded;
  var switchOn = true;

  @override
  void initState() {
    super.initState();
    userInfoFuture = UserManager.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: FutureBuilder<DoctorInfo?>(
      future: userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          userInfo = snapshot.data!;
          return buildMainColumn();
        }
      },
    ));
  }

  buildMainColumn() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 20),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.privacy_tip_outlined,
                size: 22,
              ),
              title: const Text(
                "Privacy and Security",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade700,
                size: 22,
              ),
            ),
            ListTile(
              onTap: () {
                Utils.showAlertDialog(
                    context, "Are you sure you want to logout?", () {
                  UserManager.clearData();
                  widget.resetBack();
                  if (context.mounted) {
                    final NavigatorState navigator = Navigator.of(context);

                    if (navigator.canPop()) {
                      // Pop all routes until reaching the first route
                      navigator.popUntil((route) => route.isFirst);

                      // Push a new route onto the stack
                      navigator.push(
                        MaterialPageRoute(
                          builder: (context) => const Register(),
                        ),
                      );
                    } else {
                      // If there's only one route (the first route), push a new route directly
                      navigator.push(
                        MaterialPageRoute(
                          builder: (context) => const Register(),
                        ),
                      );
                    }
                  }
                }, () {
                  Navigator.pop(context);
                });
              },
              leading: const Icon(Icons.logout, size: 22),
              title: const Text(
                "Logout",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade700,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildHeader() {
    return Container(
      width: double.maxFinite,
      color: transparentBlue,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          InkWell(
            onTap: () async {
              final userInfo = await UserManager.getUserInfo();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => CreateUpdateUser(
                      userInfo: userInfo,
                    ),
                  ),
                );
              }
            },
            child: UserImagePreview(
              isStaff: widget.user.isStaff,
              imageUrl: userInfo?.image,
            ),
          ),
          Text(
            userInfo?.name ?? "",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          Text(
            userInfo?.email ?? "",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

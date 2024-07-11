import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/ui/widgets/responsive.dart';

import '../../models/setting.dart';
import '../../models/user_info.dart';
import '../../network/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';

class RxVaultAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String clinicName;
  final Function(bool) openDrawer;
  final Setting setting;

  const RxVaultAppBar(
      {super.key,
      required this.openDrawer,
      required this.clinicName,
      required this.setting});

  @override
  State<RxVaultAppBar> createState() => RxVaultAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 15);
}

class RxVaultAppBarState extends State<RxVaultAppBar> {
  final api = API();
  late User user;
  get setting => widget.setting;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);

    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Responsive(
        desktop: buildAppBarContainer(false),
        mobile: buildAppBarContainer(true),
        tablet: buildAppBarContainer(false),
      ),
    );
  }

  Container buildAppBarContainer(bool isMobile) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).viewPadding.top),
          const SizedBox(height: 13),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isMobile ? buildMenuButton(true) : const SizedBox(),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.clinicName,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  Container(
                    color: Colors.black,
                    height: 0.5,
                    width: 180,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        getCurrentDate(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 42),
                      const Icon(
                        Icons.calendar_month,
                        color: darkBlue,
                        size: 24,
                      )
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (!isMobile) buildMenuButton(false),
            ],
          ),
        ],
      ),
    );
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final DateFormat formatter = DateFormat("dd.MM.yy");
    return formatter.format(now);
  }

  void updateSettings(bool open) async {
    Utils.showLoader(context);
    setting.status = open ? "open" : "close";
    try {
      await api.updateSettings(setting);
      Utils.toast("Clinic ${setting.status}");
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  IconButton buildMenuButton(bool isMobile) {
    return IconButton(
      onPressed: () => widget.openDrawer(isMobile),
      iconSize: 24,
      color: darkBlue,
      icon: const Icon(
        Icons.menu,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/ui/widgets/responsive.dart';
import 'package:rxvault/ui/widgets/rxvault_app_bar.dart';
import 'package:rxvault/utils/colors.dart';

import '../../custom/animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../models/setting.dart';
import '../../models/user_info.dart';
import '../../network/api_service.dart';
import '../../utils/utils.dart';
import '../mr_settings.dart';
import 'analytics.dart';
import 'clinic/clinic_screen.dart';
import 'drawer/drawer.dart';
import 'home/home.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String clinicName;

  const HomeScreen({super.key, required this.userId, required this.clinicName});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late User user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Setting setting = Setting();
  String? selectedDate;
  late final List<Widget> _screens = [
    Home(
      userId: widget.userId,
      setting: setting,
      scaffoldKey: _scaffoldKey,
      clinicName: widget.clinicName,
    ),
    ClinicScreen(
      userId: widget.userId,
      setting: setting,
      updateSettingObject: (setting) {
        this.setting.setData(setting);
      },
    ),
    Analytics(
      userId: widget.userId,
    ),
    MrSettingsScreen(userId: widget.userId)
  ];
  var _bottomNavIndex = 0;
  final iconList = [
    Icons.home,
    Icons.medical_information,
    Icons.analytics,
    Icons.toggle_on_sharp
  ];

  late Future<Setting> settingsFuture;

  final pageNames = ["Home", "Clinic", "Analytics", "MR"];

  PageController pageController =
      PageController(initialPage: 0, keepPage: true);

  var backPressCount = 0;

  @override
  void initState() {
    super.initState();
    settingsFuture = API().getSettings(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (d) {
        backPressCount++;
        if (_bottomNavIndex != 0) {
          backPressCount = 0;
          goToHome();
          return;
        }
        if (backPressCount == 2) {
          SystemNavigator.pop();
          backPressCount = 0;
          return;
        }
        if (backPressCount != -1) Utils.toast("Tap once more to exit");
      },
      child: Responsive(
        mobile: buildScaffold(false),
        desktop: buildScaffold(true),
        tablet: buildScaffold(true),
      ),
    );
  }

  Scaffold buildScaffold(bool isDesktop) {
    return Scaffold(
      appBar: _bottomNavIndex == 0
          ? null
          : RxVaultAppBar(
              userId: widget.userId,
              openDrawer: (isMobile) {
                if (isMobile) {
                  _scaffoldKey.currentState?.openDrawer();
                } else {
                  _scaffoldKey.currentState?.openEndDrawer();
                }
              },
              clinicName: widget.clinicName,
              setting: setting,
              changeAppointmentDate: (date) {
                // setState(() {
                //   // selectedDate = date;
                // });
              },
            ),
      key: _scaffoldKey,
      drawer: isDesktop
          ? null
          : RxDrawer(
              user: user,
              resetBack: () {
                backPressCount = -1;
              },
              setting: setting,
            ),
      endDrawer: isDesktop
          ? RxDrawer(
              user: user,
              resetBack: () {
                backPressCount = -1;
              },
              setting: setting,
            )
          : null,
      body: FutureBuilder<Setting>(
        future: settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            setting = snapshot.data!;
            return isDesktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      getNavigationBar(true),
                      Expanded(
                        child: buildPageView(),
                      )
                    ],
                  )
                : buildPageView();
          }
        },
      ),
      bottomNavigationBar: isDesktop ? null : getNavigationBar(false),
    );
  }

  PageView buildPageView() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      children: _screens,
      onPageChanged: (index) {
        setState(() {
          _bottomNavIndex = index;
        });
      },
    );
  }

  AnimatedBottomNavigationBar getNavigationBar(bool isDesktop) {
    return AnimatedBottomNavigationBar.builder(
      backgroundColor: Colors.white,
      itemCount: 4,
      tabBuilder: (int index, bool isActive) {
        final color = isActive ? darkBlue : Colors.grey;
        final icon = iconList[index];
        final label = isActive ? pageNames[index] : "";
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: isActive
              ? [
                  const SizedBox(height: 4),
                  Icon(
                    icon,
                    size: 25,
                    color: color,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(color: color, fontSize: 11),
                  )
                ]
              : [
                  Icon(
                    icon,
                    size: 25,
                    color: color,
                  ),
                ],
        );
      },
      activeIndex: _bottomNavIndex,
      splashColor: darkBlue,
      splashSpeedInMilliseconds: 300,
      gapLocation: GapLocation.none,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      onTap: (index) {
        setState(() {
          pageController.jumpToPage(index);
          _bottomNavIndex = index;
        });
      },
      forDesktop: isDesktop,
    );
  }

  void goToHome() => setState(() {
        pageController.jumpToPage(0);
        _bottomNavIndex = 0;
      });

  void handleBackPress() {
    backPressCount++;

    if (_bottomNavIndex != 4) {
      backPressCount = 0;
      goToHome();
      return;
    }

    if (backPressCount == 2) {
      SystemNavigator.pop();
      backPressCount = 0;
      return;
    }

    Utils.toast("Tap once more to exit");
  }
}

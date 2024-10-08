import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/ui/home_screen/home_screen.dart';
import 'package:rxvault/ui/login/create_update_user.dart';
import 'package:rxvault/ui/login/register.dart';
import 'package:rxvault/utils/colors.dart';
import 'package:rxvault/utils/constants.dart';
import 'package:rxvault/utils/user_manager.dart';
import 'package:rxvault/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'models/user_info.dart';

Future<void> initPlatformState() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.initialize(oneSignalAppId);
  await OneSignal.Notifications.requestPermission(true);
  await Future.delayed(const Duration(milliseconds: 100)); // this might be unnecessary
  OneSignal.User.pushSubscription.id;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    await initPlatformState();
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool(UserManager.isLoggedIn) ?? false;
  String userId = prefs.getString(UserManager.userId) ?? "";
  String clinicName = prefs.getString(UserManager.clinicName) ?? "";
  String userName = prefs.getString(UserManager.name) ?? "";
  String permissions = prefs.getString(UserManager.permissions) ?? "";
  bool isStaff = prefs.getBool(UserManager.isStaff) ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => User(permissions, isStaff, userName),
      child: RxVault(
        isFirstTime: false,
        isLoggedIn: isLoggedIn,
        userId: userId,
        clinicName: clinicName,
        name: userName,
      ),
    ),
  );
}

class RxVault extends StatefulWidget {
  final bool isFirstTime;
  final bool isLoggedIn;
  final String userId;
  final String clinicName;
  final String name;

  const RxVault({
    super.key,
    required this.isFirstTime,
    required this.isLoggedIn,
    required this.userId,
    required this.clinicName,
    required this.name,
  });

  @override
  State<RxVault> createState() => _RxVaultState();
}

class _RxVaultState extends State<RxVault> {
  @override
  void initState() {
    super.initState();
    OneSignal.Notifications.addClickListener((event) {
      String? url = Utils.extractUrl(event.notification.body);
      if (url != null) {
        Utils.launchUrl(url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      initialRoute: '/',
      routes: {
        '/signup': (context) => const CreateUpdateUser(phoneNumber: ''),
      },
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: darkBlue, // Primary color
          secondary: Color(0xFF33FF57), // Secondary color
          surface: Colors.white,
          error: Colors.red, // Error color
          onPrimary: Colors.white, // Color for text/icons on primary color
          onSecondary: Colors.black, // Color for text/icons on secondary color
          onSurface: Colors.black, // Color for text/icons on surface color
          onError: Colors.white, // Color for text/icons on error color
          brightness: Brightness.light, // Light or dark theme
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark,
          ),
        ),

        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary; // Track color when switch is on
            }
            return Colors.grey.shade300; // Track color when switch is off
          }),
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87), // Default text color
          bodyMedium: TextStyle(color: Colors.black87), // Default text color
        ),
        // Set default Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.maxFinite, 30),
            backgroundColor: primary,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
      home: widget.isLoggedIn
          ? HomeScreen(
              userId: widget.userId,
              clinicName: widget.clinicName,
            )
          : const Register(),
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/ui/home_screen/home_screen.dart';
import 'package:rxvault/ui/login/create_update_user.dart';
import 'package:rxvault/ui/login/register.dart';
import 'package:rxvault/utils/colors.dart';
import 'package:rxvault/utils/constants.dart';
import 'package:rxvault/utils/user_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
  // setupFirebaseMessaging(); // Initialize Firebase Messaging
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

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground message
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
}

class RxVault extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      initialRoute: '/',
      routes: {
        '/signup': (context) => const CreateUpdateUser(phoneNumber: ''),
      },
      theme: ThemeData(
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
      home: isLoggedIn
          ? HomeScreen(
              userId: userId,
              clinicName: clinicName,
            )
          : const Register(),
    );
  }
}

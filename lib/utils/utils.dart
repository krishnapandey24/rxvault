import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rxvault/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Utils {
  static void toast(String message) {
    if (message.contains("500")) message = "Server Down";
    Fluttertoast.showToast(
      backgroundColor: Colors.black.withOpacity(0.86),
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
    );
  }

  static int getRandomNumber() {
    final random = Random();
    return random.nextInt(10) + 1; // Generates a number between 1 and 10
  }

  static String reverseDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = "${dateTime.day.toString().padLeft(2, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.year}";

    return formattedDate;
  }

  static bool isEmailValid(String email) {
    if (email.isEmpty) return false;
    final pattern = RegExp(
      r'^[a-zA-Z\d]+[\w.]*@[a-zA-Z\d]+(?:\.[a-zA-Z\d]+)+$',
    );
    return pattern.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    RegExp regex = RegExp(r'^(?=.*?[A-Za-z])(?=.*?[\d)(?=.*[!@#&~]).{8,}$');
    return regex.hasMatch(password);
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  static showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning,
                color: Colors.yellow,
                size: 40.0,
              ),
              const SizedBox(height: 16.0),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void addUserDetails(
      String userId, String name, String email, String avatar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', userId);
    prefs.setString('user_name', name);
    prefs.setString('user_email', email);
    prefs.setString('user_avatar_url', avatar);
    prefs.setBool("loggedIn", true);
  }

  static Widget loadingBuilder(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    return child;
  }

  static Widget errorBuilder(
      BuildContext context, Object exception, StackTrace? stackTrace) {
    return const Expanded(
      child: Center(
        child: Icon(
          Icons.broken_image,
        ),
      ),
    );
  }

  static Widget imagePlaceHolder(context, url) {
    return const Center(child: CircularProgressIndicator());
  }

  static String capitalizeFirstLetter(String? input) {
    if (input == null) return "";
    if (input.isEmpty) {
      return input;
    }

    return input.substring(0, 1).toUpperCase() + input.substring(1);
  }

  static Widget errorWidget(BuildContext context, String url, dynamic) {
    return const Center(
      child: Icon(
        Icons.broken_image,
      ),
    );
  }

  static bool isValidPhoneNumber(String contact) {
    final pattern = RegExp(r'^[0-9]{10}$');
    return pattern.hasMatch(contact);
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("my user id: ${prefs.getString("user_id")}");
    }
    return prefs.getBool('loggedIn') ?? false;
  }

  static bool isInvalidName(String input) {
    RegExp regex = RegExp(r'[!@#&*(),.?":{}|<>\d]');
    return regex.hasMatch(input);
  }

  static String getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static showAlertDialog(
      BuildContext context, String title, Function() yes, Function() no,
      [String? yesText, String? noText]) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Icon(
            Icons.warning,
            color: Colors.yellow.shade900,
            size: 45,
          ),
          content: Text(
            title,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: yes,
              child: Text(
                yesText ?? "Yes",
                style: const TextStyle(color: Colors.black),
              ),
            ),
            if (noText == null || noText != "")
              TextButton(
                onPressed: no,
                child: Text(
                  noText ?? "No",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
          ],
        );
      },
    );
  }

  static void showMediaUploadingLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 5),
              Text(
                "Uploading Media....",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        );
      },
    );
  }

  static String getFormattedCurrentTime() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }

  static String formatDate(String dateString) {
    final DateTime parsedDate = DateTime.parse(dateString);
    final today = DateTime.now();

    final isToday = parsedDate.year == today.year &&
        parsedDate.month == today.month &&
        parsedDate.day == today.day;

    final isYesterday = parsedDate.year == today.year &&
        parsedDate.month == today.month &&
        parsedDate.day == today.day - 1;

    if (isToday) {
      return "Today at ${DateFormat('hh:mm aaa').format(parsedDate)}";
    } else if (isYesterday) {
      return "Yesterday at ${DateFormat('hh:mm aaa').format(parsedDate)}";
    } else {
      return DateFormat('dd-MMM-yyyy hh:mm aaa').format(parsedDate);
    }
  }

  static void showLoader(BuildContext context, [String? message]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: 100,
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16.0),
                Text(
                  message ?? "Please wait",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static AppBar getDefaultAppBar(String title,
      [List<Widget>? actions, Widget? leading]) {
    return AppBar(
      leading: leading,
      centerTitle: true,
      backgroundColor: transparentBlue,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: darkBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: actions,
    );
  }

  static Map<String, String> getServicesFromString(String? itemDetails) {
    Map<String, String> services = {};
    if (itemDetails == null) return services;
    try {
      Map<String, dynamic> dynamicMap = jsonDecode(itemDetails);
      Map<String, String> map =
          dynamicMap.map((key, value) => MapEntry(key, value as String));
      return map;
    } catch (e) {
      return services;
    }
  }

  static noPermission() {
    toast("You don't have permission for this operation!");
  }

  static WidgetStateProperty<Color?> getFillColor() {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return darkBlue;
      }
      return Colors.white;
    });
  }

  static String formatDateString(String dateStr) {
    try {
      // Parse the input date string
      DateTime date = DateTime.parse(dateStr);

      // Create formatter for the desired output format
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      // Return original string if parsing fails
      return dateStr;
    }
  }

  static String? extractUrl(String? text) {
    if (text == null) return null;
    final urlPattern = RegExp(
      r'((http|https):\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/[^\s]*)?',
      caseSensitive: false,
    );

    final match = urlPattern.firstMatch(text);
    return match?.group(0);
  }

  static void launchUrl(String url) async {
    try {
      await launchUrlString(url);
    } catch (e) {
      Utils.toast(e.toString());
    }
  }
}

extension StringExtensions on String? {
  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }
}

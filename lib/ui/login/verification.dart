import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rxvault/models/doctor_info.dart';
import 'package:rxvault/utils/colors.dart';

import '../../network/api_service.dart';
import '../home_screen/home_screen.dart';
import '../widgets/responsive.dart';

class Verification extends StatefulWidget {
  final DoctorInfo doctorInfo;
  final String? clinicName;

  const Verification({super.key, required this.doctorInfo, this.clinicName});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final api = API();
  String digit1Controller = '0';
  String digit2Controller = '0';
  String digit3Controller = '0';
  String digit4Controller = '0';
  var showLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((value) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userId: widget.doctorInfo.doctorId ?? "1",
            clinicName:
                widget.clinicName ?? widget.doctorInfo.clinicName ?? "Clinic",
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -30,
            top: -100,
            child: Image.asset(
              "assets/images/asset_28.png",
              height: 220,
              width: 220,
            ),
          ),
          Positioned(
            right: -30,
            top: 35,
            child: Image.asset(
              "assets/images/asset_29.png",
              height: 170,
              width: 170,
            ),
          ),
          Responsive(
            desktop: mainContainer(screenWidth * 0.3, screenWidth),
            mobile: mainContainer(null, screenWidth),
            tablet: mainContainer(screenWidth * 0.6, screenWidth),
          )
        ],
      ),
    );
  }

  Widget mainContainer(double? width, double screenWidth) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLoading)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/loading.json',
                  height: 100,
                  width: 80,
                  fit: BoxFit.fill,
                  repeat: true,
                ),
                const Text("Auto-Fetching OTP, Please wait...")
              ],
            ),
          const Text(
            "Verification",
            style: TextStyle(
              fontSize: 28,
              color: darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Enter the 4 digit OTP sent to",
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          Text(
            widget.doctorInfo.mobile ?? "",
            style: const TextStyle(
              fontSize: 17,
              color: teal,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: width,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getOtpDigitBox(digit1Controller),
                    getOtpDigitBox(digit2Controller),
                    getOtpDigitBox(digit3Controller),
                    getOtpDigitBox(digit4Controller),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.maxFinite, 30),
                    backgroundColor: primary,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Border radius
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container getOtpDigitBox(String digit) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: transparentBlue,
      ),
      child: const Text("0"),
    );
  }
}

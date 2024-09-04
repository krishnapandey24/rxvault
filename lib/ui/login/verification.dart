import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/utils/colors.dart';

import '../../models/user_info.dart';
import '../../network/api_service.dart';
import '../../utils/exceptions/registration_required.dart';
import '../../utils/utils.dart';
import '../home_screen/home_screen.dart';
import '../widgets/responsive.dart';
import 'create_update_user.dart';

class Verification extends StatefulWidget {
  final String? clinicName;
  final String selectedOption;
  final String phoneNumber;

  const Verification(
      {super.key,
      this.clinicName,
      required this.selectedOption,
      required this.phoneNumber});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final api = API();
  var showLoading = true;
  int? receivedOtp = 0;
  int enteredOtp = 0;
  late User user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Utils.showLoader(context);
      try {
        receivedOtp = await api.getOtp(widget.phoneNumber, "doctor");
      } catch (e) {
        Utils.toast(e.toString());
      } finally {
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);

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
            widget.phoneNumber,
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
                Pinput(
                  onCompleted: (String pin) {
                    enteredOtp = int.parse(pin);
                    verifyOtp();
                  },
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
                  onPressed: () {
                    verifyOtp();
                  },
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

  void verifyOtp() {
    if (receivedOtp == enteredOtp) {
      login();
    } else {
      Utils.toast("Incorrect Otp!");
    }
  }

  void login() async {
    Utils.showLoader(context);
    bool isStaff = widget.selectedOption == "staff";
    Utils.showLoader(context, "Please wait");
    api
        .login(widget.phoneNumber, widget.selectedOption,
            OneSignal.User.pushSubscription.id)
        .then(
      (value) {
        Navigator.pop(context);
        user.updateIsStaffAndPermission(
          isStaff,
          value.permissions ?? "",
        );
        user.updateName(value.name ?? "");
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userId: value.doctorId ?? "1",
              clinicName: widget.clinicName ?? value.clinicName ?? "Clinic",
            ),
          ),
        );
      },
    ).catchError(
      (e) {
        Navigator.pop(context);
        if (e is RegistrationRequired) {
          Utils.toast("Registration Required");
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => CreateUpdateUser(
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        } else {
          Utils.toast(e.toString());
        }
      },
    );
  }
}

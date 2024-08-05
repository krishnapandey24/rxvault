import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/ui/login/create_update_user.dart';
import 'package:rxvault/ui/login/verification.dart';
import 'package:rxvault/utils/colors.dart';

import '../../models/user_info.dart';
import '../../network/api_service.dart';
import '../../utils/exceptions/registration_required.dart';
import '../../utils/utils.dart';
import '../widgets/responsive.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final _phoneController = TextEditingController();
  final imageHeightAndWidth = 150.0;
  late double screenHeight;
  late double screenWidth;
  final api = API();
  final _formKey = GlobalKey<FormState>();
  String selectedOption = 'doctor';
  late User user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    final screenSize = MediaQuery.of(context).size;
    screenHeight = screenSize.height;
    screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: -30,
            top: 35,
            child: Image.asset(
              width: imageHeightAndWidth,
              height: imageHeightAndWidth,
              "assets/images/asset_26.png",
            ),
          ),
          Positioned(
            right: 0,
            top: 70,
            child: Image.asset(
              width: 80,
              height: 50,
              "assets/images/asset_27.png",
            ),
          ),
          Responsive(
            desktop: mainContainer(screenWidth * 0.3),
            mobile: mainContainer(null),
            tablet: mainContainer(screenWidth * 0.6),
          )
        ],
      ),
    );
  }

  Widget mainContainer(double? width) {
    return SingleChildScrollView(
      child: Container(
        width: screenWidth,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              const Text(
                "Welcome!",
                style: TextStyle(
                  color: darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const Text(
                "Register to get started",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                textAlign: TextAlign.center,
                "Enter your mobile number/email, we will send an OTP to verify later",
              ),
              const SizedBox(height: 13),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login As",
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Radio(
                          value: 'doctor',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Doctor',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Radio(
                          value: 'staff',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 5),
                        const Text('Staff',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      maxLength: 10,
                      maxLines: 1,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.all(15),
                        labelText: "Enter Mobile Number",
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        fillColor: transparentBlue,
                        filled: true,
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !Utils.isValidPhoneNumber(value)) {
                          return "Please Enter a valid phone number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.maxFinite, 30),
                        backgroundColor: primary,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // Border radius
                        ),
                      ),
                      onPressed: register,
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    InkWell(
                      //   Navigator.pushReplacementNamed(context, '/signup');
                      onTap: () =>
                          Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => CreateUpdateUser(
                            phoneNumber: _phoneController.text,
                          ),
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Create new account",
                          style: TextStyle(
                            fontSize: 16,
                            color: darkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void register() {
    if (_formKey.currentState!.validate()) {
      verifyOtp(_phoneController.text);
    }
  }

  void verifyOtp(String phoneNumber) async {
    bool isStaff = selectedOption == "staff";
    Utils.showLoader(context, "Please wait");
    api.login(phoneNumber, selectedOption).then(
      (value) {
        Navigator.pop(context);
        user.updateIsStaffAndPermission(
          isStaff,
          value.permissions ?? "",
        );
        user.updateName(value.name ?? "");
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => Verification(
              doctorInfo: value,
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
                phoneNumber: phoneNumber,
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

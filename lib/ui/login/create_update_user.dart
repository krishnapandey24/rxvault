import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/models/doctor_info.dart';

import '../../models/user_info.dart';
import '../../network/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/exceptions/registration_required.dart';
import '../../utils/user_manager.dart';
import '../../utils/utils.dart';
import '../home_screen/home_screen.dart';
import '../widgets/crop_image.dart';
import '../widgets/responsive.dart';
import '../widgets/user_image_preview.dart';

class CreateUpdateUser extends StatefulWidget {
  final DoctorInfo? userInfo;
  final String? phoneNumber;

  const CreateUpdateUser({super.key, this.phoneNumber, this.userInfo});

  @override
  State<CreateUpdateUser> createState() => _CreateUpdateUserState();
}

class _CreateUpdateUserState extends State<CreateUpdateUser> {
  late User user;
  final api = API();
  final _formKey = GlobalKey<FormState>();
  late DoctorInfo userInfo = widget.userInfo ?? DoctorInfo.empty();
  late String? userImageUrl = widget.userInfo?.image;

  get isUpdate => widget.userInfo != null;

  @override
  void initState() {
    super.initState();
    if (!isUpdate) {
      userInfo.mobile = widget.phoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: isUpdate ? Utils.getDefaultAppBar("Edit Profile") : null,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: headerRowChildren(),
            ),
            Responsive(
              desktop: mainContainer(screenWidth * 0.3, screenWidth),
              mobile: mainContainer(null, screenWidth),
              tablet: mainContainer(screenWidth * 0.6, screenWidth),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> headerRowChildren() {
    return isUpdate
        ? []
        : [
            Container(
              transform: Matrix4.translationValues(-13, 35, 0.0),
              child: Image.asset(
                "assets/images/asset_30.png",
                height: 120,
                width: 120,
              ),
            ),
            const Spacer(),
            Container(
              transform: Matrix4.translationValues(85, 35, 0.0),
              child: Image.asset(
                "assets/images/asset_31.png",
                height: 170,
                width: 170,
              ),
            ),
          ];
  }

  Widget mainContainer(double? width, double screenWidth) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isUpdate
              ? InkWell(
                  onTap: _handleUpdateImage,
                  child: UserImagePreview(
                    isStaff: user.isStaff,
                    imageUrl: userImageUrl,
                  ),
                )
              : const Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 28,
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          if (!isUpdate)
            const Text(
              "Fill the following details to register with us",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    maxLength: 50,
                    maxLines: 1,
                    initialValue: userInfo.name,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: const EdgeInsets.all(15),
                      labelText: "Enter Your Full Name",
                      prefixIconColor: darkBlue,
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.person),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      fillColor: transparentBlue,
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      userInfo.name = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter a valid name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (user.isDoctor) ...onlyForDoctor(),
                  TextFormField(
                    readOnly: isUpdate,
                    maxLength: 10,
                    maxLines: 1,
                    initialValue:
                        isUpdate ? userInfo.mobile : widget.phoneNumber,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: const EdgeInsets.all(15),
                      labelText: "Enter Mobile Number",
                      prefixIconColor: darkBlue,
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.phone),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      fillColor: transparentBlue,
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      userInfo.mobile = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty || !Utils.isValidPhoneNumber(value)) {
                        return "Please Enter a valid phone number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLength: 50,
                    maxLines: 1,
                    initialValue: userInfo.email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: const EdgeInsets.all(15),
                      labelText: "Enter Email",
                      prefixIconColor: darkBlue,
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.mail),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      fillColor: transparentBlue,
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      userInfo.email = value;
                    },
                    validator: (value) {
                      if (value!.isNotEmpty && !Utils.isEmailValid(value)) {
                        return "Please Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (user.isDoctor) ...[
                    TextFormField(
                      maxLength: 250,
                      maxLines: 1,
                      initialValue: userInfo.address,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.all(15),
                        labelText: "Enter Address",
                        prefixIconColor: darkBlue,
                        prefixIcon: const Icon(Icons.location_pin),
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
                      onChanged: (value) {
                        userInfo.address = value;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.maxFinite, 30),
                      backgroundColor: primary,
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // Border radius
                      ),
                    ),
                    onPressed: handleContinue,
                    child: Text(
                      isUpdate ? "Update" : "Continue",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void handleContinue() {
    if (_formKey.currentState!.validate()) {
      if (isUpdate) {
        updateUser();
      } else {
        registerUser();
      }
    }
  }

  void _handleUpdateImage() async {
    if (user.isStaff) return;
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (result != null) {
      if (!mounted) return;
      final croppedFile = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => CropImage(pickedFile: result, forProfile: true),
        ),
      );
      if (croppedFile != null) {
        final imageBytes = await croppedFile.readAsBytes();
        final filePath = croppedFile.path;
        _handleImageUpload(imageBytes, filePath);
      }
    }
  }

  void _handleImageUpload(Uint8List imageBytes, String filePath) async {
    Utils.showLoader(context, "Uploading Image...");
    try {
      final value = await api.updateImage(
          widget.userInfo?.doctorId ?? "1", filePath, imageBytes);
      final userInfo = await UserManager.getUserInfo();
      if (userInfo != null) {
        userInfo.image = value;
        UserManager.updateUserInfo(userInfo);
      }

      if (mounted) {
        Navigator.pop(context);
      }

      Utils.toast("Image Updated successfully");
      this.userInfo.image = value;
      setState(() {
        userImageUrl = value;
      });
    } catch (e) {
      Utils.toast(e.toString());
      if (mounted) Navigator.pop(context);
    }
  }

  void registerUser() {
    final playerId = OneSignal.User.pushSubscription.id;
    userInfo.playerId = playerId;
    api.registerUser(userInfo).then(
      (value) {
        api.login(userInfo.mobile!, "Login").then(
          (value) {
            user.updateName(userInfo.name ?? "");
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userId: value.doctorId ?? "1",
                  clinicName: value.clinicName ?? "Clinic",
                ),
              ),
            );
          },
        ).catchError(
          (e) {
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
              Navigator.pop(context);
              Utils.toast(e.toString());
            }
          },
        );
      },
    ).catchError(
      (e) {
        Utils.toast(e.toString());
      },
    );
  }

  onlyForDoctor() {
    return [
      TextFormField(
        maxLength: 50,
        maxLines: 1,
        initialValue: userInfo.clinicName,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.all(15),
          labelText: "Enter Clinic/Hospital's Name",
          prefixIconColor: darkBlue,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.local_hospital),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          fillColor: transparentBlue,
          filled: true,
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: (value) {
          userInfo.clinicName = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return "Please Enter a valid name";
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        maxLength: 50,
        maxLines: 1,
        initialValue: userInfo.speciality,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.all(15),
          labelText: "Enter Speciality",
          prefixIconColor: darkBlue,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.star),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          fillColor: transparentBlue,
          filled: true,
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: (value) {
          userInfo.speciality = value;
        },
      ),
      const SizedBox(height: 20),
    ];
  }

  void updateUser() {
    Utils.showLoader(context, "Updating Details...");
    if (user.isDoctor) {
      api.updateUser(userInfo).then((value) {
        user.updateName(userInfo.name ?? "");
        Utils.toast("Profile Updated Successfully");
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((e) {
        Utils.toast(e.toString());
        Navigator.pop(context);
      });
    } else {
      api.staffOperation("update_staff", {
        'staff_id': userInfo.doctorId,
        'name': userInfo.name,
        'email': userInfo.email,
        'mobile': userInfo.mobile,
      }).then((value) {
        Utils.toast("Profile Updated Successfully");
        Navigator.pop(context);
        Navigator.pop(context);
      }).catchError((e, t) {
        Utils.toast(e.toString());
        Navigator.pop(context);
      });
    }
  }
}

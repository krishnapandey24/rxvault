import 'package:flutter/material.dart';
import 'package:rxvault/models/patient.dart';
import 'package:rxvault/ui/dialogs/select_patients_dialog.dart';
import 'package:rxvault/utils/colors.dart';

import '../../network/api_service.dart';
import '../../utils/utils.dart';
import '../widgets/responsive.dart';

class AddPatientDialog extends StatefulWidget {
  final String userId;
  final Patient? patient;

  const AddPatientDialog({super.key, required this.userId, this.patient});

  @override
  State<AddPatientDialog> createState() => AddPatientDialogState();
}

class AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedGender;
  late String _allergic;
  final api = API();
  late Patient patient;
  late bool isUpdate;
  late Size size;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  late bool _isNumberChecked;
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isUpdate = widget.patient != null;
    _isNumberChecked = isUpdate;
    patient = widget.patient ?? Patient.newPatient(widget.userId);
    setPatientData(widget.patient);
  }

  void setPatientData(Patient? patient) {
    _selectedGender = patient?.gender ?? "Male";
    _allergic = patient?.allergic ?? "No";
    _mobileController.text = patient?.mobile ?? "";
    _nameController.text = patient?.name ?? "";
    _ageController.text = patient?.age ?? "";
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Utils.getDefaultAppBar(
        "${isUpdate ? "Update" : "Add"} New Patient",
        [
          IconButton(
            onPressed: () => pop(),
            icon: const Icon(
              Icons.cancel,
              color: darkBlue,
            ),
          )
        ],
        const SizedBox(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Phone number",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        focusNode: _phoneFocusNode,
                        controller: _mobileController,
                        maxLength: 10,
                        maxLines: 1,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.all(15),
                          labelText: "Enter Patient's Mobile Number",
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
                          patient.mobile = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty ||
                              !Utils.isValidPhoneNumber(value)) {
                            return "Please Enter a valid phone number";
                          }
                          patient.mobile = value;
                          return null;
                        },
                      ),
                    ),
                    if (!isUpdate)
                      InkWell(
                        onTap: _checkPatientMobile,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "Check",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  "Patient Name",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _isNumberChecked ? null : _disableToast,
                  child: TextFormField(
                    focusNode: _nameFocusNode,
                    controller: _nameController,
                    maxLength: 30,
                    maxLines: 1,
                    enabled: _isNumberChecked,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.all(15),
                      labelText: "Enter Full Patient Name",
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      fillColor: transparentBlue,
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter a valid name";
                      }
                      patient.name = value;
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Age",
                            style: TextStyle(color: darkBlue),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: _isNumberChecked ? null : _disableToast,
                            child: TextFormField(
                              enabled: _isNumberChecked,
                              controller: _ageController,
                              maxLength: 3,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: const EdgeInsets.all(15),
                                labelText: "Age",
                                labelStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                ),
                                fillColor: transparentBlue,
                                filled: true,
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Enter a valid age";
                                }
                                patient.age = value;
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Allergic",
                            style: TextStyle(color: darkBlue),
                          ),
                          const SizedBox(height: 10),
                          buildAllergySelector(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  "Gender",
                  style: TextStyle(color: darkBlue),
                ),
                const SizedBox(height: 10),
                _buildGenderSelector(),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.maxFinite, 30),
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Border radius
                    ),
                  ),
                  onPressed: _handleContinue,
                  child: Text(
                    isUpdate ? "Update" : "Continue",
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      if (isUpdate) {
        await _updatePatient();
      } else {
        await _addPatient();
      }
    }
  }

  Future<void> _updatePatient() async {
    try {
      Utils.showLoader(context, "Updating Patient...");
      await api.updatePatient(patient);
      Utils.toast("Patient Updated Successfully!");
    } catch (e) {
      Utils.toast("$e \n Please try again");
    } finally {
      _closeLoaderAndDialog();
    }
  }

  Future<void> _addPatient() async {
    try {
      Utils.showLoader(context, "Adding Patient...");

      int? newPatientId;
      if (patient.patientId.isEmpty) {
        newPatientId = await api.addPatient(patient, widget.userId);
        if (newPatientId == null) {
          Utils.toast("Patient already exists");
          return;
        }
      }
      await api.addDoctorsPatient(
          widget.userId, (newPatientId ?? patient.patientId).toString());

      Utils.toast("Patient Added Successfully!");
      _closeLoaderAndDialog(patientAdded: true);
    } catch (e) {
      Utils.toast("$e \n Please try again");
      pop();
    }
  }

  void _closeLoaderAndDialog({bool patientAdded = false}) {
    if (mounted) {
      pop(); // Close the loader
      Navigator.pop(context,
          patientAdded); // Navigate back, passing the patientAdded status
    }
  }

  _buildGenderSelector() {
    return Wrap(
      children: [
        _buildGenderOption('Male'),
        const SizedBox(width: 10),
        _buildGenderOption('Female'),
        const SizedBox(width: 10),
        _buildGenderOption('Others'),
      ],
    );
  }

  void _selectGender(String gender) {
    patient.gender = gender;
    setState(() {
      _selectedGender = gender;
    });
  }

  void _changeAllergic(String yesOrNo) {
    patient.allergic = yesOrNo;
    setState(() {
      _allergic = yesOrNo;
    });
  }

  Widget _buildGenderOption(String gender) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        if (_isNumberChecked) {
          _selectGender(gender);
        } else {
          _disableToast();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? darkBlue : transparentBlue,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  Widget buildAllergySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _buildAllergyOption('Yes'),
        const SizedBox(width: 30),
        _buildAllergyOption('No'),
      ],
    );
  }

  Widget _buildAllergyOption(String yesOrNo) {
    bool isSelected = _allergic == yesOrNo;
    return GestureDetector(
      onTap: () {
        if (_isNumberChecked) {
          _changeAllergic(yesOrNo);
        } else {
          _disableToast();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? darkBlue : transparentBlue,
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Text(
          yesOrNo,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  void _checkPatientMobile() async {
    if (_mobileController.text.isEmpty) {
      Utils.toast("Number can't be empty");
      return;
    }

    Utils.showLoader(context, "Checking if patient already exits...");

    try {
      List<Patient>? patients = await api.checkPatient(patient.mobile);
      pop();
      if (patients == null || patients.isEmpty) {
        Utils.toast("No patient found!");
      } else {
        _showViewPatientsDialog(patients);
      }
    } catch (t) {
      pop();
      Utils.toast("Patient Not Found");
    }
    setState(() {
      _isNumberChecked = true;
    });
  }

  void _showViewPatientsDialog(List<Patient> patients) async {
    Patient? newPatient = await showDialog(
      context: context,
      builder: (b) {
        return Responsive(
          mobile: _selectPatientDialog(
            EdgeInsets.symmetric(horizontal: 25, vertical: size.height * 0.1),
            patients,
          ),
          desktop: _selectPatientDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 15,
            ),
            patients,
          ),
          tablet: _selectPatientDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 50,
            ),
            patients,
          ),
        );
      },
    );

    if (newPatient == null) {
      setState(() {
        FocusScope.of(context).requestFocus(_nameFocusNode);
      });
    } else {
      _phoneFocusNode.unfocus();
      setState(() {
        setPatientData(newPatient);
        patient.copyFrom(newPatient);
      });
    }
  }

  Dialog _selectPatientDialog(EdgeInsets insetPadding, List<Patient> patients) {
    return Dialog(
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SelectPatientsDialog(patients: patients),
    );
  }

  void _disableToast() {
    Utils.toast("Check number first!");
  }

  void pop() {
    Navigator.pop(context);
  }
}

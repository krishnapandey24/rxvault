import 'package:flutter/material.dart';
import 'package:rxvault/models/patient.dart';
import 'package:rxvault/utils/colors.dart';

import '../../../../network/api_service.dart';
import '../../../../utils/utils.dart';

class AddDiagnosisDialog extends StatefulWidget {
  final String userId;
  final Patient patient;
  final Function(String) updateDiagnosis;

  const AddDiagnosisDialog(
      {super.key,
      required this.userId,
      required this.patient,
      required this.updateDiagnosis});

  @override
  State<AddDiagnosisDialog> createState() => AddDiagnosisDialogState();
}

class AddDiagnosisDialogState extends State<AddDiagnosisDialog> {
  final _formKey = GlobalKey<FormState>();
  final api = API();
  late Patient patient = widget.patient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Utils.getDefaultAppBar(
        "Add Diagnosis",
        [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.cancel,
              color: darkBlue,
            ),
          )
        ],
        const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      "Diagnosis",
                      style: TextStyle(color: darkBlue),
                    ),
                    Icon(
                      fill: 1.0,
                      Icons.arrow_drop_up_outlined,
                      color: Colors.green,
                      size: 30,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  minLines: 10,
                  maxLines: 30,
                  initialValue: patient.diagnosis,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.all(15),
                    labelText: "Enter Diagnosis",
                    alignLabelWithHint: true,
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
                    fillColor: transparentBlue,
                    filled: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    patient.diagnosis = value;
                    return null;
                  },
                ),
                const SizedBox(height: 45),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.maxFinite, 30),
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Border radius
                    ),
                  ),
                  onPressed: handleContinue,
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleContinue() {
    if (_formKey.currentState!.validate()) {
      Utils.showLoader(context, "Adding Diagnosis...");
      api.updatePatient(patient).then((value) {
        Navigator.pop(context);
        Utils.toast("Diagnosis added successfully");
        Navigator.pop(context);
        widget.updateDiagnosis(patient.diagnosis ?? "");
      }).catchError((e) {
        Utils.toast("$e \n Please try again");
        Navigator.pop(context);
      });
    }
  }
}

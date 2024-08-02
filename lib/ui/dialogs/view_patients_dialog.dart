import 'package:flutter/material.dart';

import '../../models/patient.dart';
import '../../network/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';

class ViewPatientsDialog extends StatefulWidget {
  final List<Patient> patients;

  const ViewPatientsDialog({super.key, required this.patients});

  @override
  State<ViewPatientsDialog> createState() => ViewPatientsDialogState();
}

class ViewPatientsDialogState extends State<ViewPatientsDialog> {
  late Size size;
  late List<Patient> patients = widget.patients;
  final api = API();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Utils.getDefaultAppBar(
        "Related Patients",
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: patients.length,
              itemBuilder: (BuildContext context, int index) {
                Patient patient = patients[index];
                return Container(
                  margin: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: darkBlue, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.asset(
                      patient.gender == "Male"
                          ? "assets/images/ic_male.png"
                          : "assets/images/ic_female.png",
                      height: 40,
                      width: 40,
                    ),
                    title: Text(
                      getFormattedName(patient.name),
                      maxLines: 1,
                      style: const TextStyle(
                        color: darkBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.add_circle_outlined,
                      color: darkBlue,
                    ),
                    onTap: () {
                      Navigator.pop(context, patient);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.maxFinite, 30),
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Border radius
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Add New Patient",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  String getFormattedName(String name) {
    if (name.length > 10) {
      return '${name.substring(0, 10)}...';
    } else {
      return name;
    }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxvault/selected_services.dart';
import 'package:rxvault/ui/widgets/responsive.dart';

import '../../models/setting.dart';
import '../../network/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/utils.dart';

class SelectServicesDialog extends StatefulWidget {
  final Setting setting;
  final String patientId;
  final String selectedServices;
  final Function(String, String) update;

  const SelectServicesDialog(
      {super.key,
      required this.setting,
      required this.patientId,
      required this.update,
      required this.selectedServices});

  @override
  State<SelectServicesDialog> createState() => SelectServicesDialogState();
}

class SelectServicesDialogState extends State<SelectServicesDialog> {
  late Size size;
  final searchFocusNode = FocusNode();

  get setting => widget.setting;
  late Map<String, String> allServices =
      Utils.getServicesFromString(widget.setting.itemDetails);
  List<MapEntry<String, String>> displayedServices = [];
  final searchController = TextEditingController();
  late final SelectedServices selectedServices;
  final api = API();

  @override
  void initState() {
    super.initState();
    displayedServices = allServices.entries.toList();
    selectedServices = SelectedServices(getSelectedServiceFromString());
  }

  Map<String, String> getSelectedServiceFromString() {
    try {
      return jsonDecode(widget.selectedServices);
    } catch (e) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Utils.getDefaultAppBar(
        "Select Services",
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSearchBar(),
              const SizedBox(height: 20),
              buildListViewWithCheckbox(),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: double.maxFinite,
                height: 1,
                color: Colors.grey.shade400,
              ),
              buildTotal(),
              Responsive(
                desktop: SizedBox(width: size.width * 0.3, child: saveButton()),
                mobile: saveButton(),
                tablet: SizedBox(width: size.width * 0.3, child: saveButton()),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget saveButton() {
    return ElevatedButton(
      onPressed: updateServices,
      child: const Text(
        "Add",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  String getSelectedServiceAsString() {
    try {
      return jsonEncode(selectedServices.selectedServices);
    } catch (e) {
      return "";
    }
  }

  void updateServices() {
    Utils.showLoader(context, "Updating services...");
    String selectedService = getSelectedServiceAsString();
    String totalAmount = selectedServices.total.toString();
    api
        .addDoctorsPatient(
      setting.doctorId,
      widget.patientId,
      selectedService,
      totalAmount,
    )
        .then((value) {
      widget.update(selectedService, totalAmount);
      Navigator.pop(context);
      Navigator.pop(context);
    }).catchError((e) {
      Utils.toast(e.toString());
      Navigator.pop(context);
    });
  }

  Padding buildTotal() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Total: ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              " $rupee${selectedServices.total}",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListViewWithCheckbox() {
    return Container(
      color: transparentBlue,
      height: size.height * 0.5,
      child: ListView.builder(
        itemCount: displayedServices.length,
        itemBuilder: (context, index) {
          String serviceName = displayedServices[index].key;
          String servicePrice = displayedServices[index].value;
          bool isSelected = selectedServices.haveService(serviceName);
          return InkWell(
            onTap: () {
              setState(() {
                isSelected = !isSelected;
              });
            },
            child: ListTile(
              leading: Checkbox(
                fillColor: Utils.getFillColor(),
                checkColor: Colors.white,
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedServices.addService(serviceName, servicePrice);
                    } else {
                      selectedServices.removeService(serviceName);
                    }
                  });
                },
              ),
              title: Text(serviceName),
              trailing: Text(
                "$rupee $servicePrice",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      maxLength: 10,
      maxLines: 1,
      focusNode: searchFocusNode,
      onChanged: searchService,
      keyboardType: TextInputType.text,
      controller: searchController,
      decoration: InputDecoration(
        isDense: true,
        counterText: '',
        contentPadding: EdgeInsets.zero,
        prefixIcon: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            Icons.search_sharp,
            color: darkBlue,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
          maxWidth: 50,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 50,
          maxWidth: 50,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () {
              setState(() {
                searchController.clear();
                displayedServices = allServices.entries.toList();
              });
              searchFocusNode.unfocus();
            },
            child: const Icon(
              Icons.cancel,
              color: Colors.black,
            ),
          ),
        ),
        labelText: "Search Service",
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
      style: const TextStyle(color: Colors.black, fontSize: 13),
    );
  }


  void searchService(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedServices = allServices.entries.toList();
      } else {
        displayedServices = allServices.entries
            .where((entry) =>
                entry.key.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
}

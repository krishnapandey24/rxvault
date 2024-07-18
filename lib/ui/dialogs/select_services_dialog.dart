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
  final String doctorId;
  final String selectedServices;
  final Function(String, String) update;

  const SelectServicesDialog(
      {super.key,
      required this.setting,
      required this.patientId,
      required this.update,
      required this.selectedServices,
      required this.doctorId});

  @override
  State<SelectServicesDialog> createState() => SelectServicesDialogState();
}

class SelectServicesDialogState extends State<SelectServicesDialog> {
  late Size size;
  final searchFocusNode = FocusNode();
  int otherServiceAddition = 0;

  get setting => widget.setting;
  late Map<String, String> allServices =
      Utils.getServicesFromString(widget.setting.itemDetails);
  List<MapEntry<String, String>> displayedServices = [];
  final searchController = TextEditingController();
  late final SelectedServices selectedServices;
  final api = API();
  late int servicesCount;
  String otherServiceName = "";
  String otherServiceAmount = "";
  bool otherServiceSelected = false;

  @override
  void initState() {
    super.initState();
    displayedServices = allServices.entries.toList();
    servicesCount = displayedServices.length;
    selectedServices = SelectedServices(getSelectedServiceFromString());
  }

  Map<String, String> getSelectedServiceFromString() {
    try {
      Map<String, dynamic> tempMap = jsonDecode(widget.selectedServices);
      return tempMap.map((key, value) => MapEntry(key, value.toString()));
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

  void updateServices() async {
    Utils.showLoader(context, "Updating services...");
    if (otherServiceSelected && otherServiceAmount != "") {
      if (otherServiceName == "") {
        otherServiceName = "Other";
      }
      selectedServices.addService(otherServiceName, otherServiceAmount);
    }
    String selectedService = getSelectedServiceAsString();
    String totalAmount = selectedServices.total.toString();
    try {
      await api.addDoctorsPatient(
        widget.doctorId,
        widget.patientId,
        selectedService,
        totalAmount,
      );
      if (!mounted) return;
      widget.update(selectedService, totalAmount);
      Navigator.pop(context);
    } catch (e, t) {
      Utils.toast(e.toString());
      print("$e $t");
    } finally {
      Navigator.pop(context);
    }
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
              " $rupee${selectedServices.total + otherServiceAddition}",
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
      child: ListView(
        children: _buildListViewChildren(),
      ),
    );
  }

  List<Widget> _buildListViewChildren() {
    List<Widget> children = displayedServices
        .map((service) => getListItem(service.key, service.value, false))
        .toList();
    children.addAll(selectedServices.copy.entries
        .map((service) => getListItem(service.key, service.value, true))
        .toList());
    children.add(_otherServiceItem());
    return children;
  }

  Widget _otherServiceItem() {
    return ListTile(
      leading: Checkbox(
        fillColor: Utils.getFillColor(),
        checkColor: Colors.white,
        value: otherServiceSelected,
        onChanged: (bool? value) {
          if (otherServiceAmount != "") {
            setState(() {
              otherServiceSelected = !otherServiceSelected;
              if (otherServiceSelected) {
                otherServiceAddition = parseStringToInt(otherServiceAmount);
              } else {
                otherServiceAddition = 0;
              }
            });
          }
        },
      ),
      title: Row(
        children: [
          Flexible(
            child: TextField(
              onChanged: (value) {
                otherServiceName = value;
              },
              decoration: const InputDecoration(hintText: "Others"),
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
      trailing: SizedBox(
        width: 55,
        child: TextField(
          onChanged: (value) {
            otherServiceAmount = value;
            if (otherServiceSelected) {
              setState(() {
                otherServiceAddition = parseStringToInt(otherServiceAmount);
              });
            }
          },
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixText: rupee,
          ),
        ),
      ),
    );
  }

  int parseStringToInt(String? input) {
    if (input == null) {
      return 0;
    }

    int? parsedValue = int.tryParse(input);
    if (parsedValue != null) {
      return parsedValue;
    } else {
      return 0;
    }
  }

  Widget getListItem(
      String serviceName, String servicePrice, bool alreadyAdded) {
    bool isSelected = alreadyAdded || selectedServices.haveService(serviceName);
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
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

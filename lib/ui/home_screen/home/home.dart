import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxvault/enums/permission.dart';
import 'package:rxvault/ui/dialogs/add_diagnosis_dialog.dart';
import 'package:rxvault/ui/dialogs/add_patient_dialog.dart';
import 'package:rxvault/ui/dialogs/select_services_dialog.dart';
import 'package:rxvault/ui/view_all_documents.dart';
import 'package:rxvault/ui/widgets/responsive.dart';
import 'package:rxvault/utils/colors.dart';

import '../../../models/patient.dart';
import '../../../models/setting.dart';
import '../../../models/user_info.dart';
import '../../../network/api_service.dart';
import '../../../utils/utils.dart';
import '../../dialogs/upload_image_dialog.dart';
import '../../view_patient.dart';
import '../../widgets/rxvault_app_bar.dart';
import '../../widgets/triangle.dart';

class Home extends StatefulWidget {
  final String userId;
  final Setting setting;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String clinicName;

  const Home({
    super.key,
    required this.userId,
    required this.setting,
    required this.scaffoldKey,
    required this.clinicName,
  });

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final searchController = TextEditingController();
  final fileNameController = TextEditingController();
  final searchFocusNode = FocusNode();
  bool clinicOpen = true;
  bool isSearching = false;
  bool isFirst = true;
  bool isLoading = false;
  int totalAmount = 0;
  String? permission;
  String? selectedDate;
  final api = API();
  List<Patient> patients = [];
  List<Patient> searchResults = [];
  late User user;
  late Setting setting;
  late Size size;
  late double screenWidth;
  late double screenHeight;

  String get userId => widget.userId;

  @override
  void initState() {
    super.initState();
    setting = widget.setting;
    clinicOpen = setting.status == "open";
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Patient> patients =
          await api.getSelectedPatientList(widget.userId, selectedDate);
      int totalAmount = setTotalAmount(patients);

      setState(() {
        this.patients = patients;
        this.totalAmount = totalAmount;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Utils.toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return Scaffold(
      appBar: RxVaultAppBar(
        userId: widget.userId,
        openDrawer: (isMobile) {
          if (isMobile) {
            widget.scaffoldKey.currentState?.openDrawer();
          } else {
            widget.scaffoldKey.currentState?.openEndDrawer();
          }
        },
        clinicName: widget.clinicName,
        setting: setting,
        changeAppointmentDate: (date) {
          selectedDate = date;
          _loadData();
        },
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: transparentBlue,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: buildMainColumn(),
        ),
      ),
    );
  }

  Row buildRow1(int totalPatients) {
    return Row(
      children: [
        buildUserAndDoctorName(),
        const Spacer(),
        buildBoxIndicators(Icons.person, "Patients", "$totalPatients"),
        const SizedBox(width: 15),
        buildBoxIndicators(
            Icons.currency_rupee, "Amount", totalAmount.toString()),
      ],
    );
  }

  Widget buildBoxIndicators(IconData icon, String text, String quantity) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: teal),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: Colors.black,
                ),
                const SizedBox(width: 5),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          Container(
            color: teal,
            height: 1,
            width: double.maxFinite,
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              quantity,
              style: const TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          )
        ],
      ),
    );
  }

  Column buildUserAndDoctorName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                " User:  ",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            Transform.scale(
              scale: 0.7,
              child: Switch(
                activeTrackColor: darkBlue,
                activeColor: Colors.white,
                value: clinicOpen,
                onChanged: (value) {
                  setState(() {
                    clinicOpen = value;
                  });
                  if (user.isStaff) {
                    Utils.noPermission();
                    return;
                  }
                  updateClinicStatus(clinicOpen);
                },
              ),
            ),
          ],
        ),
        Text(
          user.userName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void updateClinicStatus(bool open) async {
    Utils.showLoader(context);
    setting.status = open ? "open" : "close";
    try {
      await api.updateSettings(setting);
      Utils.toast("Clinic ${setting.status}");
    } catch (e) {
      Utils.toast(e.toString());
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  buildSearchBar() {
    return TextField(
      maxLength: 10,
      maxLines: 1,
      focusNode: searchFocusNode,
      onChanged: _searchPatient,
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
              if (isSearching) {
                clearSearch();
              } else {
                showAddPatientDialog();
              }
            },
            child: Icon(
              isSearching ? Icons.cancel : Icons.add_circle,
              color: Colors.black,
            ),
          ),
        ),
        labelText: "Search Patient by Name or mobile no.",
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
        fillColor: Colors.white,
        filled: true,
      ),
      style: const TextStyle(color: Colors.black, fontSize: 13),
    );
  }

  Dialog addPatientDialog(EdgeInsets insetPadding, [Patient? patient]) {
    return Dialog(
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: AddPatientDialog(
        userId: widget.userId,
        patient: patient,
      ),
    );
  }

  Dialog addDiagnosis(EdgeInsets insetPadding, Patient patient) {
    return Dialog(
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        height: size.height * 0.6,
        child: AddDiagnosisDialog(
          userId: widget.userId,
          patient: patient,
          updateDiagnosis: (String diagnosis) {
            setState(() {
              patient.diagnosis = diagnosis;
            });
          },
        ),
      ),
    );
  }

  void _searchPatient(String value) {
    setState(() {
      isSearching = true;
    });
    api.getPatientList(userId, value).then((value) {
      setState(() {
        searchResults.clear();
        searchResults.addAll(value);
      });
    }).catchError((e) {
      Utils.toast(e.toString());
    });
  }

  Widget buildPatientList(bool isMobile) {
    int length = patients.length;
    return Expanded(
      child: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Positioned.fill(
                  child:
                      isMobile ? buildListView(length) : buildGridView(length),
                ),
          if (searchResults.isNotEmpty)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: isMobile
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.15,
                        ),
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: searchResultItem,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  RefreshIndicator buildListView(int length) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) =>
            buildPatientListItem(context, index, false, length),
      ),
    );
  }

  RefreshIndicator buildGridView(int length) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 60,
          crossAxisSpacing: 20,
        ),
        itemCount: patients.length,
        itemBuilder: (context, index) =>
            buildPatientListItem(context, index, true, length),
      ),
    );
  }

  void onSearchedPatientTap(Patient patient) {
    if (user.doNotHavePermission(Permission.addAppointment)) {
      Utils.noPermission();
      return;
    }
    clearSearch();
    Utils.showLoader(context, "Adding Patient to the list...");
    api.addDoctorsPatient(userId, patient.patientId).then((value) {
      Navigator.pop(context);
      _loadData();
    }).catchError((e) {
      Navigator.pop(context);
      Utils.toast(e.toString());
    });
  }

  Widget searchResultItem(BuildContext context, int index) {
    Patient patient = searchResults[index];
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(6),
      width: double.maxFinite,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            getFormattedName(patient.name),
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => ViewPatient(
                  patient: patient,
                  doctorId: userId,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: const Text(
                " View ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => onSearchedPatientTap(patient),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: const Text(
                " Add Visit ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Patient List Item
  Widget? buildPatientListItem(
      BuildContext context, int index, bool isGrid, int size) {
    final GlobalKey key = GlobalKey();
    Patient patient = patients[(size - 1 - index)];
    return Container(
      height: isGrid ? 70 : 60,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      width: double.maxFinite,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: darkBlue, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => showUpdatePatientDialog(patient),
            child: Image.asset(
              patient.gender == "Male"
                  ? "assets/images/ic_male.png"
                  : "assets/images/ic_female.png",
              height: 40,
              width: 40,
            ),
          ),
          const SizedBox(width: 5),
          InkWell(
            onTap: () => showAddDiagnosis(patient),
            child: buildItemColumn1(patient),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              showSelectServicesDialog(widget.setting, patient);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: BoxDecoration(
                border: Border.all(color: teal, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: screenWidth * (isGrid ? 0.11 : 0.22),
                child: Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      color: darkBlue,
                      size: 18,
                    ),
                    Responsive(
                      mobile: buildAmountText(patient, true),
                      tablet: buildAmountText(patient, false),
                      desktop: buildAmountText(patient, false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => _showDocumentsDialog(patient.patientId),
            child: Padding(
              padding: isGrid
                  ? const EdgeInsets.all(7)
                  : const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
              child: Image.asset("assets/images/as15.png"),
            ),
          ),
          InkWell(
            onTap: () =>
                addDocumentDialog(patient.patientId, patient.doctorPatientId!),
            child: Padding(
              padding: isGrid
                  ? const EdgeInsets.all(7)
                  : const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
              child: Image.asset("assets/images/as16.png"),
            ),
          ),
          InkWell(
            key: key,
            onTap: () {
              showDropdownMenu(
                  context, key, patient.doctorPatientId!, index, patient);
            },
            child: const Icon(
              Icons.more_vert,
              color: darkBlue,
            ),
          )
        ],
      ),
    );
  }

  Text buildAmountText(Patient patient, bool isMobile) {
    return Text(
      _getFormattedAmount(patient.getTotalAmount, isMobile),
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14, color: Colors.black),
    );
  }

  String _getFormattedAmount(String amount, bool isMobile) {
    if (isMobile && amount.length > 8) {
      return "${_formatIndianNumber(amount.substring(0, 6))}...";
    }
    return _formatIndianNumber(amount);
  }

  String _formatIndianNumber(String amount) {
    amount = amount.replaceAll(',', '');

    if (amount.isEmpty || !RegExp(r'^\d+$').hasMatch(amount)) {
      return amount;
    }

    List<String> chars = amount.split('');
    chars = chars.reversed.toList();

    for (int i = 3; i < chars.length; i += 2) {
      chars.insert(i, ',');
      i++;
    }

    return chars.reversed.join('');
  }

  void showDropdownMenu(BuildContext context, GlobalKey key,
      String doctorPatientId, int index, Patient patient) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height,
        position.dx + renderBox.size.width,
        0,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
        const PopupMenuItem<String>(
          value: 'view_history',
          child: Text('View History'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        if (value == 'delete') {
          deleteSelectedPatient(doctorPatientId, index);
        } else {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => ViewPatient(
                patient: patient,
                doctorId: userId,
              ),
            ),
          );
        }
      }
    });
  }

  void _showDocumentsDialog(String patientId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: ViewAllDocuments(
            patientId: patientId,
            doctorId: widget.userId,
            date: selectedDate,
          ),
        );
      },
    );
  }

  void addDocumentDialog(String patientId, String doctorPatientId) {
    if (user.doNotHavePermission(Permission.addImage)) {
      Utils.noPermission();
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Responsive(
            mobile: UploadImageDialogs(
              isMobile: true,
              screenWidth: screenWidth,
              parentContext: context,
              userId: widget.userId,
              patientId: patientId,
              doctorPatientId: doctorPatientId,
            ),
            desktop: UploadImageDialogs(
              isMobile: false,
              screenWidth: screenWidth,
              parentContext: context,
              userId: widget.userId,
              patientId: patientId,
              doctorPatientId: doctorPatientId,
            ),
            tablet: UploadImageDialogs(
              isMobile: false,
              screenWidth: screenWidth,
              parentContext: context,
              userId: widget.userId,
              patientId: patientId,
              doctorPatientId: doctorPatientId,
            ),
          );
        });
  }

  Column buildItemColumn1(Patient patient) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => ViewPatient(
                  patient: patient,
                  doctorId: userId,
                ),
              ),
            );
          },
          child: Text(
            getFormattedName(patient.name),
            maxLines: 1,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        buildPatientInfoRow(patient)
      ],
    );
  }

  String getFormattedName(String name) {
    if (name.length > 10) {
      return '${name.substring(0, 10)}...';
    } else {
      return name;
    }
  }

  Row buildPatientInfoRow(Patient patient) {
    List<Widget> children = [
      Text(
        patient.age,
        style: const TextStyle(color: Colors.black, fontSize: 13),
      ),
      const SizedBox(width: 8),
    ];

    if (patient.diagnosis?.isNotEmpty ?? false) {
      children.add(const Triangle());
      children.add(const SizedBox(width: 4));
      children.add(
        Text(
          patient.diagnosis!.substring(0, 4),
          style: const TextStyle(color: Colors.black, fontSize: 13),
        ),
      );
    } else {
      children.add(
        const Text(
          "DIAG",
          style: TextStyle(color: Colors.black, fontSize: 13),
        ),
      );
    }

    children.add(const SizedBox(width: 8));
    children.add(
      Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: patient.isAllergic ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          " ${patient.isAllergic ? "A" : "B"} ",
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
    children.add(const SizedBox(width: 8));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget buildMainColumn() {
    return Column(
      children: [
        const SizedBox(height: 10),
        buildRow1(patients.length),
        const SizedBox(height: 10),
        buildSearchBar(),
        const SizedBox(height: 10),
        Responsive(
          mobile: buildPatientList(true),
          desktop: buildPatientList(false),
          tablet: buildPatientList(false),
          largeMobile: buildPatientList(true),
        ),
      ],
    );
  }

  void showAddPatientDialog() async {
    if (user.doNotHavePermission(Permission.addPatient)) {
      Utils.noPermission();
      return;
    }

    bool? patientAdded = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Responsive(
          mobile: addPatientDialog(
            EdgeInsets.symmetric(horizontal: 25, vertical: size.height * 0.1),
          ),
          desktop: addPatientDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 15,
            ),
          ),
          tablet: addPatientDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 50,
            ),
          ),
        );
      },
    );

    if (patientAdded != null) {
      _loadData();
    }
  }

  void showUpdatePatientDialog(Patient patient) async {
    if (user.doNotHavePermission(Permission.updatePatient)) {
      Utils.noPermission();
      return;
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Responsive(
          mobile: addPatientDialog(const EdgeInsets.all(15), patient),
          desktop: addPatientDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 15,
            ),
            patient,
          ),
          tablet: addPatientDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 50,
            ),
            patient,
          ),
        );
      },
    );

    setState(() {
      patient = patient;
    });
  }

  void showAddDiagnosis(Patient patient) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Responsive(
          mobile: addDiagnosis(const EdgeInsets.all(15), patient),
          desktop: addDiagnosis(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 15,
            ),
            patient,
          ),
          tablet: addDiagnosis(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 50,
            ),
            patient,
          ),
        );
      },
    );
  }

  void showSelectServicesDialog(Setting setting, Patient patient) {
    if (patient.getTotalAmount == "0") {
      if (user.doNotHavePermission(Permission.updatePatientService) ||
          user.doNotHavePermission(Permission.addPatientService)) {
        Utils.noPermission();
        return;
      }
    } else {
      if (user.doNotHavePermission(Permission.updatePatientService)) {
        Utils.noPermission();
        return;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Responsive(
          mobile: buildSelectServiceDialog(
            const EdgeInsets.all(15),
            setting,
            patient,
          ),
          desktop: buildSelectServiceDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 15,
            ),
            setting,
            patient,
          ),
          tablet: buildSelectServiceDialog(
            const EdgeInsets.symmetric(
              horizontal: 85,
              vertical: 50,
            ),
            setting,
            patient,
          ),
        );
      },
    );
  }

  buildSelectServiceDialog(
    EdgeInsets insetPadding,
    Setting setting,
    Patient patient,
  ) {
    return Dialog(
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SelectServicesDialog(
        setting: setting,
        doctorId: widget.userId,
        patientId: patient.patientId,
        selectedServices: patient.selectedServices ?? "",
        update: (selectedServices, totalAmount) {
          setState(() {
            patient.selectedServices = selectedServices;
            this.totalAmount = this.totalAmount +
                parseNullableStringToInt(totalAmount) -
                parseNullableStringToInt(patient.totalAmount);
            patient.totalAmount = totalAmount;
          });
        },
      ),
    );
  }

  void deleteSelectedPatient(String doctorPatientId, int index) {
    if (user.doNotHavePermission(Permission.deletePatient)) {
      Utils.noPermission();
      return;
    }
    Utils.showLoader(context, "Deleting Entry...");
    api.deleteSelectedPatient(doctorPatientId, widget.userId).then((value) {
      Navigator.pop(context);
      _loadData();
      Utils.toast("Patient Removed");
    }).catchError((e) {
      Utils.toast("Unable to remove patient!");
      Navigator.pop(context);
    });
  }

  int setTotalAmount(List<Patient> patients) {
    int total = 0;
    for (var patient in patients) {
      int addition;
      try {
        addition = int.parse(patient.getTotalAmount);
      } catch (e) {
        addition = 0;
      }
      total += addition;
    }
    return total;
  }

  void clearSearch() {
    setState(() {
      searchResults.clear();
      searchController.clear();
      isSearching = false;
    });
    searchFocusNode.unfocus();
  }

  int parseNullableStringToInt(String? nullableString) {
    return int.tryParse(nullableString ?? '') ?? 0;
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final DateFormat formatter = DateFormat("yyyy-MM-dd");
    return formatter.format(now);
  }
}

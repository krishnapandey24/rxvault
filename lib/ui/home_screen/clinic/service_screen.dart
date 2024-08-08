import 'package:flutter/material.dart';
import 'package:rxvault/models/setting.dart';

import '../../../network/api_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/utils.dart';
import '../../widgets/responsive.dart';

class ServiceScreen extends StatefulWidget {
  final Setting setting;
  final String userId;
  final bool isStaff;
  final Function({
    required bool forDelete,
    bool? forService,
    bool? isUpdate,
    Map<String, String>? givenServices,
  }) updateSettings;

  const ServiceScreen({
    super.key,
    required this.setting,
    required this.userId,
    required this.isStaff,
    required this.updateSettings,
  });

  @override
  State<ServiceScreen> createState() => ServiceScreenState();
}

class ServiceScreenState extends State<ServiceScreen> {
  late Size size;
  Map<String, String> services = {};
  late Setting setting;
  final API api = API();
  var isLoading = true;
  List<MapEntry<String, String>> _serviceList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    if (widget.setting.itemDetails != null) {
      setting = widget.setting;
    } else {
      setting = await api.getSettings(widget.userId);
    }

    setState(() {
      services = Utils.getServicesFromString(setting.itemDetails);
      _serviceList = services.entries.toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showAddUpdateServiceDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildServiceView(_serviceList.length),
    );
  }

  _buildServiceView(int length) {
    if (length == 0) {
      return const Center(
        child: Text("Click on Add Button (+) to Add Service"),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Responsive(
        desktop: _buildServiceGridView(length),
        mobile: _buildServiceListView(length),
        tablet: _buildServiceGridView(length),
      ),
    );
  }

  ListView _buildServiceListView(int length) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: length,
      itemBuilder: (context, index) => _buildServiceItem(context, index, false),
    );
  }

  GridView _buildServiceGridView(int length) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 65,
        crossAxisSpacing: 20,
      ),
      itemCount: length,
      itemBuilder: (context, index) => _buildServiceItem(context, index, true),
    );
  }

  Widget _buildServiceItem(BuildContext context, int index, bool isGrid) {
    MapEntry<String, String> service = _serviceList[index];
    return Container(
      height: isGrid ? 65 : 60,
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
          const Icon(Icons.local_hospital),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  service.key,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: darkBlue,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "$rupee${service.value}",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () =>
                showAddUpdateServiceDialog(key: service.key, index: index),
            icon: const Icon(
              Icons.edit,
              color: darkBlue,
            ),
          ),
          IconButton(
            onPressed: () => _deleteService(service.key, index),
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteService(String key, int index) {
    if (widget.isStaff) {
      Utils.noPermission();
      return;
    }
    Utils.showLoader(context, "Deleting service...");
    setState(() {
      services.remove(key);
      _serviceList.removeAt(index);
    });

    widget.updateSettings(
      givenServices: services,
      forDelete: true,
      forService: true,
      isUpdate: true,
    );
  }

  Future<void> showAddUpdateServiceDialog({String? key, int? index}) async {
    if (widget.isStaff) {
      Utils.noPermission();
      return;
    }
    bool isUpdate = key != null;
    String addOrUpdate = isUpdate ? "Update" : "Add";
    String name;
    String value;
    if (isUpdate) {
      name = key;
      value = services[key]!;
    } else {
      name = "";
      value = "";
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$addOrUpdate Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                maxLength: 20,
                initialValue: name,
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Service Name',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                onChanged: (input) {
                  name = input;
                },
              ),
              TextFormField(
                maxLength: maxAmountLength,
                initialValue: value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  counterText: '',
                  prefixIcon: Icon(Icons.currency_rupee),
                  labelText: 'Amount',
                ),
                onChanged: (input) {
                  value = input;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && value.isNotEmpty) {
                  if (key != name) {
                    services.remove(key);
                  }
                  addUpdateService(name, value, isUpdate, index);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter both service name and value.'),
                  ));
                }
              },
              child: Text(addOrUpdate),
            ),
          ],
        );
      },
    );
  }

  void addUpdateService(String name, String value, bool isUpdate,
      [int? index]) {
    name = Utils.capitalizeFirstLetter(name);
    Utils.showLoader(
        context, "${isUpdate ? "Updating" : "Adding new"} service...");

    setState(() {
      services[name] = value;
      if (!isUpdate) {
        _serviceList.add(MapEntry(name, value));
      } else {
        if (index != null) {
          _serviceList[index] = MapEntry(name, value);
        }
      }
    });
    widget.updateSettings(
        givenServices: services, forDelete: false, forService: true);
  }
}

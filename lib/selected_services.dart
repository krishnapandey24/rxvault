class SelectedServices {
  Map<String, String> selectedServices = {};
  Map<String, String> copy = {};

  SelectedServices(this.selectedServices) {
    copy = Map<String, String>.from(selectedServices);
  }

  SelectedServices.empty();

  void addService(String name, String value) {
    selectedServices[name] = value;
  }

  void removeService(String name) {
    selectedServices.remove(name);
  }

  bool haveService(String name) {
    if (selectedServices.containsKey(name)) {
      copy.remove(name);
      return true;
    } else {
      return false;
    }
  }

  int get total {
    int total = 0;
    selectedServices.forEach((key, value) {
      total += int.parse(value);
    });
    return total;
  }
}

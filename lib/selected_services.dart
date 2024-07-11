class SelectedServices {
  Map<String, String> selectedServices = {};

  SelectedServices(this.selectedServices);
  SelectedServices.empty();

  void addService(String name, String value) {
    selectedServices[name] = value;
  }

  void removeService(String name) {
    selectedServices.remove(name);
  }

  bool haveService(String name) {
    return selectedServices.containsKey(name);
  }

  int get total {
    int total = 0;
    selectedServices.forEach((key, value) {
      total += int.parse(value);
    });
    return total;
  }
}

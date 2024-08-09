import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class DropDownSelector extends StatefulWidget {
  final List<String> options;
  final Function(String) setSelection;
  final String label;

  const DropDownSelector(
      {super.key,
      required this.options,
      required this.setSelection,
      required this.label});

  @override
  State<DropDownSelector> createState() => _DropDownSelectorState();
}

class _DropDownSelectorState extends State<DropDownSelector> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: DropdownButtonFormField(
        value: selectedValue,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.all(15),
          labelText: "Select Type",
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
          fillColor: Colors.white,
          filled: true,
        ),
        icon: const CircleAvatar(
          backgroundColor: transparentBlue,
          child: Icon(
            Icons.arrow_drop_down,
            color: darkBlue,
          ),
        ),
        items: widget.options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          widget.setSelection(value!);
          setState(() {
            selectedValue = value;
          });
        },
      ),
    );
  }
}

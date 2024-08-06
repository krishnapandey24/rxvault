import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/colors.dart';
import '../../utils/utils.dart';

class TimePicker extends StatefulWidget {
  final String title;
  final bool isStaff;
  final Function(String) onPicked;
  final String? time;

  const TimePicker(
      {super.key,
      required this.title,
      required this.onPicked,
      required this.time,
      required this.isStaff});

  @override
  State<TimePicker> createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  String? time;

  @override
  void initState() {
    super.initState();
    time = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pickTime,
      child: Container(
        height: 46.4, // 58 * 0.8
        padding: const EdgeInsets.symmetric(horizontal: 9.6), // 12 * 0.8
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // 10 * 0.8
          border: Border.all(color: Colors.grey, width: 1.12), // 1.4 * 0.8
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_outlined,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 8), // 10 * 0.8
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: time == null ? Colors.grey : primary,
                    fontSize: time == null ? 14.4 : 9.6, // 18 * 0.8 : 12 * 0.8
                  ),
                ),
                if (time != null)
                  Text(
                    time!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.4, // 18 * 0.8
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8), // 10 * 0.8
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickTime() async {
    if (widget.isStaff) {
      Utils.noPermission();
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final DateTime selectedTime = DateTime(
        0,
        1,
        1,
        pickedTime.hour,
        pickedTime.minute,
      );

      final String formattedTime = DateFormat('hh:mm a').format(selectedTime);
      setState(() {
        time = formattedTime;
        widget.onPicked(time!);
      });
    }
  }
}

import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../models/notification_list_response.dart';
import '../network/api_service.dart';
import '../utils/colors.dart';

class NotificationScreen extends StatefulWidget {
  final String type;

  const NotificationScreen({super.key, required this.type});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final api = API();
  late final Future<List<Message>> notificationFuture;
  List<Message> notifications = [];
  late Size size;

  @override
  void initState() {
    super.initState();
    notificationFuture = api.getNotifications(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: Utils.getDefaultAppBar("Notifications"),
      body: FutureBuilder<List<Message>>(
        future: notificationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  "No Data Found",
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            } else {
              int size = notifications.length;
              return ListView.builder(
                itemCount: size,
                itemBuilder: (context, index) {
                  index = size - index - 1;
                  Message notification = notifications[index];
                  return buildNotificationItem(notification);
                },
              );
            }
          }
        },
      ),
    );
  }

  Widget buildNotificationItem(Message notification) {
    return InkWell(
      onTap: () {
        String? url = Utils.extractUrl(notification.message);
        if (url != null) {
          Utils.launchUrl(url);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: darkBlue),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              notification.messageTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: darkBlue,
              ),
            ),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 13,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              Utils.formatDate(notification.created),
              style: const TextStyle(
                fontSize: 10,
                color: darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void confirmClearAllDialog() {
    Utils.showAlertDialog(
        context,
        "Are you sure you want clear all notifications?",
        _clearAll,
        () => Navigator.pop(context));
  }

  void _clearAll() {
    // Utils.showLoading(context);
    // api.clearNotifications(widget.userId).then((value) {
    //   Navigator.pop(context);
    //   setState(() {
    //     notifications.clear();
    //   });
    //   Utils.toast("Notifications Cleared");
    // }).catchError((e) {
    //   Navigator.pop(context);
    //   Utils.showErrorDialog(context, "Something went wrong");
    // });
  }
}

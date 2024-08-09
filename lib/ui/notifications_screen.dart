import 'package:flutter/material.dart';
import 'package:rxvault/network/api_service.dart';
import 'package:rxvault/utils/colors.dart';

import '../../utils/utils.dart';
import '../models/notification_list_response.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;

  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final api = API();
  late final Future<List<NotificationModel>> notificationFuture;
  List<NotificationModel> notifications = [];
  late Size size;

  @override
  void initState() {
    super.initState();
    notificationFuture = api.getNotifications(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: Utils.getDefaultAppBar("Notifications"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<NotificationModel>>(
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
                  return Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: confirmClearAllDialog,
                              child: const Text(
                                "Clear All",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              NotificationModel notification =
                                  notifications[index];
                              return buildNotificationItem(notification);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildNotificationItem(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.1,
                maxWidth: size.width * 0.1,
              ),
              child: Image.asset(
                "assets/images/chat_2.png",
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  notification.title ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkBlue,
                  ),
                ),
                Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  notification.notification ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            Utils.formatDate(notification.created ?? ""),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade100,
            ),
          ),
        ],
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
    Utils.showLoading(context);
    api.clearNotifications(widget.userId).then((value) {
      Navigator.pop(context);
      setState(() {
        notifications.clear();
      });
      Utils.toast("Notifications Cleared");
    }).catchError((e) {
      Navigator.pop(context);
      Utils.showErrorDialog(context, "Something went wrong");
    });
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controller/notifications_controller.dart';
import 'package:get/get.dart';
import '../../../auth/controller/token_controller.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsController _controller = Get.find<NotificationsController>();
  Future<List<NotificationItem>>? _futureNotifications;

  @override
  void initState() {
    super.initState();
    // _futureNotifications = _controller.fetchNotifications();
    checkLoginStatus();
    checkLoginAndFetchNotifications();
  }

  void checkLoginAndFetchNotifications() async {

    if (await getAccessToken() != null) {
      setState(() {
        _controller.fetchUnreadCount();
        _futureNotifications = _controller.fetchNotifications();
      });

    }
  }


  /// Marks a notification as read and then refetches notifications
  Future<void> _onNotificationTap(NotificationItem notification) async {
    try {
      await _controller.markAsRead(notification.id);
      // Refetch notifications list to update the UI
      setState(() {
        _futureNotifications = _controller.fetchNotifications();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Clears all notifications and updates the UI
  Future<void> _clearNotifications() async {
    try {
      await _controller.clearNotifications();
      // Refetch notifications list after clearing
      setState(() {
        _futureNotifications = _controller.fetchNotifications();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications cleared')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing notifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Text('Clear All'),
            onPressed: _clearNotifications,
            tooltip: 'Clear Notifications',
          )
        ],
      ),
      body: FutureBuilder<List<NotificationItem>>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notifications available."));
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final bool isUnread = notification.readAt == null;

                DateTime? dateTime;
                try {
                  dateTime = DateTime.parse(notification.createdAt);
                } catch (_) {
                  dateTime = null;
                }

                String formattedDate = '';
                String formattedTime = '';
                if (dateTime != null) {
                  formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
                  formattedTime = DateFormat('hh:mm a').format(dateTime);
                }

                final Color cardColor = isUnread ? Colors.orangeAccent : Colors.white;
                final Color textColor = isUnread ? Colors.white : Colors.black;
                final Color subtitleColor = isUnread ? Colors.white70 : Colors.black87;
                final Color dateColor = isUnread ? Colors.white70 : Colors.grey;
                final Color iconColor = isUnread ? Colors.white : Colors.orangeAccent;

                return InkWell(
                  onTap: () => _onNotificationTap(notification),
                  child: Card(
                    color: cardColor,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notifications,
                            color: iconColor,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notification.content,
                                  style: TextStyle(color: subtitleColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: 12, color: dateColor),
                              ),
                              Text(
                                formattedTime,
                                style: TextStyle(fontSize: 12, color: dateColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

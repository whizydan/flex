import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/notification_row.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<Map<String, String>> notificationArr = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference notificationRef =
      FirebaseDatabase.instance.ref().child('notifications').child(user.uid);
      DataSnapshot snapshot = await notificationRef.get();

      if (snapshot.exists) {
        List<Map<String, String>> tempNotifications = [];
        for (var notification in snapshot.children) {
          Map<String, String> notificationMap = {
            "id": notification.key!, // Storing the notification ID
            "image": notification.child("image").value.toString(),
            "title": notification.child("title").value.toString(),
            "time": notification.child("time").value.toString(),
          };
          tempNotifications.add(notificationMap);
        }
        setState(() {
          notificationArr = tempNotifications;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNotification(String notificationId, int index) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference notificationRef = FirebaseDatabase.instance
          .ref()
          .child('notifications')
          .child(user.uid)
          .child(notificationId);
      await notificationRef.remove();

      // Remove the item from the list and update the UI
      setState(() {
        notificationArr.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Notification",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_all') {
                _deleteAllNotifications();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Text('Delete All Notifications'),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: TColor.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationArr.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/img/no_notification.png",
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 16),
            const Text(
              "No notifications available",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
          padding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          itemBuilder: ((context, index) {
            var nObj = notificationArr[index];
            return ListTile(
              leading: Image.asset(nObj['image']!),
              title: Text(nObj['title']!),
              subtitle: Text(nObj['time']!),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteNotification(nObj['id']!, index);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            );
          }),
          separatorBuilder: (context, index) {
            return Divider(
              color: TColor.gray.withOpacity(0.5),
              height: 1,
            );
          },
          itemCount: notificationArr.length),
    );
  }

  Future<void> _deleteAllNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference notificationsRef =
      FirebaseDatabase.instance.ref().child('notifications').child(user.uid);
      await notificationsRef.remove();

      setState(() {
        notificationArr.clear();
      });
    }
  }
}

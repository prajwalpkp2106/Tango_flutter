import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tango_flutter_project/bloc/notification_bloc/bloc/notification_bloc.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static int tinder_notification_count = 0;

  static final NotificationBloc notificationBloc = NotificationBloc();

  static Future<void> initialize() async {
    try {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("Notifications Initialized!");

        // Retrieve the FCM token
        String? token = await FirebaseMessaging.instance.getToken();
        print("FCM Token: $token");

        FirebaseMessaging.onBackgroundMessage(backgroundHandler);
        FirebaseMessaging.onMessage.listen(foregroundHandler);
      } else {
        print("User declined permission for notifications");
      }
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  static Future<void> backgroundHandler(RemoteMessage message) async {
    if (message.notification != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      int count = await prefs.getInt('count') ?? 0;
      count += 1;
      await prefs.setInt('count', count);
      print('notification count  in local storage: $count');
      print("Background message received! ${message.notification!.title}");
    }
  }

  static Future<void> foregroundHandler(RemoteMessage message) async {
    print("foreground message received! ${message.notification!.title}");
    NotificationService.tinder_notification_count++;
    updateunSeenNotifications();
    notificationBloc.add(NotificationCountEvent());
  }

  static void subscribeToUserTopic(String userId) {
    FirebaseMessaging.instance.subscribeToTopic(userId);
  }

  static void unsubscribeFromUserTopic(String userId) {
    FirebaseMessaging.instance.unsubscribeFromTopic(userId);
  }

  static Future<void> sendNotificationToUser(
      String userId, String notifytitle, String notifybody) async {
    // Send notification to the topic associated with the user
    final String serverKey =''; // Your Firebase Cloud Messaging server key

    final String url = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final payload = {
      'to': '/topics/$userId',
      'notification': {
        'title': notifytitle,
        'body': notifybody,
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
    }
  }

  static Future<void> updateunSeenNotifications() async {
    try {
      // Create a reference to the user's document
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('notifications')
          .doc(ActiveUser.currentuser.userId);

      // Update the 'seenNotifications' field with the provided count
      await userDocRef.update({
        'unseenNotifications': NotificationService.tinder_notification_count,
      });

      print('Seen notifications updated successfully');
    } catch (e) {
      print('Error updating seen notifications: $e');
      throw Exception('Error updating seen notifications');
    }
  }

  static Future<void> saveNotificationDataToFirestore(
      String userId, String? imageUrl, String name, String type) async {
    try {
      // Create a reference to the user's document
      CollectionReference notificationsCollection =
          FirebaseFirestore.instance.collection('notifications');

      // Reference to the specific document for the user ID
      DocumentReference userNotificationDocRef =
          notificationsCollection.doc(userId);

      // Update the document with the new data

      // Get the current timestamp in milliseconds since epoch
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create a map representing the notification data
      Map<String, dynamic> notificationData = {
        'imageUrl': imageUrl,
        'name': name,
        'userId': ActiveUser.currentuser.userId,
        'type': type,
      };

      // Check if the document already exists
      DocumentSnapshot userDocSnapshot = await userNotificationDocRef.get();
      if (!userDocSnapshot.exists) {
        // Document doesn't exist, create it with an empty 'notifications' field
        await userNotificationDocRef.set({'notifications': {}});
      }

      // Add the notification data under the 'notifications' field
      await userNotificationDocRef.update(
        {
          'notifications.$timestamp': notificationData,
        },
      );

      //notification saved successfully , now will send the notification to the user .
      if (type == 'liked') {
        await sendNotificationToUser(
            userId, 'Hey! Someone liked your profile', 'Click here to view');
      } else {
        await sendNotificationToUser(
            userId, 'Hey! You are matched with someone', 'Click here to view');
      }

      print('Notification data saved successfully');
    } catch (e) {
      print('Error saving notification data: $e');
      throw Exception('Error saving notification data');
    }
  }

  static Future<void> processNotifications() async {
    try {
      String userId = ActiveUser.currentuser.userId!;
      // Reference to the notifications collection
      CollectionReference notificationsRef =
          FirebaseFirestore.instance.collection('notifications');

      // Reference to the document with the user ID in the notifications collection
      DocumentReference userNotificationDocRef = notificationsRef.doc(userId);

      // Fetch the document snapshot
      DocumentSnapshot documentSnapshot = await userNotificationDocRef.get();

      if (documentSnapshot.exists) {
        // Document exists, convert data to a map
        Map<String, dynamic> notificationData =
            documentSnapshot.data() as Map<String, dynamic>;
        NotificationService.tinder_notification_count =
            notificationData['unseenNotifications'] ?? 0;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        NotificationService.tinder_notification_count +=
            prefs.getInt('count') ?? 0;
        await prefs.clear();
        await prefs.reload();
        print('The local storage count is : ${prefs.getInt('count') ?? 0}');
        await NotificationService.updateunSeenNotifications();
        print(
            "unseen notifications are : ${NotificationService.tinder_notification_count} ");

        // TODO: Implement your logic here to handle the fetched user notifications data
      } else {
        // Document does not exist
        print('notification Document does not exist');
        // TODO: Handle case when document does not exist
      }
    } catch (e) {
      print('Error fetching user notifications: $e');
      // TODO: Handle error case
    }
  }

//Deleting the entry when rejected the notification
  static Future<void> deleteNotificationEntry(String timestamp) async {
    try {
      String userId = ActiveUser.currentuser.userId!;

      // Reference to the notifications collection
      CollectionReference notificationsRef =
          FirebaseFirestore.instance.collection('notifications');

      // Reference to the document with the user ID in the notifications collection
      DocumentReference userNotificationDocRef = notificationsRef.doc(userId);

      // Update the document in Firestore to remove the entry with the given timestamp
      await userNotificationDocRef
          .update({'notifications.$timestamp': FieldValue.delete()});

      print(
          'Notification entry with timestamp $timestamp deleted successfully');
    } catch (e) {
      // Error occurred while deleting notification entry
      print('Error deleting notification entry: $e');
      throw e;
    }
  }

//updating matched fields
  static Future<void> updateMatchField(String userId1, String userId2) async {
    try {
      // Update match field for user 1
      await FirebaseFirestore.instance.collection('users').doc(userId1).update({
        'Matched': FieldValue.arrayUnion([userId2])
      });

      // Update match field for user 2
      await FirebaseFirestore.instance.collection('users').doc(userId2).update({
        'Matched': FieldValue.arrayUnion([userId1])
      });

      print('Match fields updated successfully');
    } catch (e) {
      print('Error updating match fields: $e');
      throw e;
    }
  }

  static Future<void> updateNotificationType(String timestamp) async {
    try {
      String userId = ActiveUser.currentuser.userId!;
      // Reference to the notifications collection
      CollectionReference notificationsRef =
          FirebaseFirestore.instance.collection('notifications');

      // Reference to the document with the user ID in the notifications collection
      DocumentReference userNotificationDocRef = notificationsRef.doc(userId);

      // Update the type of the entry directly using the timestamp
      await userNotificationDocRef
          .update({'notifications.$timestamp.type': 'matched'});

      print('Notification type updated successfully.');
    } catch (e) {
      print('Error updating notification type: $e');
    }
  }
}

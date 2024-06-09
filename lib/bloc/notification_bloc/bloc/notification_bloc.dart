import 'dart:async';
import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/services/notification_services.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<NotificationCountEvent>(_notificationcount);
    on<NotificationfetchEvent>(_notificationfetch);
  }
  FutureOr<void> _notificationcount(NotificationCountEvent event, Emitter<NotificationState> emit) {
    emit(NotificationCountState());
    print("In notification count event of notitication bloc ");
  }

   Future<void> _notificationfetch(NotificationfetchEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoadingState());
    print("In notification fetch event of notification bloc ");

    try {
      // Fetch notifications data from the database
      List<dynamic> notifications = await fetchNotifications();
      notifications=notifications.reversed.toList();

      // Emit the fetched notifications
      emit(NotificationFetchedState(notifications: notifications));
    } catch (e) {
      // Emit an error state if fetching failed
      emit(NotificationErrorState(error: e.toString()));
    }
  }

  Future<List<dynamic>> fetchNotifications() async {
  try {
    String userId=ActiveUser.currentuser.userId!;
    // Reference to the notifications collection
    CollectionReference notificationsRef = FirebaseFirestore.instance.collection('notifications');

    // Reference to the document with the user ID in the notifications collection
    DocumentReference userNotificationDocRef = notificationsRef.doc(userId);

    // Fetch the document snapshot
    DocumentSnapshot documentSnapshot = await userNotificationDocRef.get();

    if (documentSnapshot.exists) {
      // Document exists, extract the notifications field
      Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
      dynamic notifications = userData['notifications'];

      if (notifications != null) {
        // Extract notification entries from the notifications map
        List<dynamic> notificationEntries = notifications.entries.map((entry) {
          return {'timestamp': entry.key, ...entry.value};
        }).toList();

        return notificationEntries;
      } else {
        // No notifications found, return an empty list
        return [];
      }
    } else {
      // Document does not exist
      print('Document does not exist for user $userId');
      return [];
    }
  } catch (e) {
    // Error occurred while fetching notifications
    print('Error fetching notifications for user : $e');
    throw e;
  }
}
}

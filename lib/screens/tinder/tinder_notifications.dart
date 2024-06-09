import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tango_flutter_project/bloc/notification_bloc/bloc/notification_bloc.dart';
import '../../widgets/tinder/notification.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(NotificationfetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoadingState) {
            // Show loading indicator while fetching notifications
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is NotificationFetchedState) {
            // Use ListView.builder to display notifications
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                String name = notification['name'];
                name=name[0].toUpperCase() + name.substring(1);
                bool isRequest = notification['type']=='liked'?true:false;
                String profilePicUrl = notification['imageUrl'];
                String displaytext = isRequest
                    ? " $name has liked your Profile"
                    : "You have got a Match with $name!";
                String subtitle = isRequest
                    ? "Click here to see the profile"
                    : "Click here to chat";
                String userId=notification['userId'];
                String timestamp=notification['timestamp'];
                return CustomNotification(
                  profilePicUrl: profilePicUrl,
                  name: name,
                  isRequest: isRequest,
                  displaytext: displaytext,
                  subtitle: subtitle,
                  userId : userId,
                  timestamp : timestamp,
                );
              },
            );
          } else {
            // Handle other states if necessary
            return Container();
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tango_flutter_project/bloc/chatroombloc/bloc/chatroom_bloc.dart';
import 'package:tango_flutter_project/screens/tinder/chatroompage.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/services/notification_services.dart';

class CustomNotification extends StatefulWidget {
  final String profilePicUrl;
  String name;
  bool isRequest;
  String displaytext;
  String subtitle;
  String userId;
  String timestamp;

  CustomNotification({
    required this.profilePicUrl,
    required this.name,
    required this.isRequest,
    required this.displaytext,
    required this.subtitle,
    required this.userId,
    required this.timestamp,
  });

  @override
  State<CustomNotification> createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification> {
  String status = 'allowed';
  @override
  Widget build(BuildContext context) {
    String username = widget.name;
    return status == 'allowed'
        ? BlocConsumer<ChatroomBloc, ChatroomState>(
            listener: (context, state) {
              if (state is GetChatroomModelState) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomPage(
                      profilePicUrl: widget.profilePicUrl,
                      name: widget.name,
                      userId: widget.userId,
                      chatroom: state.chatroom,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Container(
                margin:
                    EdgeInsets.symmetric(vertical: 4), // Add vertical margin

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(widget.profilePicUrl),
                    radius: 30, // Set the radius as needed
                  ),
                  title: Text(
                    widget.displaytext,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: Text(widget.subtitle,
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                  trailing: widget.isRequest
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.fromLTRB(2, 0, 3, 0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pink,
                              ),
                              padding: EdgeInsets.all(
                                  8), // Adjust the padding as needed
                              child: IconButton(
                                icon: const Icon(Icons.favorite,
                                    size: 20,
                                    color: Colors
                                        .white), // Change icon color if needed
                                onPressed: () {
                                  //updating the match field for both users
                                  NotificationService.updateMatchField(
                                      ActiveUser.currentuser.userId!,
                                      widget.userId);

                                  //updating the notification type
                                  NotificationService.updateNotificationType(
                                      widget.timestamp);

                                  //sending the notification to user that sent liked
                                  String userid = widget.userId;
                                  String? imageurl =
                                      ActiveUser.currentuser.images![0];
                                  String name = ActiveUser.currentuser.name!;
                                  String type = 'matched';
                                  NotificationService
                                      .saveNotificationDataToFirestore(
                                          userid, imageurl, name, type);

                                  setState(() {
                                    widget.displaytext =
                                        "You have got a Match with $username!";
                                    widget.subtitle = "Click here to chat";
                                    widget.isRequest = false;
                                  });
                                },
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                ),
                                onPressed: () {
                                  //calling the delete entry
                                  NotificationService.deleteNotificationEntry(
                                      widget.timestamp);
                                  setState(() {
                                    status = 'rejected';
                                  });
                                },
                              ),
                            )
                          ],
                        )
                      : null,
                  onTap: () {
                    if (!widget.isRequest) {
                      // Handle chat click
                      context
                          .read<ChatroomBloc>()
                          .add(ChatRoomModelEvent(targetuserId: widget.userId));
                    } else {
                      // Handle profile click
                    }
                  },
                ),
              );
            },
          )
        : Padding(padding: EdgeInsets.zero);
  }
}

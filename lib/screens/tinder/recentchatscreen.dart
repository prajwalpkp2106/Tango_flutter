import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tango_flutter_project/models/FirebaseHelper.dart';
import 'package:tango_flutter_project/models/chat_model.dart';
import 'package:tango_flutter_project/screens/tinder/chatroompage.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/models/userprofile.dart'; // Importing the User class

class RecentChatPage extends StatefulWidget {
  const RecentChatPage({Key? key}) : super(key: key);

  @override
  _RecentChatPageState createState() => _RecentChatPageState();
}

class _RecentChatPageState extends State<RecentChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Recent Chat",
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("users", arrayContains: ActiveUser.currentuser.userId)
                .orderBy("createdon",descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Text("No Chats"),
                );
              } else {
                QuerySnapshot chatRoomSnapshot =
                    snapshot.data as QuerySnapshot;

                // Reverse the list of chatroom snapshots
                List<DocumentSnapshot> reversedChatrooms =
                    chatRoomSnapshot.docs.reversed.toList();

                return ListView.builder(
                  itemCount: reversedChatrooms.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        reversedChatrooms[index].data()
                            as Map<String, dynamic>);

                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;

                    // Get the ID of the other participant in the chat
                    String otherParticipantId = participants.keys.firstWhere(
                        (key) => key != ActiveUser.currentuser.userId);

                    return FutureBuilder(
                      future: FirebaseHelper.getUserModelById(otherParticipantId),
                      builder: (context, userData) {
                        if (userData.connectionState ==
                            ConnectionState.done) {
                          if (userData.data != null) {
                            User targetUser = userData.data as User;

                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return ChatRoomPage(
                                      profilePicUrl: targetUser.images![0],
                                      name: targetUser.name!,
                                      userId: targetUser.userId!,
                                      chatroom: chatRoomModel,
                                    );
                                  }),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(targetUser.images![0]),
                                radius: 30,
                              ),
                              title: Text(
                                targetUser.name!,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              subtitle: (chatRoomModel.lastMessage
                                          .toString() !=
                                      "")
                                  ? Text(chatRoomModel.lastMessage.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11))
                                  : Text(
                                      "Say hi to your new friend!",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 11),
                                    ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

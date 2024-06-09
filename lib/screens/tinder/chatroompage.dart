import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tango_flutter_project/main.dart';
import 'package:tango_flutter_project/models/chat_model.dart';
import 'package:tango_flutter_project/models/message_model.dart';
import 'package:tango_flutter_project/services/getuser.dart';

class ChatRoomPage extends StatefulWidget {
  final String profilePicUrl;
  final String name;
  final String userId;
  final ChatRoomModel chatroom;

  ChatRoomPage({
    required this.profilePicUrl,
    required this.name,
    required this.userId,
    required this.chatroom,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg.isNotEmpty) {
      // Send Message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: ActiveUser.currentuser.userId,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  void updateSeenStatus(QuerySnapshot snapshot) async {
    for (var doc in snapshot.docs) {
      var messageData = doc.data() as Map<String, dynamic>;
      if (messageData['sender'] != ActiveUser.currentuser.userId && !(messageData['seen'] ?? true)) {
        doc.reference.update({'seen': true});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .snapshots()
          .listen((snapshot) {
        updateSeenStatus(snapshot);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(widget.profilePicUrl.isNotEmpty ? widget.profilePicUrl : "https://via.placeholder.com/150"),
            ),
            SizedBox(width: 10),
            Text(
              widget.name.isNotEmpty ? widget.name : "Unknown",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0xFF212121), // Custom dark background color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Color(0xFF212121), // Custom dark background color
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;
                        updateSeenStatus(dataSnapshot); // Update seen status immediately

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage =
                                MessageModel.fromMap(dataSnapshot.docs[index]
                                    .data() as Map<String, dynamic>);

                            return Row(
                              mainAxisAlignment:
                                  (currentMessage.sender ==
                                          ActiveUser.currentuser.userId)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (currentMessage.sender ==
                                            ActiveUser.currentuser.userId)
                                        ? Color(0xFF00ADB5) // Custom user color
                                        : Color(0xFF424242), // Custom receiver color
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                       currentMessage.text ?? '',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      if (currentMessage.sender ==
                                          ActiveUser.currentuser.userId) ...[
                                        SizedBox(width: 5),
                                        Icon(
                                          (currentMessage.seen ?? false)
                                              ? Icons.check_circle
                                              : Icons.check_circle_outline,
                                          color: (currentMessage.seen ?? false)
                                              ? Colors.blue
                                              : Colors.grey,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "An error occurred! Please check your internet connection.",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            "Say hi to your new friend",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              color: Color(0xFF212121), // Custom dark background color
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: Colors.grey[400]), // Lighter hint color
                        filled: true,
                        fillColor: Color(0xFF424242), // Custom text field color
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Material(
                    color: Color(0xFF00ADB5), // Custom send button color
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: sendMessage,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

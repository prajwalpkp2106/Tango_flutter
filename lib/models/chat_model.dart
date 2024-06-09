import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<String> users;
  DateTime? createdon;

  ChatRoomModel({
    this.chatroomid,
    this.participants,
    this.lastMessage,
    required this.users,
    this.createdon,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map)
      : users = List<String>.from(map["users"] ?? []) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    createdon = (map["createdon"] != null)
        ? (map["createdon"] as Timestamp).toDate()
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastMessage,
      "users": users,
      "createdon": createdon,
    };
  }
}

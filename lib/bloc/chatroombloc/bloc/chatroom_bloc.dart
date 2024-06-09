import 'dart:async';
import 'package:tango_flutter_project/main.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:tango_flutter_project/models/chat_model.dart';
import 'package:tango_flutter_project/services/getuser.dart';

part 'chatroom_event.dart';
part 'chatroom_state.dart';

class ChatroomBloc extends Bloc<ChatroomEvent, ChatroomState> {
  ChatroomBloc() : super(ChatroomInitial()) {
    on<ChatRoomModelEvent>(getchatRoomModelEvent);
  }

  Future<FutureOr<void>> getchatRoomModelEvent(
      ChatRoomModelEvent event, Emitter<ChatroomState> emit) async {
  
    emit(ChatroomloadingState());
     
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${ActiveUser.currentuser.userId}", isEqualTo: true)
        .where("participants.${event.targetuserId}", isEqualTo: true)
        .get();
    
    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      emit(GetChatroomModelState(chatroom: existingChatroom));
      print("chatRoom already exits");
    } else {
      ChatRoomModel newChatroom =
          ChatRoomModel(chatroomid: uuid.v1(), lastMessage: "", participants: {
        ActiveUser.currentuser.userId.toString(): true,
        event.targetuserId.toString(): true,
      },
      users:[ActiveUser.currentuser.userId.toString(), event.targetuserId.toString()],
      createdon: DateTime.now()

      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      emit(GetChatroomModelState(chatroom: newChatroom));
      print("new chatroom created");
    }
  }
}

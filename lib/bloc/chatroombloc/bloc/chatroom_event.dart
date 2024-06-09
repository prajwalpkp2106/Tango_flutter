part of 'chatroom_bloc.dart';

@immutable
sealed class ChatroomEvent {}

class ChatRoomModelEvent extends ChatroomEvent {
  final String targetuserId;

  ChatRoomModelEvent({required this.targetuserId});
}

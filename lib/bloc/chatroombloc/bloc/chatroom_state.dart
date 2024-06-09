part of 'chatroom_bloc.dart';

@immutable
sealed class ChatroomState {}

class ChatroomInitial extends ChatroomState {}

class ChatroomloadingState extends ChatroomState {}

class GetChatroomModelState extends ChatroomState {
  final ChatRoomModel chatroom;

  GetChatroomModelState({required this.chatroom});
}

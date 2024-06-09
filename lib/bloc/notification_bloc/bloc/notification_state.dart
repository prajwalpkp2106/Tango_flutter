part of 'notification_bloc.dart';

@immutable
sealed class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationCountState extends NotificationState{}

class NotificationFetchedState extends NotificationState {
  final List<dynamic> notifications;
  NotificationFetchedState({required this.notifications});
}
class  NotificationLoadingState extends NotificationState {}

class NotificationErrorState extends NotificationState
{
    final  String error;
    NotificationErrorState({required this.error});
}


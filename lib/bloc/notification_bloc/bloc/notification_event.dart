part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}

class NotificationCountEvent extends NotificationEvent{}
 
class NotificationfetchEvent extends NotificationEvent{}
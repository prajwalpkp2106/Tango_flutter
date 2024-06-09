part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class UserfetchEvent extends HomeEvent {
  final String? lastuserid;
  final String city;
  final String gender;
  final DocumentSnapshot? lastDocument;
  UserfetchEvent(
      {required this.lastuserid,
      required this.city,
      required this.gender,
      required this.lastDocument});
}

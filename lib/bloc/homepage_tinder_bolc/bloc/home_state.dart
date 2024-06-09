part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeEmptyUserState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<User>? users;
  final DocumentSnapshot? lastDocument;

  HomeLoadedState({required this.users, this.lastDocument});
}

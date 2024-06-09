part of 'userbloc_bloc.dart';

@immutable
class UserEvent {}

class SaveUserEvent extends UserEvent {
  final TextEditingController nameController;
  final TextEditingController userIdController;

  SaveUserEvent({
    required this.nameController,
    required this.userIdController,
  });
}

class UserInformationEvent extends UserEvent {
  final TextEditingController birthdayController;
  final TextEditingController descriptionController;
  final TextEditingController genderController;
  final TextEditingController cityController;
  final List<String> interests;
  final User? user;
  final String? userId;

  UserInformationEvent({
    required this.birthdayController,
    required this.descriptionController,
    required this.genderController,
    required this.cityController,
    required this.interests,
    required this.user,
    required this.userId,
  });
}

class UpdateUserImages extends UserEvent {
  final String userId;
  final XFile image;

  UpdateUserImages({
    required this.userId,
    required this.image,
  });
}

class SaveAllUserDataEvent extends UserEvent {}

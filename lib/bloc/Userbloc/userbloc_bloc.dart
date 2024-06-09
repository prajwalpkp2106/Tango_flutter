import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:tango_flutter_project/services/getuser.dart';

part 'userbloc_event.dart';
part 'userbloc_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<SaveUserEvent>(saveUserEvent);
    on<UserInformationEvent>(userInformationEvent);
    on<SaveAllUserDataEvent>(saveAllUserDataEvent);
  }
  bool isValidUserId(String userId) {
    // Regular expression to match a valid user ID
    // Assuming a valid user ID is alphanumeric and may contain underscores
    RegExp regex = RegExp(r'^[a-zA-Z0-9_]+$');
    return regex.hasMatch(userId);
  }

  Future<FutureOr<void>> saveUserEvent(
      SaveUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());

    try {
      String name = event.nameController.text.trim();
      String userId = event.userIdController.text.trim();
      if (name.isNotEmpty && userId.isNotEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("userId", isEqualTo: userId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          //  showSnackBar('User ID already in use', context);
          emit(UserExistsState());
        } else {
          if (isValidUserId(userId)) {
            ActiveUser.currentuser.name = name;
            ActiveUser.currentuser.userId = userId;
            emit(UserSavedState());
          } else {
            emit(UserInvalidIDState());
          }
          // showSnackBar("User data saved successfully",context);
        }
      } else {
        emit(UserEmptyState());
        //  showSnackBar("Please fill all the details",context);
      }
    } catch (e) {
      emit(UserErrorState('Error saving user: $e'));
    }
  }

  void userInformationEvent(
      UserInformationEvent event, Emitter<UserState> emit) {
    emit(UserLoadingState());
    String gender = event.genderController.text.trim();
    String city = event.cityController.text.trim();
    String birthday = event.birthdayController.text.trim();
    String description = event.descriptionController.text.trim();
    List<String> interests =
        event.interests.map((interest) => interest.trim()).toList();

    // Check if any of the details are empty
    if (gender.isEmpty ||
        city.isEmpty ||
        birthday.isEmpty ||
        description.isEmpty ||
        interests.isEmpty) {
      emit(UserEmptyState());
    } else {
      ActiveUser.currentuser.gender = gender;
      ActiveUser.currentuser.city = city;
      ActiveUser.currentuser.birthday = birthday;
      ActiveUser.currentuser.description = description;
      ActiveUser.currentuser.interests = interests;
      print('Current User Data:');
      print(
          'Login Value: ${ActiveUser.currentuser.loginValue ?? 'Not provided'}');
      print('Name: ${ActiveUser.currentuser.name ?? 'Not provided'}');
      print('User ID: ${ActiveUser.currentuser.userId ?? 'Not provided'}');
      print('Gender: ${ActiveUser.currentuser.gender ?? 'Not provided'}');
      print('City: ${ActiveUser.currentuser.city ?? 'Not provided'}');
      print('Birthday: ${ActiveUser.currentuser.birthday ?? 'Not provided'}');
      print(
          'Description: ${ActiveUser.currentuser.description ?? 'Not provided'}');
      print(
          'Interests: ${ActiveUser.currentuser.interests?.join(', ') ?? 'Not provided'}');

      emit(UserInformationSaveState());
    }

    // Update the static currentuser variable
  }

  FutureOr<void> saveAllUserDataEvent(
      SaveAllUserDataEvent event, Emitter<UserState> emit) async {
    emit(UserAllLoadingState());
    await ActiveUser.uploadImagesToFirebaseStorage();
    emit(SaveAlluserDataState());
  }
}

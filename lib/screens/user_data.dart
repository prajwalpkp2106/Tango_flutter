// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tango_flutter_project/bloc/Userbloc/userbloc_bloc.dart';
import 'package:tango_flutter_project/screens/information_user.dart';
import 'package:tango_flutter_project/screens/user_display.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/widgets/snackbar.dart';

class UserData extends StatefulWidget {
  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.2,
                ),
                Image.asset(
                  "assets/images/logo1.png",
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.17,
                ),
                SizedBox(
                  height: screenHeight * 0.1,
                ),
                Container(
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.w400),
                      contentPadding: EdgeInsets.all(screenHeight * 0.02),
                      border: InputBorder.none,
                      hintText: 'Enter your Name',
                    ),
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Container(
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: TextField(
                    controller: userIdController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: EdgeInsets.all(screenHeight * 0.02),
                      border: InputBorder.none,
                      hintText: 'User Id',
                    ),
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Container(
                  width: screenWidth * 0.8, // Set width of the input field
                  height: screenHeight * 0.075,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30, width: 1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: BlocConsumer<UserBloc, UserState>(
                    listener: (context, state) {
                      if (state is UserSavedState) {
                        showSnackBar("User Saved Successfully ", context);

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationPage(),
                            ));
                      } else if (state is UserExistsState) {
                        showSnackBar("User ID already in use", context);
                      } else if (state is UserInvalidIDState) {
                        showSnackBar(
                            "Please enter a user ID containing only alphanumeric characters and underscores",
                            context);
                      } else if (state is UserEmptyState) {
                        showSnackBar("Please fill all the details", context);
                      }
                    },
                    builder: (context, state) {
                      if (state is UserLoadingState) {
                        return Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                          backgroundColor: Colors.black,
                        );
                      } else {
                        return ElevatedButton(
                          onPressed: () {
                            String? loginValue =
                                ActiveUser.currentuser.loginValue;
                            context.read<UserBloc>().add(
                                  SaveUserEvent(
                                    nameController: nameController,
                                    userIdController: userIdController,
                                  ),
                                );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.031,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

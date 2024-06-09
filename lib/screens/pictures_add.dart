import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tango_flutter_project/bloc/Userbloc/userbloc_bloc.dart';
import 'package:tango_flutter_project/screens/tinder/TinderHomepage.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/services/notification_services.dart';
import 'package:tango_flutter_project/widgets/Add_image_custom.dart';

class Pictures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoadingState) {
          return Center(child: CircularProgressIndicator());
        } else {
          // Handle default case
          return Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              children: [
                SizedBox(height: screenHeight * 0.10),
                Text(
                  'Add Your Pictures',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: SizedBox(
                    height: screenHeight * 0.68,
                    width: screenWidth,
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int index) {
                        return CustomImageContainer();
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.075,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30, width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: BlocConsumer<UserBloc, UserState>(
                      listener: (context, state) {
                        if (state is SaveAlluserDataState) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => TinderHomepage(),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is UserAllLoadingState) {
                          return Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                            backgroundColor: Colors.black,
                          );
                        }
                        return ElevatedButton(
                          onPressed: () async {
                            //subsribing to topic for notification
                            NotificationService.subscribeToUserTopic(
                                ActiveUser.currentuser.userId!);
                            context
                                .read<UserBloc>()
                                .add(SaveAllUserDataEvent());
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            side: MaterialStateProperty.all<BorderSide>(
                              BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.031,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

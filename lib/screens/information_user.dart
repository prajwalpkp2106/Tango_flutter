import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';
import 'package:tango_flutter_project/bloc/Userbloc/userbloc_bloc.dart';
import 'package:tango_flutter_project/screens/pictures_add.dart';
import 'package:tango_flutter_project/screens/tinder/TinderHomepage.dart';
import 'package:tango_flutter_project/widgets/snackbar.dart';

class RegistrationPage extends StatefulWidget {
  final User? user;
  final String? userId;

  const RegistrationPage({Key? key, this.user, this.userId}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  List<String> interests = [];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Tell us about yourself',
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Gender selection
            Text(
              'Gender :',
              style:
                  TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      genderController.text = "Male";
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: genderController.text == "Male"
                        ? Colors.deepPurple
                        : Colors.grey.shade200,
                    fixedSize: const Size(50, 50),
                  ),
                  icon: Icon(
                    Ionicons.male,
                    color: genderController.text == "Male"
                        ? Colors.white
                        : Colors.black,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    setState(() {
                      genderController.text = "Female";
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: genderController.text == "Female"
                        ? Colors.deepPurple
                        : Colors.grey.shade200,
                    fixedSize: const Size(50, 50),
                  ),
                  icon: Icon(
                    Ionicons.female,
                    color: genderController.text == "Female"
                        ? Colors.white
                        : Colors.black,
                    size: 18,
                  ),
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            // City input
            Container(
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: TextField(
                controller: cityController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: EdgeInsets.all(screenHeight * 0.02),
                  border: InputBorder.none,
                  hintText: 'Enter your City',
                ),
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  color: Colors.white,
                ),
              ),
            ), // City input
            SizedBox(height: screenHeight * 0.03),
            Container(
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: TextField(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      birthdayController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                readOnly: true,
                controller: birthdayController,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: EdgeInsets.all(screenHeight * 0.02),
                  border: InputBorder.none,
                  hintText: 'Enter your Birthday Date',
                  prefixIcon: Icon(Icons.calendar_today_rounded,
                      color: Colors.white), // Add prefix icon
                ),
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),
            // Description input
            Text(
              'Describe Yourself :',
              style:
                  TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
            ),
            SizedBox(height: 10),
            Container(
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: TextField(
                controller: descriptionController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Enter your description',
                  hintStyle: TextStyle(color: Colors.white38),
                  contentPadding: EdgeInsets.all(screenHeight * 0.02),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.transparent), // Set color to transparent
                  ),
                ),
                style: TextStyle(color: Colors.white),
                maxLines: 3,
              ),
            ),

            SizedBox(height: screenHeight * 0.03),
            // Interests selection
            Text(
              'Interests :',
              style:
                  TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
            ),

            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: List.generate(
                interests.length,
                (index) => Chip(
                  label: Text(interests[index],
                      style: TextStyle(color: Colors.black)),
                  onDeleted: () {
                    setState(() {
                      interests.removeAt(index);
                    });
                  },
                ),
              ).toList(),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: interestController,
                    decoration: InputDecoration(
                      hintText: 'Add interest',
                      hintStyle: TextStyle(color: Colors.white38),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      if (interestController.text.isNotEmpty) {
                        interests.add(interestController.text);
                        interestController.clear();
                      } else {
                        showSnackBar("Enter a Interest", context);
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.075,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30, width: 1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: BlocConsumer<UserBloc, UserState>(
                listener: (context, state) {
                  if (state is UserInformationSaveState) {
                    showSnackBar("Information Saved successfully", context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Pictures()),
                    );
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
                      onPressed: () async {
                        context.read<UserBloc>().add(UserInformationEvent(
                              interests: interests,
                              user: widget.user,
                              userId: widget.userId,
                              birthdayController: birthdayController,
                              descriptionController: descriptionController,
                              genderController: genderController,
                              cityController: cityController,
                            ));
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
    );
  }
}

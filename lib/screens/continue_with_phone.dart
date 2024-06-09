import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_cubit.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_state.dart';
import 'package:tango_flutter_project/screens/otp.dart';
import 'package:tango_flutter_project/widgets/snackbar.dart';

class ContinueWithPhone extends StatefulWidget {
  const ContinueWithPhone({Key? key}) : super(key: key);

  @override
  State<ContinueWithPhone> createState() => _ContinueWithPhoneState();
}

class _ContinueWithPhoneState extends State<ContinueWithPhone> {
  String _selectedCode = '+91';
  TextEditingController phoneController = TextEditingController();
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: screenHeight * 0.1,
              ),
              Text(
                'Continue With Phone',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.005,
              ),
              Text(
                "We'll send a verification code on this number",
                style: TextStyle(
                    color: Colors.white, fontSize: screenHeight * 0.025),
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              Stack(
                children: [
                  Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.080,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.05,
                    top: screenHeight * 0.015,
                    child: CircleAvatar(
                      radius: screenWidth * 0.0375,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          const AssetImage('assets/images/Indian_flag.png'),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.155,
                    top: screenHeight * 0.004,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCode,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCode = newValue!;
                          });
                        },
                        dropdownColor: Colors.black,
                        items: <String>[
                          '+91',
                          '+92',
                          '+93'
                        ] // Add more Indian number codes as needed
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenHeight * 0.030),
                            ),
                          );
                        }).toList(),
                        underline: null,
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.31,
                    child: SizedBox(
                      width: screenWidth *
                          0.6, // Adjust width to fit the available space
                      child: TextField(
                        controller: phoneController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]')), // Allow only digits
                        ],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(screenHeight * 0.01),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.030,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Container(
                width: screenWidth * 0.9, // Set width of the input field
                height: screenHeight * 0.075,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30, width: 1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthCodeSentState) {
                      String phone = "+91" + phoneController.text.trim();
                      ;
                      print('In continue with phone  : phonenumber: $phone');
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyOtp(phone: phone),
                        ),
                      );
                    } else if (state is AuthSendErrorState) {
                      setState(() {
                        _isloading = false;
                      });
                      showSnackBar(state.error, context);
                      //  showSnackBar("Verification is unsuccessful", context);
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: () {
                        String phone = "+91" + phoneController.text.trim();
                        BlocProvider.of<AuthCubit>(context).sendOTP(phone);
                        setState(() {
                          _isloading = true;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      child: _isloading
                          ? CircularProgressIndicator()
                          : Text(
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
              SizedBox(
                height: screenHeight * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_cubit.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_state.dart';
import 'package:tango_flutter_project/screens/signup_page.dart';
import 'package:tango_flutter_project/screens/tinder/TinderHomepage.dart';
import 'package:tango_flutter_project/screens/user_data.dart';
import 'package:tango_flutter_project/screens/user_display.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/services/notification_services.dart';
import 'package:tango_flutter_project/widgets/snackbar.dart';

class MyOtp extends StatefulWidget {
  final String phone;

  const MyOtp({
    Key? key,
    required this.phone,
  }) : super(key: key);

  @override
  _MyOtpState createState() => _MyOtpState();
}

class _MyOtpState extends State<MyOtp> {
  late TextEditingController otpController;
  late Timer _timer;
  int _start = 30;
  bool _isResend = false;
  bool _isloading = false;
  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Pinput(
                controller: otpController,
                length: 6,
                defaultPinTheme: PinTheme(
                  width: screenWidth * 0.12,
                  height: screenHeight * 0.08,
                  textStyle: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(234, 239, 243, 1)),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: screenWidth * 0.12,
                  height: screenHeight * 0.08,
                  textStyle: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(114, 178, 238, 1)),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: screenWidth * 0.12,
                  height: screenHeight * 0.08,
                  textStyle: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(234, 239, 243, 1)),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
                showCursor: true,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: screenHeight * 0.03),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) async {
                  if (state is AuthUserPhoneNewState) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => UserData()));
                  } else if (state is AuthUserPhoneLoggedInState) {
                    //subsribing to topic for notification
                    NotificationService.subscribeToUserTopic(state.userId);
                    print("In otp file auth logged in state ");
                    await ActiveUser.getUserData(state.userId);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TinderHomepage()));
                  } else if (state is AuthVerifyErrorState) {
                    setState(() {
                      _isloading = false;
                    });
                    showSnackBar("${state.error}", context);
                    //  showSnackBar("Verification is unsuccessful", context);
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                      onPressed: () {
                        print('phonenumber:$widget.phone');
                        BlocProvider.of<AuthCubit>(context)
                            .verifyOTP(otpController.text, widget.phone);
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
                              'Verify Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.031,
                              ),
                            ));
                },
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_isResend) {
                        BlocProvider.of<AuthCubit>(context)
                            .sendOTP(widget.phone);
                        setState(() {
                          _isResend = false;
                          _start = 30;
                          startTimer();
                        });
                      } else {
                        showSnackBar(
                            "Please Wait for $_start seconds ", context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                        bottom: 1,
                        top: 2,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Text(
                        "Resend Code",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                          decoration: TextDecoration.underline,
                          color:
                              _isResend ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _isResend ? ' ' : ': in $_start seconds',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer.cancel();
          _isResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

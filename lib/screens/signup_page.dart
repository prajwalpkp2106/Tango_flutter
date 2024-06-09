import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_cubit.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_state.dart';
import 'package:tango_flutter_project/screens/continue_with_phone.dart';
import 'package:tango_flutter_project/screens/tinder/TinderHomepage.dart';
import 'package:tango_flutter_project/screens/user_data.dart';
import 'package:tango_flutter_project/screens/user_display.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/services/notification_services.dart';
import 'package:tango_flutter_project/widgets/snackbar.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "By logging in, you confirm you're over 18 years old and agree to our Terms of Use and Privacy Policy",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.2,
            height: screenHeight * 0.2,
          ),
          Image.asset(
            "assets/images/logo1.png",
            width: screenWidth * 0.2,
            height: screenHeight * 0.14,
          ),
          Text(
            "tango",
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.1,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.only(top: screenHeight * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  child: Text(
                    'Login Or SignUp',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenWidth * 0.05,
                  ),
                  child: Text(
                    'Join a world-wide live-streaming community',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
            ),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) async {
                if (state is AuthUserEmailNewState) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  //  print("${state.firebaseUser.email}");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserData(),
                    ),
                  );
                } else if (state is AuthUserEmailLoggedInState) {
                  //subsribing to user for the notification
                  NotificationService.subscribeToUserTopic(state.userId);
                  Navigator.popUntil(context, (route) => route.isFirst);
                  await ActiveUser.getUserData(state.userId);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TinderHomepage(),
                    ),
                  );
                } else if (state is AuthEmailErrorState) {
                  showSnackBar(state.error, context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return ElevatedButton.icon(
                  onPressed: () {
                    BlocProvider.of<AuthCubit>(context).signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.maxFinite, screenHeight * 0.06),
                    shadowColor: Colors.white,
                  ),
                  icon: Image.asset(
                    "assets/images/googlelogo.png",
                    width: screenWidth * 0.06,
                    height: screenHeight * 0.06,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ContinueWithPhone(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.maxFinite, screenHeight * 0.06),
                shadowColor: Colors.white,
              ),
              icon: Icon(Icons.phone_android, size: screenWidth * 0.06),
              label: Text(
                'Continue with Phone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: screenWidth * 0.05,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

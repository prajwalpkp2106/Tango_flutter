import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_state.dart';
import 'package:tango_flutter_project/services/auth_service.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/widgets/snackbar.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthCubit() : super(AuthInitialState()) {
    Future.delayed(Duration.zero, () {
      checkUserStatus();
    });
  }

  //checking user has already signed in or not;
  void checkUserStatus() async {
    emit(AuthLoadingState());
    User? user = FirebaseAuth.instance.currentUser;
    String userId;

    if (user != null) {
      print(user.toString());

      print("check user in user");

      if (user.email != null && user.email!.isNotEmpty) {
        print("check user in email ");
        userId = await AuthService().fetchUserByEmail(user.email!);
        if (userId != "null") {
          emit(AuthCheckExists(userId: userId));
        } else {
          emit(AuthCheckNewState());
        }
      } else {
        print('check user in phone');

        userId = await AuthService().fetchUserByPhoneNumber(user.phoneNumber!);
        if (userId != "null") {
          emit(AuthCheckExists(userId: userId));
        } else {
          emit(AuthCheckNewState());
        }
      }
    } else {
      emit(AuthCheckNewState());
    }
  }

  //login with phone logic
  String? _verificationId;

  void sendOTP(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (verificationId, forceResendingToken) {
        _verificationId = verificationId;
        emit(AuthCodeSentState());
      },
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        emit(AuthSendErrorState(error.toString()));
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void verifyOTP(String otp, String phone) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: otp);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userId = await AuthService().fetchUserByPhoneNumber(phone);

        if (userId != "null") {
          print("In verify otp $userId");
          emit(AuthUserPhoneLoggedInState(
            userId: userId,
          ));
        } else {
          ActiveUser.currentuser.loginValue = phone;
          print("In verify otp new user ");
          emit(AuthUserPhoneNewState());
        }
      }
    } catch (e) {
      emit(AuthVerifyErrorState('Error verifying OTP: $e'));
    }
  }

//Sign in Google logic
  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? existingUser =
          await GoogleSignIn().signInSilently();
      if (existingUser != null) {
        // If there's an existing signed-in user, sign them out
        await GoogleSignIn().signOut();
      }

      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check if the user exists in the database based on their email
        String userEmail = user.email ?? "";
        String userId = await AuthService().fetchUserByEmail(userEmail);
        // print('print username:$user.name');

        if (userId != "null") {
          print("In google sign in $userId");
          emit(AuthUserEmailLoggedInState(userId: userId));
        } else {
          print("new user from googl sign in ");
          ActiveUser.currentuser.loginValue = userEmail;
          // User does not exist, navigate to UserData with the Google email used for login
          emit(AuthUserEmailNewState());
        }
      }
    } catch (e) {
      emit(AuthEmailErrorState('Error signing in with Google: $e'));
    }
  }

//Log out logic
  void logOut() async {
    await _auth.signOut();
    emit(AuthLoggedOutState());
  }
}

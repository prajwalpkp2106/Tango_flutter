import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_cubit.dart';
import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_state.dart';
import 'package:tango_flutter_project/bloc/Userbloc/userbloc_bloc.dart';
import 'package:tango_flutter_project/bloc/chatroombloc/bloc/chatroom_bloc.dart';
import 'package:tango_flutter_project/bloc/homepage_tinder_bolc/bloc/home_bloc.dart';
import 'package:tango_flutter_project/HomePage.dart';
import 'package:tango_flutter_project/screens/signup_page.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/services/notification_services.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
var uuid = const Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBUJ1uk5BjUoAIqpEOpMAgR_T1QWUbkSss',
      appId: "1:711121500208:android:2ede95f340e6b7dab0d5f5",
      storageBucket: 'tango-991f5.appspot.com',
      messagingSenderId: '711121500208',
      projectId: "tango-991f5",
    ),
  );
  await NotificationService.initialize();
  FirebaseAppCheck.instance.activate();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        BlocProvider(
          create: (context) => HomeBloc(),
        ),
        BlocProvider(
          create: (context) => NotificationService.notificationBloc,
        ),
        BlocProvider(
          create: (context) => ChatroomBloc(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkUserStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
              backgroundColor: Colors.black,
            );
          } else if (state is AuthCheckExists) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: ActiveUser.getUserData(state.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return const Scaffold(
                    body: Center(child: Text('Error fetching data')),
                  );
                } else if (snapshot.hasData) {
                  return const HomePage();
                } else {
                  return const Scaffold(
                    body: Center(child: Text('User data not found')),
                  );
                }
              },
            );
          } else {
            return const SignUpPage();
          }
        },
      ),
    );
  }
}

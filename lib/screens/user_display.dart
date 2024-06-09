// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_cubit.dart';
// import 'package:tango_flutter_project/bloc/auth_bloc/cubit/authcubit_state.dart';
// import 'package:tango_flutter_project/screens/pictures_add.dart';
// import 'package:tango_flutter_project/screens/signup_page.dart';
// import 'package:tango_flutter_project/services/getuser.dart';
// import 'package:tango_flutter_project/widgets/snackbar.dart';

// class UserDisplay extends StatefulWidget {
//   @override
//   State<UserDisplay> createState() => _UserDisplayState();
// }

// class _UserDisplayState extends State<UserDisplay> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Hello!!!",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   ActiveUser.currentuser.name ?? 'Unknown',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   ActiveUser.currentuser.userId!,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 BlocConsumer<AuthCubit, AuthState>(
//                   listener: (context, state) {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SignUpPage(),
//                       ),
//                     );
//                   },
//                   builder: (context, state) {
//                     return ElevatedButton(
//                         onPressed: () {
//                           BlocProvider.of<AuthCubit>(context).logOut();
//                         },
//                         child: const Text("Sign out"));
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

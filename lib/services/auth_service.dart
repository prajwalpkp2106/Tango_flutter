import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  Future<String> fetchUserByEmail(String email) async {
    try {
      // Reference to the "users" collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Query to find the user with the provided email
      QuerySnapshot querySnapshot =
          await users.where('login value', isEqualTo: email).get();

      // Check if there's any matching document
      if (querySnapshot.docs.isNotEmpty) {
        // Access the first matching document (assuming emails are unique)
        DocumentSnapshot userDocument = querySnapshot.docs[0];

        // Access the user ID
        String userId = userDocument.get('userId') as String;

        // Now you have the user ID for the given email
        // print('User ID for email $email: $userId');
        return userId;
      } else {
        // No user found with the provided email
        // print('No user found with email $email');
        return "null";
      }
    } catch (e) {
      //print('Error fetching user by email: $e');
      return "null";
    }
  }

  Future<String> fetchUserByPhoneNumber(String phoneNumber) async {
    try {
      // Reference to the "users" collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Query to find the user with the provided phone number
      QuerySnapshot querySnapshot =
          await users.where('login value', isEqualTo: phoneNumber).get();

      // Check if there's any matching document
      if (querySnapshot.docs.isNotEmpty) {
        // Access the first matching document (assuming phone numbers are unique)
        DocumentSnapshot userDocument = querySnapshot.docs[0];

        // Access the user ID
        String userId = userDocument.get('userId') as String;

        // Now you have the user ID for the given phone number
        print('User ID for phone number $phoneNumber: $userId');
        return userId;
      } else {
        // No user found with the provided phone number
        print('No user found with phone number $phoneNumber');
        return "null";
      }
    } catch (e) {
      print('Error fetching user by phone number: $e');
      return "null";
    }
  }
}

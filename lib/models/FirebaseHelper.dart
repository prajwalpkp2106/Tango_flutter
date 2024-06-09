import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tango_flutter_project/models/userprofile.dart';

class FirebaseHelper {
  static Future<User?> getUserModelById(String userId) async {
    User? user;

    try {
      DocumentSnapshot docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();

      if (docSnap.exists) {
        user = User.fromMap(docSnap.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }

    return user;
  }
}

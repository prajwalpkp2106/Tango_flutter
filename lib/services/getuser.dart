// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tango_flutter_project/services/notification_services.dart';
import 'package:uuid/uuid.dart';
import '../models/userprofile.dart';

class ActiveUser {
  static User currentuser = User(
      birthday: null,
      city: null,
      description: null,
      gender: null,
      images: [],
      interests: null,
      loginValue: null,
      name: null,
      userId: null,
      lastDocument: null);
  static DocumentSnapshot? lastDocumentsnapshot = null;

  static List<XFile?> imageFiles = [];

  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('userId', isEqualTo: userId)
              .limit(1) // Limit to 1 document as userId should be unique
              .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> user = snapshot.docs.first.data();
        ActiveUser.currentuser = User.fromMap(user);
        //Notification purposes
        await NotificationService.processNotifications();
        //Notification purposes ends here
        print('Current User Data:');
        print(
            'Login Value: ${ActiveUser.currentuser.loginValue ?? 'Not provided'}');
        print('Name: ${ActiveUser.currentuser.name ?? 'Not provided'}');
        print('User ID: ${ActiveUser.currentuser.userId ?? 'Not provided'}');
        print('Gender: ${ActiveUser.currentuser.gender ?? 'Not provided'}');
        print('City: ${ActiveUser.currentuser.city ?? 'Not provided'}');
        print('Birthday: ${ActiveUser.currentuser.birthday ?? 'Not provided'}');
        print(
            'Description: ${ActiveUser.currentuser.description ?? 'Not provided'}');
        print(
            'Interests: ${ActiveUser.currentuser.interests?.join(', ') ?? 'Not provided'}');
        print('Last Document: ${ActiveUser.currentuser.lastDocument}');
        lastDocumentsnapshot =
            await getUserDocument(ActiveUser.currentuser.lastDocument);

        return user;
      } else {
        print('User with userId $userId does not exist ');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<bool> CreatePost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    var uid = Uuid().v4();
    DateTime data = new DateTime.now();
    Map<String, dynamic>? user =
        await getUserData(ActiveUser.currentuser.userId.toString());
    await FirebaseFirestore.instance.collection('posts').doc(uid).set({
      'postImage': postImage,
      'username': user?['name'],
      'caption': caption,
      'location': location,
      'uid': ActiveUser.currentuser.userId,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }

  Future<String> uploadImageToStorage(String name, File file) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(name)
        .child(ActiveUser.currentuser.userId.toString())
        .child(const Uuid().v4());

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<bool> Comments({
    required String comment,
    required String type,
    required String postId,
  }) async {
    var uid = Uuid().v4();
    try {
      Map<String, dynamic>? user =
          await getUserData(ActiveUser.currentuser.userId.toString());
      String? profileImage = (ActiveUser.currentuser.images != null &&
              ActiveUser.currentuser.images!.isNotEmpty)
          ? ActiveUser.currentuser.images!.first
          : null;

      await FirebaseFirestore.instance
          .collection(type)
          .doc(postId)
          .collection('comments')
          .doc(uid)
          .set({
        'comment': comment,
        'username': user?['name'],
        'profileImage': profileImage,
        'CommentUid': uid,
      });
      return true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  Future<String> like({
    required List like,
    required String type,
    required String uid,
    required String postId,
  }) async {
    String res = 'some error';
    try {
      if (like.contains(uid)) {
        FirebaseFirestore.instance.collection(type).doc(postId).update({
          'like': FieldValue.arrayRemove([uid])
        });
      } else {
        FirebaseFirestore.instance.collection(type).doc(postId).update({
          'like': FieldValue.arrayUnion([uid])
        });
      }
      res = 'seccess';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<bool> CreatReels({
    required String video,
    required String caption,
  }) async {
    var uid = Uuid().v4();
    DateTime data = new DateTime.now();
    Map<String, dynamic>? user =
        await getUserData(ActiveUser.currentuser.userId.toString());
    String? profileImage = (ActiveUser.currentuser.images != null &&
            ActiveUser.currentuser.images!.isNotEmpty)
        ? ActiveUser.currentuser.images!.first
        : null;
    await FirebaseFirestore.instance.collection('reels').doc(uid).set({
      'reelsvideo': video,
      'username': user?['name'],
      'profileImage': profileImage,
      'caption': caption,
      'uid': ActiveUser.currentuser.userId,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }

  static Future<void> uploadImagesToFirebaseStorage() async {
    String userId = ActiveUser.currentuser.userId!;
    try {
      for (int i = 0; i < imageFiles.length; i++) {
        XFile? imageFile = imageFiles[i];

        if (imageFile == null || imageFile.path.isEmpty) {
          continue; // Skip if image is null or path is empty
        }

        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('user_images/$userId/$fileName');

        File image = File(imageFile.path);

        // Specify content type as 'image/png'
        final metadata = SettableMetadata(
          contentType: 'image/png',
          customMetadata: {'userId': userId}, // Optional
        );

        UploadTask uploadTask = firebaseStorageRef.putFile(image, metadata);
        TaskSnapshot taskSnapshot = await uploadTask;

        if (uploadTask.snapshot.state == TaskState.success) {
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();

          // Add the download URL to the user's images list
          ActiveUser.currentuser.images!.add(downloadUrl);
        } else {
          throw Exception('Failed to upload image');
        }
      }
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Error uploading images');
    }
    await saveUserDataToFirestore();
  }

  static Future<void> saveUserDataToFirestore() async {
    String userId = ActiveUser.currentuser.userId!;
    try {
      Map<String, dynamic> userData = User.toMap(ActiveUser.currentuser);

      // Reference to the 'users' collection
      CollectionReference usersRef =
          FirebaseFirestore.instance.collection('users');

      await usersRef.doc(userId).set(userData);

      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
      throw Exception('Error saving user data');
    }
  }

  static Future<DocumentSnapshot?> getUserDocument(String? userId) async {
    try {
      // Get the document reference for the user
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Fetch the user document
      DocumentSnapshot userSnapshot = await userDocRef.get();

      // Check if the document exists
      if (userSnapshot.exists) {
        // Document exists, return the DocumentSnapshot
        return userSnapshot;
      } else {
        // Document does not exist
        print('User document with ID $userId does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching user document: $e');
      return null;
    }
  }
}

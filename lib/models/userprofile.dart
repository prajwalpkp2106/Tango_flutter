import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? birthday;
  String? city;
  String? description;
  String? gender;
  List<String>? interests;
  String? loginValue;
  String? name;
  String? userId;
  List<String>? images;
  String? lastDocument;

  User({
    required this.birthday,
    required this.city,
    required this.description,
    required this.gender,
    required this.interests,
    required this.loginValue,
    required this.name,
    required this.userId,
    required this.images,
    required this.lastDocument,
  });

  // Convert a Firestore document (Map) to a User object
  factory User.fromMap(Map<String, dynamic> user) {
    return User(
        name: user['name'],
        userId: user['userId'],
        loginValue: user['login value'],
        birthday: user['birthday'],
        city: user['city'],
        description: user['description'],
        gender: user['gender'],
        interests: List<String>.from(user['interests']),
        images: List<String>.from(user['images']),
        lastDocument: user['lastDocument']);
  }

  // Convert a User object to a Firestore document (Map)
  static Map<String, dynamic> toMap(User user) {
    return <String, dynamic>{
      'name': user.name,
      'userId': user.userId,
      'login value': user.loginValue,
      'birthday': user.birthday,
      'city': user.city,
      'description': user.description,
      'gender': user.gender,
      'interests': user.interests,
      'images': user.images,
      'lastDocument': user.lastDocument,
    };
  }
}

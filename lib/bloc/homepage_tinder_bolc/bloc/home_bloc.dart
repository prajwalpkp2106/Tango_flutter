import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tango_flutter_project/models/userprofile.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/widgets/snackbar.dart';

part 'home_event.dart';
part 'home_state.dart';

class UserFetchResult {
  final List<User> users;
  final DocumentSnapshot? lastDocument;

  UserFetchResult({required this.users, this.lastDocument});
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<UserfetchEvent>(_userfetchEvent);
  }

  Future<void> _userfetchEvent(
      UserfetchEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      String gender = "";
      if (event.gender == "Male")
        gender = "Female";
      else
        gender = "Male";
      UserFetchResult result = await fetchNextUsersByCityAndGender(
          event.city, gender, event.lastDocument);
      print("in user fetch event , last user  id  was : ${event.lastuserid}");
      await updateLastDocument(
          ActiveUser.currentuser.userId!, event.lastuserid);
      if (result.users.isEmpty) {
        emit(HomeEmptyUserState());
      } else {
        emit(HomeLoadedState(
            users: result.users, lastDocument: result.lastDocument));
      }
    } catch (e) {
      print('error');
    }
  }

  Future<UserFetchResult> fetchNextUsersByCityAndGender(
      String city, String gender, DocumentSnapshot? lastDocument) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .where('city', isEqualTo: city)
          .where('gender', isEqualTo: gender)
          .limit(1);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot? lastDoc =
            querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
        List<User> users = querySnapshot.docs
            .map((doc) => User.fromMap(doc.data()! as Map<String, dynamic>))
            .toList();

        return UserFetchResult(users: users, lastDocument: lastDoc);
      } else {
        print('No more users available');
        return UserFetchResult(users: [], lastDocument: null);
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw e;
    }
  }

  Future<void> updateLastDocument(String userId, String? lastDocument) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      // Get the document reference for the user
      DocumentReference userDocRef = users.doc(userId);

      // Create a data map with the last document
      Map<String, dynamic> userData = {
        'lastDocument': lastDocument,
      };

      // Update the user document with the last document
      await userDocRef.update(userData);
    } catch (e) {
      print('Error updating last document: $e');
      throw e;
    }
  }
}

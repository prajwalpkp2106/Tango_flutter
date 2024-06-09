import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tango_flutter_project/bloc/homepage_tinder_bolc/bloc/home_bloc.dart';
import 'package:tango_flutter_project/screens/instagram/UserProfile.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/services/notification_services.dart';
import 'package:tango_flutter_project/widgets/Customapp_bar.dart';
import 'package:tango_flutter_project/widgets/tinder/user_card.dart';
import 'package:tango_flutter_project/widgets/tinder/user_image.dart';

class TinderHomepage extends StatefulWidget {
  @override
  State<TinderHomepage> createState() => _TinderHomepageState();
}

class _TinderHomepageState extends State<TinderHomepage> {
  int count = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("hello in home page");
    context.read<HomeBloc>().add(UserfetchEvent(
        lastuserid: ActiveUser.currentuser.lastDocument,
        city: ActiveUser.currentuser.city!,
        gender: ActiveUser.currentuser.gender!,
        lastDocument: ActiveUser.lastDocumentsnapshot));
    print('profile');
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        if (state is HomeLoadingState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
            backgroundColor: Colors.black,
          );
        } else if (state is HomeLoadedState) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: const CustomAppBar(
              title: 'tinder',
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                UserCard(user: state.users![count]),
                // Add some spacing between UserCard and buttons
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if ((count + 1) < state.users!.length) {
                            count++;
                          } else {
                            ActiveUser.currentuser.lastDocument =
                                state.users![count].userId;
                            ActiveUser.lastDocumentsnapshot =
                                state.lastDocument;
                            context.read<HomeBloc>().add(UserfetchEvent(
                                lastuserid: state.users![count].userId,
                                city: ActiveUser.currentuser.city!,
                                gender: ActiveUser.currentuser.gender!,
                                lastDocument: state.lastDocument));
                            count = 0;
                          }
                        });
                        print("dislike");
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.black,
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.thumb_down,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String userid = state.users![count].userId!;
                        String? imageurl = ActiveUser.currentuser.images![0];
                        String name = ActiveUser.currentuser.name!;
                        String type = 'liked';
                        NotificationService.saveNotificationDataToFirestore(
                            userid, imageurl, name, type);
                        setState(() {
                          if ((count + 1) < state.users!.length) {
                            count++;
                          } else {
                            ActiveUser.currentuser.lastDocument =
                                state.users![count].userId;
                            ActiveUser.lastDocumentsnapshot =
                                state.lastDocument;
                            context.read<HomeBloc>().add(UserfetchEvent(
                                lastuserid: state.users![count].userId,
                                city: ActiveUser.currentuser.city!,
                                gender: ActiveUser.currentuser.gender!,
                                lastDocument: state.lastDocument));
                            count = 0;
                          }
                        });
                        print('Liked');
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.black,
                        side: const BorderSide(color: Colors.pink, width: 2),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 20,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final currentUser = state.users![count];
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                UserProfile(user: currentUser)));
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.black,
                        side: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (state is HomeEmptyUserState) {
          // Handle the case when count exceeds the number of users
          // For now, return an empty Container, you can replace this with any other widget
          // showSnackBar("No users Available , Please Try Again ", context);
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: const CustomAppBar(title: "tinder"),
            body: Hero(
              tag: 'user_card',
              child: Padding(
                padding: const EdgeInsets.only(top: 25.0, left: 20, right: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 1.48,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      const UserImage.large(url: null),
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      // Show Snackbar directly within the Stack

                      Builder(
                        builder: (BuildContext context) {
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "No users Available , Please Try Again "),
                              ),
                            );
                          });
                          return const SizedBox
                              .shrink(); // Empty SizedBox to maintain Stack size
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // Handle other states here, for now, return an empty Container
          return Container();
        }
      },
    );
  }
}

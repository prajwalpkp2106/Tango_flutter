import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tango_flutter_project/models/userprofile.dart';
import 'package:tango_flutter_project/widgets/tinder/user_image.dart';

class UserCard extends StatefulWidget {
  final User? user;

  const UserCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late String largeImage;
  late int age;
  final txtKey = GlobalKey();

  @override
  void initState() {
    largeImage = widget.user!.images![0];
    print("in user card ${widget.user!.name} ");
    age = calculateAge(DateTime.parse(widget.user!.birthday ?? ""));
    super.initState();
  }

  int calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  void didUpdateWidget(covariant UserCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user) {
      _updateUserDetails(widget.user);
    }
  }

  void _updateUserDetails(User? newUser) {
    if (newUser != null) {
      setState(() {
        largeImage = newUser.images![0];
        print("in user card ${newUser.name} ");
        age = calculateAge(DateTime.parse(newUser.birthday ?? ""));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size? textSize;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final keyContext = txtKey.currentContext;
      if (keyContext != null) {
        final txtBox = keyContext.findRenderObject() as RenderBox;
        textSize = txtBox.size;

        if (textSize!.width > (MediaQuery.of(context).size.width - 90)) {
          setState(() {}); // Rebuild the widget to show ellipsis
        }
      }
    });

    return widget.user != null
        ? Hero(
            tag: 'user_card',
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0, left: 20, right: 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.48,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    UserImage.large(url: largeImage),
                    Container(
                      decoration: BoxDecoration(
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
                    Positioned(
                      bottom: 30,
                      left: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.user!.name} , ${age} yrs (${widget.user!.gender})',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 90,
                            ),
                            child: Text(
                              widget.user!.description!,
                              key: txtKey,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (textSize != null &&
                              textSize!.width >
                                  (MediaQuery.of(context).size.width - 90))
                            GestureDetector(
                              onTap: () {
                                print('Tapped on ellipsis');
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.user!.description!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            height: 70,
                            width: MediaQuery.of(context).size.width - 60,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.user!.images!.length,
                              itemBuilder: (builder, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      largeImage = widget.user!.images![index];
                                    });
                                  },
                                  child: UserImage.small(
                                    url: widget.user!.images![index],
                                    margin:
                                        const EdgeInsets.only(top: 8, right: 8),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const Scaffold(
            body: Center(
              child: Text(
                "Error",
                style: TextStyle(
                  fontSize: 33,
                ),
              ),
            ),
          );
  }
}

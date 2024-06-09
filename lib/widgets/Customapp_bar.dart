import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tango_flutter_project/bloc/notification_bloc/bloc/notification_bloc.dart';
import 'package:tango_flutter_project/screens/tinder/recentchatscreen.dart';
import 'package:tango_flutter_project/screens/tinder/tinder_notifications.dart';
import 'package:tango_flutter_project/services/notification_services.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    Key? key,
    required this.title, // Initialize the notificationCount parameter
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
  @override
  Size get preferredSize => Size.fromHeight(56.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    context.read<NotificationBloc>().add(NotificationCountEvent());
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              child: Image.asset(
                'assets/images/logo.png',
                height: 50,
                width: 60,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8.0),
            child: Text(
              widget.title,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.favorite, color: Colors.white),
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationCountState &&
                      NotificationService.tinder_notification_count != 0) {
                    int count = NotificationService.tinder_notification_count;
                    print(
                        "In builder of custom app bar for notification : $count");
                    return Positioned(
                      right: 0,
                      top: -5,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return Padding(padding: EdgeInsets.zero);
                  }
                },
              )
            ],
          ),
          onPressed: () {
            if (NotificationService.tinder_notification_count != 0) {
              NotificationService.tinder_notification_count = 0;
              NotificationService.updateunSeenNotifications();
              context.read<NotificationBloc>().add(NotificationCountEvent());
            }
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NotificationPage(),
            ));
          },
        ),
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications, color: Colors.white),
              Positioned(
                right: 0,
                top: -5,
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.message, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RecentChatPage(),
            ));
          },
        ),
      ],
    );
  }
}

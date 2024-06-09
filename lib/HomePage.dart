import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:tango_flutter_project/screens/instagram/Profile_screen.dart';
import 'package:tango_flutter_project/screens/instagram/Reels_screen.dart';
import 'package:tango_flutter_project/screens/instagram/add_post.dart';
import 'package:tango_flutter_project/screens/omegal/omegal.dart';
import 'package:tango_flutter_project/screens/tinder/TinderHomepage.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentpage = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChange(int pageNumber) {
    setState(() {
      _currentpage = pageNumber;
    });
  }

  void navigate(int pageNumber) {
    pageController.jumpToPage(pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChange,
        children: [
          TinderHomepage(),
          const ReelScreen(),
          const AddPost(),
          const Omegle(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentpage,
        backgroundColor: Colors.white,
        color: Colors.black,
        buttonBackgroundColor: Colors.grey[800],
        height: 50, // Reduced height for a smaller curve
        onTap: navigate,
        items: const [
          CurvedNavigationBarItem(
            child: Icon(Icons.favorite_border, color: Colors.white),
            label: '',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.play_arrow_rounded, color: Colors.white),
            label: '',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.add, color: Colors.white),
            label: '',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.video_call, color: Colors.white),
            label: '',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person, color: Colors.white),
            label: '',
          ),
        ],
        animationCurve: Curves.easeOut,
        animationDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}

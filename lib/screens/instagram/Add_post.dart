import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tango_flutter_project/screens/instagram/Add_post_screen.dart';
import 'package:tango_flutter_project/screens/instagram/Add_reels_screen.dart';
import 'package:tango_flutter_project/screens/instagram/Reels_screen.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

int _currentI = 0;

class _AddPostState extends State<AddPost> {
  late PageController pageControl;

  @override
  void initState() {
    super.initState();
    pageControl = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageControl.dispose();
  }

  onScreenChange(int pageno) {
    setState(() {
      _currentI = pageno;
    });
  }

  navigationPressed(int pageno) {
    pageControl.jumpToPage(pageno);
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            PageView(
              controller: pageControl,
              onPageChanged: onScreenChange,
              children: const [AddPostScreen(), AddReelsScreen()],
            ),
            Container(
              width: screenWidth * 0.5,
              height: screenHeight * 0.07,
              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      navigationPressed(0);
                    },
                    child: Text(
                      'POST',
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        fontWeight: FontWeight.w500,
                        color: _currentI == 0 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  // Text(
                  //   'STORY',
                  //   style: TextStyle(
                  //     fontSize: screenHeight*0.02,
                  //     fontWeight: FontWeight.w500,
                  //     color: _currentI == 1 ? Colors.white : Colors.grey,
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () {
                      navigationPressed(1);
                    },
                    child: Text(
                      'REEL',
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        fontWeight: FontWeight.w500,
                        color: _currentI == 1 ? Colors.white : Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

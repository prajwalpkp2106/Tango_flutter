import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor:
            Colors.black, // Set the background color of the BottomNavigationBar
      ),
      child: Padding(
         padding: EdgeInsets.only(right: 20), 
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          currentIndex: selectedIndex,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 15),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'assets/images/tinder.png',
                  ),
                ),
              ),
              label: '', // Empty label
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.symmetric(), // Adjust padding as needed
                child: Icon(Icons.video_library, size: 30,
                color: Colors.white),
              ),
              label: '', // Empty label
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.add, size: 30,
                 color: Colors.white),
              
              ),
              label: '', // Empty label
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.videocam, size: 30,
                 color: Colors.white),
              ),
              label: '', // Empty label
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.person, size: 30,
                 color: Colors.white),
              ),
              label: '', // Empty label
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AccountWidget extends StatelessWidget {
  const AccountWidget({
    super.key,
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: const AssetImage('assets/images/profile.png'),
        radius: screenWidth * 0.06,
      ),
      title: Text(
        "Good bear",
        style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth * 0.05,
        ),
      ),
      subtitle: Text(
        "@goodbear-14014",
        style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.w300,
        ),
      ),
      trailing: IconButton(
        splashRadius: screenWidth * 0.05,
        iconSize: screenWidth * 0.04,
        onPressed: () {},
        icon: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}

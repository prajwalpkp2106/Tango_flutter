import 'package:flutter/material.dart';
import 'package:tango_flutter_project/screens/instagram/post_widget.dart';

class PostScreen extends StatefulWidget {
  final snapshot;
  PostScreen(this.snapshot, {super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: PostWidget(widget.snapshot)),
    );
  }
}

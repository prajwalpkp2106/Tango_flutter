import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tango_flutter_project/services/getuser.dart';

class AddPostTextScreen extends StatefulWidget {
  File _file;
  AddPostTextScreen(this._file, {super.key});

  @override
  State<AddPostTextScreen> createState() => _AddPostTextScreenState();
}

class _AddPostTextScreenState extends State<AddPostTextScreen> {
  final caption = TextEditingController();
  final location = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'New post',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  String postUrl = await ActiveUser()
                      .uploadImageToStorage('post', widget._file);
                  await ActiveUser().CreatePost(
                    postImage: postUrl,
                    caption: caption.text,
                    location: location.text,
                  );
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Share',
                  style: TextStyle(
                      color: Colors.blue, fontSize: screenHeight * 0.018),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.12,
                            height: screenHeight * 0.06,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                image: FileImage(widget._file),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          SizedBox(
                            width: screenWidth * 0.7,
                            height: screenHeight * 0.05,
                            child: TextField(
                              controller: caption,
                              cursorColor: Colors.black,
                              decoration: const InputDecoration(
                                  hintText: 'Write a caption ...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.white)),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      child: SizedBox(
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.025,
                        child: TextField(
                          controller: location,
                          decoration: const InputDecoration(
                              hintText: 'Add location',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.white)),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

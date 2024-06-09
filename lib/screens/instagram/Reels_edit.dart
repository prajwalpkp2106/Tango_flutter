// ignore_for_file: must_be_immutable

import 'dart:io';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tango_flutter_project/services/getuser.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class ReelsEditeScreen extends StatefulWidget {
  File videoFile;
  ReelsEditeScreen(this.videoFile, {super.key});

  @override
  State<ReelsEditeScreen> createState() => _ReelsEditeScreenState();
}

class _ReelsEditeScreenState extends State<ReelsEditeScreen> {
  final caption = TextEditingController();
  late VideoPlayerController controller;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true);
        controller.setVolume(1.0);
        controller.play();
      });
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double width(double value) {
      return screenWidth * value;
    }

    double height(double value) {
      return screenHeight * value;
    }

    TextStyle textStyle(double fontSize, {Color? color}) {
      return TextStyle(
        fontSize: screenWidth * (fontSize / 375),
        color: color,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        title: const Text(
          'New Reels',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: width(0.0267)),
                child: Column(
                  children: [
                    SizedBox(height: height(0.0369)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width(0.1067)),
                      child: SizedBox(
                        width: width(0.72),
                        height: height(0.5172),
                        child: controller.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: VideoPlayer(controller),
                              )
                            : const CircularProgressIndicator(),
                      ),
                    ),
                    SizedBox(height: height(0.0246)),
                    SizedBox(
                      height: height(0.0735),
                      width: width(0.7467),
                      child: TextField(
                        controller: caption,
                        maxLines: 10,
                        decoration: const InputDecoration(
                            hintText: 'Write a caption ...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white)),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const Divider(),
                    SizedBox(height: height(0.0246)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: height(0.0553),
                          width: width(0.4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(width(0.0267)),
                          ),
                          child: Text(
                            'Save draft',
                            style: textStyle(16),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              loading = true;
                            });
                            String reelsUrl = await ActiveUser()
                                .uploadImageToStorage(
                                    'Reels', widget.videoFile);
                            await ActiveUser().CreatReels(
                              video: reelsUrl,
                              caption: caption.text,
                            );
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: height(0.0553),
                            width: width(0.4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.circular(width(0.0267)),
                            ),
                            child: Text(
                              'Share',
                              style: TextStyle(
                                fontSize: textStyle(16).fontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

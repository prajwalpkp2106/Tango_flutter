import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tango_flutter_project/screens/instagram/UserProfile.dart';
import 'package:tango_flutter_project/screens/instagram/comment.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/screens/instagram/like_animation.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tango_flutter_project/screens/instagram/imageCached.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// Ensure correct import path

class ReelsItem extends StatefulWidget {
  final snapshot;
  const ReelsItem(this.snapshot, {super.key});

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  late VideoPlayerController controller;
  bool play = true;
  bool isAnimating = false;
  bool isLoading = true;
  bool isMuted = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!.uid;
    controller = VideoPlayerController.network(widget.snapshot['reelsvideo'])
      ..initialize().then((value) {
        setState(() {
          controller.setLooping(true);
          controller.setVolume(1);
          controller.play();
          isLoading = false;
        });
      });
    FlutterDownloader.initialize(debug: true);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      controller.setVolume(isMuted ? 0 : 1);
    });
  }

  Future<void> downloadVideo() async {
    try {
      // Check and request permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // Get directory to save the video
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          String videoUrl = widget.snapshot['reelsvideo'];
          String localPath = directory.path;

          print('Download URL: $videoUrl');
          print('Local Path: $localPath');

          // Show progress dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Downloading..."),
                  ],
                ),
              );
            },
          );

          // Start the download
          final taskId = await FlutterDownloader.enqueue(
            url: videoUrl,
            savedDir: localPath,
            fileName: 'reels_video.mp4',
            showNotification: true,
            openFileFromNotification: true,
          );

          print('Task ID: $taskId');

          // Listen for the download progress
          FlutterDownloader.registerCallback((id, status, progress) {
            if (id == taskId) {
              print('Status: $status');
              print('Progress: $progress%');
              if (status == DownloadTaskStatus.complete) {
                Navigator.of(context).pop(); // Close the progress dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download complete!')),
                );
              } else if (status == DownloadTaskStatus.failed) {
                Navigator.of(context).pop(); // Close the progress dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download failed.')),
                );
              }
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get storage directory.')),
          );
        }
      } else {
        // Handle permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permission to access storage is denied.')),
        );
      }
    } catch (e) {
      print('Download failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onDoubleTap: () {
            ActiveUser().like(
              like: widget.snapshot['like'],
              type: 'reels',
              uid: user,
              postId: widget.snapshot['postId'],
            );
            setState(() {
              isAnimating = true;
            });
          },
          onTap: () {
            setState(() {
              play = !play;
            });
            if (play) {
              controller.play();
            } else {
              controller.pause();
            }
          },
          child: SizedBox(
            width: double.infinity,
            height: screenHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
                if (isLoading) const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
        if (!play)
          Center(
            child: CircleAvatar(
              backgroundColor: Colors.white30,
              radius: screenHeight * 0.043,
              child: Icon(
                Icons.play_arrow,
                size: screenWidth * 0.1,
                color: Colors.white,
              ),
            ),
          ),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isAnimating ? 1 : 0,
            child: LikeAnimation(
              isAnimating: isAnimating,
              duration: const Duration(milliseconds: 400),
              iconlike: false,
              end: () {
                setState(() {
                  isAnimating = false;
                });
              },
              child: Icon(
                Icons.favorite,
                size: screenWidth * 0.25,
                color: Colors.red,
              ),
            ),
          ),
        ),
        Positioned(
          top: screenHeight * 0.5,
          right: screenWidth * 0.04,
          child: Column(
            children: [
              LikeAnimation(
                isAnimating: widget.snapshot['like'].contains(user),
                child: IconButton(
                  onPressed: () {
                    ActiveUser().like(
                      like: widget.snapshot['like'],
                      type: 'reels',
                      uid: user,
                      postId: widget.snapshot['postId'],
                    );
                  },
                  icon: Icon(
                    widget.snapshot['like'].contains(user)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.snapshot['like'].contains(user)
                        ? Colors.red
                        : Colors.white,
                    size: screenWidth * 0.08,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                widget.snapshot['like'].length.toString(),
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              GestureDetector(
                onTap: () {
                  showBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: DraggableScrollableSheet(
                          maxChildSize: 0.6,
                          initialChildSize: 0.6,
                          minChildSize: 0.2,
                          builder: (context, scrollController) {
                            return Comment('reels', widget.snapshot['postId']);
                          },
                        ),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.comment,
                  color: Colors.white,
                  size: screenWidth * 0.08,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reels')
                    .doc(widget.snapshot['postId'])
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(
                      '0',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    );
                  } else {
                    return Text(
                      snapshot.data!.docs.length.toString(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: toggleMute,
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: screenWidth * 0.08,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: downloadVideo,
                child: Icon(
                  Icons.download,
                  color: Colors.white,
                  size: screenWidth * 0.08,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: screenHeight * 0.05,
          left: screenWidth * 0.025,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.snapshot['profileImage'] != null &&
                      widget.snapshot['profileImage'].isNotEmpty)
                    GestureDetector(
                      onTap: () {},
                      child: ClipOval(
                        child: SizedBox(
                          height: screenHeight * 0.06,
                          width: screenWidth * 0.12,
                          child: CachedImage(widget.snapshot['profileImage']),
                        ),
                      ),
                    ),
                  SizedBox(width: screenWidth * 0.03),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      widget.snapshot['username'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                widget.snapshot['caption'],
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tango_flutter_project/screens/instagram/comment.dart';
import 'package:tango_flutter_project/screens/instagram/imageCached.dart';
import 'package:tango_flutter_project/screens/instagram/like_animation.dart';
import 'package:tango_flutter_project/services/getuser.dart';

class PostWidget extends StatefulWidget {
  final snapshot;
  const PostWidget(this.snapshot, {super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!.uid;
  }

  void handleLike() {
    ActiveUser().like(
      like: widget.snapshot['like'],
      type: 'posts',
      uid: user,
      postId: widget.snapshot['postId'],
    );
    setState(() {
      isAnimating = true;
      if (widget.snapshot['like'].contains(user)) {
        widget.snapshot['like'].remove(user);
      } else {
        widget.snapshot['like'].add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      // resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and post settings icon
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: screenWidth * 0.093,
                      height: screenWidth * 0.093,
                      child: CachedImage(widget.snapshot['profileImage']),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.snapshot['username'],
                        style: TextStyle(
                          fontSize: screenWidth * 0.034,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.snapshot['location'],
                        style: TextStyle(
                          fontSize: screenWidth * 0.027,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.more_horiz, color: Colors.white),
                ],
              ),
            ),
            // Post image
            GestureDetector(
              onDoubleTap: handleLike,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: screenHeight * 0.356,
                    child: CachedImage(
                      widget.snapshot['postImage'],
                    ),
                  ),
                  AnimatedOpacity(
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
                        size: screenWidth * 0.266,
                        color: Colors.red,
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Post actions (like, comment) and like/comment count
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  LikeAnimation(
                    isAnimating: widget.snapshot['like'].contains(user),
                    child: IconButton(
                      onPressed: handleLike,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 24.0),
                    child: Text(
                      widget.snapshot['like'].length.toString(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.034,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                                return Comment(
                                    'posts', widget.snapshot['postId']);
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
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.snapshot['postId'])
                          .collection('comments')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text(
                            '0',
                            style: TextStyle(
                              fontSize: screenWidth * 0.034,
                              color: Colors.white,
                            ),
                          );
                        } else {
                          return Text(
                            snapshot.data!.docs.length.toString(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.034,
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Caption
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.snapshot['username'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.034,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: ' ${widget.snapshot['caption']}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.034,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Post time
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                formatDate(
                    widget.snapshot['time'].toDate(), [yyyy, '-', mm, '-', dd]),
                style: TextStyle(
                  fontSize: screenWidth * 0.027,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

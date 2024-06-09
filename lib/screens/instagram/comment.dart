import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tango_flutter_project/screens/instagram/imageCached.dart';
import 'package:tango_flutter_project/services/getuser.dart';

class Comment extends StatefulWidget {
  final String type;
  final String uid;
  Comment(this.type, this.uid, {super.key});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(mediaQuery.size.width * 0.05),
        topRight: Radius.circular(mediaQuery.size.width * 0.05),
      ),
      child: Container(
        color: Colors.black,
        height: mediaQuery.size.height * 0.6, // Adjust height as needed
        child: Column(
          children: [
            SizedBox(height: mediaQuery.size.height * 0.02),
            Container(
              width: mediaQuery.size.width * 0.25,
              height: mediaQuery.size.height * 0.004,
              color: Colors.grey[800],
            ),
            SizedBox(height: mediaQuery.size.height * 0.02),
            const Text(
              "Comments",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection(widget.type)
                    .doc(widget.uid)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: mediaQuery.size.height * 0.02),
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return commentItem(snapshot.data!.docs[index].data());
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: mediaQuery.viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width * 0.02,
                    vertical: mediaQuery.size.height * 0.01),
                color: Colors.black,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        maxLines: 1,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Add a comment',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (commentController.text.isNotEmpty) {
                          await ActiveUser().Comments(
                            comment: commentController.text,
                            type: widget.type,
                            postId: widget.uid,
                          );
                        }
                        setState(() {
                          isLoading = false;
                          commentController.clear();
                        });
                      },
                      child: isLoading
                          ? SizedBox(
                              width: mediaQuery.size.width * 0.05,
                              height: mediaQuery.size.width * 0.05,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commentItem(final snapshot) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mediaQuery.size.height * 0.005,
          horizontal: mediaQuery.size.width * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              height: mediaQuery.size.height * 0.05,
              width: mediaQuery.size.width * 0.1,
              child: CachedImage(
                snapshot['profileImage'],
              ),
            ),
          ),
          SizedBox(width: mediaQuery.size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot['username'],
                  style: TextStyle(
                    fontSize: mediaQuery.size.width * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: mediaQuery.size.height * 0.005),
                Text(
                  snapshot['comment'],
                  style: TextStyle(
                    fontSize: mediaQuery.size.width * 0.035,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: mediaQuery.size.height * 0.005),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

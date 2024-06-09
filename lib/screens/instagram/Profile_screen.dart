import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tango_flutter_project/screens/instagram/PostScreen.dart';
import 'package:tango_flutter_project/screens/instagram/reel_item.dart';
import 'package:tango_flutter_project/services/getuser.dart';
import 'package:tango_flutter_project/models/userprofile.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    var userData =
        await ActiveUser.getUserData(ActiveUser.currentuser.userId.toString());
    setState(() {
      _userData = userData;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            if (_userData == null)
              const Center(child: CircularProgressIndicator())
            else
              buildProfileHead(_userData),
            TabBar(
              controller: _tabController,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on)),
                Tab(icon: Icon(Icons.video_collection)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsTab(),
                  _buildReelsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchAllUserPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        var posts = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PostScreen(post)));
              },
              child: Image.network(
                post['postImage'],
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllUserPosts() async {
    List<Map<String, dynamic>> posts = [];

    // Fetch images from posts collection
    var postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: ActiveUser.currentuser.userId.toString())
        .get();
    for (var doc in postsSnapshot.docs) {
      posts.add(doc.data());
    }

    // Fetch images from user's document in users collection
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(ActiveUser.currentuser.userId.toString())
        .get();
    if (userDoc.exists && userDoc.data()!.containsKey('images')) {
      List<dynamic> userImages = userDoc['images'];
      for (var imageUrl in userImages) {
        // Check if the image already exists in the posts collection
        bool exists = posts.any((post) => post['postImage'] == imageUrl);
        if (!exists) {
          // Add the image to the posts collection
          await FirebaseFirestore.instance.collection('posts').add({
            'uid': ActiveUser.currentuser.userId.toString(),
            'postImage': imageUrl,
            'timestamp': FieldValue.serverTimestamp(),
          });
          // Also add to local posts list
          posts.add({'postImage': imageUrl});
        }
      }
    }

    return posts;
  }

  Widget _buildReelsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reels')
          .where('uid', isEqualTo: ActiveUser.currentuser.userId.toString())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        var snapLen = snapshot.data!.docs.length;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: snapLen,
          itemBuilder: (context, index) {
            var snap = snapshot.data!.docs[index];
            return FutureBuilder<String?>(
              future: _generateThumbnail(snap['reelsvideo']),
              builder: (context, thumbnailSnapshot) {
                if (thumbnailSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (thumbnailSnapshot.hasError ||
                    thumbnailSnapshot.data == null) {
                  return const Center(child: Icon(Icons.error));
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ReelsItem(snap.data())));
                  },
                  child: Image.file(
                    File(thumbnailSnapshot.data!),
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String?> _generateThumbnail(String videoUrl) async {
    final directory = await getTemporaryDirectory();
    final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final thumbnailPath = '${directory.path}/$filename';

    await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: thumbnailPath,
      imageFormat: ImageFormat.JPEG,
      quality: 75,
    );

    return thumbnailPath;
  }

  Container buildProfileHead(Map<String, dynamic>? userData) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (userData == null) {
      return Container(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    User currentuser = User.fromMap(userData);

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GestureDetector(
                  onTap: () => _showProfileImage(
                      context,
                      currentuser.images != null &&
                              currentuser.images!.isNotEmpty
                          ? currentuser.images!.first
                          : 'https://via.placeholder.com/150'),
                  child: ClipOval(
                    child: SizedBox(
                      width: screenWidth * 0.23,
                      height: screenHeight * 0.15,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(currentuser.images != null &&
                                    currentuser.images!.isNotEmpty
                                ? currentuser.images!.first
                                : 'https://via.placeholder.com/150'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentuser.userId ?? 'Name',
                      style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      currentuser.birthday ?? 'Birth Date',
                      style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                    Text(
                      currentuser.description ?? 'Bio',
                      style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                    Text(
                      currentuser.interests?.join(', ') ?? 'Interests',
                      style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.05),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              alignment: Alignment.center,
              height: screenHeight * 0.05,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenHeight * 0.01),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.02,
          ),
        ],
      ),
    );
  }

  void _showProfileImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(imageUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

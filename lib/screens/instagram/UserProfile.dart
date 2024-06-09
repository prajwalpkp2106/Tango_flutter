import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tango_flutter_project/screens/instagram/PostScreen.dart';
import 'package:tango_flutter_project/screens/instagram/reel_item.dart';
import 'package:tango_flutter_project/models/userprofile.dart'; // Ensure the User model is imported
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class UserProfile extends StatefulWidget {
  final User user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            buildProfileHead(widget.user),
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
                  _buildPostsTab(widget.user.userId!),
                  _buildReelsTab(widget.user.userId!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(String userId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: userId)
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Upload Posts',
              style: TextStyle(color: Colors.white),
            ),
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
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PostScreen(snap.data())));
              },
              child: Image.network(
                snap['postImage'],
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReelsTab(String userId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reels')
          .where('uid', isEqualTo: userId)
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Upload Reels',
              style: TextStyle(color: Colors.white),
            ),
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

  Container buildProfileHead(User currentuser) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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

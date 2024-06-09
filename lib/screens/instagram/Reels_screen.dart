import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tango_flutter_project/screens/instagram/reel_item.dart';

class ReelScreen extends StatefulWidget {
  const ReelScreen({super.key});

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Set background color to black for dark theme
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('reels')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors
                    .white, // Set CircularProgressIndicator color to white for dark theme
              ));
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(
                        color: Colors
                            .white)), // Set error text color to white for dark theme
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                'No reels available',
                style: TextStyle(
                    color: Colors
                        .white), // Set "No reels available" text color to white for dark theme
              ));
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              controller: PageController(initialPage: 0, viewportFraction: 1),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var reelData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return ReelsItem(reelData);
              },
            );
          },
        ),
      ),
    );
  }
}

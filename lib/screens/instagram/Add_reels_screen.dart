import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:tango_flutter_project/screens/instagram/Reels_edit.dart';

class AddReelsScreen extends StatefulWidget {
  const AddReelsScreen({Key? key}) : super(key: key);

  @override
  State<AddReelsScreen> createState() => _AddReelsScreenState();
}

class _AddReelsScreenState extends State<AddReelsScreen> {
  VideoPlayerController? _controller;
  final List<Widget> _mediaList = [];
  final List<File> path = [];
  File? _file;
  int currentPage = 0;
  int? lastPage;

  Future<void> _fetchNewMedia() async {
    final XFile? video =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      path.add(File(video.path));
      _file = path[0];
      _controller = VideoPlayerController.file(path[0]);
      await _controller!.initialize();
      setState(() {
        _mediaList.add(_buildMediaWidget());
      });
    }
  }

  Widget _buildMediaWidget() {
    return Container(
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'New Reels',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: _mediaList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                setState(() {
                  _file = path[index];
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReelsEditeScreen(_file!),
                  ));
                });
              },
              child: _mediaList[index],
            );
          },
        ),
      ),
    );
  }
}

// // ignore_for_file: unused_import, non_constant_identifier_names, avoid_unnecessary_containers,

// import 'package:flutter/material.dart';
// import 'package:peerdart/peerdart.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:tango_flutter_project/screens/tinder/Homepage.dart';
// class Omegle extends StatefulWidget {
//   const Omegle({Key? key}) : super(key: key);

//   @override
//   State<Omegle> createState() => _OmegleState();
// }

// class _OmegleState extends State<Omegle> {
//   //Icon for the button change conditionally
//   bool video = true;
//   bool audio = true;
//   bool socketStatus = false;
//   String UserConnectionMsg = "Not Connected";
//   io.Socket? socket;
//   List<Widget> messages = [];

// //Peerdart copied code
//   final TextEditingController _msgController = TextEditingController();
//   final Peer peer = Peer(options: PeerOptions(debug: LogLevel.All));
//   final _localRenderer = RTCVideoRenderer();
//   final _remoteRenderer = RTCVideoRenderer();
//   bool inCall = false;
//   String? peerID;
//   //END

//   String? otherUser;
//   MediaStream? theStream;
//   String? otherPeerID;

//   bool joined = false;
//   bool waitingOnConnection = false;
//   late bool videoOn;
//   int onlineUsers = 0;

//   @override
//   void initState() {
//     super.initState();
//     initRenderers(); //Initializes the local and remote RTCVideoRenderer objects used to display video streams.
//     peer.on("open").listen((id) {
//       //Listens for the "open" event to get the unique peer ID when the connection is established.
//       setState(() {
//         peerID = peer.id;
//         debugPrint('peerID: $peerID');
//       });
//     });
//     connectSocekt();
//     _getUsersMedia(audio, video);

//     //Peerdart copied code
//     peer.on<MediaConnection>("call").listen((call) async {
//       //Handles incoming calls by answering with the local media stream and setting up listeners for the remote stream and call closure.
//       final mediaStream = await navigator.mediaDevices
//           .getUserMedia({"video": true, "audio": true});

//       call.answer(mediaStream);

//       call.on("close").listen((event) {
//         setState(() {
//           inCall = false;
//         });
//       });

//       call.on<MediaStream>("stream").listen((event) {
//         _localRenderer.srcObject = mediaStream;
//         _remoteRenderer.srcObject = event;

//         setState(() {
//           inCall = true;
//         });
//       });
//     });
//     //END
//   }

//   Future<void> initRenderers() async {
//     //Initializes the local and remote RTCVideoRenderer objects used to display video streams.
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

// // 'oc': Updates the online users count.
// // 'connect': Indicates the socket connection is established and joins a room.
// // 'dc': Handles disconnection events.
// // 'other peer': Receives the ID of the other peer.
// // 'user joined': Handles a user joining the room and establishes a connection with them.
//   connectSocekt() {
//     //Connects to the WebSocket server and sets up event listeners for various socket events:
//     debugPrint("Connecting to socket");
//     socket = io.io('https://omegleclone.onrender.com', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//     socket!.connect();
//     socket!.on('oc', (oc) {
//       setState(() {
//         socketStatus = true;
//         debugPrint('online users: $oc');
//         debugPrint('Socket connected');

//         onlineUsers = oc;
//       });
//     });
//     //Submit sent message
//     socket!.on('connect', (data) {
//       setState(() {
//         debugPrint('Socket connected $data');
//         socketStatus = true;
//         // UserConnectionMsg = "Connected ${socket!.id} $peerID";
//       });
//       _getUsersMedia(audio, video);
//       socket!.emit('join', peerID);
//     });
//       socket!.on('chat message', (msg) {
//       setState(() {
//         messages.add(strangerMsg(msg));
//       });
// });
// //done and working
//     socket!.on('dc', (msg) {
//       setState(() {
//         debugPrint('Socket disconnected $msg');
//         _remoteRenderer.srcObject = null;
//         socketStatus = false;
//         joined = false;
//         UserConnectionMsg = "Disconnected";
//       });
//     });

//     //done and working
//     socket!.on('other peer', (pid) {
//       //Listens for the 'other peer' event which provides the peer ID of the other user.
//       setState(() {
//         otherPeerID = pid;
//         debugPrint('otherPeerID: $otherPeerID');
//       });
//     });
//     socket!.on('user joined', (msg) {
//       // Listens for the 'user joined' event which is triggered when another user joins the room.
//       setState(() {
//         socketStatus = true;
//         // otherPeerID = pid;
//         debugPrint('joined1: $msg $peerID');
//         // debugPrint(msg.runtimeType.toString());
//         print(msg[0]);
//         print(msg[1]);
//         print(msg[2]);
//         connect(msg[
//             1]); //Calls the connect function to establish a peer connection with the new user.
//         joined = true;
//         UserConnectionMsg = "Connected";
//       });
//     });
//   }

//   connectToNewUser(pid, stream) {
//     debugPrint('connectToNewUser: $pid Stream: $stream');
//     final call = peer.call(pid, stream);
//     call.on('stream').listen((remoteStream) {
//       _remoteRenderer.srcObject = remoteStream;
//     });
//   }

//   joinRoom() {
//     try {
//       setState(() {
//         waitingOnConnection = true;
//         UserConnectionMsg = "Searching for a user...";
//         joined = false;
//       });

//       socket!.emit('join room', ({peerID, video}));
//       debugPrint('join room: $peerID $video');
//       setState(() {
//         waitingOnConnection = true;
//         joined = false;
//         _remoteRenderer.srcObject = null;
//       });
//       peer.on('call').listen((call) {
//         call.answer(_localRenderer.srcObject);
//         call.on('stream').listen((stream) {
//           setState(() {
//             _remoteRenderer.srcObject = stream;
//             waitingOnConnection = false;
//             joined = true;
//             UserConnectionMsg = "Connected";
//           });
//         });
//       });
//     } catch (e) {
//       debugPrint('join Room: $e');
//     }
//   }

//   _getUsersMedia(bool x, bool y) async {
//     final Map<String, dynamic> mediaConstraints = {'audio': x, 'video': y};
//     try {
//       final MediaStream stream =
//           await navigator.mediaDevices.getUserMedia(mediaConstraints);

//       _localRenderer.srcObject = stream;
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   serverMsg(msg) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       margin: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 255, 255, 255),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         "Server : $msg",
//         style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//       ),
//     );
//   }

//   strangerMsg(msg) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       margin: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         "stranger : $msg",
//         style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
//       ),
//     );
//   }
// void sendMessage() {
//   if (_msgController.text.isNotEmpty) {
//     final msg = _msgController.text;
//     _msgController.clear();
//     setState(() {
//       messages.add(serverMsg(msg));
//     });
//     socket!.emit('chat message', msg);
//   }
// }
//   @override
//   void dispose() {
//     peer.dispose();
//     _msgController.dispose();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     socket!.disconnect();
//     super.dispose();
//   }

//   void connect(String peerid) async {
//     final mediaStream = await navigator.mediaDevices
//         .getUserMedia({"video": true, "audio": true});

//     // final conn = peer.call(_msgController.text, mediaStream);
//     final conn = peer.call(peerid, mediaStream);

//     conn.on("close").listen((event) {
//       setState(() {
//         inCall = false;
//       });
//     });

//     conn.on<MediaStream>("stream").listen((event) {
//       _remoteRenderer.srcObject = event;
//       _localRenderer.srcObject = mediaStream;

//       setState(() {
//         inCall = true;
//       });
//     });

//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     debugPrint('build');
//     return Scaffold(
//       backgroundColor: Colors.black,
//       // extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.arrow_back_ios_rounded,
//             color: Colors.white,
//           ),
//         ),
//       ),

//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             VideoRenderers(),
//             ButtonSection(),
//             NavBar(),
//           ],
//         ),
//       ),
//     );
//   }

//     NavBar() {
//     // var selectedIndex;
//     // var onTap;
//     return Theme(
//       data: Theme.of(context).copyWith(
//         canvasColor:
//             Colors.black, // Set the background color of the BottomNavigationBar
//       ),
//       child: Padding(
//          padding: EdgeInsets.only(right: 20),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.black,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.grey,
//           // currentIndex: selectedIndex,
//           // onTap: onTap,
//           items: [
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(top: 15),
//                 child: CircleAvatar(
//                   radius: 15,
//                   backgroundColor: Colors.transparent,
//                   child: Image.asset(
//                     'assets/images/tinder.png',
//                   ),
//                 ),
//               ),
//               label: '', // Empty label
//             ),
//             BottomNavigationBarItem(
//               icon: const Padding(
//                 padding: EdgeInsets.symmetric(), // Adjust padding as needed
//                 child: Icon(Icons.video_library, size: 30,
//                 color: Colors.white),
//               ),
//               label: '', // Empty label
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(left: 8),
//                 child: Icon(Icons.add, size: 30,
//                  color: Colors.white),

//               ),
//               label: '', // Empty label
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(left: 8),
//                 child: Icon(Icons.videocam, size: 30,
//                  color: Colors.white),
//               ),
//               label: '', // Empty label
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(left: 8),
//                 child: Icon(Icons.person, size: 30,
//                  color: Colors.white),
//               ),
//               label: '', // Empty label
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// //for testing purpose gives the status of user
// // UserJoinStatus() {
// //   return Container(
// //     width: double.infinity,
// //     height: 50,
// //     decoration: const BoxDecoration(
// //       color: Colors.black38,
// //     ),
// //     child: Align(
// //       alignment: Alignment.center,
// //       child: Text(
// //         joined ? 'Stranger Joined' : UserConnectionMsg,
// //         style: TextStyle(
// //           color: joined ? Colors.green : Colors.red,
// //           fontSize: 15,
// //           fontWeight: FontWeight.w700,
// //         ),
// //       ),
// //     ),
// //   );
// // }

//   Row ButtonSection() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         IconButton(
//           onPressed: () {
//             setState(() {
//               video = !video;
//             });
//             _getUsersMedia(audio, video);
//           },
//           icon: Icon(
//             video ? Icons.videocam : Icons.videocam_off,
//             color: video ? Colors.blue : Colors.grey,
//           ),
//         ),
//         Container(
//           height: 40,
//           width: 1,
//           color: Colors.black,
//         ),
//         IconButton(
//           onPressed: () {
//             setState(() {
//               audio = !audio;
//             });
//             _getUsersMedia(audio, video);
//           },
//           icon: Icon(
//             audio ? Icons.mic : Icons.mic_off,
//             color: audio ? Colors.blue : Colors.grey,
//           ),
//         ),
//         Container(
//           height: 40,
//           width: 1,
//           color: Colors.black,
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             await joinRoom();
//           },
//           style: ElevatedButton.styleFrom(
//             elevation: 0,
//             shape: const StadiumBorder(),
//             backgroundColor: Colors.white,
//           ),
//           child: const Text('Search for Partner',
//               style: TextStyle(color: Color.fromARGB(255, 7, 7, 7))),
//         ),
//       ],
//     );
//   }

// SizedBox VideoRenderers() => SizedBox(
//       height: MediaQuery.of(context).size.height * 0.75, // Adjust height as needed
//       child: Column(
//         children: [
//           Flexible(
//             flex: 1,
//             fit: FlexFit.tight,
//             child: Container(
//                 key: const Key('remote'),
//                 margin: const EdgeInsets.all(3),
//                 decoration: const BoxDecoration(
//                   color: Colors.black54,
//                 ),
//                 child: RTCVideoView(
//                   _remoteRenderer,
//                   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                 )),
//           ),
//           Flexible(
//             flex: 1,
//             fit: FlexFit.tight,
//             child: Container(
//                 key: const Key('local'),
//                 margin: const EdgeInsets.all(3),
//                 decoration: const BoxDecoration(
//                   color: Colors.black54,
//                 ),
//                 child: video
//                     ? RTCVideoView(
//                         _localRenderer,
//                         mirror: true,
//                         objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                       )
//                     : const Center(child: Text('No Video'))),
//           ),
//         ],
//       ),
//     );

// }

// // ignore_for_file: unused_import, non_constant_identifier_names, avoid_unnecessary_containers,

import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
// Import the custom bottom navbar

class Omegle extends StatefulWidget {
  const Omegle({Key? key}) : super(key: key);

  @override
  State<Omegle> createState() => _OmegleState();
}

class _OmegleState extends State<Omegle> {
  //Icon for the button change conditionally
  bool video = true;
  bool audio = true;
  bool socketStatus = false;
  String UserConnectionMsg = "Not Connected";
  io.Socket? socket;
  List<Widget> messages = [];

//Peerdart copied code
  final TextEditingController _msgController = TextEditingController();
  final Peer peer = Peer(options: PeerOptions(debug: LogLevel.All));
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool inCall = false;
  String? peerID;
  //END

  String? otherUser;
  MediaStream? theStream;
  String? otherPeerID;

  bool joined = false;
  bool waitingOnConnection = false;
  late bool videoOn;
  int onlineUsers = 0;

  int _selectedIndex = 3; // Added: Default selected index for Omegle page

  @override
  void initState() {
    super.initState();
    initRenderers(); //Initializes the local and remote RTCVideoRenderer objects used to display video streams.
    peer.on("open").listen((id) {
      //Listens for the "open" event to get the unique peer ID when the connection is established.
      setState(() {
        peerID = peer.id;
        debugPrint('peerID: $peerID');
      });
    });
    connectSocekt();
    _getUsersMedia(audio, video);

    //Peerdart copied code
    peer.on<MediaConnection>("call").listen((call) async {
      //Handles incoming calls by answering with the local media stream and setting up listeners for the remote stream and call closure.
      final mediaStream = await navigator.mediaDevices
          .getUserMedia({"video": true, "audio": true});

      call.answer(mediaStream);

      call.on("close").listen((event) {
        setState(() {
          inCall = false;
        });
      });

      call.on<MediaStream>("stream").listen((event) {
        _localRenderer.srcObject = mediaStream;
        _remoteRenderer.srcObject = event;

        setState(() {
          inCall = true;
        });
      });
    });
    //END
  }

  Future<void> initRenderers() async {
    //Initializes the local and remote RTCVideoRenderer objects used to display video streams.
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

// 'oc': Updates the online users count.
// 'connect': Indicates the socket connection is established and joins a room.
// 'dc': Handles disconnection events.
// 'other peer': Receives the ID of the other peer.
// 'user joined': Handles a user joining the room and establishes a connection with them.
  connectSocekt() {
    //Connects to the WebSocket server and sets up event listeners for various socket events:
    debugPrint("Connecting to socket");
    socket = io.io('https://omegleclone.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
    socket!.on('oc', (oc) {
      setState(() {
        socketStatus = true;
        debugPrint('online users: $oc');
        debugPrint('Socket connected');

        onlineUsers = oc;
      });
    });
    //Submit sent message
    socket!.on('connect', (data) {
      setState(() {
        debugPrint('Socket connected $data');
        socketStatus = true;
        // UserConnectionMsg = "Connected ${socket!.id} $peerID";
      });
      _getUsersMedia(audio, video);
      socket!.emit('join', peerID);
    });
    socket!.on('chat message', (msg) {
      setState(() {
        messages.add(strangerMsg(msg));
      });
    });
//done and working
    socket!.on('dc', (msg) {
      setState(() {
        debugPrint('Socket disconnected $msg');
        _remoteRenderer.srcObject = null;
        socketStatus = false;
        joined = false;
        UserConnectionMsg = "Disconnected";
      });
    });

    //done and working
    socket!.on('other peer', (pid) {
      //Listens for the 'other peer' event which provides the peer ID of the other user.
      setState(() {
        otherPeerID = pid;
        debugPrint('otherPeerID: $otherPeerID');
      });
    });
    socket!.on('user joined', (msg) {
      // Listens for the 'user joined' event which is triggered when another user joins the room.
      setState(() {
        socketStatus = true;
        // otherPeerID = pid;
        debugPrint('joined1: $msg $peerID');
        // debugPrint(msg.runtimeType.toString());
        print(msg[0]);
        print(msg[1]);
        print(msg[2]);
        connect(msg[
            1]); //Calls the connect function to establish a peer connection with the new user.
        joined = true;
        UserConnectionMsg = "Connected";
      });
    });
  }

  connectToNewUser(pid, stream) {
    debugPrint('connectToNewUser: $pid Stream: $stream');
    final call = peer.call(pid, stream);
    call.on('stream').listen((remoteStream) {
      _remoteRenderer.srcObject = remoteStream;
    });
  }

  joinRoom() {
    try {
      setState(() {
        waitingOnConnection = true;
        UserConnectionMsg = "Searching for a user...";
        joined = false;
      });

      socket!.emit('join room', ({peerID, video}));
      debugPrint('join room: $peerID $video');
      setState(() {
        waitingOnConnection = true;
        joined = false;
        _remoteRenderer.srcObject = null;
      });
      peer.on('call').listen((call) {
        call.answer(_localRenderer.srcObject);
        call.on('stream').listen((stream) {
          setState(() {
            _remoteRenderer.srcObject = stream;
            waitingOnConnection = false;
            joined = true;
            UserConnectionMsg = "Connected";
          });
        });
      });
    } catch (e) {
      debugPrint('join Room: $e');
    }
  }

  _getUsersMedia(bool x, bool y) async {
    final Map<String, dynamic> mediaConstraints = {'audio': x, 'video': y};
    try {
      final MediaStream stream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);

      _localRenderer.srcObject = stream;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  serverMsg(msg) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "Server : $msg",
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  strangerMsg(msg) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "stranger : $msg",
        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  void sendMessage() {
    if (_msgController.text.isNotEmpty) {
      final msg = _msgController.text;
      _msgController.clear();
      setState(() {
        messages.add(serverMsg(msg));
      });
      socket!.emit('chat message', msg);
    }
  }

  @override
  void dispose() {
    peer.dispose();
    _msgController.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    socket!.disconnect();
    super.dispose();
  }

  void connect(String peerid) async {
    final mediaStream = await navigator.mediaDevices
        .getUserMedia({"video": true, "audio": true});

    // final conn = peer.call(_msgController.text, mediaStream);
    final conn = peer.call(peerid, mediaStream);

    conn.on("close").listen((event) {
      setState(() {
        inCall = false;
      });
    });

    conn.on<MediaStream>("stream").listen((event) {
      _remoteRenderer.srcObject = event;
      _localRenderer.srcObject = mediaStream;

      setState(() {
        inCall = true;
      });
    });

    // });
  }

  // void _onItemTapped(int index) {
  //   // Add navigation logic based on index
  //   setState(() {
  //     _selectedIndex = index;
  //   });

  //   switch (index) {
  //     case 0:
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => Homepage()));
  //       break;
  //     case 1:
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => Homepage()));
  //       break;
  //     case 2:
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => Homepage()));
  //       break;
  //     case 3:
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => Omegle()));
  //       break;
  //     case 4:
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => Homepage()));
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    debugPrint('build');
    return Scaffold(
      backgroundColor: Colors.black,
      // extendBodyBehindAppBar: true,

      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            VideoRenderers(),
            ButtonSection(),
            // UserJoinStatus(),
            // CustomBottomNavBar(
            //   selectedIndex: _selectedIndex,
            //   onItemTapped: _onItemTapped,
            //   onTap: (int) {},
            // ), // Use custom bottom navbar
          ],
        ),
      ),
    );
  }

  // UserJoinStatus() {
  //   return Container(
  //     width: double.infinity,
  //     height: 50,
  //     decoration: const BoxDecoration(
  //       color: Colors.black38,
  //     ),
  //     child: Align(
  //       alignment: Alignment.center,
  //       child: Text(
  //         joined ? 'Stranger Joined' : UserConnectionMsg,
  //         style: TextStyle(
  //           color: joined ? Colors.green : Colors.red,
  //           fontSize: 15,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Row ButtonSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              video = !video;
            });
            _getUsersMedia(audio, video);
          },
          icon: Icon(
            video ? Icons.videocam : Icons.videocam_off,
            color: video ? Colors.blue : Colors.grey,
          ),
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.black,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              audio = !audio;
            });
            _getUsersMedia(audio, video);
          },
          icon: Icon(
            audio ? Icons.mic : Icons.mic_off,
            color: audio ? Colors.blue : Colors.grey,
          ),
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.black,
        ),
        ElevatedButton(
          onPressed: () async {
            await joinRoom();
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: const StadiumBorder(),
            backgroundColor: Colors.white,
          ),
          child: const Text('Search for next Partner',
              style: TextStyle(color: Color.fromARGB(255, 7, 7, 7))),
        ),
      ],
    );
  }

  SizedBox VideoRenderers() => SizedBox(
        height: MediaQuery.of(context).size.height *
            0.85, // Adjust height as needed
        child: Column(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  key: const Key('remote'),
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                  ),
                  child: RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  key: const Key('local'),
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                  ),
                  child: video
                      ? RTCVideoView(
                          _localRenderer,
                          mirror: true,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : const Center(child: Text('No Video'))),
            ),
          ],
        ),
      );
}

// ignore_for_file: unused_import, non_constant_identifier_names, avoid_unnecessary_containers,































// import 'package:flutter/material.dart';
// import 'package:peerdart/peerdart.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;

// class Omegle extends StatefulWidget {
//   const Omegle({Key? key}) : super(key: key);

//   @override
//   State<Omegle> createState() => _OmegleState();
// }

// class _OmegleState extends State<Omegle> {
//   //Icon for the button change conditionally
//   bool video = true;
//   bool audio = true;
//   bool socketStatus = false;
//   String UserConnectionMsg = "Not Connected";
//   io.Socket? socket;
//   List<Widget> messages = [];

// //Peerdart copied code
//   final TextEditingController _msgController = TextEditingController();
//   final Peer peer = Peer(options: PeerOptions(debug: LogLevel.All));
//   final _localRenderer = RTCVideoRenderer();
//   final _remoteRenderer = RTCVideoRenderer();
//   bool inCall = false;
//   String? peerID;
//   //END

//   String? otherUser;
//   MediaStream? theStream;
//   String? otherPeerID;

//   bool joined = false;
//   bool waitingOnConnection = false;
//   late bool videoOn;
//   int onlineUsers = 0;

//   @override
//   void initState() {
//     super.initState();
//     initRenderers(); //Initializes the local and remote RTCVideoRenderer objects used to display video streams.
//     peer.on("open").listen((id) {
//       //Listens for the "open" event to get the unique peer ID when the connection is established.
//       setState(() {
//         peerID = peer.id;
//         debugPrint('peerID: $peerID');
//       });
//     });
//     connectSocekt();
//     _getUsersMedia(audio, video);

//     //Peerdart copied code
//     peer.on<MediaConnection>("call").listen((call) async {
//       //Handles incoming calls by answering with the local media stream and setting up listeners for the remote stream and call closure.
//       final mediaStream = await navigator.mediaDevices
//           .getUserMedia({"video": true, "audio": true});

//       call.answer(mediaStream);

//       call.on("close").listen((event) {
//         setState(() {
//           inCall = false;
//         });
//       });

//       call.on<MediaStream>("stream").listen((event) {
//         _localRenderer.srcObject = mediaStream;
//         _remoteRenderer.srcObject = event;

//         setState(() {
//           inCall = true;
//         });
//       });
//     });
//     //END
//   }

//   Future<void> initRenderers() async {
//     //Initializes the local and remote RTCVideoRenderer objects used to display video streams.
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

// // 'oc': Updates the online users count.
// // 'connect': Indicates the socket connection is established and joins a room.
// // 'dc': Handles disconnection events.
// // 'other peer': Receives the ID of the other peer.
// // 'user joined': Handles a user joining the room and establishes a connection with them.
//   connectSocekt() {
//     //Connects to the WebSocket server and sets up event listeners for various socket events:
//     debugPrint("Connecting to socket");
//     socket = io.io('https://omegleclone.onrender.com', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//     socket!.connect();
//     socket!.on('oc', (oc) {
//       setState(() {
//         socketStatus = true;
//         debugPrint('online users: $oc');
//         debugPrint('Socket connected');

//         onlineUsers = oc;
//       });
//     });
//     //Submit sent message
//     socket!.on('connect', (data) {
//       setState(() {
//         debugPrint('Socket connected $data');
//         socketStatus = true;
//         // UserConnectionMsg = "Connected ${socket!.id} $peerID";
//       });
//       _getUsersMedia(audio, video);
//       socket!.emit('join', peerID);
//     });
//       socket!.on('chat message', (msg) {
//       setState(() {
//         messages.add(strangerMsg(msg));
//       });
// });
// //done and working
//     socket!.on('dc', (msg) {
//       setState(() {
//         debugPrint('Socket disconnected $msg');
//         _remoteRenderer.srcObject = null;
//         socketStatus = false;
//         joined = false;
//         UserConnectionMsg = "Disconnected";
//       });
//     });

//     //done and working
//     socket!.on('other peer', (pid) {
//       //Listens for the 'other peer' event which provides the peer ID of the other user.
//       setState(() {
//         otherPeerID = pid;
//         debugPrint('otherPeerID: $otherPeerID');
//       });
//     });
//     socket!.on('user joined', (msg) {
//       // Listens for the 'user joined' event which is triggered when another user joins the room.
//       setState(() {
//         socketStatus = true;
//         // otherPeerID = pid;
//         debugPrint('joined1: $msg $peerID');
//         // debugPrint(msg.runtimeType.toString());
//         print(msg[0]);
//         print(msg[1]);
//         print(msg[2]);
//         connect(msg[
//             1]); //Calls the connect function to establish a peer connection with the new user.
//         joined = true;
//         UserConnectionMsg = "Connected";
//       });
//     });
//   }

//   connectToNewUser(pid, stream) {
//     debugPrint('connectToNewUser: $pid Stream: $stream');
//     final call = peer.call(pid, stream);
//     call.on('stream').listen((remoteStream) {
//       _remoteRenderer.srcObject = remoteStream;
//     });
//   }

//   joinRoom() {
//     try {
//       setState(() {
//         waitingOnConnection = true;
//         UserConnectionMsg = "Searching for a user...";
//         joined = false;
//       });

//       socket!.emit('join room', ({peerID, video}));
//       debugPrint('join room: $peerID $video');
//       setState(() {
//         waitingOnConnection = true;
//         joined = false;
//         _remoteRenderer.srcObject = null;
//       });
//       peer.on('call').listen((call) {
//         call.answer(_localRenderer.srcObject);
//         call.on('stream').listen((stream) {
//           setState(() {
//             _remoteRenderer.srcObject = stream;
//             waitingOnConnection = false;
//             joined = true;
//             UserConnectionMsg = "Connected";
//           });
//         });
//       });
//     } catch (e) {
//       debugPrint('join Room: $e');
//     }
//   }

//   _getUsersMedia(bool x, bool y) async {
//     final Map<String, dynamic> mediaConstraints = {'audio': x, 'video': y};
//     try {
//       final MediaStream stream =
//           await navigator.mediaDevices.getUserMedia(mediaConstraints);

//       _localRenderer.srcObject = stream;
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   serverMsg(msg) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       margin: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 255, 255, 255),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         "Server : $msg",
//         style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
//       ),
//     );
//   }

//   strangerMsg(msg) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       margin: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         "stranger : $msg",
//         style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
//       ),
//     );
//   }
// void sendMessage() {
//   if (_msgController.text.isNotEmpty) {
//     final msg = _msgController.text;
//     _msgController.clear();
//     setState(() {
//       messages.add(serverMsg(msg));
//     });
//     socket!.emit('chat message', msg);
//   }
// }
//   @override
//   void dispose() {
//     peer.dispose();
//     _msgController.dispose();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     socket!.disconnect();
//     super.dispose();
//   }

//   void connect(String peerid) async {
//     final mediaStream = await navigator.mediaDevices
//         .getUserMedia({"video": true, "audio": true});

//     // final conn = peer.call(_msgController.text, mediaStream);
//     final conn = peer.call(peerid, mediaStream);

//     conn.on("close").listen((event) {
//       setState(() {
//         inCall = false;
//       });
//     });

//     conn.on<MediaStream>("stream").listen((event) {
//       _remoteRenderer.srcObject = event;
//       _localRenderer.srcObject = mediaStream;

//       setState(() {
//         inCall = true;
//       });
//     });

//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     debugPrint('build');
//     return Scaffold(
//       backgroundColor: Colors.black,
//       // extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.arrow_back_ios_rounded,
//             color: Colors.white,
//           ),
//         ),
//       ),

//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             VideoRenderers(),
//             ButtonSection(),
//             // MessageArea(),
//             UserJoinStatus(),
//           ],
//         ),
//       ),
//     );
//   }

//   // MessageArea() {
//   //   return Container(
//   //     height: 50,
//   //     color: const Color.fromARGB(255, 211, 211, 211),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //       children: [
//   //         Expanded(
//   //           child: TextField(
//   //             controller: _msgController,
//   //             decoration: const InputDecoration(
//   //               hintText: 'Enter Messages',
//   //             ),
//   //           ),
//   //         ),
//   //         // IconButton(onPressed: connect, icon: const Icon(Icons.send)),
//   //         // IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
//   //         IconButton(onPressed: sendMessage, icon: const Icon(Icons.send)),
//   //       ],
//   //     ),
//   //   );
//   // }

// //for testing purpose gives the status of user
// UserJoinStatus() {
//   return Container(
//     width: double.infinity,
//     height: 50,
//     decoration: const BoxDecoration(
//       color: Colors.black38,
//     ),
//     child: Align(
//       alignment: Alignment.center,
//       child: Text(
//         joined ? 'Stranger Joined' : UserConnectionMsg,
//         style: TextStyle(
//           color: joined ? Colors.green : Colors.red,
//           fontSize: 15,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     ),
//   );
// }

//   Row ButtonSection() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         IconButton(
//           onPressed: () {
//             setState(() {
//               video = !video;
//             });
//             _getUsersMedia(audio, video);
//           },
//           icon: Icon(
//             video ? Icons.videocam : Icons.videocam_off,
//             color: video ? Colors.blue : Colors.grey,
//           ),
//         ),
//         Container(
//           height: 40,
//           width: 1,
//           color: Colors.black,
//         ),
//         IconButton(
//           onPressed: () {
//             setState(() {
//               audio = !audio;
//             });
//             _getUsersMedia(audio, video);
//           },
//           icon: Icon(
//             audio ? Icons.mic : Icons.mic_off,
//             color: audio ? Colors.blue : Colors.grey,
//           ),
//         ),
//         Container(
//           height: 40,
//           width: 1,
//           color: Colors.black,
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             await joinRoom();
//           },
//           style: ElevatedButton.styleFrom(
//             elevation: 0,
//             shape: const StadiumBorder(),
//             backgroundColor: Colors.white,
//           ),
//           child: const Text('Search for Partner',
//               style: TextStyle(color: Color.fromARGB(255, 7, 7, 7))),
//         ),
//       ],
//     );
//   }

// SizedBox VideoRenderers() => SizedBox(
//       height: MediaQuery.of(context).size.height * 0.7, // Adjust height as needed
//       child: Column(
//         children: [
//           Flexible(
//             flex: 1,
//             fit: FlexFit.tight,
//             child: Container(
//                 key: const Key('remote'),
//                 margin: const EdgeInsets.all(3),
//                 decoration: const BoxDecoration(
//                   color: Colors.black54,
//                 ),
//                 child: RTCVideoView(
//                   _remoteRenderer,
//                   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                 )),
//           ),
//           Flexible(
//             flex: 1,
//             fit: FlexFit.tight,
//             child: Container(
//                 key: const Key('local'),
//                 margin: const EdgeInsets.all(3),
//                 decoration: const BoxDecoration(
//                   color: Colors.black54,
//                 ),
//                 child: video
//                     ? RTCVideoView(
//                         _localRenderer,
//                         mirror: true,
//                         objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                       )
//                     : const Center(child: Text('No Video'))),
//           ),
//         ],
//       ),
//     );

// }
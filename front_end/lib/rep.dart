import 'dart:convert';
import 'package:cs_ia_gym_app/login.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';

class Rep extends StatefulWidget {
  const Rep({super.key});

  @override
  State<Rep> createState() => _RepState();
}

late WebSocketChannel channel;
bool showCamera = false;

final localRenderer = RTCVideoRenderer();
final remoteRenderer = RTCVideoRenderer();
RTCPeerConnection? peerConnection;
MediaStream? localmediaStream;

final pendingRemoteCandidate = <RTCIceCandidate> []; //for incoming ice candidates that come too early
bool remotedescr = false; // a gate for whether or not flutter recieved/applied python's response

class _RepState extends State<Rep> {
  @override
  void initState() {
    super.initState();
    initRenderer();
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.50.172:9001'));
    initCamera().then((_) => startWebRTC());
    print("connected uri");
  } 
  
  Future<void> initRenderer() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  @override
  void dispose() {
    channel.sink.close();
    peerConnection?.close();
    remoteRenderer.dispose();
    localRenderer.dispose();
    localmediaStream?.getTracks().forEach((t) => t.stop());
    super.dispose();
  }

  Future<void> initCamera() async {
    final cameraPermission = await Permission.camera.request();
    if (!cameraPermission.isGranted) {
      return;
    }
    await localRenderer.initialize();
    localmediaStream = await navigator.mediaDevices.getUserMedia({
      'video': {'facingMode': 'user'},
      'audio': false,
    });

    setState(() {
      localRenderer.srcObject = localmediaStream;
      print("local render working");
    });
  }

  Future<void> startWebRTC() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };

    peerConnection =
        await createPeerConnection(config); //creates RTC connection
    
    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        channel.sink.add(jsonEncode({
          'type': 'candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid, // media id (sdpMid = 0, 1, 2 -> audio, video, application)
            'sdpMLineIndex': candidate.sdpMLineIndex, // index of media
          },
        })
        );
      }
    };// trickle ice

    for (var i in localmediaStream!.getTracks()) {
      //getTracks get tracks from localmediaStream (line 47) / i represent each track in stream
      await peerConnection!.addTrack(i, localmediaStream!);
      print("track added");
    } // attach local tracks

    peerConnection!.onTrack = (RTCTrackEvent e) {
      //get video back from python/ RTCTrackEvent: data obj includes (tracks, streams, transceivers)
      if (e.streams.isNotEmpty) {
        setState(() => remoteRenderer.srcObject = e.streams[0]); // connects remote video to your flutter UI
        print("processed video back");
      }
    };

    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    channel.sink.add(jsonEncode({
      'type': 'offer',
      'sdp': offer.sdp,
    }));

    channel.stream.listen((data) async {
      // listens to server's answer and remoteDescription
      final message = jsonDecode(data);
      if (message['type'] == 'answer') {
        final answer = RTCSessionDescription(message['sdp'], 'answer');
        await peerConnection!.setRemoteDescription(answer);

        remotedescr = true;

        for (final c in pendingRemoteCandidate) {
          await peerConnection!.addCandidate(c);
        }
        pendingRemoteCandidate.clear();
      }
   
      else if (message['type'] == 'candidate') {
        final candidate = message['candidate'];
        final ice = RTCIceCandidate(candidate['candidate'] as String, candidate['sdpMid'] as String?, candidate['sdpMLineIndex'] as int?);
        if (remotedescr == true) {
          await peerConnection!.addCandidate(ice);
        }
        else {
          pendingRemoteCandidate.add(ice);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF3A3E42),
        body: Column(
          children: [
            const SizedBox(height: 5),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(4),
              width: 750,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                      colors: [Color(0xFF715DC8), Color(0xFFCAB5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)),
              child: Row(
                children: [
                  Align(child: Image.asset('assets/repup.png')),
                  Flexible(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          "Hi, $userinput",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              fontSize: 27,
                              color: Colors.white),
                        ),
                        const Text(
                          "Let's get your fitness journey started",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white),
                        )
                      ]))
                ],
              ),
            ),
            DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(5),
              color: Color(0xFF715DC8),
              strokeWidth: 2,
              child: localmediaStream != null
                  ? SizedBox(
                      width: 330,
                      height: 265,
                      child: RTCVideoView(
                        remoteRenderer,
                        mirror: true,
                        objectFit: RTCVideoViewObjectFit
                            .RTCVideoViewObjectFitCover, // entire image fit without cropping
                      ),
                    )
                  : Column(children: [
                      Container(
                        width: 330,
                        height: 80,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF715DC8),
                        ),
                        width: 95,
                        height: 55,
                        child: Icon(
                          Icons.photo_camera,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "This is where the image will be \n displayed when workout starts",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                    ]),
            ),
            const SizedBox(
              height: 15,
            ),
            // StreamBuilder(
            //     stream: channel.stream,
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData) {
            //         return Text("");
            //       } else
            //         return Text("");
            //     }),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0xFF3A3E42),
                    minimumSize: const Size(45, 45),
                    side: BorderSide(color: Color(0xFF715DC8), width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                child: const Text(
                  "Select a workout!",
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Colors.white),
                ),
              ),
            ),
            Divider(
              color: Colors.white,
              thickness: 2,
              indent: 10,
              endIndent: 15,
            ),
            const SizedBox(
              height: 35,
            ),
            Row(
              children: [
                const SizedBox(width: 10),
                OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(80, 80),
                        backgroundColor: Color(0xFF3A3E42),
                        side: BorderSide(color: Color(0xFF715DC8), width: 3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Image.asset(
                      'assets/chest.png',
                      width: 60,
                      height: 80,
                      fit: BoxFit.contain,
                    )),
                const SizedBox(width: 10),
                OutlinedButton(
                    onPressed: () {
                      print("bicep");
                    },
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(80, 80),
                        backgroundColor: Color(0xFF3A3E42),
                        side: BorderSide(color: Color(0xFF715DC8), width: 3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Image.asset(
                      'assets/bicep.png',
                      width: 60,
                      height: 80,
                      fit: BoxFit.contain,
                    )),
                const SizedBox(width: 10),
                OutlinedButton(
                    onPressed: () {
                      print("quads");
                    },
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(80, 80),
                        backgroundColor: Color(0xFF3A3E42),
                        side: BorderSide(color: Color(0xFF715DC8), width: 3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Image.asset(
                      'assets/quads.png',
                      width: 60,
                      height: 80,
                      fit: BoxFit.contain,
                    )),
              ],
            )
          ],
        ));
  }
}

import 'dart:convert';
import 'package:cs_ia_gym_app/login.dart';
import 'package:cs_ia_gym_app/rep_main.dart';
import 'package:cs_ia_gym_app/chest_edit.dart';
import 'package:cs_ia_gym_app/chest_edit.dart' show load_template;
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';

class RepChest extends StatefulWidget {
  const RepChest({super.key});

  @override
  State<RepChest> createState() => _RepChestState();
}

late WebSocketChannel channel;
bool showCamera = false;

final localRenderer = RTCVideoRenderer();
final remoteRenderer = RTCVideoRenderer();
RTCPeerConnection? peerConnection;
MediaStream? localmediaStream;

final pendingRemoteCandidate =
    <RTCIceCandidate>[]; //for incoming ice candidates that come too early
bool remotedescr =
    false; // a gate for whether or not flutter recieved/applied python's response

int? reps;
Workout? template;
int currentexcerciseIndex =
    0; // need a new variable to the "excerciseindex" parameter in the listview builder because listbuilder only runs once and hence can't actively switch between excercises/indexes

class _RepChestState extends State<RepChest> {
  @override
  void initState() {
    super.initState();
    initRenderer();
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.50.181:9001'));
    initCamera().then((_) => startWebRTC());
    load_template().then((loaded) {
      if (loaded != null) {
        setState(() {
          template = loaded;
        });
      }
    });
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
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 640},
        'height': {'ideal': 480},
        'frameRate': {'ideal': 15},
      },
      'audio': false,
    });

    setState(() {
      localRenderer.srcObject = localmediaStream; //.srcObject: video source for RTCVideoRenderer
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
            'sdpMid': candidate
                .sdpMid, // media id (sdpMid = 0, 1, 2 -> audio, video, application)
            'sdpMLineIndex': candidate.sdpMLineIndex, // index of media
          },
        }));
      }
    }; // trickle ice

    for (var i in localmediaStream!.getTracks()) {
      //getTracks get tracks from localmediaStream (line 47) / i represent each track in stream
      await peerConnection!.addTrack(i, localmediaStream!);
      print("track added");
    } // attach local tracks

    peerConnection!.onTrack = (RTCTrackEvent e) {
      //get video back from python / RTCTrackEvent: data obj includes (tracks, streams, transceivers)
      if (e.streams.isNotEmpty) {
        setState(() => remoteRenderer.srcObject =
            e.streams[0]); // connects remote video to your flutter UI
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
      } else if (message['type'] == 'candidate') {
        final candidate = message['candidate'];
        final ice = RTCIceCandidate(
            candidate['candidate'] as String,
            candidate['sdpMid'] as String?,
            (candidate['sdpMLineIndex'] as num?)?.toInt());
        if (remotedescr == true) {
          await peerConnection!.addCandidate(ice);
        } else {
          pendingRemoteCandidate.add(ice);
        }
      }

      if (message['type'] == 'rep_count') {
        final reps = message['value'];
        print("recieved reps!");
        print(reps);
      }
      ;
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
            Expanded(
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(5),
                color: const Color(0xFF715DC8),
                strokeWidth: 2,
                child: Center(
                  child: AspectRatio(
                    aspectRatio:
                        640 / 480, // match your actual frame aspect ratio
                    child: RTCVideoView(
                      remoteRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, DateTime.now()); // returns data
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Rep()));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF715DC8),
                    textStyle: TextStyle(fontSize: 15),
                  ),
                  child: Text(
                    "FINISH WORKOUT",
                  )),
            ),
            if (template == null) ...[
              Padding(
                padding: EdgeInsets.all(20),
                child:
                    Text("Loading...", style: TextStyle(color: Colors.white)),
              )
            ] else ...[
              Expanded(
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int excerciseIndex) {
                    final excercise =
                        template!.excercises[currentexcerciseIndex];
                    return Container(
                      margin: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            excercise.excerciseName.toString(),
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text("Set",
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.white)),
                              ),
                              Expanded(
                                child: Text("KG",
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.white)),
                              ),
                              Expanded(
                                child: Text("Reps",
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.white)),
                              ),
                              Expanded(
                                child: Text("V",
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                          ...excercise.sets.asMap().entries.map((entry) {
                            //...adds each row as an individual widget/asMap() converts it to map with key and value/.entries -> Mapentry(idex, value)
                            final setIndex = entry.key + 1;
                            final set = entry.value;

                            return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          "$setIndex",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white),
                                        )),
                                        Expanded(
                                            child: Text(set.weight.toString(),
                                                style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                    color: Colors.white))),
                                        Expanded(
                                            child: Text(
                                          set.reps.toString(),
                                          style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.white),
                                        )),
                                        Expanded(
                                            child: Checkbox(
                                                value: false,
                                                activeColor: Color(0xFF715DC8),
                                                checkColor: Colors.white,
                                                onChanged: null))
                                      ],
                                    ),
                                  ],
                                ));
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (template != null)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          if (currentexcerciseIndex > 0) {
                            setState(() {
                              currentexcerciseIndex -= 1;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.arrow_left_rounded,
                          size: 50,
                          color: Colors.white,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                        onPressed: () {
                          if (currentexcerciseIndex <
                              template!.excercises.length - 1) {
                            setState(() {
                              currentexcerciseIndex += 1;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.arrow_right_rounded,
                          size: 50,
                          color: Colors.white,
                        )),
                  ],
                ),
              )
          ],
        ));
  }
}

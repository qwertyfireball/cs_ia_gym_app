import 'package:dotted_border/dotted_border.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';

class Calorie extends StatefulWidget {
  const Calorie({super.key});

  @override
  State<Calorie> createState() => _CalorieState();
}

class _CalorieState extends State<Calorie> {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  bool cameraInitialized = false;
  int ? salmon_count;

  @override
  void initState() {
    super.initState();
    initcamera();
  }

  Future<void> initcamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    await cameraController.initialize();
    setState(() {
      cameraInitialized = true;
    });
  }

  Future<void> capture_send() async {
    XFile file = await cameraController.takePicture();
    File imageFile = File(file.path);
    await sendToPython(imageFile);
  }

  Future<void> sendToPython(File imagefile) async {
    final url = Uri.parse("http://192.168.50.172:9001/detect"); // parses the python server url
    final request = http.MultipartRequest("POST", url).. files.add(await http.MultipartFile.fromPath("file", imagefile.path));//creates a post request (.. = apply this to the same object) 
    final flutter_response = await request.send(); // sends request (opens socket + upload file + wait python response)
    final python_response = await flutter_response.stream.bytesToString();

    if (flutter_response.statusCode == 200) { //check if python got it, status code = 200 means got it
      print("python got it");
      final decoded = jsonDecode(python_response);
      final obj_count = decoded['salmon_count'];

      setState(() {
        obj_count == int ? salmon_count = obj_count : salmon_count = int.tryParse(obj_count.toString());
      });
    }
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
                padding: const EdgeInsets.all(15),
                width: 750,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                        colors: [Color(0xFF715DC8), Color(0xFFCAB5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: const Text(
                  "Calorie Tracker: 🔥",
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 27,
                      color: Colors.white),
                )),
            Container(
              width: 330,
              height: 200,
              decoration: BoxDecoration(
                  color: Color(0xFF3A3E42),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF715DC8), width: 3)),
              child: Row(
                children: [
                  const Text(
                    " - ⚡ Calories: 566 cal \n - 🍚 Carbs: 33 g \n - 🥩 Protein: 55 g \n - 🧈 Fats : 13 g ",
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                      width: 150,
                      height: 150,
                      child: PieChart(PieChartData(sections: [
                        // 1 fillet of salmon: 290-310 calories, 44g of protein, and 16-25g of fat
                        PieChartSectionData(
                            value: 33,
                            color: Color(0xFFA22CFF),
                            title: "Carbohydrates",
                            titleStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                color: Colors.white)),
                        PieChartSectionData(
                            value: 55,
                            color: Color(0xFF8C52FF),
                            title: "Protein",
                            titleStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                color: Colors.white)),
                        PieChartSectionData(
                            value: 13,
                            color: Color(0xFFD7BFFF),
                            title: "Fats",
                            titleStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                color: Colors.white))
                      ])))
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(5),
                color: Color(0xFF715DC8),
                strokeWidth: 2,
                child: cameraInitialized
                    ? Column(
                        children: [
                          SizedBox(
                            width: 330,
                            height: 250,
                            child: CameraPreview(
                              cameraController,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          ElevatedButton(
                            onPressed: () {
                              capture_send();
                             
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(5, 5),
                            ),
                            child: Icon(
                              Icons.photo_camera,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ],
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
                          "Press the button \n to start tracking",
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
                      ])),
          ],
        ));
  }
}

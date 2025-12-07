import 'package:cs_ia_gym_app/login.dart';
import 'package:cs_ia_gym_app/rep_chest.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class Rep extends StatefulWidget {
  const Rep({super.key});

  @override
  State<Rep> createState() => _RepState();
}

class _RepState extends State<Rep> {
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
              child: Column(children: [
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
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => RepChest()));
                    },
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
                    onPressed: () {},
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
                    onPressed: () {},
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

import 'package:cs_ia_gym_app/chest_edit.dart';
import 'package:flutter/material.dart';

class Template extends StatefulWidget {
  const Template({super.key});

  @override
  State<Template> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF3A3E42),
        body: Column(
          children: [
            Row(
              children: [
                const SizedBox(height: 5),
                Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(15),
                    width: 340,
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                            colors: [Color(0xFF715DC8), Color(0xFFCAB5FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                    child: const Text(
                      "My Workouts: 🏋️‍♀️",
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          fontSize: 27,
                          color: Colors.white),
                    )),
              ],
            ),
            Divider(
              color: Colors.white,
              thickness: 3.5,
              indent: 10,
              endIndent: 15,
            ),
            OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ChestEdit()
                    )
                  );
                },
                style: OutlinedButton.styleFrom(
                    fixedSize: Size(325, 100),
                    backgroundColor: Color(0xFF3A3E42),
                    side: BorderSide(color: Color(0xFF715DC8), width: 3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/chest.png',
                      width: 150,
                      height: 75,
                    ),
                    const SizedBox(width: 50),
                    // const Text(
                    //   "$",
                    //   style: TextStyle(
                    //     fontFamily: 'Roboto',
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w700,
                    //     fontStyle: FontStyle.italic,
                    //     color: Colors.white,
                    //   ),
                    // )
                  ],
                )),
            const SizedBox(
              height: 40,
            ),
            OutlinedButton(
                onPressed: () {
                  
                },
                style: OutlinedButton.styleFrom(
                    fixedSize: Size(325, 100),
                    backgroundColor: Color(0xFF3A3E42),
                    side: BorderSide(color: Color(0xFF715DC8), width: 3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/bicep.png',
                      width: 150,
                      height: 75,
                    ),
                    const SizedBox(width: 50),
                    // const Text(
                    //   "$",
                    //   style: TextStyle(
                    //     fontFamily: 'Roboto',
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w700,
                    //     fontStyle: FontStyle.italic,
                    //     color: Colors.white,
                    //   ),
                    // )
                  ],
                )),
            const SizedBox(
              height: 40,
            ),
            OutlinedButton(
                onPressed: () {
                 
                },
                style: OutlinedButton.styleFrom(
                    fixedSize: Size(325, 100),
                    backgroundColor: Color(0xFF3A3E42),
                    side: BorderSide(color: Color(0xFF715DC8), width: 3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/quads.png',
                      width: 150,
                      height: 75,
                    ),
                    const SizedBox(width: 50),
                    // const Text(
                    //   "$",
                    //   style: TextStyle(
                    //     fontFamily: 'Roboto',
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w700,
                    //     fontStyle: FontStyle.italic,
                    //     color: Colors.white,
                    //   ),
                    // )
                  ],
                )),
          ],
        ));
  }
}
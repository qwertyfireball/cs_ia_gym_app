import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Template extends StatefulWidget {
  const Template({super.key});

  @override
  State<Template> createState() => _TemplateState();
}

  class Sets {
    double ? weight;
    int ? reps;
    Sets({required this.weight, required this.reps});
    Map<String, dynamic> toMap() => {'rep': reps, 'weight': weight};
    factory Sets.fromMap(Map<String, dynamic> m) => Sets((weight: m['weight'] as num).toDouble(), reps: m['weight'] as num).toDouble()
  }

  class Excercise {

  }

  class Workout {

  }

class _TemplateState extends State<Template> {
  Future<void> save_template() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("", )
  }

  Future<void> load_template() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.getString("") ?? {};
  }



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
                  print("edit chest workout");
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
                    const Text(
                      "- Chest Flys x 12 \n- Bench Press x 33 \n- Incline Press x 8",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    )
                  ],
                )),
            const SizedBox(
              height: 40,
            ),
            OutlinedButton(
                onPressed: () {
                  print("edit arm workout");
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
                    const Text(
                      "- Chest Flys x 12 \n- Bench Press x 33 \n- Incline Press x 8",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    )
                  ],
                )),
            const SizedBox(
              height: 40,
            ),
            OutlinedButton(
                onPressed: () {
                  print("edit leg workout");
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
                    const Text(
                      "- Chest Flys x 12 \n- Bench Press x 33 \n- Incline Press x 8",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    )
                  ],
                )),
            const SizedBox(height: 50,),
            OutlinedButton(
                onPressed: () {
                  print('edit a new workout');
                },
                style: OutlinedButton.styleFrom(
                    fixedSize: Size(275, 50),
                    backgroundColor: Color(0xFF3A3E42),
                    side: BorderSide(color: Color(0xFF715DC8), width: 3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25))),
                child: const Text(
                  'Add a new workout!',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ))
          ],
        ));
  }
}

import 'dart:convert';
import 'package:cs_ia_gym_app/page_nav.dart';
import 'package:cs_ia_gym_app/template.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sets {
  double? weight;
  int? reps;

  Sets({required this.weight, required this.reps});
  Map<String, dynamic> toMap() =>
      {'reps': reps, 'weight': weight}; //toMap serialize to Json format
  factory Sets.fromMap(Map<String, dynamic> m) => Sets(
      reps: m['reps'],
      weight: (m['weight'] as num).toDouble()); //deserialize to editable format
}

class Excercise {
  String? excerciseName;
  List<Sets> sets;
  Excercise({required this.excerciseName, required this.sets});

  Map<String, dynamic> toMap() => {
        'excercisename': excerciseName,
        'sets': sets.map((s) => s.toMap()).toList()
      };
  factory Excercise.fromMap(Map<String, dynamic> m) => Excercise(
        excerciseName: m['excercisename'],
        sets: (m['sets'] as List)
            .map((e) => Sets.fromMap(e))
            .toList(), //map m & e, m: map, e: element
      );
}

class Workout {
  String? workoutName;
  List<Excercise> excercises;
  Workout({required this.workoutName, required this.excercises});

  Map<String, dynamic> toMap() => {
        'workoutname': workoutName,
        'excercises': excercises.map((s) => s.toMap()).toList()
      }; //need to turn into map because json doesn't accept lists
  factory Workout.fromMap(Map<String, dynamic> m) => Workout(
      workoutName: m['workoutname'],
      excercises:
          (m['excercises'] as List).map((e) => Excercise.fromMap(e)).toList());
}

class ChestEdit extends StatefulWidget {
  const ChestEdit({super.key});

  @override
  State<ChestEdit> createState() => _ChestEditState();
}

Future<void> save_template(Workout w) async {
  //Workout w here is an parameter (input)
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("workout_Template", jsonEncode(w.toMap()));
}

Future<Workout?> load_template() async {
  // Workout w here is an ouput
  final prefs = await SharedPreferences.getInstance();
  final rawjson = prefs.getString("workout_Template");
  if (rawjson == null) return null;
  return Workout.fromMap(jsonDecode(rawjson));
}

class _ChestEditState extends State<ChestEdit> {
  // Workout ? workout;

  Workout workout = Workout(
    workoutName: "Chest Day",
    excercises: [
      Excercise(
        excerciseName: "Bench Press",
        sets: [
          Sets(weight: 60, reps: 8),
          Sets(weight: 65, reps: 8),
          Sets(weight: 70, reps: 6),
        ],
      ),
      Excercise(
        excerciseName: "Incline Dumbbell Press",
        sets: [
          Sets(weight: 20, reps: 12),
          Sets(weight: 22.5, reps: 10),
          Sets(weight: 25, reps: 8),
        ],
      ),
      Excercise(
        excerciseName: "Chest Fly Machine",
        sets: [
          Sets(weight: 40, reps: 15),
          Sets(weight: 45, reps: 12),
        ],
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    init_template();
  }

  Future<void> init_template() async {
    final loaded = await load_template();
    if (loaded != null) {
      setState(() {
        workout = loaded;
      });
    }
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
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Template()));
                    },
                    color: Colors.white,
                    iconSize: 25,
                    icon: const Icon(Icons.arrow_back)),
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
            workout == null
                ? Text(
                    "No workouts added yet!",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                    itemCount: workout!.excercises.length,
                    itemBuilder: (BuildContext context, int excerciseIndex) {
                      final excercise = workout!.excercises[excerciseIndex];
                      return Container(
                        margin: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: excercise.excerciseName ?? "",
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xFFD7BFFF),
                                      width: 2,
                                    )),
                                disabledBorder: UnderlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  excercise.excerciseName = value;
                                });
                              },
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
                              ],
                            ),
                            ...excercise.sets.asMap().entries.map((entry) {
                              //...adds each row as an individual widget/asMap() converts it to map with key and value/.entries -> Mapentry(idex, value)
                              final setIndex = entry.key;
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
                                              child: TextFormField(
                                            initialValue: set.weight.toString(),
                                            onChanged: (value) {
                                              set.weight =
                                                  double.tryParse(value) ??
                                                      set.weight;
                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: Color(0xFFD7BFFF),
                                                    width: 2,
                                                  )),
                                              disabledBorder:
                                                  UnderlineInputBorder(),
                                            ),
                                          )),
                                          Expanded(
                                              child: TextFormField(
                                            initialValue: set.reps.toString(),
                                            onChanged: (value) {
                                              set.reps = int.tryParse(value) ??
                                                  set.reps;
                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: Color(0xFFD7BFFF),
                                                    width: 2,
                                                  )),
                                              disabledBorder:
                                                  UnderlineInputBorder(),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ],
                                  ));
                            }).toList(),
                            Align(
                              alignment: Alignment.center,
                              child: OutlinedButton(
                                  onPressed: () async {
                                    setState(() {
                                      excercise.sets
                                          .add(Sets(weight: 0, reps: 0));
                                    });
                                    await save_template(workout);
                                  },
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xFFD7BFFF),
                                      shape: const CircleBorder()),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 25,
                                  )),
                            )
                          ],
                        ),
                      );
                    },
                  )),
            const Spacer(),
            TextButton(
                onPressed: () async {
                  setState(() {
                    workout.excercises.add(Excercise(
                        excerciseName: "New Excercise",
                        sets: [Sets(weight: 0, reps: 0)]));
                  });
                  await save_template(workout);
                },
                style: TextButton.styleFrom(),
                child: Text("ADD EXCERCISE")),
            OutlinedButton(
                onPressed: () async {
                  setState(() {
                    if (workout != null) save_template(workout!);
                  });
                },
                style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0xFFD7BFFF)),
                child: Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ));
  }
}

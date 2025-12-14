import 'package:cs_ia_gym_app/rep_chest.dart';
import 'package:cs_ia_gym_app/rep_main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

  int frequency = 0;
  List<DateTime> workout_history = [];
  Map <String, int> workout_by_month = {};
  DateTime ? now;
  int ? month;


class _HistoryState extends State<History> {
  @override
  void initState() {
    super.initState();
    load_history();
    // .then((_) {build_by_month();});
     WidgetsBinding.instance.addPostFrameCallback((_) async {
        now = await Navigator.push<DateTime>(context, MaterialPageRoute(builder: (_) => RepChest()));
        setState(() {
        if (now != null) {
          workout_history.add(now!);
          // build_by_month();
        }
        });
        await store_history();
     });
  }

  Future<void> store_history() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> to_string = workout_history
        .map((i) => i.toIso8601String())
        .toList(); //.map runs through the list and applies a function on each element, =>: returns an expression
    await prefs.setStringList('history', to_string);
  }

  Future<void> load_history() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> get_history = prefs.getStringList('history') ?? [];
    setState(() {
      workout_history = get_history.map((i) => DateTime.parse(i)).toList();
    });
  }

  // Future<void> build_by_month() async {
  //   workout_by_month.clear(); // prevents double counting -> essentially rebuilds
  //   for (final dateTime in workout_history) {
  //     final month = DateFormat('MM').format(dateTime);
  //     workout_by_month[month] = (workout_by_month[month] ?? 0) + 1; // increments month count by 1
  //   }
  // }

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
                      "Workout History: ⏱️",
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          fontSize: 27,
                          color: Colors.white),
                    )),
              ],
            ),
            // List<BarChartGroupData> buildBargroups {
              
            // }
            Expanded(
              child: ListView.builder(
              itemCount: workout_history.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(12),
                  elevation: 4,
                  color: Color(0xFF9680DF),
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          FontAwesomeIcons.dumbbell,
                          size: 20,
                          color: Colors.black,
                        )),
                    title: Text(
                      DateFormat('MMM d, yyyy hh:mm a')
                          .format(workout_history[index]),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    // subtitle: ,
                    trailing: const Text(
                      "back + tricep",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ),
                );
              },
            ))
          ],
        ));
  }
}

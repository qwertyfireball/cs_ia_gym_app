import 'package:cs_ia_gym_app/page_nav.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Repup'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isloggedin = false;

  @override
  void initState() {
    super.initState();
    username_detection();
  }

  Future<void> username_detection() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    setState(() {
      if (username != null && username.isNotEmpty) {
        print("log is true");
        isloggedin = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isloggedin == true) {
      return const PageNav();
    } else {
      return Login();
    }
  }
}

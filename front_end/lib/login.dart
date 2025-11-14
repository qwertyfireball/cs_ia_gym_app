import 'package:cs_ia_gym_app/page_nav.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

String ? userinput;

class _LoginState extends State<Login> {
  final TextEditingController _controller = TextEditingController();

  Future<void> enter_user_name() async {
    final prefs = await SharedPreferences.getInstance();
    userinput = _controller.text;
    await prefs.setString('username', userinput!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF715DC8), Color(0xFFCAB5FF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Image.asset('assets/repup.png')),
                const SizedBox(height: 50),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: "What should we call you?",
                        hintStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.3))),
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                ElevatedButton(
                    onPressed: () async {
                      await enter_user_name();
                      if (_controller.text.trim().isEmpty) {
                        return;
                      }
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PageNav()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3A3E42),
                        minimumSize: const Size(300, 45),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: const Text(
                      "Start Now!",
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white),
                    ))
              ],
            ),
          )),
    );
  }
}

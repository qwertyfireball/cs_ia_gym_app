import 'rep.dart';
import 'calorie.dart';
import 'history.dart';
import 'template.dart';

import 'package:flutter/material.dart';

class PageNav extends StatefulWidget {
  const PageNav({super.key});

  @override
  State<PageNav> createState() => _PageNavState();
}

class _PageNavState extends State<PageNav> {
  final List<Widget> _pages = [
    const Rep(),
    const Calorie(),
    const Template(),
    const History(),
  ];

  int _selected_index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222222),
      body: _pages[_selected_index],
      bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Color(0xFFD7BFFF),
          ),
          child: NavigationBar(
              backgroundColor: Color(0xFF9680DF),
              animationDuration: const Duration(seconds: 1),
              selectedIndex: _selected_index,
              onDestinationSelected: (index) {
                setState(() {
                  _selected_index = index;
                });
              },
              destinations: _navitems)),
    );
  }
}

const _navitems = [
  NavigationDestination(
    icon: Icon(Icons.fitness_center_outlined),
    selectedIcon: Icon(Icons.fitness_center_rounded),
    label: 'Reps',
  ),
  NavigationDestination(
    icon: Icon(Icons.restaurant_outlined),
    selectedIcon: Icon(Icons.restaurant_rounded),
    label: 'Calories',
  ),
  NavigationDestination(
    icon: Icon(Icons.article_outlined),
    selectedIcon: Icon(Icons.article_rounded),
    label: 'Template',
  ),
  NavigationDestination(
    icon: Icon(Icons.history_outlined),
    selectedIcon: Icon(Icons.history_rounded),
    label: 'History',
  ),
];

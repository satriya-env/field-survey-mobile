import 'package:azhmobile/screens/dashboard/page/dashboard.dart';
import 'package:azhmobile/screens/dashboard/page/profil.dart';
import 'package:azhmobile/screens/dashboard/page/survey.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  // Daftar tampilan halaman untuk tiap-tiap tab
  final List<Widget> _pages = const [
    Dashboard(),
    SurveyPage(),
    Profil()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color.fromARGB(255, 0, 150, 10),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
            activeIcon: Icon(Icons.dashboard_rounded, color: Color.fromARGB(255, 0, 150, 10)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Survey',
            activeIcon: Icon(Icons.assignment_rounded, color: Color.fromARGB(255, 0, 150, 10)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
            activeIcon: Icon(Icons.person_rounded, color: Color.fromARGB(255, 0, 150, 10)),
          ),
        ],
      ),
    );
  }
}
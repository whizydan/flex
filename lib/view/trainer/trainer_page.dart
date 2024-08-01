import 'package:flutter/material.dart';
import 'trainer_manage_routines.dart';
import 'view_analysis.dart';

class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

  @override
  State<TrainerPage> createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ManageRoutinesPage(),
    const ViewAnalysisPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Manage Routines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'View Analysis',
          ),
        ],
      ),
    );
  }
}

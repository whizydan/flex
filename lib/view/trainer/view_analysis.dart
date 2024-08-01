import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ViewAnalysisPage extends StatefulWidget {
  const ViewAnalysisPage({super.key});

  @override
  State<ViewAnalysisPage> createState() => _ViewAnalysisPageState();
}

class _ViewAnalysisPageState extends State<ViewAnalysisPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int totalRoutines = 0;
  double averageDuration = 0.0;
  double averageCalories = 0.0;
  Map<String, int> difficultyDistribution = {
    'beginner': 0,
    'intermediate': 0,
    'advanced': 0,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalysisData();
  }

  Future<void> _fetchAnalysisData() async {
    try {
      DataSnapshot snapshot = await _database.child('routines').get();
      if (snapshot.exists) {
        int totalDuration = 0;
        int totalCalories = 0;
        int routineCount = 0;
        Map<String, int> difficultyCount = {
          'beginner': 0,
          'intermediate': 0,
          'advanced': 0,
        };

        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Map<dynamic, dynamic> routine = value['info'] as Map<dynamic, dynamic>;
          routineCount++;
          totalDuration += (routine['duration'] ?? 0) as int;
          totalCalories += (routine['calories'] ?? 0) as int;
          String difficulty = routine['difficulty'] ?? 'beginner';
          if (difficultyCount.containsKey(difficulty)) {
            difficultyCount[difficulty] = difficultyCount[difficulty]! + 1;
          } else {
            difficultyCount[difficulty] = 1;
          }
        });

        setState(() {
          totalRoutines = routineCount;
          averageDuration = routineCount > 0 ? totalDuration / routineCount : 0;
          averageCalories = routineCount > 0 ? totalCalories / routineCount : 0;
          difficultyDistribution = difficultyCount;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching analysis data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Analysis'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('Total Routines'),
                trailing: Text(totalRoutines.toString()),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Average Duration (minutes)'),
                trailing: Text(averageDuration.toStringAsFixed(2)),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Average Calories Burned'),
                trailing: Text(averageCalories.toStringAsFixed(2)),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Difficulty Distribution'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: difficultyDistribution.entries
                      .map((entry) => Text(
                      '${entry.key}: ${entry.value} (${(entry.value / totalRoutines * 100).toStringAsFixed(1)}%)'))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

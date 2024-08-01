import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ManageRoutinesPage extends StatefulWidget {
  const ManageRoutinesPage({super.key});

  @override
  State<ManageRoutinesPage> createState() => _ManageRoutinesPageState();
}

class _ManageRoutinesPageState extends State<ManageRoutinesPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('routines');
  Map<String, Map<String, dynamic>> routines = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutines();
  }

  Future<void> _fetchRoutines() async {
    try {
      DataSnapshot snapshot = await _database.get();
      if (snapshot.exists) {
        Map<String, Map<String, dynamic>> fetchedRoutines = {};
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          fetchedRoutines[key as String] = (value as Map<dynamic, dynamic>)
              .map((innerKey, innerValue) => MapEntry(innerKey as String, innerValue));
        });
        setState(() {
          routines = fetchedRoutines;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching routines: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleApproval(String routineKey, bool isApproved) async {
    try {
      await _database.child('$routineKey/info').update({
        'approved': isApproved,
      });
      _fetchRoutines();
    } catch (e) {
      print("Error updating approval status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routines'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : routines.isEmpty
          ? const Center(child: Text('No routines found'))
          : ListView.builder(
        itemCount: routines.keys.length,
        itemBuilder: (context, index) {
          String key = routines.keys.elementAt(index);
          Map<String, dynamic> routineInfo = routines[key]?['info'] ?? {};
          bool isApproved = routineInfo['approved'] ?? false;
          return ListTile(
            title: Text(key),  // Using the key as the title
            subtitle: Text(routineInfo['difficulty'] ?? 'No Description'),
            trailing: Switch(
              value: isApproved,
              onChanged: (value) {
                _toggleApproval(key, value);
              },
            ),
          );
        },
      ),
    );
  }
}

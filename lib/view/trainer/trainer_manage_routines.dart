import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ManageRoutinesPage extends StatefulWidget {
  const ManageRoutinesPage({super.key});

  @override
  State<ManageRoutinesPage> createState() => _ManageRoutinesPageState();
}

class _ManageRoutinesPageState extends State<ManageRoutinesPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, Map<String, dynamic>> routines = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutines();
  }

  Future<void> _fetchRoutines() async {
    try {
      DataSnapshot snapshot = await _database.child('routines').get();
      if (snapshot.exists) {
        Map<String, Map<String, dynamic>> fetchedRoutines = {};
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          fetchedRoutines[key as String] = (value as Map<dynamic, dynamic>)
              .map((innerKey, innerValue) =>
              MapEntry(innerKey as String, innerValue));
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

  Future<void> _deleteRoutine(String routineKey) async {
    try {
      await _database.child('routines/$routineKey').remove();
      _fetchRoutines();
    } catch (e) {
      print("Error deleting routine: $e");
    }
  }

  void _addOrUpdateRoutine({String? routineKey, Map<String, dynamic>? routineData}) {
    final TextEditingController titleController = TextEditingController(
        text: routineData != null ? routineData['title'] : '');
    final TextEditingController descriptionController = TextEditingController(
        text: routineData != null ? routineData['desc'] : '');
    final TextEditingController caloriesController = TextEditingController(
        text: routineData != null ? routineData['calories'].toString() : '');
    final TextEditingController difficultyController = TextEditingController(
        text: routineData != null ? routineData['difficulty'] : '');
    final TextEditingController durationController = TextEditingController(
        text: routineData != null ? routineData['duration'].toString() : '');
    final TextEditingController exerciseController = TextEditingController(
        text: routineData != null ? routineData['exercise'].toString() : '');
    final TextEditingController imageController = TextEditingController(
        text: routineData != null ? routineData['image'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(routineKey == null ? 'Add Routine' : 'Update Routine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: difficultyController,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: exerciseController,
                  decoration: const InputDecoration(labelText: 'Exercise'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (routineKey == null) {
                    // Add routine
                    String newRoutineKey = _database.child('routines').push().key!;
                    await _database.child('routines/$newRoutineKey/info').set({
                      'title': titleController.text,
                      'desc': descriptionController.text,
                      'calories': int.parse(caloriesController.text),
                      'difficulty': difficultyController.text,
                      'duration': int.parse(durationController.text),
                      'exercise': int.parse(exerciseController.text),
                      'image': imageController.text,
                      'approved': false,
                    });
                  } else {
                    // Update routine
                    await _database.child('routines/$routineKey/info').update({
                      'title': titleController.text,
                      'desc': descriptionController.text,
                      'calories': int.parse(caloriesController.text),
                      'difficulty': difficultyController.text,
                      'duration': int.parse(durationController.text),
                      'exercise': int.parse(exerciseController.text),
                      'image': imageController.text,
                    });
                  }
                  _fetchRoutines();
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error adding/updating routine: $e");
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
          return ListTile(
            title: Text(key),  // Use the key as the title
            subtitle: Text(routineInfo['difficulty'] ?? 'No Description'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _addOrUpdateRoutine(
                        routineKey: key, routineData: routineInfo);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteRoutine(key);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrUpdateRoutine();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

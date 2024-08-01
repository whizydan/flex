import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('users');
  Map<String, Map<String, dynamic>> users = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      DataSnapshot snapshot = await _database.get();
      if (snapshot.exists) {
        Map<String, Map<String, dynamic>> fetchedUsers = {};
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          fetchedUsers[key as String] = (value as Map<dynamic, dynamic>)
              .map((innerKey, innerValue) =>
              MapEntry(innerKey as String, innerValue));
        });
        setState(() {
          users = fetchedUsers;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await _database.child(userId).remove();
      _fetchUsers();
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('No users found'))
          : ListView.builder(
        itemCount: users.keys.length,
        itemBuilder: (context, index) {
          String key = users.keys.elementAt(index);
          Map<String, dynamic> userInfo = users[key] ?? {};
          return ListTile(
            title: Text(userInfo['firstName'] ?? 'No Name'),
            subtitle: Text(userInfo['email'] ?? 'No Email'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteUser(key);
              },
            ),
          );
        },
      ),
    );
  }
}

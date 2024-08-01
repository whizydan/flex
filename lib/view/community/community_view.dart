import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _database = FirebaseDatabase.instance.reference();
  final _auth = FirebaseAuth.instance;
  final _messageController = TextEditingController();
  late String _userId;

  @override
  void initState() {
    super.initState();
    _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    UserCredential userCredential = await _auth.signInAnonymously();
    setState(() {
      _userId = userCredential.user!.uid;
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = {
        'time': DateTime.now().millisecondsSinceEpoch,
        'userId': _userId,
        'message': _messageController.text,
      };
      _database.child('chat').push().set(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _database.child('chat').orderByChild('time').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return Center(child: CircularProgressIndicator());
                }
                Map<dynamic, dynamic> data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>;
                List messages = data.values.toList();
                messages.sort((a, b) => a['time'].compareTo(b['time']));

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]['message']),
                      subtitle: Text(messages[index]['userId']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

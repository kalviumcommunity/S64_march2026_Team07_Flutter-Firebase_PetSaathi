import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestore = FirestoreService();
  final AuthService auth = AuthService();
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addNote() {
    String text = controller.text.trim();

    if (text.isEmpty) {
      print("Empty input ❌");
      return;
    }

    print("Sending: $text"); // 🔥 DEBUG

    firestore.addNote(text);

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 🔹 Input Section
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Enter note",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: addNote,
                )
              ],
            ),
          ),

          // 🔹 Notes List
          Expanded(
            child: StreamBuilder(
              stream: firestore.getNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No notes yet 📝"));
                }

                var docs = snapshot.data!.docs;

                return ListView(
                  children: docs.map((doc) {
                    return ListTile(
                      title: Text(doc['text']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          print("Deleting: ${doc.id}"); // DEBUG
                          firestore.deleteNote(doc.id);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
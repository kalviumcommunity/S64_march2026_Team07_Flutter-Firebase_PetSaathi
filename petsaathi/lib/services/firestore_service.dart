import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // CREATE
  

  // READ (real-time)
  Stream<QuerySnapshot> getNotes() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // UPDATE
  Future<void> updateNote(String id, String newText) async {
    await notes.doc(id).update({
      'text': newText,
    });
  }

  // DELETE
  Future<void> deleteNote(String id) async {
    await notes.doc(id).delete();
  }

  Future<void> addNote(String text) async {
  try {
    await notes.add({
      'text': text,
      'timestamp': Timestamp.now(),
    });
    debugPrint('Note added');
  } catch (e) {
    debugPrint('Error: $e');
  }
}
  
}
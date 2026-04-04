import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_log_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logActivity({
    required String userId,
    required String title,
    required String subtitle,
    required String iconType,
  }) async {
    await _firestore.collection('activity_logs').add({
      'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'iconType': iconType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ActivityLog>> watchUserActivity(String userId) {
    return _firestore
        .collection('activity_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ActivityLog.fromMap(doc.id, doc.data())).toList());
  }
}

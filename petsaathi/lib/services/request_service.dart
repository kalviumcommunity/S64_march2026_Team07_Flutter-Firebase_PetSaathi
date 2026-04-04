import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/walk_request_model.dart';
import 'activity_service.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ActivityService _activityService = ActivityService();

  Future<void> createRequest(WalkRequest request) async {
    final docRef = _firestore.collection('requests').doc();
    final newRequest = WalkRequest(
      id: docRef.id,
      petId: request.petId,
      petName: request.petName,
      ownerId: request.ownerId,
      ownerName: request.ownerName,
      status: 'pending',
      scheduledAt: request.scheduledAt,
      amount: request.amount,
      location: request.location,
      tags: request.tags,
      imageUrl: request.imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(newRequest.toMap());
    
    await _activityService.logActivity(
      userId: request.ownerId,
      title: 'Walk Requested',
      subtitle: 'For ${request.petName}',
      iconType: 'pending',
    );
  }

  Future<void> updateRequestStatus(String requestId, String status, {String? walkerId, String? walkerName}) async {
    final updates = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (walkerId != null) updates['walkerId'] = walkerId;
    if (walkerName != null) updates['walkerName'] = walkerName;

    await _firestore.collection('requests').doc(requestId).update(updates);
    
    final doc = await _firestore.collection('requests').doc(requestId).get();
    final request = WalkRequest.fromMap(doc.id, doc.data()!);

    await _activityService.logActivity(
      userId: request.ownerId,
      title: 'Walk ${status[0].toUpperCase()}${status.substring(1)}',
      subtitle: 'For ${request.petName}${walkerName != null ? ' by $walkerName' : ''}',
      iconType: _iconTypeFromStatus(status),
    );

    if (walkerId != null) {
      await _activityService.logActivity(
        userId: walkerId,
        title: 'Walk ${status[0].toUpperCase()}${status.substring(1)}',
        subtitle: 'For ${request.petName}',
        iconType: _iconTypeFromStatus(status),
      );
    }
  }

  String _iconTypeFromStatus(String status) {
    if (status == 'completed') return 'done';
    if (status == 'accepted') return 'schedule';
    if (status == 'rejected' || status == 'cancelled') return 'cancel';
    return 'pending';
  }

  Stream<List<WalkRequest>> watchOwnerRequests(String ownerId) {
    return _firestore
        .collection('requests')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => WalkRequest.fromMap(doc.id, doc.data())).toList());
  }

  Stream<List<WalkRequest>> watchNearbyRequests() {
    return _firestore
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => WalkRequest.fromMap(doc.id, doc.data())).toList());
  }

  Stream<List<WalkRequest>> watchWalkerJobs(String walkerId) {
    return _firestore
        .collection('requests')
        .where('walkerId', isEqualTo: walkerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => WalkRequest.fromMap(doc.id, doc.data())).toList());
  }
}

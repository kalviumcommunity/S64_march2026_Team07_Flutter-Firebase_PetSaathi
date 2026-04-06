import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/walk_request_model.dart';
import 'activity_service.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ActivityService _activityService = ActivityService();
  static const Duration _defaultTtl = Duration(minutes: 15);

  String _buildRequestKey({
    required String ownerId,
    required String petId,
    required DateTime scheduledAt,
    String? targetWalkerId,
  }) {
    final minuteSlot = scheduledAt.millisecondsSinceEpoch ~/ 60000;
    return '$ownerId|$petId|$minuteSlot|${targetWalkerId ?? 'broadcast'}';
  }

  Future<String> createRequest(WalkRequest request) async {
    final requestKey = request.requestKey ??
        _buildRequestKey(
          ownerId: request.ownerId,
          petId: request.petId,
          scheduledAt: request.scheduledAt,
          targetWalkerId: request.targetWalkerId,
        );

    final existing = await _firestore
        .collection('requests')
        .where('requestKey', isEqualTo: requestKey)
        .where('status', whereIn: ['pending', 'accepted', 'in-progress'])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw StateError('A similar request is already active.');
    }

    final docRef = _firestore.collection('requests').doc();
    final newRequest = WalkRequest(
      id: docRef.id,
      petId: request.petId,
      petName: request.petName,
      ownerId: request.ownerId,
      ownerName: request.ownerName,
      targetWalkerId: request.targetWalkerId,
      status: 'pending',
      scheduledAt: request.scheduledAt,
      amount: request.amount,
      location: request.location,
      requestNote: request.requestNote,
      tags: request.tags,
      rejectedByWalkerIds: const [],
      requestKey: requestKey,
      expiresAt: DateTime.now().add(_defaultTtl),
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

    return docRef.id;
  }

  Future<bool> updateRequestStatus(String requestId, String status, {String? walkerId, String? walkerName}) async {
    final docRef = _firestore.collection('requests').doc(requestId);

    if (status == 'accepted' && walkerId != null) {
      final accepted = await _firestore.runTransaction<bool>((txn) async {
        final snapshot = await txn.get(docRef);
        final data = snapshot.data();
        if (data == null) return false;

        final currentStatus = data['status'] ?? 'pending';
        final assignedWalkerId = data['walkerId'];
        final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
        final alreadyExpired = expiresAt != null && expiresAt.isBefore(DateTime.now());

        if (alreadyExpired || currentStatus != 'pending' || assignedWalkerId != null) {
          return false;
        }

        txn.update(docRef, {
          'status': 'accepted',
          'walkerId': walkerId,
          'walkerName': walkerName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      });

      if (!accepted) {
        return false;
      }
    } else if (status == 'rejected' && walkerId != null) {
      await _firestore.runTransaction((txn) async {
        final snapshot = await txn.get(docRef);
        final data = snapshot.data();
        if (data == null) return;

        final currentStatus = data['status'] ?? 'pending';
        if (currentStatus != 'pending') return;

        txn.update(docRef, {
          'rejectedByWalkerIds': FieldValue.arrayUnion([walkerId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      await _activityService.logActivity(
        userId: walkerId,
        title: 'Request Dismissed',
        subtitle: 'You dismissed a walk request.',
        iconType: 'cancel',
      );
      return true;
    } else {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (walkerId != null) updates['walkerId'] = walkerId;
      if (walkerName != null) updates['walkerName'] = walkerName;
      await docRef.update(updates);
    }

    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) {
      return false;
    }
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

    return true;
  }

  String _iconTypeFromStatus(String status) {
    if (status == 'completed') return 'done';
    if (status == 'accepted') return 'schedule';
    if (status == 'rejected' || status == 'cancelled' || status == 'expired') return 'cancel';
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

  Stream<List<WalkRequest>> watchNearbyRequests({String? walkerId}) {
    return _firestore
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => WalkRequest.fromMap(doc.id, doc.data()))
            .where((request) {
              final canSeeBroadcast = request.targetWalkerId == null;
              final canSeeTargeted = walkerId != null && request.targetWalkerId == walkerId;
              final notRejectedByMe = walkerId == null || !request.rejectedByWalkerIds.contains(walkerId);
              final notExpired = request.status != 'expired';
              return (canSeeBroadcast || canSeeTargeted) && notRejectedByMe && notExpired;
            })
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  }

  Stream<List<WalkRequest>> watchWalkerJobs(String walkerId) {
    return _firestore
        .collection('requests')
        .where('walkerId', isEqualTo: walkerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => WalkRequest.fromMap(doc.id, doc.data())).toList());
  }

  Stream<WalkRequest?> watchRequestById(String requestId) {
    return _firestore.collection('requests').doc(requestId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return WalkRequest.fromMap(doc.id, data);
    });
  }

  Stream<WalkRequest?> watchOwnerActiveRequest(String ownerId) {
    return watchOwnerRequests(ownerId).map((requests) {
      final active = requests.where((request) =>
          request.status == 'pending' || request.status == 'accepted' || request.status == 'in-progress');
      if (active.isEmpty) {
        return null;
      }
      return active.first;
    });
  }

  Stream<WalkRequest?> watchWalkerActiveJob(String walkerId) {
    return watchWalkerJobs(walkerId).map((requests) {
      final active = requests.where((request) => request.status == 'accepted' || request.status == 'in-progress');
      if (active.isEmpty) {
        return null;
      }
      return active.first;
    });
  }

  Stream<List<WalkRequest>> watchWalkerCompletedJobsToday(String walkerId) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _firestore
        .collection('requests')
        .where('walkerId', isEqualTo: walkerId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snap) {
          final requests = snap.docs.map((doc) => WalkRequest.fromMap(doc.id, doc.data())).toList();
          return requests.where((r) => 
            r.updatedAt.year == todayStart.year && 
            r.updatedAt.month == todayStart.month && 
            r.updatedAt.day == todayStart.day
          ).toList();
        });
  }
}

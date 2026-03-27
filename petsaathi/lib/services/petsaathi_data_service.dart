import 'package:cloud_firestore/cloud_firestore.dart';

class PetSaathiDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPetProfile({
    required String ownerId,
    required CreatePetProfileInput input,
  }) async {
    await _firestore.collection('pets').add({
      'ownerId': ownerId,
      'name': input.name,
      'petType': input.petType,
      'ageGroup': input.ageGroup,
      'notes': input.notes,
      'statusText': 'Profile created. Ready for first booking',
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePetProfile({
    required String petId,
    required CreatePetProfileInput input,
  }) async {
    await _firestore.collection('pets').doc(petId).update({
      'name': input.name,
      'petType': input.petType,
      'ageGroup': input.ageGroup,
      'notes': input.notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePetProfile(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
  }

  Future<PetDetail?> getPetDetail(String petId) async {
    final doc = await _firestore.collection('pets').doc(petId).get();
    if (!doc.exists) return null;
    return PetDetail.fromMap(petId, doc.data()!);
  }

  Stream<List<PetSummary>> watchOwnerPets(String ownerId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PetSummary.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Stream<List<ActivityEvent>> watchRecentOwnerActivity(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('updatedAt', descending: true)
        .limit(12)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ActivityEvent.fromBooking(doc.id, doc.data()))
              .toList(growable: false),
        );
  }
}

class PetSummary {
  final String id;
  final String name;
  final String statusText;
  final String imageUrl;

  const PetSummary({
    required this.id,
    required this.name,
    required this.statusText,
    required this.imageUrl,
  });

  factory PetSummary.fromMap(String id, Map<String, dynamic> map) {
    return PetSummary(
      id: id,
      name: (map['name'] as String?) ?? 'Pet',
      statusText: (map['statusText'] as String?) ?? 'Ready for a new walk',
      imageUrl: (map['photoUrl'] as String?) ?? '',
    );
  }
}

class ActivityEvent {
  final String id;
  final String title;
  final String subtitle;
  final String iconType;

  const ActivityEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconType,
  });

  factory ActivityEvent.fromBooking(String id, Map<String, dynamic> map) {
    final status = (map['status'] as String?) ?? 'pending';
    final serviceType = (map['serviceType'] as String?) ?? 'Walk';
    final walkerName = (map['walkerName'] as String?) ?? 'your walker';
    final updatedAt = map['updatedAt'];
    final subtitle = _formatTimestamp(updatedAt);

    return ActivityEvent(
      id: id,
      title: '$serviceType $status by $walkerName',
      subtitle: subtitle,
      iconType: _iconTypeFromStatus(status),
    );
  }

  static String _formatTimestamp(dynamic raw) {
    if (raw is! Timestamp) return 'No recent timestamp';
    final date = raw.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _iconTypeFromStatus(String status) {
    if (status == 'completed') return 'done';
    if (status == 'accepted') return 'schedule';
    if (status == 'cancelled') return 'cancel';
    return 'pending';
  }
}

class CreatePetProfileInput {
  final String name;
  final String petType;
  final String ageGroup;
  final String notes;

  const CreatePetProfileInput({
    required this.name,
    required this.petType,
    required this.ageGroup,
    required this.notes,
  });
}

class PetDetail {
  final String id;
  final String ownerId;
  final String name;
  final String petType;
  final String ageGroup;
  final String notes;
  final String statusText;
  final String photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PetDetail({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.petType,
    required this.ageGroup,
    required this.notes,
    required this.statusText,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PetDetail.fromMap(String id, Map<String, dynamic> map) {
    return PetDetail(
      id: id,
      ownerId: (map['ownerId'] as String?) ?? '',
      name: (map['name'] as String?) ?? 'Pet',
      petType: (map['petType'] as String?) ?? 'Dog',
      ageGroup: (map['ageGroup'] as String?) ?? 'Adult',
      notes: (map['notes'] as String?) ?? '',
      statusText: (map['statusText'] as String?) ?? 'Ready for a new walk',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

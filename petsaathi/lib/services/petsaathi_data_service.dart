import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PetSaathiDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Pet Profile Methods
  Future<void> createPetProfile({
    required String ownerId,
    required CreatePetProfileInput input,
  }) async {
    await _firestore.collection('pets').add({
      'ownerId': ownerId,
      'name': input.name,
      'petType': input.petType,
      'breed': input.breed,
      'ageGroup': input.ageGroup,
      'description': input.description,
      'thingsToKnow': input.thingsToKnow,
      'medicalHealth': input.medicalHealth,
      'statusText': 'Profile created. Ready for first booking',
      'photoUrl': input.photoUrl,
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
      'breed': input.breed,
      'ageGroup': input.ageGroup,
      'description': input.description,
      'thingsToKnow': input.thingsToKnow,
      'medicalHealth': input.medicalHealth,
      'photoUrl': input.photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadPetPhoto(String ownerId, File file) async {
    final fileName = 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('owners/$ownerId/pets/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
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

  // Activity & Bookings Methods
  Stream<List<ActivityEvent>> watchRecentOwnerActivity(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('updatedAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ActivityEvent.fromBooking(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Stream<List<Booking>> watchOwnerBookings(String ownerId, {bool upcoming = true}) {
    final now = DateTime.now();
    Query query = _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId);
        
    if (upcoming) {
      query = query.where('scheduledAt', isGreaterThan: Timestamp.fromDate(now))
                   .orderBy('scheduledAt', descending: false);
    } else {
      query = query.where('scheduledAt', isLessThanOrEqualTo: Timestamp.fromDate(now))
                   .orderBy('scheduledAt', descending: true);
    }

    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => Booking.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList(growable: false),
        );
  }

  // Messaging Methods
  Stream<List<ChatMessage>> watchWalkerNotifications(String ownerId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: ownerId)
        .where('type', isEqualTo: 'notification')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
            .toList());
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
  final String breed;
  final String ageGroup;
  final String description;
  final String thingsToKnow;
  final String medicalHealth;
  final String photoUrl;

  const CreatePetProfileInput({
    required this.name,
    required this.petType,
    required this.breed,
    required this.ageGroup,
    required this.description,
    required this.thingsToKnow,
    required this.medicalHealth,
    required this.photoUrl,
  });
}

class PetDetail {
  final String id;
  final String ownerId;
  final String name;
  final String petType;
  final String breed;
  final String ageGroup;
  final String description;
  final String thingsToKnow;
  final String medicalHealth;
  final String statusText;
  final String photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PetDetail({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.petType,
    required this.breed,
    required this.ageGroup,
    required this.description,
    required this.thingsToKnow,
    required this.medicalHealth,
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
      breed: (map['breed'] as String?) ?? '',
      ageGroup: (map['ageGroup'] as String?) ?? 'Adult',
      description: (map['description'] as String?) ?? '',
      thingsToKnow: (map['thingsToKnow'] as String?) ?? '',
      medicalHealth: (map['medicalHealth'] as String?) ?? '',
      statusText: (map['statusText'] as String?) ?? 'Ready for a new walk',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class Booking {
  final String id;
  final String petId;
  final String petName;
  final String walkerId;
  final String walkerName;
  final String serviceType;
  final DateTime scheduledAt;
  final String status;
  final String paymentStatus;
  final double amount;
  final double? rating;

  Booking({
    required this.id,
    required this.petId,
    required this.petName,
    required this.walkerId,
    required this.walkerName,
    required this.serviceType,
    required this.scheduledAt,
    required this.status,
    required this.paymentStatus,
    required this.amount,
    this.rating,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? 'Your Pet',
      walkerId: map['walkerId'] ?? '',
      walkerName: map['walkerName'] ?? 'Walker',
      serviceType: map['serviceType'] ?? 'Walk',
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble(),
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final String type; // 'text' or 'notification'

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    required this.type,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Walker',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: map['type'] ?? 'text',
    );
  }
}

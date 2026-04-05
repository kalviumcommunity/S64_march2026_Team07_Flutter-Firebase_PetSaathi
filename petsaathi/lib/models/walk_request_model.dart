import 'package:cloud_firestore/cloud_firestore.dart';

class WalkRequest {
  final String id;
  final String petId;
  final String petName;
  final String ownerId;
  final String ownerName;
  final String? targetWalkerId;
  final String? walkerId; // Initially null for discovery
  final String? walkerName;
  final String status; // 'pending', 'accepted', 'rejected', 'in-progress', 'completed'
  final DateTime scheduledAt;
  final double amount;
  final String? location;
  final String? requestNote;
  final List<String> tags;
  final List<String> rejectedByWalkerIds;
  final String? requestKey;
  final DateTime? expiresAt;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalkRequest({
    required this.id,
    required this.petId,
    required this.petName,
    required this.ownerId,
    required this.ownerName,
    this.targetWalkerId,
    this.walkerId,
    this.walkerName,
    required this.status,
    required this.scheduledAt,
    required this.amount,
    this.location,
    this.requestNote,
    this.tags = const [],
    this.rejectedByWalkerIds = const [],
    this.requestKey,
    this.expiresAt,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalkRequest.fromMap(String id, Map<String, dynamic> map) {
    final expiresAt = (map['expiresAt'] as Timestamp?)?.toDate();
    final rawStatus = map['status'] ?? 'pending';

    return WalkRequest(
      id: id,
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? 'Pet',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? 'Owner',
      targetWalkerId: map['targetWalkerId'],
      walkerId: map['walkerId'],
      walkerName: map['walkerName'],
      status: rawStatus,
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      location: map['location'],
      requestNote: map['requestNote'],
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rejectedByWalkerIds: (map['rejectedByWalkerIds'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      requestKey: map['requestKey'],
      expiresAt: expiresAt,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'petName': petName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'targetWalkerId': targetWalkerId,
      'walkerId': walkerId,
      'walkerName': walkerName,
      'status': status,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'amount': amount,
      'location': location,
      'requestNote': requestNote,
      'tags': tags,
      'rejectedByWalkerIds': rejectedByWalkerIds,
      'requestKey': requestKey,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

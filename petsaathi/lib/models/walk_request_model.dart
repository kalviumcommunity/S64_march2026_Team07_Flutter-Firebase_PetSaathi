import 'package:cloud_firestore/cloud_firestore.dart';

class WalkRequest {
  final String id;
  final String petId;
  final String petName;
  final String ownerId;
  final String ownerName;
  final String? walkerId; // Initially null for discovery
  final String? walkerName;
  final String status; // 'pending', 'accepted', 'rejected', 'in-progress', 'completed'
  final DateTime scheduledAt;
  final double amount;
  final String? location;
  final List<String> tags;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalkRequest({
    required this.id,
    required this.petId,
    required this.petName,
    required this.ownerId,
    required this.ownerName,
    this.walkerId,
    this.walkerName,
    required this.status,
    required this.scheduledAt,
    required this.amount,
    this.location,
    this.tags = const [],
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalkRequest.fromMap(String id, Map<String, dynamic> map) {
    return WalkRequest(
      id: id,
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? 'Pet',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? 'Owner',
      walkerId: map['walkerId'],
      walkerName: map['walkerName'],
      status: map['status'] ?? 'pending',
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      location: map['location'],
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
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
      'walkerId': walkerId,
      'walkerName': walkerName,
      'status': status,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'amount': amount,
      'location': location,
      'tags': tags,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

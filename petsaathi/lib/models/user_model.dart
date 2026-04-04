import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role; // 'owner' or 'walker'
  final String name;
  final String? avatarUrl;
  final bool isAvailable;
  final double trustScore;
  final String? location;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.avatarUrl,
    this.isAvailable = true,
    this.trustScore = 5.0,
    this.location,
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'owner',
      name: map['name'] ?? 'User',
      avatarUrl: map['avatarUrl'],
      isAvailable: map['isAvailable'] ?? true,
      trustScore: (map['trustScore'] as num?)?.toDouble() ?? 5.0,
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'avatarUrl': avatarUrl,
      'isAvailable': isAvailable,
      'trustScore': trustScore,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

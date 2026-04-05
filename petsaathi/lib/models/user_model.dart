import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role; // 'owner' or 'walker'
  final String name;
  final String? avatarUrl;
  final String? phone;
  final String? city;
  final String? address;
  final String? bio;
  final double? pricePerWalk;
  final List<String> availabilitySchedule;
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
    this.phone,
    this.city,
    this.address,
    this.bio,
    this.pricePerWalk,
    this.availabilitySchedule = const [],
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
      phone: map['phone'],
      city: map['city'],
      address: map['address'],
      bio: map['bio'],
      pricePerWalk: (map['pricePerWalk'] as num?)?.toDouble(),
      availabilitySchedule: (map['availabilitySchedule'] as List?)?.map((e) => e.toString()).toList() ?? const [],
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
      'phone': phone,
      'city': city,
      'address': address,
      'bio': bio,
      'pricePerWalk': pricePerWalk,
      'availabilitySchedule': availabilitySchedule,
      'isAvailable': isAvailable,
      'trustScore': trustScore,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String ownerId;
  final String name;
  final String petType;
  final String breed;
  final String ageGroup;
  final String description;
  final String thingsToKnow;
  final String medicalHealth;
  final String photoUrl;
  final String statusText;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.petType,
    required this.breed,
    required this.ageGroup,
    required this.description,
    required this.thingsToKnow,
    required this.medicalHealth,
    required this.photoUrl,
    this.statusText = 'Ready for a new walk',
    required this.createdAt,
    required this.updatedAt,
  });

  factory PetModel.fromMap(String id, Map<String, dynamic> map) {
    return PetModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? 'Pet',
      petType: map['petType'] ?? 'Dog',
      breed: map['breed'] ?? '',
      ageGroup: map['ageGroup'] ?? 'Adult',
      description: map['description'] ?? '',
      thingsToKnow: map['thingsToKnow'] ?? '',
      medicalHealth: map['medicalHealth'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      statusText: map['statusText'] ?? 'Ready for a new walk',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'petType': petType,
      'breed': breed,
      'ageGroup': ageGroup,
      'description': description,
      'thingsToKnow': thingsToKnow,
      'medicalHealth': medicalHealth,
      'photoUrl': photoUrl,
      'statusText': statusText,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

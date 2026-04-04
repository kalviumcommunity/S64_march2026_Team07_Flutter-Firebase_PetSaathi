import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final String title;
  final String subtitle;
  final String iconType; // 'done', 'schedule', 'cancel', 'pending'
  final String userId; // User who this log belongs to
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconType,
    required this.userId,
    required this.createdAt,
  });

  factory ActivityLog.fromMap(String id, Map<String, dynamic> map) {
    return ActivityLog(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      iconType: map['iconType'] ?? 'pending',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'iconType': iconType,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

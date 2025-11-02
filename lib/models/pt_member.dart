import 'package:cloud_firestore/cloud_firestore.dart';

/// パーソナルトレーニング会員のモデル
class PTMember {
  final String id;
  final String userId; // B2Cアプリのユーザー ID
  final String partnerId;
  final String name;
  final String email;
  final String? phoneNumber;
  final DateTime joinedAt;
  final String trainerName;
  final String planName;
  final int totalSessions;
  final int remainingSessions;
  final DateTime? lastSessionAt;
  final String status; // 'active', 'dormant', 'cancelled'

  PTMember({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.joinedAt,
    required this.trainerName,
    required this.planName,
    required this.totalSessions,
    required this.remainingSessions,
    this.lastSessionAt,
    this.status = 'active',
  });

  bool get isActive {
    if (lastSessionAt == null) return false;
    final daysSince = DateTime.now().difference(lastSessionAt!).inDays;
    return daysSince < 14;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'partnerId': partnerId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'trainerName': trainerName,
      'planName': planName,
      'totalSessions': totalSessions,
      'remainingSessions': remainingSessions,
      'lastSessionAt':
          lastSessionAt != null ? Timestamp.fromDate(lastSessionAt!) : null,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory PTMember.fromFirestore(Map<String, dynamic> data, String id) {
    return PTMember(
      id: id,
      userId: data['userId'] ?? '',
      partnerId: data['partnerId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      trainerName: data['trainerName'] ?? '',
      planName: data['planName'] ?? '',
      totalSessions: data['totalSessions'] ?? 0,
      remainingSessions: data['remainingSessions'] ?? 0,
      lastSessionAt: data['lastSessionAt'] != null
          ? (data['lastSessionAt'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'active',
    );
  }
}

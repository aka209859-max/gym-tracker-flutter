import 'package:cloud_firestore/cloud_firestore.dart';

/// パーソナルトレーニングセッションのモデル
class PTSession {
  final String id;
  final String partnerId;
  final String memberId;
  final String memberName;
  final String trainerId;
  final String trainerName;
  final DateTime sessionDate;
  final int duration; // 分
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? notes;
  final String? cancellationReason;

  PTSession({
    required this.id,
    required this.partnerId,
    required this.memberId,
    required this.memberName,
    required this.trainerId,
    required this.trainerName,
    required this.sessionDate,
    this.duration = 60,
    this.status = 'confirmed',
    this.notes,
    this.cancellationReason,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'partnerId': partnerId,
      'memberId': memberId,
      'memberName': memberName,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'sessionDate': Timestamp.fromDate(sessionDate),
      'duration': duration,
      'status': status,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory PTSession.fromFirestore(Map<String, dynamic> data, String id) {
    return PTSession(
      id: id,
      partnerId: data['partnerId'] ?? '',
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      trainerId: data['trainerId'] ?? '',
      trainerName: data['trainerName'] ?? '',
      sessionDate: (data['sessionDate'] as Timestamp).toDate(),
      duration: data['duration'] ?? 60,
      status: data['status'] ?? 'confirmed',
      notes: data['notes'],
      cancellationReason: data['cancellationReason'],
    );
  }
}

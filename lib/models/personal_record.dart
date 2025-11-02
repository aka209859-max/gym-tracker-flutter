import 'package:cloud_firestore/cloud_firestore.dart';

/// パーソナルレコード（自己ベスト）のモデル
class PersonalRecord {
  final String id;
  final String userId;
  final String exerciseName;
  final String bodyPart;
  final double weight;
  final int reps;
  final double calculated1RM; // Brzycki式による推定1RM
  final DateTime achievedAt;
  final String gymId;

  PersonalRecord({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.bodyPart,
    required this.weight,
    required this.reps,
    required this.calculated1RM,
    required this.achievedAt,
    required this.gymId,
  });

  /// Brzycki式で1RMを計算
  static double calculate1RM(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (36 / (37 - reps));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'exerciseName': exerciseName,
      'bodyPart': bodyPart,
      'weight': weight,
      'reps': reps,
      'calculated1RM': calculated1RM,
      'achievedAt': Timestamp.fromDate(achievedAt),
      'gymId': gymId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory PersonalRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return PersonalRecord(
      id: id,
      userId: data['userId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      bodyPart: data['bodyPart'] ?? '',
      weight: (data['weight'] ?? 0).toDouble(),
      reps: data['reps'] ?? 0,
      calculated1RM: (data['calculated1RM'] ?? 0).toDouble(),
      achievedAt: (data['achievedAt'] as Timestamp).toDate(),
      gymId: data['gymId'] ?? '',
    );
  }
}

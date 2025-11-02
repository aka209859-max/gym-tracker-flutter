import 'package:cloud_firestore/cloud_firestore.dart';

/// 週次レポートのモデル
class WeeklyReport {
  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalWorkouts;
  final int totalMinutes;
  final int streak;
  final Map<String, int> bodyParts; // 部位別実施回数
  final WeeklyRecommendation? recommendations;

  WeeklyReport({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.streak,
    required this.bodyParts,
    this.recommendations,
  });

  factory WeeklyReport.fromFirestore(Map<String, dynamic> data, String id) {
    return WeeklyReport(
      id: id,
      weekStart: (data['weekStart'] as Timestamp).toDate(),
      weekEnd: (data['weekEnd'] as Timestamp).toDate(),
      totalWorkouts: data['totalWorkouts'] ?? 0,
      totalMinutes: data['totalMinutes'] ?? 0,
      streak: data['streak'] ?? 0,
      bodyParts: Map<String, int>.from(data['bodyParts'] ?? {}),
      recommendations: data['recommendations'] != null
          ? WeeklyRecommendation.fromMap(
              data['recommendations'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 週次レコメンデーション
class WeeklyRecommendation {
  final int targetFrequency;
  final String balanceAdvice;
  final List<String> suggestedDays;

  WeeklyRecommendation({
    required this.targetFrequency,
    required this.balanceAdvice,
    required this.suggestedDays,
  });

  factory WeeklyRecommendation.fromMap(Map<String, dynamic> map) {
    return WeeklyRecommendation(
      targetFrequency: map['targetFrequency'] ?? 3,
      balanceAdvice: map['balanceAdvice'] ?? '',
      suggestedDays: List<String>.from(map['suggestedDays'] ?? []),
    );
  }
}

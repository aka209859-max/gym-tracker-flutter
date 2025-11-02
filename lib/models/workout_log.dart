import 'package:cloud_firestore/cloud_firestore.dart';

/// トレーニングログのモデル
class WorkoutLog {
  final String id;
  final String userId;
  final DateTime date;
  final String gymId;
  final String? gymName;
  final List<Exercise> exercises;
  final String? notes;
  final bool isAutoCompleted;
  final int consecutiveDays;
  final int? duration; // 分

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.gymId,
    this.gymName,
    required this.exercises,
    this.notes,
    this.isAutoCompleted = false,
    this.consecutiveDays = 1,
    this.duration,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'gymId': gymId,
      'gymName': gymName,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'notes': notes,
      'isAutoCompleted': isAutoCompleted,
      'consecutiveDays': consecutiveDays,
      'duration': duration,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory WorkoutLog.fromFirestore(Map<String, dynamic> data, String id) {
    return WorkoutLog(
      id: id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      gymId: data['gymId'] ?? '',
      gymName: data['gymName'],
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: data['notes'],
      isAutoCompleted: data['isAutoCompleted'] ?? false,
      consecutiveDays: data['consecutiveDays'] ?? 1,
      duration: data['duration'],
    );
  }
}

/// 種目のモデル
class Exercise {
  final String name;
  final String bodyPart; // 胸、背中、脚、肩、腕、腹筋
  final List<WorkoutSet> sets;

  Exercise({
    required this.name,
    required this.bodyPart,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bodyPart': bodyPart,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      bodyPart: map['bodyPart'] ?? '',
      sets: (map['sets'] as List<dynamic>?)
              ?.map((s) => WorkoutSet.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// セットのモデル
class WorkoutSet {
  final int targetReps;
  final int? actualReps;
  final double? weight;
  final DateTime? completedAt;

  WorkoutSet({
    required this.targetReps,
    this.actualReps,
    this.weight,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'targetReps': targetReps,
      'actualReps': actualReps,
      'weight': weight,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      targetReps: map['targetReps'] ?? 0,
      actualReps: map['actualReps'],
      weight: map['weight']?.toDouble(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

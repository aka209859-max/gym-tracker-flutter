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

/// セットタイプの列挙型
enum SetType {
  normal,     // 通常セット
  warmup,     // ウォームアップ
  superset,   // スーパーセット
  dropset,    // ドロップセット
  failure,    // フェイラーセット (限界まで)
}

/// セットのモデル
class WorkoutSet {
  final int targetReps;
  final int? actualReps;
  final double? weight;
  final DateTime? completedAt;
  final SetType setType;
  final String? supersetPairId; // スーパーセットのペア識別子
  final int? dropsetLevel;      // ドロップセットのレベル (1, 2, 3...)
  final int? rpe;               // RPE (Rate of Perceived Exertion) 1-10
  final bool? hasAssist;        // 補助有無

  WorkoutSet({
    required this.targetReps,
    this.actualReps,
    this.weight,
    this.completedAt,
    this.setType = SetType.normal,
    this.supersetPairId,
    this.dropsetLevel,
    this.rpe,
    this.hasAssist,
  });

  Map<String, dynamic> toMap() {
    return {
      'targetReps': targetReps,
      'actualReps': actualReps,
      'weight': weight,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'setType': setType.name,
      'supersetPairId': supersetPairId,
      'dropsetLevel': dropsetLevel,
      'rpe': rpe,
      'hasAssist': hasAssist,
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
      setType: SetType.values.firstWhere(
        (e) => e.name == map['setType'],
        orElse: () => SetType.normal,
      ),
      supersetPairId: map['supersetPairId'],
      dropsetLevel: map['dropsetLevel'],
      rpe: map['rpe'],
      hasAssist: map['hasAssist'] ?? map['has_assist'],
    );
  }

  /// セットのボリューム (重量 × 回数) を計算
  double get volume {
    if (weight == null || actualReps == null) return 0;
    return weight! * actualReps!;
  }

  /// セットタイプの表示名を取得
  String get setTypeDisplayName {
    switch (setType) {
      case SetType.normal:
        return '通常';
      case SetType.warmup:
        return 'W-UP';
      case SetType.superset:
        return 'SS';
      case SetType.dropset:
        return 'DS';
      case SetType.failure:
        return '限界';
    }
  }
}

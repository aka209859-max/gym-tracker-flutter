import 'package:cloud_firestore/cloud_firestore.dart';

/// ワークアウトテンプレートのモデル
class WorkoutTemplate {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String muscleGroup;
  final List<TemplateExercise> exercises;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final int usageCount;
  final bool isDefault; // デフォルトテンプレートフラグ

  WorkoutTemplate({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.muscleGroup,
    required this.exercises,
    required this.createdAt,
    this.lastUsedAt,
    this.usageCount = 0,
    this.isDefault = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'muscle_group': muscleGroup,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
      'last_used_at': lastUsedAt != null ? Timestamp.fromDate(lastUsedAt!) : null,
      'usage_count': usageCount,
      'is_default': isDefault,
    };
  }

  factory WorkoutTemplate.fromFirestore(Map<String, dynamic> data, String id) {
    return WorkoutTemplate(
      id: id,
      userId: data['user_id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      muscleGroup: data['muscle_group'] ?? '',
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => TemplateExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUsedAt: (data['last_used_at'] as Timestamp?)?.toDate(),
      usageCount: data['usage_count'] ?? 0,
      isDefault: data['is_default'] ?? false,
    );
  }

  /// テンプレートをコピーして使用回数を増やす
  WorkoutTemplate copyWithUsage() {
    return WorkoutTemplate(
      id: id,
      userId: userId,
      name: name,
      description: description,
      muscleGroup: muscleGroup,
      exercises: exercises,
      createdAt: createdAt,
      lastUsedAt: DateTime.now(),
      usageCount: usageCount + 1,
      isDefault: isDefault,
    );
  }
}

/// テンプレート内の種目
class TemplateExercise {
  final String exerciseName;
  final int targetSets;
  final int targetReps;
  final double? targetWeight;
  final String setType; // 'normal', 'warmup', 'superset', 'dropset', 'failure'

  TemplateExercise({
    required this.exerciseName,
    required this.targetSets,
    required this.targetReps,
    this.targetWeight,
    this.setType = 'normal',
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_name': exerciseName,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'target_weight': targetWeight,
      'set_type': setType,
    };
  }

  factory TemplateExercise.fromMap(Map<String, dynamic> map) {
    return TemplateExercise(
      exerciseName: map['exercise_name'] ?? '',
      targetSets: map['target_sets'] ?? 3,
      targetReps: map['target_reps'] ?? 10,
      targetWeight: map['target_weight']?.toDouble(),
      setType: map['set_type'] ?? 'normal',
    );
  }
}

/// デフォルトテンプレート定義
class DefaultTemplates {
  /// PPL（Push/Pull/Legs）- Push Day
  static WorkoutTemplate pplPush(String userId) {
    return WorkoutTemplate(
      id: 'default_ppl_push',
      userId: userId,
      name: 'PPL - Push Day（胸・肩・三頭）',
      description: 'プッシュ系種目を集中的に鍛えるテンプレート',
      muscleGroup: '胸',
      isDefault: true,
      createdAt: DateTime.now(),
      exercises: [
        TemplateExercise(exerciseName: 'ベンチプレス', targetSets: 4, targetReps: 8),
        TemplateExercise(exerciseName: 'インクラインプレス', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'ショルダープレス', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'サイドレイズ', targetSets: 3, targetReps: 12),
        TemplateExercise(exerciseName: 'トライセプスエクステンション', targetSets: 3, targetReps: 12),
      ],
    );
  }

  /// PPL - Pull Day
  static WorkoutTemplate pplPull(String userId) {
    return WorkoutTemplate(
      id: 'default_ppl_pull',
      userId: userId,
      name: 'PPL - Pull Day（背中・二頭）',
      description: 'プル系種目を集中的に鍛えるテンプレート',
      muscleGroup: '背中',
      isDefault: true,
      createdAt: DateTime.now(),
      exercises: [
        TemplateExercise(exerciseName: 'デッドリフト', targetSets: 4, targetReps: 6),
        TemplateExercise(exerciseName: 'ラットプルダウン', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'ベントオーバーロウ', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'シーテッドロウ', targetSets: 3, targetReps: 12),
        TemplateExercise(exerciseName: 'バーベルカール', targetSets: 3, targetReps: 10),
      ],
    );
  }

  /// PPL - Legs Day
  static WorkoutTemplate pplLegs(String userId) {
    return WorkoutTemplate(
      id: 'default_ppl_legs',
      userId: userId,
      name: 'PPL - Legs Day（脚）',
      description: '下半身を徹底的に鍛えるテンプレート',
      muscleGroup: '脚',
      isDefault: true,
      createdAt: DateTime.now(),
      exercises: [
        TemplateExercise(exerciseName: 'スクワット', targetSets: 4, targetReps: 8),
        TemplateExercise(exerciseName: 'レッグプレス', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'レッグエクステンション', targetSets: 3, targetReps: 12),
        TemplateExercise(exerciseName: 'レッグカール', targetSets: 3, targetReps: 12),
        TemplateExercise(exerciseName: 'カーフレイズ', targetSets: 4, targetReps: 15),
      ],
    );
  }

  /// フルボディ - 初心者向け
  static WorkoutTemplate fullBodyBeginner(String userId) {
    return WorkoutTemplate(
      id: 'default_full_body',
      userId: userId,
      name: 'フルボディ - 初心者向け',
      description: '全身をバランスよく鍛える初心者向けテンプレート',
      muscleGroup: '胸',
      isDefault: true,
      createdAt: DateTime.now(),
      exercises: [
        TemplateExercise(exerciseName: 'ベンチプレス', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'スクワット', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'ラットプルダウン', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'ショルダープレス', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'バーベルカール', targetSets: 2, targetReps: 12),
      ],
    );
  }

  /// 上半身特化
  static WorkoutTemplate upperBodyFocus(String userId) {
    return WorkoutTemplate(
      id: 'default_upper_body',
      userId: userId,
      name: '上半身特化トレーニング',
      description: '胸・背中・肩を集中的に鍛えるテンプレート',
      muscleGroup: '胸',
      isDefault: true,
      createdAt: DateTime.now(),
      exercises: [
        TemplateExercise(exerciseName: 'ベンチプレス', targetSets: 4, targetReps: 8),
        TemplateExercise(exerciseName: 'ラットプルダウン', targetSets: 4, targetReps: 10),
        TemplateExercise(exerciseName: 'ショルダープレス', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'ダンベルプレス', targetSets: 3, targetReps: 10),
        TemplateExercise(exerciseName: 'ベントオーバーロウ', targetSets: 3, targetReps: 10),
      ],
    );
  }

  /// 全デフォルトテンプレートを取得
  static List<WorkoutTemplate> getAll(String userId) {
    return [
      pplPush(userId),
      pplPull(userId),
      pplLegs(userId),
      fullBodyBeginner(userId),
      upperBodyFocus(userId),
    ];
  }
}

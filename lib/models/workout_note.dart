import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutNote {
  final String id;
  final String userId;
  final String workoutSessionId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutNote({
    required this.id,
    required this.userId,
    required this.workoutSessionId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestoreからデータを取得する際のコンストラクタ
  factory WorkoutNote.fromFirestore(Map<String, dynamic> data, String docId) {
    return WorkoutNote(
      id: docId,
      userId: data['user_id'] as String? ?? '',
      workoutSessionId: data['workout_session_id'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Firestoreに保存する際のマップ変換
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'workout_session_id': workoutSessionId,
      'content': content,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // メモのコピーを作成（編集時に使用）
  WorkoutNote copyWith({
    String? id,
    String? userId,
    String? workoutSessionId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutNote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // メモが空かどうか判定
  bool get isEmpty => content.trim().isEmpty;

  // メモの文字数
  int get characterCount => content.length;
}

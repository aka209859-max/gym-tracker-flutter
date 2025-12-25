import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/goal.dart';

import 'package:gym_match/gen/app_localizations.dart';
/// 目標管理サービス
class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 新しい目標を作成
  Future<String> createGoal({
    required String userId,
    required GoalType type,
    required GoalPeriod period,
    required int targetValue,
  }) async {
    // 期間の開始日と終了日を計算
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (period == GoalPeriod.weekly) {
      // 今週の月曜日を開始日
      startDate = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      // 今週の日曜日を終了日
      endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59));
    } else {
      // 今月の1日を開始日
      startDate = DateTime(now.year, now.month, 1);
      // 今月の最終日を終了日
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59);
    }

    // 既存のアクティブな同種目標を無効化
    await _deactivateExistingGoals(userId, type, period);

    // 新しい目標を作成
    final goal = Goal(
      id: '',
      userId: userId,
      type: type,
      period: period,
      targetValue: targetValue,
      currentValue: 0,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
      isCompleted: false,
    );

    final docRef = await _firestore.collection('user_goals').add(goal.toFirestore());

    if (kDebugMode) {
      debugPrint('✅ 目標を作成しました: ${goal.name} - $targetValue${goal.unit}');
    }

    return docRef.id;
  }

  /// 既存のアクティブな同種目標を無効化
  Future<void> _deactivateExistingGoals(
    String userId,
    GoalType type,
    GoalPeriod period,
  ) async {
    final querySnapshot = await _firestore
        .collection('user_goals')
        .where('user_id', isEqualTo: userId)
        .where('type', isEqualTo: type.name)
        .where('period', isEqualTo: period.name)
        .where('is_active', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'is_active': false});
    }
    await batch.commit();

    if (kDebugMode && querySnapshot.docs.isNotEmpty) {
      debugPrint('✅ ${querySnapshot.docs.length}件の既存目標を無効化');
    }
  }

  /// ユーザーのアクティブな目標を取得
  Future<List<Goal>> getActiveGoals(String userId) async {
    final querySnapshot = await _firestore
        .collection('user_goals')
        .where('user_id', isEqualTo: userId)
        .where('is_active', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// 目標の進捗を更新
  Future<void> updateGoalProgress(String userId) async {
    final goals = await getActiveGoals(userId);

    for (var goal in goals) {
      // 期限切れチェック
      if (goal.isExpired) {
        await _firestore.collection('user_goals').doc(goal.id).update({
          'is_active': false,
        });
        continue;
      }

      // 進捗値を計算
      int currentValue = 0;

      if (goal.type == GoalType.weeklyWorkoutCount) {
        currentValue = await _calculateWeeklyWorkoutCount(userId, goal.startDate, goal.endDate);
      } else if (goal.type == GoalType.monthlyTotalWeight) {
        currentValue = await _calculateMonthlyTotalWeight(userId, goal.startDate, goal.endDate);
      }

      // 達成チェック
      final isCompleted = currentValue >= goal.targetValue;
      final completedAt = isCompleted && !goal.isCompleted ? DateTime.now() : goal.completedAt;

      // 更新
      await _firestore.collection('user_goals').doc(goal.id).update({
        'current_value': currentValue,
        'is_completed': isCompleted,
        'completed_at': completedAt != null ? Timestamp.fromDate(completedAt) : null,
      });

      if (kDebugMode) {
        debugPrint('📊 目標進捗更新: ${goal.name} - $currentValue / ${goal.targetValue}${goal.unit}');
      }
    }
  }

  /// 週間トレーニング回数を計算
  Future<int> _calculateWeeklyWorkoutCount(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final querySnapshot = await _firestore
        .collection('workout_logs')
        .where('user_id', isEqualTo: userId)
        .get();

    // 指定期間内のユニークな日数をカウント
    final uniqueDates = <DateTime>{};

    for (var doc in querySnapshot.docs) {
      final date = (doc.data()['date'] as Timestamp?)?.toDate();
      if (date != null && 
          date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          date.isBefore(endDate.add(const Duration(seconds: 1)))) {
        // 日付のみで比較（時刻を無視）
        final dateOnly = DateTime(date.year, date.month, date.day);
        uniqueDates.add(dateOnly);
      }
    }

    return uniqueDates.length;
  }

  /// 月間総重量を計算
  Future<int> _calculateMonthlyTotalWeight(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final querySnapshot = await _firestore
        .collection('workout_logs')
        .where('user_id', isEqualTo: userId)
        .get();

    int totalWeight = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp?)?.toDate();
      
      if (date != null &&
          date.isAfter(startDate.subtract(Duration(seconds: 1))) &&
          date.isBefore(endDate.add(Duration(seconds: 1)))) {
        final sets = data['sets'] as List<dynamic>?;
        if (sets == null) continue;

        for (var set in sets) {
          final isCardio = set['is_cardio'] as bool? ?? false;
          if (!isCardio) {
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            final reps = set['reps'] as int? ?? 0;
            totalWeight += (weight * reps).toInt();
          }
        }
      }
    }

    return totalWeight;
  }

  /// 目標を削除
  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection('user_goals').doc(goalId).delete();

    if (kDebugMode) {
      debugPrint(AppLocalizations.of(context)!.generatedKey_901fff2b);
    }
  }

  /// 目標を更新
  Future<void> updateGoal(String goalId, {
    int? targetValue,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{};
    if (targetValue != null) updates['target_value'] = targetValue;
    if (isActive != null) updates['is_active'] = isActive;

    if (updates.isNotEmpty) {
      await _firestore.collection('user_goals').doc(goalId).update(updates);

      if (kDebugMode) {
        debugPrint(AppLocalizations.of(context)!.generatedKey_10698ef0);
      }
    }
  }

  /// 全目標を取得（履歴含む）
  Future<List<Goal>> getAllGoals(String userId) async {
    // シンプルなクエリ（インデックス不要）
    final querySnapshot = await _firestore
        .collection('user_goals')
        .where('user_id', isEqualTo: userId)
        .get();

    // メモリ内でソート（新しい順）
    final goals = querySnapshot.docs
        .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
        .toList();
    
    goals.sort((a, b) => b.startDate.compareTo(a.startDate));
    
    return goals;
  }

  /// 目標統計を取得
  Future<Map<String, int>> getGoalStats(String userId) async {
    final allGoals = await getAllGoals(userId);
    final completedGoals = allGoals.where((g) => g.isCompleted).length;
    final activeGoals = allGoals.where((g) => g.isActive).length;

    return {
      'total': allGoals.length,
      'completed': completedGoals,
      'active': activeGoals,
      'failed': allGoals.length - completedGoals - activeGoals,
    };
  }
}

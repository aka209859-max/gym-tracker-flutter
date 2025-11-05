import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/achievement.dart';

/// 達成バッジサービス
class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ユーザーのバッジを初期化（初回のみ）
  Future<void> initializeUserBadges(String userId) async {
    // 既に初期化済みかチェック
    final existingBadges = await _firestore
        .collection('user_achievements')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingBadges.docs.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('✅ User badges already initialized');
      }
      return;
    }

    // 全バッジを未解除状態で作成
    final allBadges = PredefinedBadges.getAllBadges();
    final batch = _firestore.batch();

    for (var badgeData in allBadges) {
      final docRef = _firestore.collection('user_achievements').doc();
      batch.set(docRef, {
        'user_id': userId,
        'category': badgeData['category'],
        'title': badgeData['title'],
        'description': badgeData['description'],
        'icon_name': badgeData['icon_name'],
        'threshold': badgeData['threshold'],
        'is_unlocked': false,
        'unlocked_at': null,
      });
    }

    await batch.commit();
    if (kDebugMode) {
      debugPrint('✅ Initialized ${allBadges.length} badges for user');
    }
  }

  /// ユーザーのバッジをチェックして更新
  Future<List<Achievement>> checkAndUpdateBadges(String userId) async {
    final newlyUnlocked = <Achievement>[];

    // 現在の統計を取得
    final stats = await _calculateUserStats(userId);

    // 各カテゴリーのバッジをチェック
    await _checkStreakBadges(userId, stats['currentStreak'] ?? 0, newlyUnlocked);
    await _checkTotalWeightBadges(userId, stats['totalWeight'] ?? 0, newlyUnlocked);
    await _checkPrCountBadges(userId, stats['prCount'] ?? 0, newlyUnlocked);

    return newlyUnlocked;
  }

  /// 継続日数バッジをチェック
  Future<void> _checkStreakBadges(
    String userId,
    int currentStreak,
    List<Achievement> newlyUnlocked,
  ) async {
    // シンプルなクエリでカテゴリーのみ取得
    final badges = await _firestore
        .collection('user_achievements')
        .where('user_id', isEqualTo: userId)
        .where('category', isEqualTo: 'streak')
        .get();
    
    // メモリ内で未解除のみフィルター
    final unlockedBadges = badges.docs
        .map((doc) => Achievement.fromFirestore(doc.data(), doc.id))
        .where((badge) => !badge.isUnlocked)
        .toList();

    for (var badge in unlockedBadges) {
      if (currentStreak >= badge.threshold) {
        final unlockedBadge = badge.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        await _firestore.collection('user_achievements').doc(badge.id).update(unlockedBadge.toFirestore());
        newlyUnlocked.add(unlockedBadge);

        if (kDebugMode) {
          debugPrint('🏆 Unlocked badge: ${badge.title}');
        }
      }
    }
  }

  /// 総重量バッジをチェック
  Future<void> _checkTotalWeightBadges(
    String userId,
    int totalWeight,
    List<Achievement> newlyUnlocked,
  ) async {
    // シンプルなクエリでカテゴリーのみ取得
    final badges = await _firestore
        .collection('user_achievements')
        .where('user_id', isEqualTo: userId)
        .where('category', isEqualTo: 'totalWeight')
        .get();
    
    // メモリ内で未解除のみフィルター
    final unlockedBadges = badges.docs
        .map((doc) => Achievement.fromFirestore(doc.data(), doc.id))
        .where((badge) => !badge.isUnlocked)
        .toList();

    for (var badge in unlockedBadges) {
      if (totalWeight >= badge.threshold) {
        final unlockedBadge = badge.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        await _firestore.collection('user_achievements').doc(badge.id).update(unlockedBadge.toFirestore());
        newlyUnlocked.add(unlockedBadge);

        if (kDebugMode) {
          debugPrint('🏆 Unlocked badge: ${badge.title}');
        }
      }
    }
  }

  /// PR回数バッジをチェック
  Future<void> _checkPrCountBadges(
    String userId,
    int prCount,
    List<Achievement> newlyUnlocked,
  ) async {
    // シンプルなクエリでカテゴリーのみ取得
    final badges = await _firestore
        .collection('user_achievements')
        .where('user_id', isEqualTo: userId)
        .where('category', isEqualTo: 'prCount')
        .get();
    
    // メモリ内で未解除のみフィルター
    final unlockedBadges = badges.docs
        .map((doc) => Achievement.fromFirestore(doc.data(), doc.id))
        .where((badge) => !badge.isUnlocked)
        .toList();

    for (var badge in unlockedBadges) {
      if (prCount >= badge.threshold) {
        final unlockedBadge = badge.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        await _firestore.collection('user_achievements').doc(badge.id).update(unlockedBadge.toFirestore());
        newlyUnlocked.add(unlockedBadge);

        if (kDebugMode) {
          debugPrint('🏆 Unlocked badge: ${badge.title}');
        }
      }
    }
  }

  /// ユーザーの統計を計算
  Future<Map<String, int>> _calculateUserStats(String userId) async {
    // 継続日数の計算
    final currentStreak = await _calculateCurrentStreak(userId);

    // 累計総重量の計算
    final totalWeight = await _calculateTotalWeight(userId);

    // PR回数の計算（仮実装 - 実際はPR記録システムと連携）
    final prCount = await _calculatePrCount(userId);

    return {
      'currentStreak': currentStreak,
      'totalWeight': totalWeight,
      'prCount': prCount,
    };
  }

  /// 継続日数を計算
  Future<int> _calculateCurrentStreak(String userId) async {
    // シンプルなクエリ（インデックス不要）
    final workouts = await _firestore
        .collection('workout_logs')
        .where('user_id', isEqualTo: userId)
        .get();
    
    // メモリ内でソート（新しい順）
    final sortedDocs = workouts.docs.toList()
      ..sort((a, b) {
        final dateA = (a.data()['date'] as Timestamp?)?.toDate();
        final dateB = (b.data()['date'] as Timestamp?)?.toDate();
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA); // 降順
      });

    if (sortedDocs.isEmpty) return 0;

    int streak = 0;
    DateTime? previousDate;

    for (var doc in sortedDocs) {
      final date = (doc.data()['date'] as Timestamp?)?.toDate();
      if (date == null) continue;

      final workoutDate = DateTime(date.year, date.month, date.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (previousDate == null) {
        // 最初の記録
        final daysDiff = todayDate.difference(workoutDate).inDays;
        if (daysDiff > 1) {
          // 最新のワークアウトが2日以上前ならストリーク0
          break;
        }
        streak = 1;
        previousDate = workoutDate;
      } else {
        // 前回の記録との差を確認
        final daysDiff = previousDate.difference(workoutDate).inDays;
        if (daysDiff == 1) {
          // 連続している
          streak++;
          previousDate = workoutDate;
        } else if (daysDiff > 1) {
          // 連続が途切れた
          break;
        }
        // daysDiff == 0 の場合は同じ日なのでスキップ
      }
    }

    return streak;
  }

  /// 累計総重量を計算
  Future<int> _calculateTotalWeight(String userId) async {
    final workouts = await _firestore
        .collection('workout_logs')
        .where('user_id', isEqualTo: userId)
        .get();

    int totalWeight = 0;

    for (var doc in workouts.docs) {
      final sets = doc.data()['sets'] as List<dynamic>?;
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

    return totalWeight;
  }

  /// PR回数を計算（簡易実装）
  Future<int> _calculatePrCount(String userId) async {
    // 簡易実装: 種目ごとの最大重量記録の更新回数をカウント
    // シンプルなクエリ（インデックス不要）
    final workouts = await _firestore
        .collection('workout_logs')
        .where('user_id', isEqualTo: userId)
        .get();
    
    // メモリ内でソート（古い順）
    final sortedDocs = workouts.docs.toList()
      ..sort((a, b) {
        final dateA = (a.data()['date'] as Timestamp?)?.toDate();
        final dateB = (b.data()['date'] as Timestamp?)?.toDate();
        if (dateA == null || dateB == null) return 0;
        return dateA.compareTo(dateB); // 昇順
      });

    final Map<String, double> exerciseMaxWeight = {};
    int prCount = 0;

    for (var doc in sortedDocs) {
      final sets = doc.data()['sets'] as List<dynamic>?;
      if (sets == null) continue;

      for (var set in sets) {
        final isCardio = set['is_cardio'] as bool? ?? false;
        if (isCardio) continue;

        final exerciseName = set['exercise_name'] as String? ?? '';
        final weight = (set['weight'] as num?)?.toDouble() ?? 0;

        if (exerciseName.isNotEmpty && weight > 0) {
          final currentMax = exerciseMaxWeight[exerciseName] ?? 0;
          if (weight > currentMax) {
            exerciseMaxWeight[exerciseName] = weight;
            prCount++;
          }
        }
      }
    }

    return prCount;
  }

  /// ユーザーの全バッジを取得
  Future<List<Achievement>> getUserBadges(String userId) async {
    final snapshot = await _firestore
        .collection('user_achievements')
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => Achievement.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// 解除済みバッジのみを取得
  Future<List<Achievement>> getUnlockedBadges(String userId) async {
    // シンプルなクエリ（インデックス不要）
    final snapshot = await _firestore
        .collection('user_achievements')
        .where('user_id', isEqualTo: userId)
        .get();

    // メモリ内でフィルター&ソート
    final unlockedBadges = snapshot.docs
        .map((doc) => Achievement.fromFirestore(doc.data(), doc.id))
        .where((badge) => badge.isUnlocked)
        .toList();
    
    // 解除日時でソート（新しい順）
    unlockedBadges.sort((a, b) {
      if (a.unlockedAt == null || b.unlockedAt == null) return 0;
      return b.unlockedAt!.compareTo(a.unlockedAt!);
    });
    
    return unlockedBadges;
  }

  /// バッジ統計を取得
  Future<Map<String, int>> getBadgeStats(String userId) async {
    final allBadges = await getUserBadges(userId);
    final unlockedBadges = allBadges.where((b) => b.isUnlocked).toList();

    return {
      'total': allBadges.length,
      'unlocked': unlockedBadges.length,
      'locked': allBadges.length - unlockedBadges.length,
    };
  }
}

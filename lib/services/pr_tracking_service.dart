import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/personal_record.dart';

/// PR（Personal Record）追跡サービス
/// 
/// トレーニング記録から自己ベストを自動検出し、
/// Firestoreの personal_records コレクションに保存します。
class PRTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// トレーニング記録からPRをチェックし、必要に応じて更新
  /// 
  /// Returns: 新記録が達成された場合は PersonalRecord のリスト
  Future<List<PersonalRecord>> checkAndUpdatePRs({
    required String userId,
    required List<Map<String, dynamic>> sets,
    required DateTime achievedDate,
    String gymId = 'default',
  }) async {
    final newRecords = <PersonalRecord>[];

    try {
      // 種目ごとにグループ化
      final exerciseGroups = <String, List<Map<String, dynamic>>>{};
      for (var set in sets) {
        final exerciseName = set['exercise_name'] as String;
        exerciseGroups.putIfAbsent(exerciseName, () => []).add(set);
      }

      // 各種目の最大1RMをチェック
      for (var entry in exerciseGroups.entries) {
        final exerciseName = entry.key;
        final exerciseSets = entry.value;

        // この種目の最大1RMを計算
        double maxCalculated1RM = 0;
        double maxWeight = 0;
        int maxReps = 0;

        for (var set in exerciseSets) {
          final weight = (set['weight'] as num).toDouble();
          final reps = set['reps'] as int;
          final calculated1RM = PersonalRecord.calculate1RM(weight, reps);

          if (calculated1RM > maxCalculated1RM) {
            maxCalculated1RM = calculated1RM;
            maxWeight = weight;
            maxReps = reps;
          }
        }

        // 現在のPRを取得
        final currentPR = await getCurrentPR(userId, exerciseName);

        // 新記録かチェック
        bool isNewRecord = false;
        if (currentPR == null) {
          // 初回記録
          isNewRecord = true;
        } else if (maxCalculated1RM > currentPR.calculated1RM) {
          // 既存記録を更新
          isNewRecord = true;
        }

        if (isNewRecord) {
          // 新記録を保存
          final newRecord = await _savePR(
            userId: userId,
            exerciseName: exerciseName,
            weight: maxWeight,
            reps: maxReps,
            calculated1RM: maxCalculated1RM,
            achievedDate: achievedDate,
            gymId: gymId,
            currentPRId: currentPR?.id,
          );

          if (newRecord != null) {
            newRecords.add(newRecord);
          }
        }
      }

      return newRecords;
    } catch (e) {
      print('❌ PR追跡エラー: $e');
      return [];
    }
  }

  /// 現在のPRを取得
  Future<PersonalRecord?> getCurrentPR(String userId, String exerciseName) async {
    try {
      final snapshot = await _firestore
          .collection('personal_records')
          .where('userId', isEqualTo: userId)
          .where('exerciseName', isEqualTo: exerciseName)
          .orderBy('calculated1RM', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return PersonalRecord.fromFirestore(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      print('❌ PR取得エラー: $e');
      return null;
    }
  }

  /// 全ての種目のPRを取得
  Future<List<PersonalRecord>> getAllPRs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('personal_records')
          .where('userId', isEqualTo: userId)
          .orderBy('calculated1RM', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PersonalRecord.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ 全PR取得エラー: $e');
      return [];
    }
  }

  /// PRを保存または更新
  Future<PersonalRecord?> _savePR({
    required String userId,
    required String exerciseName,
    required double weight,
    required int reps,
    required double calculated1RM,
    required DateTime achievedDate,
    required String gymId,
    String? currentPRId,
  }) async {
    try {
      final bodyPart = _getBodyPartFromExercise(exerciseName);
      
      final prData = {
        'userId': userId,
        'exerciseName': exerciseName,
        'bodyPart': bodyPart,
        'weight': weight,
        'reps': reps,
        'calculated1RM': calculated1RM,
        'achievedAt': Timestamp.fromDate(achievedDate),
        'gymId': gymId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef;
      if (currentPRId != null) {
        // 既存記録を更新
        docRef = _firestore.collection('personal_records').doc(currentPRId);
        await docRef.update(prData);
      } else {
        // 新規記録を作成
        docRef = await _firestore.collection('personal_records').add(prData);
      }

      print('✅ PR保存成功: $exerciseName - ${calculated1RM.toStringAsFixed(1)}kg (1RM)');

      return PersonalRecord(
        id: docRef.id,
        userId: userId,
        exerciseName: exerciseName,
        bodyPart: bodyPart,
        weight: weight,
        reps: reps,
        calculated1RM: calculated1RM,
        achievedAt: achievedDate,
        gymId: gymId,
      );
    } catch (e) {
      print('❌ PR保存エラー: $e');
      return null;
    }
  }

  /// 種目名から部位を推定
  String _getBodyPartFromExercise(String exerciseName) {
    final Map<String, String> exerciseBodyParts = {
      // 胸
      'ベンチプレス': '胸',
      'インクラインプレス': '胸',
      'ダンベルフライ': '胸',
      'ケーブルフライ': '胸',
      'ディップス': '胸',
      'プッシュアップ': '胸',
      
      // 背中
      'デッドリフト': '背中',
      'バーベルロウ': '背中',
      'ダンベルロウ': '背中',
      'ラットプルダウン': '背中',
      'プルアップ': '背中',
      'シーテッドロウ': '背中',
      
      // 脚
      'スクワット': '脚',
      'レッグプレス': '脚',
      'レッグエクステンション': '脚',
      'レッグカール': '脚',
      'カーフレイズ': '脚',
      
      // 肩
      'ショルダープレス': '肩',
      'ダンベルプレス': '肩',
      'サイドレイズ': '肩',
      'フロントレイズ': '肩',
      'リアレイズ': '肩',
      
      // 腕
      'バーベルカール': '腕',
      'ダンベルカール': '腕',
      'トライセプスエクステンション': '腕',
      'スカルクラッシャー': '腕',
    };

    return exerciseBodyParts[exerciseName] ?? 'その他';
  }

  /// 種目別のPR履歴を取得（グラフ表示用）
  Future<List<PersonalRecord>> getPRHistory(
    String userId,
    String exerciseName, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('personal_records')
          .where('userId', isEqualTo: userId)
          .where('exerciseName', isEqualTo: exerciseName)
          .orderBy('achievedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PersonalRecord.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ PR履歴取得エラー: $e');
      return [];
    }
  }
}

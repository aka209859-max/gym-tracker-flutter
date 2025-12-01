import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_log.dart';
import '../models/exercise.dart';

/// クイックスタートサービス（v1.02新機能）
/// 
/// 初心者向けのサンプルトレーニングを提供
class QuickStartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// クイックスタートテンプレート（初心者向け）
  static final Map<String, List<Map<String, dynamic>>> templates = {
    '胸トレ初心者': [
      {
        'name': 'ベンチプレス',
        'sets': 3,
        'reps': 10,
        'weight': 40.0,
        'notes': 'バーベルを胸につけるイメージで',
      },
      {
        'name': 'ダンベルフライ',
        'sets': 3,
        'reps': 12,
        'weight': 10.0,
        'notes': '胸を大きく開くイメージで',
      },
      {
        'name': 'プッシュアップ',
        'sets': 3,
        'reps': 15,
        'weight': 0.0,
        'notes': '体幹をまっすぐに保つ',
      },
    ],
    '背中トレ初心者': [
      {
        'name': 'デッドリフト',
        'sets': 3,
        'reps': 8,
        'weight': 50.0,
        'notes': '背中をまっすぐに保つ',
      },
      {
        'name': 'ラットプルダウン',
        'sets': 3,
        'reps': 12,
        'weight': 30.0,
        'notes': '肩甲骨を寄せるイメージで',
      },
      {
        'name': 'ダンベルロウ',
        'sets': 3,
        'reps': 10,
        'weight': 12.0,
        'notes': '肘を後ろに引くイメージで',
      },
    ],
    '脚トレ初心者': [
      {
        'name': 'スクワット',
        'sets': 3,
        'reps': 10,
        'weight': 40.0,
        'notes': '膝がつま先より前に出ないように',
      },
      {
        'name': 'レッグプレス',
        'sets': 3,
        'reps': 12,
        'weight': 60.0,
        'notes': '足全体で押すイメージで',
      },
      {
        'name': 'レッグカール',
        'sets': 3,
        'reps': 15,
        'weight': 20.0,
        'notes': 'ハムストリングスを意識',
      },
    ],
    '全身トレ初心者': [
      {
        'name': 'スクワット',
        'sets': 3,
        'reps': 10,
        'weight': 40.0,
        'notes': '下半身の王道種目',
      },
      {
        'name': 'ベンチプレス',
        'sets': 3,
        'reps': 10,
        'weight': 40.0,
        'notes': '上半身の押す動作',
      },
      {
        'name': 'デッドリフト',
        'sets': 3,
        'reps': 8,
        'weight': 50.0,
        'notes': '背中とハムストリングス',
      },
    ],
  };

  /// テンプレート一覧を取得
  List<String> getTemplateNames() {
    return templates.keys.toList();
  }

  /// テンプレートからサンプルトレーニングを作成
  Future<String> createSampleWorkout(String templateName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final template = templates[templateName];
    if (template == null) throw Exception('Template not found');

    try {
      // ワークアウトログを作成
      final workoutLogRef = _firestore.collection('workout_logs').doc();
      
      final exercises = template.map((exercise) {
        return Exercise(
          name: exercise['name'] as String,
          sets: List.generate(
            exercise['sets'] as int,
            (index) => ExerciseSet(
              weight: exercise['weight'] as double,
              reps: exercise['reps'] as int,
              setType: 'normal',
              rpe: 7.0, // サンプルなので中程度の強度
            ),
          ),
          notes: exercise['notes'] as String?,
        );
      }).toList();

      final workoutLog = WorkoutLog(
        id: workoutLogRef.id,
        userId: user.uid,
        date: DateTime.now(),
        exercises: exercises,
        duration: Duration(minutes: 45), // サンプル時間
        totalVolume: _calculateTotalVolume(exercises),
        notes: '🚀 クイックスタート: $templateName',
        gymId: null,
        gymName: null,
      );

      await workoutLogRef.set(workoutLog.toFirestore());

      print('✅ クイックスタート作成成功: $templateName');
      return workoutLogRef.id;
    } catch (e) {
      print('❌ クイックスタート作成エラー: $e');
      throw Exception('Failed to create sample workout: $e');
    }
  }

  /// 総挙上重量を計算
  double _calculateTotalVolume(List<Exercise> exercises) {
    double total = 0.0;
    for (var exercise in exercises) {
      for (var set in exercise.sets) {
        total += set.weight * set.reps;
      }
    }
    return total;
  }

  /// クイックスタートを使用済みにする
  Future<void> markAsUsed() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'quickStartUsed': true,
      'quickStartUsedAt': FieldValue.serverTimestamp(),
    });
  }

  /// クイックスタート使用済みかチェック
  Future<bool> hasUsedQuickStart() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();

    return data?['quickStartUsed'] as bool? ?? false;
  }
}

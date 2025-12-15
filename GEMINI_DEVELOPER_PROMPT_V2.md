# 🚨 GYM MATCH iOS版 - 緊急バグ修正依頼 (v1.0.244+269)

**日付**: 2025-12-15  
**対象**: Gemini Developer  
**優先度**: HIGH  
**iOS Repository**: https://github.com/aka209859-max/gym-tracker-flutter

---

## 📊 現状の問題サマリー

TestFlight Build 269をデプロイしましたが、以下4つの重大な問題が未解決です：

### 🔴 Problem 1: 部位別トラッキングで「その他」が残存
### 🔴 Problem 2: 有酸素運動の入力UIが間違っている（バーピージャンプ）
### 🔴 Problem 3: PR記録画面がドロップダウンのまま
### 🔴 Problem 4: メモと週次レポートが空

---

## 🔴 Problem 1: 部位別トラッキング「その他」103回 (100%)

### **スクリーンショット分析**
- 📷 URL: https://www.genspark.ai/api/files/s/xT7RD4ip
- **現状**: 「その他」が103回（100%）と表示
- **期待**: 各部位（脚、肩、背中など）が正しく分類される

### **原因分析**

#### 修正したはずのコード (v1.0.243+268)
```dart
// lib/services/exercise_master_data.dart
class ExerciseMasterData {
  static const Map<String, List<String>> muscleGroupExercises = {
    '胸': ['ベンチプレス', 'ダンベルプレス', ...],
    '脚': ['バーベルスクワット', 'スクワット', 'レッグプレス', ...],
    '背中': ['デッドリフト', 'ラットプルダウン', 'チンニング', '懸垂', ...],
    '肩': ['ショルダープレス', 'サイドレイズ', ...],
    '有酸素': ['ランニング', 'バーピージャンプ', ...],
    // ...
  };

  static String getBodyPartByName(String exerciseName) {
    for (final entry in muscleGroupExercises.entries) {
      if (entry.value.contains(exerciseName)) {
        return entry.key;
      }
    }
    return 'その他';  // ← ここが呼ばれている
  }
}
```

#### データ保存処理 (v1.0.243+268)
```dart
// lib/screens/workout/add_workout_screen.dart (Line ~505)
'sets': _sets.map((set) {
  return {
    'exercise_name': set.exerciseName,
    'bodyPart': ExerciseMasterData.getBodyPartByName(set.exerciseName), // ← 追加
    'weight': ...,
    'reps': ...,
    'is_cardio': set.isCardio,
    // ...
  };
}).toList(),
```

#### 部位別トラッキング画面 (v1.0.243+268)
```dart
// lib/screens/workout/body_part_tracking_screen.dart
Map<String, int> _calculateBodyPartStats(List<WorkoutLog> logs) {
  final stats = <String, int>{};
  
  for (final log in logs) {
    for (final exercise in log.exercises) {
      for (final set in exercise.sets) {
        // 🔧 v1.0.243: bodyPart フィールドを使用（なければ種目名から推定）
        final bodyPart = set.bodyPart ?? 
            ExerciseMasterData.getBodyPartByName(exercise.name);
        stats[bodyPart] = (stats[bodyPart] ?? 0) + 1;
      }
    }
  }
  
  return stats;
}
```

### **問題の可能性**

#### Possibility A: データ保存が正しく機能していない
**検証方法**:
```dart
// add_workout_screen.dart の _saveWorkout() で確認
debugPrint('🔍 保存データ確認:');
for (final set in _sets) {
  final bodyPart = ExerciseMasterData.getBodyPartByName(set.exerciseName);
  debugPrint('  ${set.exerciseName} → bodyPart: $bodyPart');
}
```

**確認ポイント**:
- `ExerciseMasterData.getBodyPartByName()` が正しく動作しているか？
- `bodyPart` フィールドが Firestore に保存されているか？
- Firestore のデータ構造: `workout_logs/{docId}/sets[]/bodyPart` が存在するか？

#### Possibility B: 種目名のマッチングが失敗
**例**:
- ユーザーが入力した種目名: `"バーベルスクワット "`（末尾スペース）
- マスターデータ: `"バーベルスクワット"`
- 結果: マッチせず → `'その他'`

**解決策**:
```dart
static String getBodyPartByName(String exerciseName) {
  final trimmed = exerciseName.trim(); // スペース除去
  for (final entry in muscleGroupExercises.entries) {
    if (entry.value.any((e) => e == trimmed)) {
      return entry.key;
    }
  }
  return 'その他';
}
```

#### Possibility C: 既存データに bodyPart がない
**問題**:
- v1.0.243より前のデータには `bodyPart` フィールドが存在しない
- Runtime補完が機能していない可能性

**確認コード**:
```dart
// lib/models/workout_log.dart の WorkoutSet.fromMap
factory WorkoutSet.fromMap(Map<String, dynamic> map) {
  final bodyPart = map['bodyPart'] as String?;
  final exerciseName = map['exercise_name'] as String? ?? '';
  
  debugPrint('🔍 WorkoutSet.fromMap:');
  debugPrint('  exercise_name: $exerciseName');
  debugPrint('  bodyPart (stored): $bodyPart');
  
  // Runtime補完
  final finalBodyPart = bodyPart ?? 
      ExerciseMasterData.getBodyPartByName(exerciseName);
  
  debugPrint('  bodyPart (final): $finalBodyPart');
  
  return WorkoutSet(
    // ...
    bodyPart: finalBodyPart,
  );
}
```

### **📝 Action Items for Problem 1**

1. **デバッグログ追加**: `add_workout_screen.dart` の `_saveWorkout()` で bodyPart 保存を確認
2. **Firestore データ確認**: Firebase Console で `workout_logs` の実際のデータ構造確認
3. **種目名マッチング改善**: trim() 処理と部分一致サポート
4. **既存データ補完**: `WorkoutSet.fromMap` で runtime 補完が正しく動作しているか確認

---

## 🔴 Problem 2: 有酸素運動の入力UIが間違っている

### **スクリーンショット分析**
- 📷 URL: https://www.genspark.ai/api/files/s/I3R24gQe
- **種目**: バーピージャンプ
- **現状**: 「重量 (kg)」と「回数」の入力フィールド
- **期待**: 「時間 (分)」と「距離 (km)」の入力フィールド

### **原因分析**

#### ExerciseMasterData に登録済み
```dart
// lib/services/exercise_master_data.dart
'有酸素': [
  'ランニング', 'ジョギング', 'サイクリング', 'エアロバイク', 
  'ステッパー', '水泳', 'ローイングマシン', 'ウォーキング', 
  'インターバルラン', 'クロストレーナー', 'バトルロープ', 
  'バーピージャンプ',  // ← 登録済み
  'マウンテンクライマー',
],

static bool isCardioExercise(String exerciseName) {
  return muscleGroupExercises['有酸素']?.contains(exerciseName) ?? false;
}
```

#### セット作成時の isCardio 判定
```dart
// lib/screens/workout/add_workout_screen.dart (Line ~1200)
WorkoutSet(
  exerciseName: exerciseName,
  targetReps: 10,
  targetWeight: 0.0,
  isCardio: _isCardioExercise(exerciseName), // ← ここで判定
  isTimeMode: _getDefaultTimeMode(exerciseName),
  // ...
)

// Helper function
bool _isCardioExercise(String exerciseName) {
  final cardioExercises = [
    'ランニング', 'ジョギング', 'サイクリング', 'エアロバイク',
    'ステッパー', '水泳', 'ローイングマシン', 'ウォーキング',
    'インターバルラン', 'クロストレーナー', 'バトルロープ',
    'バーピージャンプ', // ← リストに存在
    'マウンテンクライマー',
  ];
  return cardioExercises.contains(exerciseName);
}
```

#### UI表示ロジック
```dart
// lib/screens/workout/add_workout_screen.dart (Line ~2445)
TextField(
  decoration: InputDecoration(
    labelText: set.isCardio ? '時間 (分)' : '重量 (kg)', // ← set.isCardio フラグで分岐
  ),
  // ...
)
```

### **問題の可能性**

#### Possibility A: セット追加時に isCardio が false のまま
**シナリオ**:
1. ユーザーがカスタム種目として「バーピージャンプ」を追加
2. `_isCardioExercise()` が呼ばれるが、何らかの理由で false を返す
3. UI は「重量 (kg)」と「回数」を表示

**検証方法**:
```dart
// add_workout_screen.dart の _addCustomExercise() 付近
debugPrint('🔍 カスタム種目追加: $exerciseName');
final isCardio = _isCardioExercise(exerciseName);
debugPrint('  → isCardio: $isCardio');
```

#### Possibility B: 種目名が完全一致していない
**例**:
- ユーザー入力: `"バーピー ジャンプ"`（スペース入り）
- リスト: `"バーピージャンプ"`
- 結果: マッチせず → `isCardio = false`

**解決策**:
```dart
bool _isCardioExercise(String exerciseName) {
  final normalized = exerciseName.trim().replaceAll(' ', ''); // スペース除去
  return cardioExercises.any((cardio) => 
    cardio.replaceAll(' ', '') == normalized
  );
}
```

#### Possibility C: AIコーチから渡される isCardio が無視されている
**確認ポイント**:
```dart
// AIコーチからのデータ初期化 (Line ~188)
final isCardio = _getPropertyValue(exercise, 'isCardio') as bool? ?? false;
debugPrint('  🏋️ 種目: $exerciseName (有酸素: $isCardio)');

// セット作成時
WorkoutSet(
  exerciseName: exerciseName,
  isCardio: isCardio, // ← AIコーチの値を使用しているか？
  // ...
)
```

### **📝 Action Items for Problem 2**

1. **デバッグログ追加**: セット追加時に `isCardio` の値を確認
2. **種目名正規化**: trim() とスペース除去を実装
3. **ExerciseMasterData 統合**: `_isCardioExercise()` を `ExerciseMasterData.isCardioExercise()` に統一
4. **AIコーチ連携確認**: ParsedExercise の isCardio が正しく反映されているか確認

---

## 🔴 Problem 3: PR記録画面がドロップダウンのまま

### **スクリーンショット分析**
- 📷 URL: https://www.genspark.ai/api/files/s/iVYK2FWJ
- **現状**: 「種目を選択」というドロップダウン
- **期待**: 全PR記録を一覧表示 + タップでグラフ表示

### **現在の実装**
```dart
// lib/screens/workout/personal_records_screen.dart (Line ~19)
String? _selectedExercise;
List<String> _exercises = [];

// ドロップダウン実装
DropdownButton<String>(
  value: _selectedExercise,
  items: _exercises.map((exercise) {
    return DropdownMenuItem(
      value: exercise,
      child: Text(exercise),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedExercise = value;
    });
  },
)
```

### **要求される新UI**

#### デザイン要件
- **一覧表示**: 全種目をカード形式で表示
- **情報表示**: 各種目の最新PR（重量/回数/日付）
- **グラフ**: タップで時系列グラフを展開
- **ソート**: PR記録回数順、最新日付順

#### 実装案
```dart
// PR記録カード
class PRRecordCard extends StatelessWidget {
  final String exerciseName;
  final double maxWeight;
  final int maxReps;
  final DateTime lastRecordDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(exerciseName),
        subtitle: Text('${maxWeight}kg × ${maxReps}回'),
        trailing: Text(DateFormat('yyyy/MM/dd').format(lastRecordDate)),
        onTap: onTap, // グラフ表示
      ),
    );
  }
}
```

### **📝 Action Items for Problem 3**

1. **UI再設計**: ドロップダウンをカード一覧に変更
2. **PR計算**: 各種目の最大重量/回数を集計
3. **グラフ実装**: タップでfl_chartを使用した時系列グラフ表示
4. **ソート機能**: PR回数、最新日付でソート

---

## 🔴 Problem 4: メモと週次レポートが空

### **スクリーンショット分析**

#### メモ画面
- 📷 URL: https://www.genspark.ai/api/files/s/PYD2NxYO
- **現状**: 「メモはまだありません」
- **問題**: トレーニング記録にメモを追加したはずなのに表示されない

#### 週次レポート画面
- 📷 URL: https://www.genspark.ai/api/files/s/cIFw20mR
- **現状**: 「まだ週次レポートがありません」
- **期待**: 毎週月曜日に自動生成される

### **メモ機能の問題**

#### 現在の実装
```dart
// lib/screens/workout/workout_memo_list_screen.dart
Future<void> _loadMemosWithWorkouts() async {
  final user = firebase_auth.FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // workout_notes コレクションから取得
  final notesSnapshot = await FirebaseFirestore.instance
      .collection('workout_notes')
      .where('user_id', isEqualTo: user.uid)
      .orderBy('created_at', descending: true)
      .get();

  // メモとワークアウトログを関連付け
  for (final noteDoc in notesSnapshot.docs) {
    final workoutSessionId = noteData['workout_session_id'] as String?;
    if (workoutSessionId != null) {
      final workoutDoc = await FirebaseFirestore.instance
          .collection('workout_logs')
          .doc(workoutSessionId)
          .get();
      // ...
    }
  }
}
```

#### 保存処理の確認
```dart
// lib/screens/workout/add_workout_screen.dart (Line ~1590)
if (_memoController.text.isNotEmpty) {
  final noteId = DateTime.now().millisecondsSinceEpoch.toString();
  await FirebaseFirestore.instance
      .collection('workout_notes')
      .doc(noteId)
      .set({
    'user_id': user.uid,
    'workout_session_id': sessionId,
    'content': _memoController.text,
    'created_at': Timestamp.now(),
  });
  debugPrint('✅ メモ保存完了: $noteId');
}
```

#### 問題の可能性

**Possibility A: workout_session_id が一致しない**
- 保存時の `sessionId` と読み込み時の `workout_session_id` が異なる可能性
- sessionId の生成方法を確認する必要あり

**Possibility B: created_at インデックスが存在しない**
- Firestore で `orderBy('created_at')` を使用しているが、インデックスが未作成
- Firebase Console で複合インデックスを確認

**Possibility C: メモが保存されていない**
- `_memoController.text.isNotEmpty` の条件が満たされていない
- デバッグログ「✅ メモ保存完了」が出力されていない

### **週次レポート機能の問題**

#### 現在の実装
```dart
// lib/screens/workout/weekly_reports_screen.dart
// Cloud Function で自動生成される想定
// users/{uid}/weeklyReports コレクションを読み込み
final reportsSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .collection('weeklyReports')
    .orderBy('weekEnd', descending: true)
    .limit(10)
    .get();
```

#### 問題の可能性

**Root Cause: Cloud Function が未実装**
- 週次レポートは Cloud Function で自動生成される設計
- しかし、Cloud Function がまだ実装されていない
- 結果: `weeklyReports` コレクションが空のまま

**優先度**: 低（Cloud Function実装は別タスク）

### **📝 Action Items for Problem 4**

#### メモ機能
1. **sessionId 確認**: 保存時と読み込み時のIDが一致しているか確認
2. **Firestore インデックス**: `workout_notes` の `created_at` インデックス作成
3. **デバッグログ**: メモ保存処理が正常に動作しているか確認
4. **データ確認**: Firebase Console で `workout_notes` コレクションの実データ確認

#### 週次レポート
1. **優先度低**: Cloud Function実装は別タスクとして扱う
2. **代替案**: 手動生成機能を実装（「今すぐ生成」ボタン）
3. **UI改善**: 「Cloud Function未実装」の説明を追加

---

## 🎯 修正の優先順位

### Priority 1: Critical (即時修正必要)
1. ✅ **Problem 2**: 有酸素運動の入力UI（バーピージャンプ）
   - ユーザーが毎回間違った入力をしてしまう
   - データ整合性に影響

2. ✅ **Problem 1**: 部位別トラッキング「その他」100%
   - メイン機能が全く動作していない
   - ユーザー体験が著しく低下

### Priority 2: High (早急に対応)
3. ✅ **Problem 4a**: メモ機能が表示されない
   - トレーニング記録の重要な補足情報が失われている

### Priority 3: Medium (次期バージョン)
4. ⚠️ **Problem 3**: PR記録画面のUI改善
   - 既存機能は動作しているが、UXが悪い

5. ⚠️ **Problem 4b**: 週次レポート（Cloud Function未実装）
   - 別タスクとして扱う

---

## 📊 デバッグ手順

### Step 1: ローカル環境での再現
```bash
# iOS Simulatorで実行
cd /home/user/webapp
flutter run -d simulator
```

### Step 2: Firestore データ確認
Firebase Console で以下を確認：
1. `workout_logs/{docId}/sets[]/bodyPart` フィールドの存在
2. `workout_logs/{docId}/sets[]/is_cardio` フィールドの値
3. `workout_notes` コレクションの実データ
4. `users/{uid}/weeklyReports` コレクションの有無

### Step 3: デバッグログ追加
```dart
// 各機能で以下を追加
debugPrint('🔍 DEBUG: $functionName');
debugPrint('  Input: $input');
debugPrint('  Output: $output');
```

### Step 4: 修正とテスト
1. 修正コードをコミット
2. TestFlightビルド作成
3. ユーザーに検証依頼

---

## 📝 期待される成果物

### Deliverable 1: 修正コード
- 4つの問題すべてに対する修正コミット
- 明確なコミットメッセージ（例: `fix: Cardio exercise UI for バーピージャンプ`）

### Deliverable 2: テスト結果
- 各問題の修正確認
- スクリーンショットによる Before/After

### Deliverable 3: ドキュメント
- 修正内容の詳細説明
- 今後の予防策

---

## 🆘 緊急連絡先

**Repository**: https://github.com/aka209859-max/gym-tracker-flutter (iOS専用)  
**Current Version**: v1.0.244 (Build 269)  
**Deadline**: 2025-12-16 EOD

**重要**: このリポジトリはiOS専用です。Android版（gym-tracker-flutter-android）には触れないでください。

---

**Gemini Developer様、これらの問題の早急な修正をお願いいたします。特にProblem 1と2は、ユーザー体験に直接影響するため、最優先での対応が必要です。**

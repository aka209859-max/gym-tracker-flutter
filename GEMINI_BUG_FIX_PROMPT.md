# 🐛 GYM MATCH - Critical Bug Fix Request for Gemini Developer

**Date**: 2025-12-15  
**Version**: v1.0.244 (Build 269)  
**Platform**: iOS  
**Priority**: HIGH

---

## 📋 Executive Summary

TestFlight Build 269で以下の4つの重大な問題が確認されました：

1. ✅ **部位別トラッキング** - 「その他」が103回(100%)で残存（修正が不完全）
2. ✅ **PR記録画面** - ドロップダウンのまま（未実装）
3. ✅ **メモ機能** - 空のまま表示されない
4. ✅ **週次レポート** - 空のまま表示されない
5. ⚠️ **有酸素運動入力UI** - バーピージャンプが「重さ(kg) × 回数」表示（本来は「時間(分) × 距離(km)」であるべき）

---

## 🔴 Problem 1: 部位別トラッキング - 「その他」が100%表示

### **現象**
- 画面: トレーニング履歴 → 部位別タブ
- 表示: 「その他 103回 100%」
- 期待: 脚40%、肩38%、背中35%など、実際の部位が表示されるべき

### **スクリーンショット**
URL: https://www.genspark.ai/api/files/s/xT7RD4ip

### **過去の修正内容（v1.0.243, commit 665d0db）**
```dart
// lib/services/exercise_master_data.dart - 作成済み
// lib/models/workout_log.dart - WorkoutSet に bodyPart フィールド追加
// lib/screens/workout/add_workout_screen.dart - 保存時に bodyPart 追加
```

### **問題の原因（推定）**

#### **原因1: 既存データに bodyPart が null**
- 過去のworkout_logsには `bodyPart` フィールドが存在しない
- `WorkoutSet.fromMap()` で runtime 補完を実装したが、不完全

#### **原因2: bodyPart 推定ロジックの不備**
`lib/models/workout_log.dart` の `fromMap()` で以下を実装済み：
```dart
// ✅ v1.0.243: 既存データの bodyPart を推定
final bodyPart = map['bodyPart'] as String? ?? 
                 ExerciseMasterData.getBodyPart(exerciseName) ?? 
                 'その他';
```

しかし、`ExerciseMasterData.getBodyPart()` が正しく動作していない可能性。

### **Required Fix**

#### **Step 1: ExerciseMasterData.getBodyPart() の検証**
`lib/services/exercise_master_data.dart` を確認：
```dart
static String? getBodyPart(String exerciseName) {
  for (var entry in _exerciseMap.entries) {
    if (entry.value.contains(exerciseName)) {
      return entry.key; // 部位を返す
    }
  }
  return null; // 見つからない場合は null
}
```

**問題の可能性**:
- `_exerciseMap` に種目が登録されていない
- 種目名の表記揺れ（例: "デッドリフト" vs "バーベルデッドリフト"）
- 大文字小文字の違い

#### **Step 2: 種目名の表記揺れ対応**
```dart
static String? getBodyPart(String exerciseName) {
  // 正規化: 前後の空白を削除、小文字化
  final normalized = exerciseName.trim().toLowerCase();
  
  for (var entry in _exerciseMap.entries) {
    for (var exercise in entry.value) {
      if (exercise.toLowerCase() == normalized || 
          normalized.contains(exercise.toLowerCase())) {
        return entry.key;
      }
    }
  }
  return null;
}
```

#### **Step 3: デバッグログ追加**
`lib/models/workout_log.dart` の `fromMap()` にログ追加：
```dart
final bodyPart = map['bodyPart'] as String? ?? 
                 ExerciseMasterData.getBodyPart(exerciseName) ?? 
                 'その他';

// デバッグログ
if (bodyPart == 'その他') {
  print('⚠️ 種目「$exerciseName」が「その他」に分類されました');
  print('   ExerciseMasterData.getBodyPart() の結果: ${ExerciseMasterData.getBodyPart(exerciseName)}');
}
```

#### **Step 4: 種目マスターデータの拡充**
`lib/services/exercise_master_data.dart` に不足している種目を追加：
- ユーザーが実際に使用している種目名を確認
- 表記揺れを全てカバー

---

## 🔴 Problem 2: PR記録画面 - ドロップダウンのまま

### **現象**
- 画面: トレーニング履歴 → PR記録タブ
- 表示: ドロップダウンで「種目を選択」→ 「インクラインDP」を選択 → 「まだ記録がありません」
- 期待: ドロップダウンを廃止し、記録がある全種目を一覧表示、タップでグラフ表示

### **スクリーンショット**
URL: https://www.genspark.ai/api/files/s/iVYK2FWJ

### **ユーザー要望（再確認）**
> PR記録ではドロップダウンを廃止し、入力済みのメニュー（カスタム含む）を一覧表示し、タップで過去の記録をグラフ表示してほしい。

### **現在の実装**
`lib/screens/workout/personal_records_screen.dart`:
- ドロップダウンで種目を選択
- 選択した種目のPR履歴を表示

### **Required Implementation**

#### **新しいUI設計**

```
┌─────────────────────────────────┐
│  パーソナルレコード              │
├─────────────────────────────────┤
│  🏋️ ベンチプレス                │
│     現在のPR: 100kg × 10reps    │
│     └→ タップでグラフ表示       │
├─────────────────────────────────┤
│  🏋️ デッドリフト                │
│     現在のPR: 150kg × 5reps     │
│     └→ タップでグラフ表示       │
├─────────────────────────────────┤
│  🏋️ スクワット                  │
│     現在のPR: 120kg × 8reps     │
│     └→ タップでグラフ表示       │
└─────────────────────────────────┘
```

#### **実装手順**

**Step 1: 全種目のPRデータ取得**
```dart
Future<Map<String, PRRecord>> _loadAllPRRecords() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return {};
  
  // 全てのworkout_logsからユニークな種目とそのPRを取得
  final snapshot = await FirebaseFirestore.instance
      .collection('workout_logs')
      .where('user_id', isEqualTo: user.uid)
      .get();
  
  Map<String, PRRecord> prRecords = {};
  
  for (var doc in snapshot.docs) {
    final sets = doc.data()['sets'] as List?;
    if (sets == null) continue;
    
    for (var set in sets) {
      final exerciseName = set['exercise_name'] as String?;
      final weight = (set['weight'] as num?)?.toDouble() ?? 0.0;
      final reps = set['reps'] as int? ?? 0;
      
      if (exerciseName == null) continue;
      
      // PRの更新判定（1RM計算）
      final oneRM = _calculate1RM(weight, reps);
      
      if (!prRecords.containsKey(exerciseName) || 
          oneRM > prRecords[exerciseName]!.oneRM) {
        prRecords[exerciseName] = PRRecord(
          exerciseName: exerciseName,
          weight: weight,
          reps: reps,
          oneRM: oneRM,
          date: doc.data()['date'] as Timestamp,
        );
      }
    }
  }
  
  return prRecords;
}

double _calculate1RM(double weight, int reps) {
  if (reps == 1) return weight;
  // Brzycki式: 1RM = weight × (36 / (37 - reps))
  return weight * (36 / (37 - reps));
}
```

**Step 2: リスト表示UI**
```dart
Widget _buildPRList(Map<String, PRRecord> prRecords) {
  if (prRecords.isEmpty) {
    return Center(child: Text('まだPR記録がありません'));
  }
  
  // 1RM降順でソート
  final sortedEntries = prRecords.entries.toList()
    ..sort((a, b) => b.value.oneRM.compareTo(a.value.oneRM));
  
  return ListView.builder(
    itemCount: sortedEntries.length,
    itemBuilder: (context, index) {
      final entry = sortedEntries[index];
      return _buildPRCard(entry.key, entry.value);
    },
  );
}

Widget _buildPRCard(String exerciseName, PRRecord pr) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      leading: Icon(Icons.fitness_center, color: Colors.blue),
      title: Text(exerciseName, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('PR: ${pr.weight}kg × ${pr.reps}reps (1RM: ${pr.oneRM.toStringAsFixed(1)}kg)'),
      trailing: Icon(Icons.chevron_right),
      onTap: () => _showPRGraph(exerciseName),
    ),
  );
}
```

**Step 3: グラフ表示**
タップ時に該当種目の履歴をグラフで表示：
```dart
void _showPRGraph(String exerciseName) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PRGraphScreen(exerciseName: exerciseName),
    ),
  );
}
```

---

## 🔴 Problem 3: メモ機能 - 表示されない

### **現象**
- 画面: トレーニング履歴 → メモタブ
- 表示: 「メモはまだありません」
- 期待: 保存したメモが一覧表示される

### **スクリーンショット**
URL: https://www.genspark.ai/api/files/s/PYD2NxYO

### **現在の実装確認が必要**

#### **Check 1: メモ保存処理**
`lib/screens/workout/add_workout_screen.dart` の `_saveWorkout()`:
```dart
// メモの保存処理を確認
if (_memoController.text.trim().isNotEmpty) {
  await FirebaseFirestore.instance.collection('workout_notes').add({
    'user_id': user.uid,
    'workout_id': workoutDoc.id, // ← workout_logs のドキュメントID
    'note': _memoController.text.trim(),
    'created_at': FieldValue.serverTimestamp(),
  });
}
```

**確認事項**:
- メモが正しく `workout_notes` コレクションに保存されているか？
- `workout_id` が正しく設定されているか？

#### **Check 2: メモ読み込み処理**
`lib/screens/workout/workout_memo_list_screen.dart`:
```dart
Stream<List<Map<String, dynamic>>> _loadWorkoutNotes() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('workout_notes')
      .where('user_id', isEqualTo: user.uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'note_id': doc.id,
            'note': doc.data()['note'] as String,
            'workout_id': doc.data()['workout_id'] as String,
            'created_at': doc.data()['created_at'] as Timestamp?,
          };
        }).toList();
      });
}
```

**問題の可能性**:
1. `workout_notes` コレクションにデータが保存されていない
2. `user_id` が一致していない（匿名ユーザーの場合）
3. `created_at` インデックスが作成されていない（Firestore）
4. ストリーム接続エラー

#### **Required Fix**

**Step 1: デバッグログ追加**
```dart
Stream<List<Map<String, dynamic>>> _loadWorkoutNotes() {
  final user = FirebaseAuth.instance.currentUser;
  print('🔍 メモ読み込み - ユーザーID: ${user?.uid}');
  
  if (user == null) {
    print('❌ ユーザー未ログイン');
    return Stream.value([]);
  }
  
  return FirebaseFirestore.instance
      .collection('workout_notes')
      .where('user_id', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        print('📝 メモ件数: ${snapshot.docs.length}');
        return snapshot.docs.map((doc) {
          print('  - メモ: ${doc.data()['note']}');
          return {...};
        }).toList();
      });
}
```

**Step 2: Firestore ルール確認**
```javascript
// firestore.rules
match /workout_notes/{noteId} {
  allow read, write: if request.auth != null;
}
```

**Step 3: 代替クエリ（インデックス不要）**
```dart
// orderBy を削除してシンプルクエリ
return FirebaseFirestore.instance
    .collection('workout_notes')
    .where('user_id', isEqualTo: user.uid)
    .snapshots()
    .map((snapshot) {
      // メモリ内でソート
      final notes = snapshot.docs.map((doc) => {...}).toList();
      notes.sort((a, b) {
        final aTime = a['created_at'] as Timestamp?;
        final bTime = b['created_at'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // 降順
      });
      return notes;
    });
```

---

## 🔴 Problem 4: 週次レポート - 空のまま

### **現象**
- 画面: トレーニング履歴 → 週次タブ
- 表示: 「まだ週次レポートがありません」「毎週月曜日に自動生成されます」
- 期待: 過去のトレーニングデータから週次レポートが生成される

### **スクリーンショット**
URL: https://www.genspark.ai/api/files/s/cIFw20mR

### **現在の実装確認**
`lib/screens/workout/weekly_reports_screen.dart`:
```dart
// users/{uid}/weeklyReports コレクションから読み込み
// 注釈: Cloud Function で自動生成予定
```

### **問題の原因**
**Cloud Function が未実装** - 週次レポートの自動生成機能が存在しない

### **Required Implementation Options**

#### **Option A: クライアントサイドで生成（推奨）**
Cloud Function を待たずに、アプリ内で週次レポートを生成：

```dart
Future<WeeklyReport> _generateWeeklyReport(DateTime weekStart) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('未ログイン');
  
  final weekEnd = weekStart.add(Duration(days: 7));
  
  // その週のworkout_logsを取得
  final snapshot = await FirebaseFirestore.instance
      .collection('workout_logs')
      .where('user_id', isEqualTo: user.uid)
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
      .where('date', isLessThan: Timestamp.fromDate(weekEnd))
      .get();
  
  // 統計計算
  int totalWorkouts = snapshot.docs.length;
  int totalSets = 0;
  double totalVolume = 0.0;
  Map<String, int> bodyPartCounts = {};
  
  for (var doc in snapshot.docs) {
    final sets = doc.data()['sets'] as List?;
    if (sets == null) continue;
    
    totalSets += sets.length;
    
    for (var set in sets) {
      final weight = (set['weight'] as num?)?.toDouble() ?? 0.0;
      final reps = set['reps'] as int? ?? 0;
      final bodyPart = set['bodyPart'] as String? ?? 'その他';
      
      totalVolume += weight * reps;
      bodyPartCounts[bodyPart] = (bodyPartCounts[bodyPart] ?? 0) + 1;
    }
  }
  
  return WeeklyReport(
    weekStart: weekStart,
    weekEnd: weekEnd,
    totalWorkouts: totalWorkouts,
    totalSets: totalSets,
    totalVolume: totalVolume,
    bodyPartBreakdown: bodyPartCounts,
  );
}
```

#### **Option B: Cloud Function 実装（低優先）**
Firebase Functions で週次レポート生成（後回し推奨）

---

## ⚠️ Problem 5: 有酸素運動入力UI - バーピージャンプが「重さ × 回数」表示

### **現象**
- 画面: トレーニング記録 → バーピージャンプを選択
- 表示: 「重量 (kg)」「回数」の入力フィールド
- 期待: 有酸素運動は「時間 (分)」「距離 (km)」の入力フィールドであるべき

### **スクリーンショット**
URL: https://www.genspark.ai/api/files/s/I3R24gQe

### **現在の実装確認**

#### **Check 1: 有酸素運動の判定**
`lib/screens/workout/add_workout_screen.dart`:
```dart
bool _isCardioExercise(String exerciseName) {
  final cardioExercises = _muscleGroupExercises['有酸素'] ?? [];
  return cardioExercises.contains(exerciseName);
}
```

`lib/services/exercise_master_data.dart`:
```dart
'有酸素': ['ランニング', '...', 'バーピージャンプ', '...']
```

✅ バーピージャンプは有酸素リストに含まれている

#### **Check 2: UI表示ロジック**
`lib/screens/workout/add_workout_screen.dart` の `_buildSetInput()`:
```dart
// v1.0.226+242: 有酸素運動の場合、時間(分) x 距離(km) 表示
if (set.isCardio) {
  // 時間(分)入力
  TextField(
    decoration: InputDecoration(labelText: '時間 (分)'),
    ...
  );
  // 距離(km)入力
  TextField(
    decoration: InputDecoration(labelText: '距離 (km)'),
    ...
  );
} else {
  // 通常の重量(kg) x 回数
  TextField(
    decoration: InputDecoration(labelText: '重量 (kg)'),
    ...
  );
  TextField(
    decoration: InputDecoration(labelText: '回数'),
    ...
  );
}
```

### **問題の原因**

**set.isCardio が false になっている**

AIコーチから種目を選択した場合：
```dart
// lib/screens/workout/add_workout_screen.dart - _initializeFromAICoach()
final isCardio = exercise['is_cardio'] as bool? ?? _isCardioExercise(exerciseName);
```

**手動で種目を追加した場合**（これが問題！）:
```dart
// 種目追加時
void _addExercise(String exerciseName) {
  setState(() {
    _sets.add(WorkoutSet(
      exerciseName: exerciseName,
      weight: 0.0,
      reps: 10,
      isCompleted: false,
      isBodyweightMode: _isPullUpExercise(exerciseName) || _isAbsExercise(exerciseName),
      isTimeMode: _getDefaultTimeMode(exerciseName),
      isCardio: _isCardioExercise(exerciseName), // ← ここで判定されているはず
    ));
  });
}
```

### **Required Fix**

#### **Step 1: デバッグログ追加**
```dart
void _addExercise(String exerciseName) {
  final isCardio = _isCardioExercise(exerciseName);
  print('✅ 種目追加: $exerciseName, isCardio: $isCardio');
  print('   有酸素リスト: ${_muscleGroupExercises['有酸素']}');
  
  setState(() {
    _sets.add(WorkoutSet(
      exerciseName: exerciseName,
      isCardio: isCardio,
      ...
    ));
  });
}
```

#### **Step 2: UI表示の確認**
`_buildSetInput()` で `set.isCardio` が正しく参照されているか確認：
```dart
Widget _buildSetInput(WorkoutSet set, int index) {
  print('🎨 UI表示: ${set.exerciseName}, isCardio: ${set.isCardio}');
  
  if (set.isCardio) {
    // 有酸素UI
  } else {
    // 通常UI
  }
}
```

#### **Step 3: バーピージャンプの特殊ケース**
バーピージャンプは「回数」のみの場合もあるため、柔軟な対応：
```dart
// バーピージャンプの場合、時間 or 回数を選択可能に
if (set.isCardio && exerciseName == 'バーピージャンプ') {
  // トグルで「時間×距離」 or 「回数のみ」を選択
  Row(
    children: [
      ElevatedButton(
        onPressed: () => setState(() => set.isTimeMode = true),
        child: Text('時間'),
      ),
      ElevatedButton(
        onPressed: () => setState(() => set.isTimeMode = false),
        child: Text('回数'),
      ),
    ],
  );
  
  if (set.isTimeMode) {
    // 時間 × 距離入力
  } else {
    // 回数のみ入力
  }
}
```

---

## 🎯 Priority Order

### **Phase 1: Critical Bugs (HIGH)**
1. ✅ **部位別トラッキング「その他」問題** - ExerciseMasterData の修正
2. ✅ **有酸素運動入力UI** - バーピージャンプの isCardio フラグ確認

### **Phase 2: Important Features (MEDIUM)**
3. ✅ **PR記録画面** - ドロップダウン廃止、全種目一覧+グラフ表示
4. ✅ **メモ機能** - 表示されない問題の調査と修正

### **Phase 3: Nice to Have (LOW)**
5. ⚠️ **週次レポート** - クライアントサイド生成 or Cloud Function実装

---

## 📊 Testing Requirements

### **Test Case 1: 部位別トラッキング**
1. 過去30日間のトレーニングデータを確認
2. デッドリフト → 背中、ベンチプレス → 胸 などが正しく分類されることを確認
3. 「その他」が0%または最小限であることを確認

### **Test Case 2: PR記録**
1. 記録がある全種目が一覧表示されることを確認
2. 各種目のPR（重量×回数、1RM）が正しく表示されることを確認
3. タップするとグラフが表示されることを確認

### **Test Case 3: メモ機能**
1. トレーニング記録時にメモを入力して保存
2. メモタブで保存したメモが表示されることを確認
3. メモの日付が正しく表示されることを確認

### **Test Case 4: 週次レポート**
1. 過去のトレーニングデータから週次レポートが生成されることを確認
2. 総ワークアウト数、総セット数、総ボリュームが正しく計算されることを確認
3. 部位別の内訳が正しく表示されることを確認

### **Test Case 5: 有酸素運動入力**
1. バーピージャンプを選択
2. 入力フィールドが「時間(分)」「距離(km)」または「回数」であることを確認
3. 保存後、ホーム画面で正しく「N分 × Nkm」または「N回」と表示されることを確認

---

## 📁 Files to Modify

### **High Priority**
1. `lib/services/exercise_master_data.dart` - bodyPart判定ロジック改善
2. `lib/models/workout_log.dart` - デバッグログ追加
3. `lib/screens/workout/add_workout_screen.dart` - 有酸素運動判定確認
4. `lib/screens/workout/personal_records_screen.dart` - 全面的な UI 改修

### **Medium Priority**
5. `lib/screens/workout/workout_memo_list_screen.dart` - クエリ修正
6. `lib/screens/workout/weekly_reports_screen.dart` - クライアントサイド生成実装

---

## 🚀 Deployment

修正後、以下の手順でデプロイ：

1. ✅ ローカルでテスト
2. ✅ `pubspec.yaml` のバージョンを更新（v1.0.245+270）
3. ✅ Git コミット & プッシュ
4. ✅ タグ作成: `git tag v1.0.245`
5. ✅ GitHub Actions でビルド
6. ✅ TestFlight 配信
7. ✅ 上記テストケースで動作確認

---

## 📞 Contact

**Repository**: https://github.com/aka209859-max/gym-tracker-flutter (iOS専用)  
**Platform**: iOS ONLY  
**Current Version**: v1.0.244 (Build 269)

---

**🙏 Please fix these critical bugs and implement the requested features. Thank you!**

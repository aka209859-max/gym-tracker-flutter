# 🚨 Gemini開発者へ: AIコーチの有酸素運動表示問題のデバッグ依頼

## 📋 問題の概要

**FlutterアプリのAIコーチ機能**において、有酸素運動と筋トレが混在するメニューを生成した際、**トレーニング記録画面に遷移すると、すべての種目が同じ表示形式（時間/距離 or 重さ/回数）になってしまう**問題が発生しています。

---

## 🐛 現在の問題（v1.0.237でも未解決）

### **スクリーンショット分析結果**

添付のスクリーンショット（https://www.genspark.ai/api/files/s/db7EsXfM）を確認したところ、以下の問題が確認されました：

```
トレーニング記録画面の表示:

1. インターバルラン（有酸素）
   セット | 時間 | 距離 | 補助
   1     | 10.0分 | 10 km | 

2. ローイングマシン（有酸素）
   セット | 時間 | 距離 | 補助
   1     | 10.0分 | 10 km |

3. デッドリフト（筋トレ）❌
   セット | 時間 | 距離 | 補助
   1     | 400.0分 | 10 km |  ← ❌ 重さ/回数ではなく時間/距離で表示されている！
```

**期待される表示**:
```
3. デッドリフト（筋トレ）✅
   セット | 重さ | 回数 | 補助
   1     | 400.0kg | 10回 |
```

---

## 🔍 これまでの修正履歴

### **v1.0.237での修正内容**

1. ✅ `ParsedExercise` クラスを拡張
   ```dart
   class ParsedExercise {
     final bool isCardio; // 有酸素運動フラグ
     final double? distance; // 距離（有酸素用）
     final int? duration; // 時間（有酸素用）
     final double? weight; // 重さ（筋トレ用）
     final int? reps; // 回数（筋トレ用）
     final int? sets; // セット数
   }
   ```

2. ✅ `_parseGeneratedMenu` を修正
   - `bodyPart == '有酸素'` で明示的に判定
   - 有酸素運動: `isCardio = true`, `duration`, `distance` を設定
   - 筋トレ: `isCardio = false`, `weight`, `reps` を設定

3. ✅ AIコーチ画面のUI表示を修正
   - `exercise.isCardio` で条件分岐
   - 有酸素運動: 距離/時間アイコンを表示
   - 筋トレ: 重さ/回数アイコンを表示

---

## ❌ なぜv1.0.237で修正できなかったのか？

### **推測される根本原因**

**トレーニング記録画面（`AddWorkoutScreen`）が `ParsedExercise` のデータを正しく受け取っていない、または表示ロジックが対応していない可能性が高い。**

#### **考えられる問題箇所**

1. **データの受け渡し問題**
   - `ai_coaching_screen_tabbed.dart` から `AddWorkoutScreen` へのデータ引き継ぎ
   - 現在のコード:
     ```dart
     await Navigator.of(context).pushNamed(
       '/add-workout',
       arguments: {
         'fromAICoach': true,
         'selectedExercises': selectedExercises, // List<ParsedExercise>
       },
     );
     ```
   - `AddWorkoutScreen` 側で `arguments` を受け取っていない可能性

2. **`AddWorkoutScreen` の表示ロジック問題**
   - スクリーンショットのヘッダー行: 「セット | 時間 | 距離 | 補助」
   - この表示形式が**固定**されている可能性
   - 筋トレの場合は「セット | 重さ | 回数 | 補助」に切り替える必要

3. **データ変換の問題**
   - `ParsedExercise` から `WorkoutSet` への変換時に、`isCardio` フラグが失われている可能性
   - 有酸素運動の場合の変換:
     ```dart
     WorkoutSet(
       weight: 0.0,  // ← これが問題？
       reps: duration, // 時間を reps に
       distance: distance, // ← この情報が失われている？
     )
     ```

---

## 🎯 解決すべき課題

### **1. トレーニング記録画面の表示ロジック確認**

**ファイル**: `lib/screens/workout/add_workout_screen_complete.dart`

**確認ポイント**:
- ヘッダー行（「時間/距離」または「重さ/回数」）をどのように決定しているか？
- 最初に追加された種目の形式で固定されているか？
- 各種目ごとに個別に判定しているか？

### **2. データの受け渡し確認**

**ファイル**: `lib/screens/workout/add_workout_screen_complete.dart`

**確認ポイント**:
- `ModalRoute.of(context)?.settings.arguments` でデータを受け取っているか？
- `ParsedExercise` の `isCardio` フラグが保持されているか？
- `selectedExercises` から `WorkoutSet` への変換ロジックは正しいか？

### **3. `WorkoutSet` クラスの拡張**

**ファイル**: `lib/screens/workout/add_workout_screen_complete.dart` または `lib/models/workout_log.dart`

**現在の `WorkoutSet` クラス**（推測）:
```dart
class WorkoutSet {
  final double weight; // kg
  final int reps; // 回数
  final String? note;
  // ❌ 有酸素運動用のフィールドがない？
}
```

**必要な拡張**:
```dart
class WorkoutSet {
  final bool isCardio; // 有酸素運動フラグ
  final double? weight; // kg（筋トレ用）
  final int? reps; // 回数（筋トレ用）
  final double? distance; // 距離（有酸素用）
  final int? duration; // 時間（有酸素用）
  final String? note;
}
```

---

## 📝 具体的な修正依頼

### **タスク1: データ受け渡しの確認と修正**

1. `AddWorkoutScreen` で `arguments` を受け取る処理を実装
   ```dart
   @override
   void didChangeDependencies() {
     super.didChangeDependencies();
     
     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
     if (args != null && args['fromAICoach'] == true) {
       final exercises = args['selectedExercises'] as List<ParsedExercise>?;
       if (exercises != null) {
         _applyAICoachExercises(exercises);
       }
     }
   }
   ```

2. `_applyAICoachExercises` メソッドを実装
   ```dart
   void _applyAICoachExercises(List<ParsedExercise> exercises) {
     for (final exercise in exercises) {
       if (exercise.isCardio) {
         // 有酸素運動として追加
         _addCardioExercise(
           name: exercise.name,
           duration: exercise.duration,
           distance: exercise.distance,
           sets: exercise.sets,
         );
       } else {
         // 筋トレとして追加
         _addStrengthExercise(
           name: exercise.name,
           weight: exercise.weight,
           reps: exercise.reps,
           sets: exercise.sets,
         );
       }
     }
   }
   ```

### **タスク2: 表示ロジックの修正**

1. **ヘッダー行を動的に変更**
   ```dart
   // ❌ 現在（固定）
   Row(
     children: [
       Text('セット'),
       Text('時間'),
       Text('距離'),
       Text('補助'),
     ],
   )
   
   // ✅ 修正後（種目ごとに切り替え）
   Row(
     children: [
       Text('セット'),
       if (exercise.isCardio) ...[
         Text('時間'),
         Text('距離'),
       ] else ...[
         Text('重さ'),
         Text('回数'),
       ],
       Text('補助'),
     ],
   )
   ```

2. **データ行も動的に変更**
   ```dart
   // ❌ 現在（すべて時間/距離）
   Row(
     children: [
       Text('${set.reps}分'),
       Text('${set.weight}km'),
     ],
   )
   
   // ✅ 修正後（種目タイプで切り替え）
   Row(
     children: [
       if (exercise.isCardio) ...[
         Text('${set.duration}分'),
         Text('${set.distance}km'),
       ] else ...[
         Text('${set.weight}kg'),
         Text('${set.reps}回'),
       ],
     ],
   )
   ```

### **タスク3: `WorkoutSet` クラスの拡張**

```dart
class WorkoutSet {
  final bool isCardio; // ✅ 追加
  final double? weight; // kg（筋トレ用）
  final int? reps; // 回数（筋トレ用）
  final double? distance; // km（有酸素用）✅ 追加
  final int? duration; // 分（有酸素用）✅ 追加
  final int? sets; // セット数
  final String? note;
  final bool hasAssist;
  final SetType setType;

  WorkoutSet({
    this.isCardio = false, // デフォルトは筋トレ
    this.weight,
    this.reps,
    this.distance, // ✅ 追加
    this.duration, // ✅ 追加
    this.sets,
    this.note,
    this.hasAssist = false,
    this.setType = SetType.normal,
  });
}
```

---

## 🧪 テストケース

修正後、以下のケースで検証してください：

### **ケース1: 有酸素→筋トレの順**
1. AIコーチで「有酸素」を選択 → インターバルラン（20分）
2. 「胸」を追加 → デッドリフト（100kg、10回）
3. トレーニング記録画面に遷移
4. **期待値**:
   - インターバルラン: 「セット | 時間 | 距離」
   - デッドリフト: 「セット | 重さ | 回数」

### **ケース2: 筋トレ→有酸素の順**
1. AIコーチで「胸」を選択 → デッドリフト（100kg、10回）
2. 「有酸素」を追加 → インターバルラン（20分）
3. トレーニング記録画面に遷移
4. **期待値**:
   - デッドリフト: 「セット | 重さ | 回数」
   - インターバルラン: 「セット | 時間 | 距離」

### **ケース3: 有酸素のみ**
1. AIコーチで「有酸素」のみ選択
2. トレーニング記録画面に遷移
3. **期待値**: すべて「時間/距離」形式

### **ケース4: 筋トレのみ**
1. AIコーチで「胸」のみ選択
2. トレーニング記録画面に遷移
3. **期待値**: すべて「重さ/回数」形式

---

## 📂 関連ファイル

修正が必要なファイル:

1. **`lib/screens/workout/add_workout_screen_complete.dart`**
   - データ受け渡し処理
   - 表示ロジック
   - ヘッダー行の動的切り替え

2. **`lib/models/workout_log.dart`**（存在する場合）
   - `WorkoutSet` クラスの拡張

3. **`lib/screens/workout/ai_coaching_screen_tabbed.dart`**
   - データ引き継ぎ処理（既に修正済み）

---

## 🎯 修正の優先順位

1. **最優先**: トレーニング記録画面の表示ロジック修正
   - ヘッダー行の動的切り替え
   - データ行の動的切り替え

2. **優先**: データ受け渡しの確認と修正
   - `arguments` の受け取り処理
   - `ParsedExercise` から `WorkoutSet` への変換

3. **推奨**: `WorkoutSet` クラスの拡張
   - `isCardio`, `distance`, `duration` フィールドの追加

---

## 📊 現在の状況まとめ

| 項目 | 状態 |
|------|------|
| **AIコーチ画面の表示** | ✅ 修正済み（v1.0.237） |
| **データモデル（`ParsedExercise`）** | ✅ 修正済み（v1.0.237） |
| **データパース処理** | ✅ 修正済み（v1.0.237） |
| **トレーニング記録画面の表示** | ❌ **未修正** ← ここが問題 |
| **データ受け渡し** | ⚠️ 確認が必要 |
| **`WorkoutSet` クラス** | ⚠️ 拡張が必要 |

---

## 🙏 Geminiへのお願い

以下の情報を教えていただけますか？

1. **`add_workout_screen_complete.dart` の関連コード**
   - `arguments` の受け取り処理
   - ヘッダー行の生成ロジック
   - データ行の生成ロジック

2. **`WorkoutSet` クラスの現在の定義**
   - どのフィールドが存在するか
   - 有酸素運動用のフィールドはあるか

3. **具体的な修正コード**
   - 上記の3つのタスクを実装するコード
   - コピー＆ペーストで動作するコード

4. **テスト結果**
   - 修正後、4つのテストケースで検証
   - スクリーンショットで確認

---

## 📝 補足情報

### **現在のプロジェクト状態**

- **Version**: v1.0.237+261
- **Flutter SDK**: v3.5.0〜v4.0.0
- **Main Branch**: https://github.com/aka209859-max/gym-tracker-flutter

### **デバッグログ**

AIコーチ画面からトレーニング記録画面に遷移する際のログ:
```
✅ AIコーチ: 3種目をトレーニング記録画面に渡します
  ✅ インターバルラン (有酸素): 20分, 0km, 10セット [有酸素]
  ✅ ローイングマシン (有酸素): 10分, 5km, 1セット [有酸素]
  ✅ デッドリフト (胸): 400.0kg, 10回, 3セット [筋トレ]
```

**問題**: このログは正しいが、トレーニング記録画面では正しく表示されない

---

よろしくお願いいたします！🙏

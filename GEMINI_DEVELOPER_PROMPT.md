# Gemini Developer: 有酸素運動のデータ構造に関する質問

## 背景

Flutter + Firebaseで開発しているトレーニング記録アプリで、有酸素運動の記録に関する問題が発生しています。

## 現在のデータ構造

### Firestore `workout_logs` コレクション
```javascript
{
  user_id: "user123",
  muscle_group: "胸",  // 最初に選択した部位（筋トレ用）
  date: Timestamp,
  sets: [
    {
      exercise_name: "ベンチプレス",
      weight: 100.0,
      reps: 10,
      is_completed: true,
      is_cardio: false,
      is_time_mode: false
    },
    {
      exercise_name: "ランニング",
      weight: 30.0,  // 時間（分）として使用
      reps: 5,       // 距離（km）として使用
      is_completed: true,
      is_cardio: true,
      is_time_mode: false
    }
  ]
}
```

## 問題点

### 1. 部位別トラッキングで「その他」が100%になる
- 現在: 各セットに`bodyPart`情報が保存されていない
- 結果: `WorkoutLog`モデルで`exercise.bodyPart`を読み取ると、すべて「その他」になる

### 2. 有酸素運動が筋トレ後に追加されると表示がおかしくなる
**ユーザーの報告**:
> 筋トレの後にAIコーチやトレーニング記録で有酸素を入力、反映させると「時間/距離」になってしまう現象

**期待される動作**:
- 筋トレ: 「重量(kg) × 回数」で表示
- 有酸素: 「時間(分) × 距離(km)」で表示

**現在の実装**:
```dart
// lib/screens/workout/add_workout_screen.dart (Line 2425, 2448)
TextFormField(
  decoration: InputDecoration(
    labelText: set.isCardio ? '時間 (分)' : '重量 (kg)',
  ),
  // ...
),
TextFormField(
  decoration: InputDecoration(
    labelText: set.isCardio 
        ? '距離 (km)' 
        : _isAbsExercise(set.exerciseName)
            ? (set.isTimeMode ? '秒数' : '回数')
            : '回数',
  ),
  // ...
)
```

## 質問

### Q1: データ構造の設計
筋トレと有酸素運動を同一ワークアウトセッション内で記録する場合、以下のどの設計が最適ですか？

**Option A: 現在の統合構造（推奨？）**
```javascript
{
  muscle_group: "胸",
  sets: [
    { exercise_name: "ベンチプレス", bodyPart: "胸", weight: 100, reps: 10, is_cardio: false },
    { exercise_name: "ランニング", bodyPart: "有酸素", weight: 30, reps: 5, is_cardio: true }
  ]
}
```
- メリット: 1つのドキュメントで管理、時系列が明確
- デメリット: `muscle_group`が筋トレ部位なのか有酸素なのか不明瞭

**Option B: 有酸素運動を別フィールドに分離**
```javascript
{
  muscle_group: "胸",
  sets: [
    { exercise_name: "ベンチプレス", weight: 100, reps: 10 }
  ],
  cardio_exercises: [
    { name: "ランニング", duration_minutes: 30, distance_km: 5 }
  ]
}
```
- メリット: データ型が明確、クエリしやすい
- デメリット: セット順序が失われる

**Option C: 有酸素運動を別コレクションに保存**
```javascript
// workout_logs コレクション（筋トレ用）
{ muscle_group: "胸", sets: [...] }

// cardio_logs コレクション（有酸素用）
{ exercise_name: "ランニング", duration_minutes: 30, distance_km: 5 }
```
- メリット: 完全に分離、スキーマが明確
- デメリット: 同一セッション内の記録が分散

### Q2: UIフロー
ユーザーが以下の操作をする場合、どのようなUI/UXが最適ですか？
1. 筋トレセット（ベンチプレス 3セット）を記録
2. 続けて有酸素運動（ランニング）を追加
3. 保存

**現在の実装**:
- 部位選択（胸/背中/脚 etc.）→ 種目選択 → セット入力
- 有酸素運動も同じフローで「有酸素」部位を選択

**問題**:
- ユーザーが筋トレ後に有酸素を追加しようとすると、既に「胸」が選択されている
- 有酸素運動の種目（「ランニング」等）が「胸」カテゴリに入ってしまう？

### Q3: 既存データのマイグレーション
現在、数百件のワークアウトログが以下の形式で保存されています：
```javascript
{
  sets: [
    { exercise_name: "ベンチプレス", weight: 100, reps: 10 }
    // bodyPart フィールドなし
  ]
}
```

各種目名から部位を逆引きする必要がありますが、どのようなアプローチが最適ですか？

**Option A: アプリ側で種目名→部位マッピング**
```dart
final Map<String, String> exerciseToBodyPart = {
  'ベンチプレス': '胸',
  'ラットプルダウン': '背中',
  'ランニング': '有酸素',
  // 100種目以上...
};
```

**Option B: Firestore関数でバッチ更新**
Cloud Functionsで既存データに`bodyPart`を追加

**Option C: 読み取り時にリアルタイム補完**
`WorkoutLog.fromFirestore`で種目名から部位を推定

### Q4: 「時間/距離」表示バグ
ユーザーレポート：
> 筋トレの後にAIコーチやトレーニング記録で有酸素を入力すると「時間/距離」になってしまう

これは以下のどの問題ですか？
1. **UIの動的更新問題**: 筋トレセット表示後、有酸素セットを追加するとUIが更新されない？
2. **データ保存問題**: `is_cardio`フラグが正しく保存されていない？
3. **読み取り問題**: 既存の筋トレセットが有酸素として読み取られる？
4. **混在表示問題**: 筋トレと有酸素が同一画面に表示される際のレンダリングバグ？

## 技術スタック
- **Frontend**: Flutter 3.35.4 (Dart)
- **Backend**: Firebase Firestore
- **認証**: Firebase Auth (Anonymous)
- **状態管理**: StatefulWidget (setState)

## 期待する回答
1. 推奨されるFirestoreデータ構造
2. UI/UXフロー設計
3. 既存データマイグレーション戦略
4. 「時間/距離」表示バグの根本原因と解決策

よろしくお願いします。

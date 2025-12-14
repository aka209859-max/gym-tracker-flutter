# Phase 6 実装計画：データ集計バグ修正

## 🚨 問題の診断結果（Geminiによる指摘）

### 1. フィールド名の不一致（user_id vs userId）

**影響範囲**:
- ✅ **修正完了**: `lib/screens/workout/workout_log_screen.dart:219` - シェア機能
- ✅ **修正完了**: `lib/screens/workout/ai_coaching_screen_tabbed.dart:3530` - 履歴取得
- ✅ **修正完了**: `lib/services/firestore_service.dart:173` - getPreviousExercise
- ✅ **修正完了**: `lib/services/firestore_service.dart:205` - getUserWorkoutLogs

**修正内容**: すべて `userId` → `user_id` に統一

### 2. 集計データの更新ロジック欠落

**問題**:
- トレーニング記録保存時に、以下のコレクションが更新されていない：
  1. `personalRecords` - PR（自己ベスト）
  2. `weeklyReports` - 週次レポート
  3. `workout_notes` - メモ（部分的に実装済み）

**原因**:
- `add_workout_screen.dart` が直接 Firestore に保存しており、`FirestoreService` の集計ロジックを通っていない

---

## 🔧 Phase 6 実装内容

### ✅ Phase 6-A: フィールド名統一（完了）

**変更ファイル**:
- `lib/screens/workout/workout_log_screen.dart`
- `lib/screens/workout/ai_coaching_screen_tabbed.dart`
- `lib/services/firestore_service.dart`

**変更内容**:
- すべての `userId`（キャメルケース）を `user_id`（スネークケース）に統一

### ✅ Phase 6-B/C/D: 集計ロジック追加（完了）

**新規追加メソッド（`firestore_service.dart`）**:

1. **`_updatePersonalRecords(userId, log)`**
   - 各種目の1RM換算値を計算
   - 既存PRを上回る場合、`personalRecords` コレクションを更新
   - ドキュメントID: `{userId}_{exercise_name}`

2. **`_updateWeeklyReport(userId, log)`**
   - 該当週のドキュメントIDを生成（例: `2025-W50`）
   - トレーニング回数、総負荷量、部位カウントを集計
   - `weeklyReports` コレクションに追加/更新

3. **`_saveWorkoutNotes(userId, log)`**
   - メモが存在する場合、`workout_notes` コレクションに保存

4. **`saveWorkoutLogWithAggregation(userId, log)`**
   - 上記3つの集計処理を統合
   - ワークアウト保存 + 集計を一括実行

---

## ⚠️ 次のステップ（Phase 6.5: 実装統合）

### 🔴 重要: add_workout_screen.dart の修正が必要

**現状**:
```dart
// lib/screens/workout/add_workout_screen.dart:1637
final workoutDoc = await FirebaseFirestore.instance.collection('workout_logs').add({
  'user_id': user.uid,
  // ...直接Firestoreに保存
});
```

**必要な修正**:
1. `FirestoreService` のインスタンスを作成
2. 保存ロジックを `saveWorkoutLogWithAggregation()` に置き換え
3. `WorkoutLog` モデルを使用してデータ構造を整理

**修正箇所**:
- `lib/screens/workout/add_workout_screen.dart:1637` - メイン保存処理
- `lib/screens/workout/add_workout_screen_complete.dart:317` - 完了画面からの保存

---

## 📋 動作確認手順

### テストケース 1: PR記録の自動更新

1. トレーニングを記録（例: ベンチプレス 80kg x 5reps）
2. PR画面（Personal Records）を開く
3. **期待結果**: ベンチプレスのPRが即座に表示される

### テストケース 2: 週次レポートの自動更新

1. トレーニングを2回記録（同じ週内）
2. 週次レポート画面を開く
3. **期待結果**:
   - トレーニング回数: 2回
   - 総負荷量が表示される
   - 部位別カウントが表示される

### テストケース 3: メモの自動保存

1. トレーニング記録時にメモを入力
2. メモ一覧画面を開く
3. **期待結果**: 入力したメモが表示される

---

## 🎯 実装の優先度

| 優先度 | タスク | ステータス |
|-------|--------|----------|
| 🔴 必須 | フィールド名統一 | ✅ 完了 |
| 🔴 必須 | 集計ロジック追加 | ✅ 完了 |
| 🔴 必須 | add_workout_screen.dart 修正 | ⏳ 未実施 |
| 🟡 推奨 | エラーハンドリング強化 | ⏳ 未実施 |
| 🟢 任意 | PR更新時の演出追加 | ⏳ 未実施 |

---

## 📝 備考

### 既知の制限事項

1. **部位推定の精度**: `_inferBodyPart()` は種目名からの推定のため、完璧ではない
   - 改善案: `muscle_group` フィールドを活用

2. **週番号の計算**: 簡易的な実装（ISO 8601完全準拠ではない）
   - 影響: 年初の週跨ぎで微妙なずれが発生する可能性

3. **1RM換算式**: Brzycki式を簡略化（`weight * (1 + reps / 30)`）
   - 正確なBrzycki式: `weight * (36 / (37 - reps))`

---

**作成日**: 2025-12-14  
**ステータス**: Phase 6-A/B/C/D 完了、Phase 6.5（統合）が残存

# Week 2 Day 2 Phase 2: Variable Interpolation Analysis

## 残り未翻訳文字列（変数補間あり）

### ファイル1: lib/screens/home_screen.dart (8件)
```
908: シェアに失敗しました: $e
2544: 削除エラー: $e
3303: $weight 分
4033: 「$exerciseName」の記録を削除しますか？\nこの操作は取り消せません。
4309: 「$exerciseName」を削除しました（残り${totalRemainingExercises}種目）
4319: 削除に失敗しました: $updateError
4374: 「$exerciseName」を削除しました（残り${totalRemainingExercises}種目）
4816: ❌ エラー: $e
```

### ファイル2: lib/screens/goals_screen.dart (2件)
```
60: 目標の読み込みに失敗しました: $e
417: 「$goalName」を削除しますか？\nこの操作は取り消せません。
623: 更新に失敗しました: $e
583: ${goal.name}を編集
```

### ファイル3: lib/screens/body_measurement_screen.dart (6件)
```
165: 📴 オフライン保存しました\nオンライン復帰時に自動同期されます
214: 体重: ${weight.toStringAsFixed(1)}kg
215: 体脂肪率: ${bodyFat.toStringAsFixed(1)}%
740: yyyy年MM月dd日 (DateFormat - 要対応)
743: 体重: ${weight.toStringAsFixed(1)}kg (重複)
744: •  (separator - 不要)
745: 体脂肪率: ${bodyFat.toStringAsFixed(1)}% (重複)
```

### ファイル4: lib/widgets/reward_ad_dialog.dart (2件)
```
85: ✅ AIクレジット1回分を獲得しました！（テストモード）
110: 広告の読み込みに失敗しました。もう一度お試しください。
136: ✅ AIクレジット1回分を獲得しました！
149: 広告の表示に失敗しました。しばらく待ってからお試しください。
```

---

## Phase 2 戦略

### 1. 新規ARBキーを作成（変数対応）

**高優先度（エラーメッセージ）: 12件**
- `home_shareFailed`: "シェアに失敗しました: {error}"
- `home_deleteError`: "削除エラー: {error}"
- `home_deleteRecordConfirm`: "「{exerciseName}」の記録を削除しますか？\nこの操作は取り消せません。"
- `home_deleteRecordSuccess`: "「{exerciseName}」を削除しました（残り{count}種目）"
- `home_deleteFailed`: "削除に失敗しました: {error}"
- `home_generalError`: "❌ エラー: {error}"
- `goals_loadFailed`: "目標の読み込みに失敗しました: {error}"
- `goals_deleteConfirm`: "「{goalName}」を削除しますか？\nこの操作は取り消せません。"
- `goals_updateFailed`: "更新に失敗しました: {error}"
- `goals_editTitle`: "{goalName}を編集"
- `reward_adLoadFailed`: "広告の読み込みに失敗しました。もう一度お試しください。"
- `reward_adDisplayFailed`: "広告の表示に失敗しました。しばらく待ってからお試しください。"

**中優先度（動的コンテンツ）: 5件**
- `home_weightMinutes`: "{weight} 分"
- `body_offlineSaved`: "📴 オフライン保存しました\nオンライン復帰時に自動同期されます"
- `body_weightKg`: "体重: {weight}kg"
- `body_bodyFatPercent`: "体脂肪率: {bodyFat}%"
- `reward_creditEarnedTest`: "✅ AIクレジット1回分を獲得しました！（テストモード）"

**低優先度: 2件**
- `reward_creditEarned`: "✅ AIクレジット1回分を獲得しました！" （既存キーあり）
- DateFormat対応（日付フォーマットは l10n で対応済みの可能性）

---

## Phase 2 実行計画

### Step 1: 新規ARBキー追加（17キー × 7言語 = 119追加）
スクリプト作成: `add_week2_day2_phase2_arb_keys.py`

### Step 2: 文字列置換スクリプト作成
変数補間対応の置換スクリプト: `apply_week2_day2_phase2.py`

### Step 3: 実行 & 検証
- 17件の文字列を置換
- コンパイルチェック
- コミット

### Step 4: Phase 3へ
Build #15トリガー

---

## 期待される成果
- 置換数: 17件（変数補間対応）
- Phase 1 + Phase 2: 合計40件
- 翻訳カバレッジ: 79.5% → 80.0%

# 🔥 GYM MATCH v1.0.186-187 リリースノート

**リリース日**: 2025-12-08  
**Build**: 186-187  
**優先度**: 🔴 高（バグ修正 + 機能改善）

---

## 📦 このリリースに含まれる修正

### v1.0.186: 腹筋秒数表示の完全修正
### v1.0.187: オフライン検出ロジック改善

---

# 🩹 v1.0.186: is_time_mode=false データの秒数表示修正

## 🐛 問題

v1.0.185 では `is_time_mode == null` の場合のみ種目名から判定していたため、
**`is_time_mode: false` で保存されたデータは「回」表示のまま**でした。

## 🔧 修正内容

```dart
// Before
if (set['is_time_mode'] == null) {
  isTimeMode = _getDefaultTimeMode(setExerciseName);
}

// After
if (set['is_time_mode'] != true) {
  isTimeMode = _getDefaultTimeMode(setExerciseName);
}
```

**効果**: `is_time_mode` が `null` または `false` の場合、種目名から判定

## ✅ 修正箇所（3箇所）

1. **ワークアウトテーブル表示** (home_screen.dart line 3086-3094)
2. **テーブルヘッダー表示** (home_screen.dart line 2903-2910)
3. **今日のトレーニングリスト** (home_screen.dart line 3410-3421)

## 📊 修正結果

| 種目 | is_time_mode | 表示（v1.0.185） | 表示（v1.0.186） |
|------|--------------|------------------|------------------|
| サイドプランク | `false` | 40回 ❌ | 40秒 ✅ |
| クランチ | `false` | 40回 ❌ | 40秒 ✅ |
| プランク | `false` | 60回 ❌ | 60秒 ✅ |

---

# 🔧 v1.0.187: オフライン検出ロジック改善

## 🐛 問題

オフラインモードでネットワークを切断しても、オフライン判定されない

## 🔍 原因

1. Firestore の接続確認タイムアウトが **1秒で長すぎた**
2. **`hasPendingWrites` をチェックしていなかった**

## 🔧 修正内容

### タイムアウト短縮

```dart
// Before
const Duration(seconds: 1)

// After
const Duration(milliseconds: 500)  // 500ms に短縮
```

### 判定厳格化

```dart
// Before
final isOnline = result.metadata.isFromCache == false;

// After
final isFromCache = result.metadata.isFromCache;
final hasPendingWrites = result.metadata.hasPendingWrites;

if (isFromCache) return false;
if (hasPendingWrites) return false;
return true;
```

## ✅ 改善点

### 1. 高速なオフライン判定
- **1秒 → 500ms** でタイムアウト
- ネットワーク切断時の応答速度が2倍向上

### 2. 正確なオフライン検出
- `isFromCache` チェック（キャッシュから取得 → オフライン）
- `hasPendingWrites` チェック（保留中の書き込みあり → オフライン）

### 3. デバッグログ強化

**オンライン時:**
```
🔍 [Network] 接続検出: [ConnectivityResult.wifi]
🔍 [Firestore] サーバー接続テスト開始...
🌐 [Firestore] サーバー接続成功 ✅ - 234ms
```

**オフライン時:**
```
📴 [Offline] ネットワーク接続なし
📴 [Firestore] タイムアウト (500ms)
📴 オフラインモード: ローカルに保存開始
✅ オフライン保存成功: offline_1733652123456
```

---

## 📱 検証手順

### v1.0.186 の検証（腹筋秒数表示）

1. **既存データの確認**
   - サイドプランク 40秒のデータを表示
   - 「**40秒**」と表示されることを確認 ✅

2. **ログ確認**
   ```
   📊 表示: サイドプランク - isTimeMode: true, reps: 40, is_time_mode field: false
   ```
   - `is_time_mode field: false` でも `isTimeMode: true` を確認 ✅

### v1.0.187 の検証（オフライン検出）

1. **オフラインモードテスト**
   - 機内モードON
   - トレーニング記録を入力して保存
   - **SnackBar表示**: 「📴 オフライン保存しました」✅

2. **オンライン復帰テスト**
   - 機内モードOFF
   - アプリを起動
   - **自動同期が実行される**ことを確認 ✅

---

## 🎯 技術詳細

### v1.0.186: データ判定ロジック

| is_time_mode | 判定結果 |
|--------------|----------|
| `true` | 秒数モード ✅ |
| `null` | 種目名から判定 ✅ |
| `false` | 種目名から判定 ✅（v1.0.186で修正） |

### v1.0.187: オフライン検出の2段階プロセス

#### Step 1: ネットワーク接続確認
- `connectivity_plus` で接続状態をチェック
- `ConnectivityResult.none` → 即座にオフライン判定

#### Step 2: Firestore サーバー接続確認
- `Source.server` で強制的にサーバーから取得
- **500ms タイムアウト**で高速判定
- メタデータから実際のサーバー接続を確認

---

## 🔗 関連リンク

- **GitHub リポジトリ**: https://github.com/aka209859-max/gym-tracker-flutter
- **GitHub Actions**: https://github.com/aka209859-max/gym-tracker-flutter/actions
- **App Store**: https://apps.apple.com/jp/app/gym-match/id6755346813

---

## 📊 リリース履歴

- **v1.0.185**: 全ての腹筋種目で `is_time_mode=null` データを秒数表示
- **v1.0.186**: 全ての腹筋種目で `is_time_mode=false` データも秒数表示 ✅
- **v1.0.187**: オフライン検出ロジック改善（500ms タイムアウト） ✅

---

**リリース完了** 🎉

**これで腹筋データの表示とオフライン機能が完全に動作します！**

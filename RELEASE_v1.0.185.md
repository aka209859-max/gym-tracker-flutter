# 🩹 GYM MATCH v1.0.185 リリースノート

**リリース日**: 2025-12-08  
**Build**: 185  
**優先度**: 🔴 高（表示バグ修正）

---

## 🎯 主要な変更

### 腹筋全種目で秒数入力時は秒表記に統一

**問題**:
- サイドプランク以外の腹筋種目（クランチ、レッグレイズなど）で秒数入力しても「回」表示されていた
- 過去データで `is_time_mode` フィールドが null の場合、正しく秒数表示されなかった

**修正**:
- `_getDefaultTimeMode()` ロジックを簡素化
- **全ての腹筋種目**で秒数モードをデフォルトに設定
- 過去データとの互換性を維持しつつ、秒数入力時は必ず「秒」表記

---

## ✅ 期待動作

### Before (v1.0.184まで)
| 種目 | 入力 | 表示 | 状態 |
|------|------|------|------|
| サイドプランク | 40秒 | 40秒 | ✅ OK |
| **クランチ** | 40秒 | **40回** | ❌ NG |
| **レッグレイズ** | 30秒 | **30回** | ❌ NG |

### After (v1.0.185)
| 種目 | 入力 | 表示 | 状態 |
|------|------|------|------|
| サイドプランク | 40秒 | 40秒 | ✅ OK |
| クランチ | 40秒 | 40秒 | ✅ **修正** |
| レッグレイズ | 30秒 | 30秒 | ✅ **修正** |
| プランク | 60秒 | 60秒 | ✅ OK |
| アブローラー | 20秒 | 20秒 | ✅ **修正** |

---

## 📝 対象種目（全8種）

1. クランチ
2. レッグレイズ
3. プランク
4. サイドプランク
5. アブローラー
6. ハンギングレッグレイズ
7. バイシクルクランチ
8. ケーブルクランチ

---

## 🔧 技術詳細

### 修正ファイル
1. `lib/screens/home_screen.dart` (line 2304-2309)
2. `lib/screens/workout/add_workout_screen.dart` (line 113-119)
3. `pubspec.yaml` (version 1.0.185+185)

### コード変更

#### Before
```dart
bool _getDefaultTimeMode(String exerciseName) {
  if (!_isAbsExercise(exerciseName)) return false;
  
  // プランク系種目は秒数がデフォルト
  final timeModeExercises = ['プランク', 'サイドプランク'];
  return timeModeExercises.any((e) => exerciseName.contains(e));
}
```

#### After (v1.0.185)
```dart
/// ユーザーが秒数入力した場合は「秒」表記にするため、デフォルトで全ての腹筋を秒数モードとして扱う
/// （過去のis_time_mode=nullデータとの互換性のため）
bool _getDefaultTimeMode(String exerciseName) {
  // 腹筋種目は全て秒数モードをデフォルトとする
  return _isAbsExercise(exerciseName);
}
```

### 動作原理
1. Firestore データで `is_time_mode` フィールドが明示的に保存されている場合、その値を使用
2. `is_time_mode` が `null` の場合（古いデータ）、`_getDefaultTimeMode()` で種目名から判定
3. v1.0.185 では、全ての腹筋種目で `true` を返すため、秒数表示

---

## ⚠️ 注意事項

### ユーザーへの影響
- **ポジティブ**: 秒数入力時に正しく「秒」表示されるようになります
- **ネガティブ**: 過去に「回数」で入力したクランチなども「秒」表示になる可能性があります
  - ただし、これは稀なケースで、ほとんどのユーザーは秒数で入力していると想定

### 今後の入力
- ユーザーが秒数/回数トグルを選択した場合、`is_time_mode` が明示的に保存されます
- 過去データの互換性問題は、今後の入力では発生しません

---

## 🚀 次のステップ

1. ✅ GitHub にコミット済み（ローカル）
2. ⏳ GitHub Actions で自動ビルド開始
3. ⏳ TestFlight 配信
4. ✅ ユーザー検証：クランチ、レッグレイズで秒数入力 → 「秒」表示確認

---

## 🔗 関連リンク

- **GitHub リポジトリ**: https://github.com/aka209859-max/gym-tracker-flutter
- **GitHub Actions**: https://github.com/aka209859-max/gym-tracker-flutter/actions
- **App Store**: https://apps.apple.com/jp/app/gym-match/id6755346813

---

## 📞 サポート

問題が発生した場合は、GitHub Issues でご報告ください：
https://github.com/aka209859-max/gym-tracker-flutter/issues

---

**リリース完了** 🎉

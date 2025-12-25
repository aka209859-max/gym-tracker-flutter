# 🚀 Week 1 クイックリファレンス - 実装者向け

**対象**: 開発者・エンジニア  
**目的**: Week 1 の技術詳細と Week 2 への引継ぎ

---

## 📊 **Week 1 数値サマリー**

```
処理ファイル数:     32
const削除:       1,256
文字列置換:         792
エラー数:             0
成功率:           100%
コミット数:           6
所要時間:         5.5時間
```

---

## 🛠️ **技術スタック**

### **1. apply_pattern_a_v2.py**

#### 使用方法
```bash
# Dry-run (変更なし)
python3 apply_pattern_a_v2.py lib/screens/home_screen.dart --dry-run

# 実行（ファイル更新）
python3 apply_pattern_a_v2.py lib/screens/home_screen.dart

# レポート確認
cat pattern_a_v2_report_home_screen.txt
```

#### 内部処理
```python
Step 1: const削除
  const Text() → Text()
  const SizedBox() → SizedBox()
  const Icon() → Icon()
  # など6パターン

Step 2: 文字列置換
  "日本語文字列" → l10n.arbKey
  '日本語文字列' → l10n.arbKey
  
  # 安全性チェック
  - static const / static final を回避
  - final String を回避
```

### **2. arb_key_mappings.json**

#### データ構造
```json
{
  "日本語文字列": {
    "key": "general_xxxxx",
    "match_type": "exact",
    "arb_value": "日本語文字列"
  }
}
```

#### 統計
- 総エントリー: 1,773
- Week 1使用: 792 (45%)
- 残り: 981 (Week 2で使用可能)

### **3. Pre-commit Hook**

#### ファイル位置
```
.git/hooks/pre-commit
```

#### チェック内容
1. `static const.*AppLocalizations` 検出
2. `flutter analyze` 実行（CI環境のみ）

---

## 📁 **ディレクトリ構造**

```
/home/user/webapp/
├── lib/
│   ├── screens/          # 32ファイル更新
│   │   ├── home_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── workout/
│   │   ├── partner/
│   │   ├── settings/
│   │   └── po/
│   └── l10n/
│       ├── app_ja.arb    # 3,329キー
│       ├── app_en.arb
│       ├── app_de.arb
│       ├── app_es.arb
│       ├── app_ko.arb
│       ├── app_zh.arb
│       └── app_zh_TW.arb
├── apply_pattern_a_v2.py
├── arb_key_mappings.json
├── baseline_analyze.txt
├── pattern_a_v2_report_*.txt  # 32レポート
├── WEEK1_COMPLETION_REPORT.md
├── APP_VERIFICATION_CHECKLIST.md
└── WEEK1_IMPLEMENTATION_REFERENCE.md (this file)
```

---

## 🔄 **Git ワークフロー**

### **ブランチ構造**
```
main
  └── localization-perfect (開発ブランチ)
       ├── v1.0.20251226-WEEK1-COMPLETE (Week 1タグ)
       └── (Week 2で継続使用)
```

### **コミット履歴**
```bash
# Week 1コミット一覧
git log --oneline localization-perfect --since="2025-12-25"

dd4cc6a docs: Day 1 completion
02e157c feat: Day 2 Phase 1 (home_screen)
871a1ab feat: Day 2 Phase 2 (4 files)
64df379 feat: Day 3 Phase 1 (3 files)
d66effd feat: Day 3 Phase 2 (6 files)
c2e1d66 feat: Day 4 (18 files)
a854b0d docs: Day 4 completion
```

### **PR情報**
- PR #3: https://github.com/aka209859-max/gym-tracker-flutter/pull/3
- ステータス: Open
- マージ予定: Week 2完了後

---

## 📝 **処理済みファイル詳細**

### **const削除数トップ5**
1. home_screen.dart: 248
2. ai_coaching_screen_tabbed.dart: 160
3. add_workout_screen.dart: 68
4. gym_detail_screen.dart: 63
5. subscription_screen.dart: 62

### **文字列置換数トップ5**
1. add_workout_screen.dart: 93
2. ai_coaching_screen_tabbed.dart: 83
3. home_screen.dart: 78
4. partner_search_screen_new.dart: 60
5. profile_edit_screen.dart: 51

---

## 🎯 **Week 2 実装ガイド**

### **Pattern B: 静的定数（150文字列）**

#### 対象例
```dart
// Before (危険)
static const List<String> options = ['オプション1', 'オプション2'];

// After (安全)
static List<String> getOptions(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return [l10n.option1, l10n.option2];
}
```

#### 実装手順
1. `static const` を検索
2. `List<String>` の箇所を特定
3. `static` メソッドに変換
4. `BuildContext` を引数で受け取る
5. ARBキーを追加

### **Pattern D: Model/Enum（100文字列）**

#### 対象例
```dart
// Before
enum WorkoutType {
  strength,
  cardio,
  flexibility
}

// After (Extension追加)
extension WorkoutTypeExtension on WorkoutType {
  String getName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case WorkoutType.strength:
        return l10n.workoutTypeStrength;
      case WorkoutType.cardio:
        return l10n.workoutTypeCardio;
      case WorkoutType.flexibility:
        return l10n.workoutTypeFlexibility;
    }
  }
}
```

#### 実装手順
1. Enum を検索
2. 表示用メソッドを追加（Extension）
3. ARBキーを追加

### **Pattern C & E: その他（50文字列）**

#### 対象例
- クラスレベルの `late` 変数
- `main()` 関数内の文字列
- その他特殊ケース

---

## 🐛 **トラブルシューティング**

### **問題1: l10nキー名が画面に表示される**

#### 原因
- ARBキーが存在しない
- `flutter gen-l10n` が実行されていない

#### 解決方法
```bash
# 1. ARBファイルを確認
grep "keyName" lib/l10n/app_ja.arb

# 2. 再生成
flutter pub get
flutter gen-l10n

# 3. リビルド
flutter clean
flutter build ipa --release
```

### **問題2: コンパイルエラー**

#### よくあるパターン
```
Error: The method 'of' isn't defined for the type 'AppLocalizations'
```

#### 原因
- `static const` 内で `l10n` を使用

#### 解決方法
- Pattern B の実装方法に変更

### **問題3: Pre-commit Hook エラー**

#### エラーメッセージ
```
❌ Dangerous pattern detected: static const with AppLocalizations
```

#### 解決方法
- `static const` を削除
- Pattern B の実装方法に変更

---

## 📊 **パフォーマンス指標**

### **実装速度**

| フェーズ | ファイル数 | 所要時間 | 速度 (ファイル/時間) |
|---------|-----------|---------|---------------------|
| Day 2 | 5 | 2h | 2.5 |
| Day 3 | 9 | 2h | 4.5 |
| Day 4 | 18 | 1.5h | 12.0 |
| **平均** | **10.7** | **1.8h** | **6.3** |

### **学習曲線**
- Day 2: 初期実装・学習中
- Day 3: 加速（206%達成）
- Day 4: 最高効率（12ファイル/時間）

---

## 🔗 **参照リンク**

### **内部ドキュメント**
- [Week 1 完了レポート](./WEEK1_COMPLETION_REPORT.md)
- [アプリ確認用チェックリスト](./APP_VERIFICATION_CHECKLIST.md)
- [7言語ロードマップ](./ROADMAP_7LANG_100PERCENT.md)

### **外部リンク**
- [Repository](https://github.com/aka209859-max/gym-tracker-flutter)
- [PR #3](https://github.com/aka209859-max/gym-tracker-flutter/pull/3)
- [Build #7](https://github.com/aka209859-max/gym-tracker-flutter/actions/runs/20511797913)

---

## 💡 **ベストプラクティス**

### **DO ✅**
- Exact match のみ使用
- 段階的コミット
- Pre-commit Hook で検証
- Dry-run で事前確認
- レポートファイルを保存

### **DON'T ❌**
- 一括置換（Phase 4の失敗）
- `static const` 内で l10n 使用
- Pre-commit Hook をスキップ
- テストせずにコミット
- ドキュメント化を怠る

---

## 🎓 **学んだ教訓**

### **成功要因**
1. **2段階戦略**: const削除 → 文字列置換
2. **Exact match**: 安全性100%
3. **段階的実装**: エラー0達成
4. **Pre-commit Hook**: 早期検出

### **Phase 4 失敗からの学び**
- 一括置換は危険
- `const` は l10n と非互換
- 段階的アプローチが最適

---

**作成日時**: 2025-12-25  
**作成者**: AI Coding Assistant  
**対象**: 開発者・エンジニア  
**次回更新**: Week 2開始時

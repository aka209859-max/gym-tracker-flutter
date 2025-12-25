# 📖 多言語化再実装プロンプト使用ガイド

## 🎯 このガイドについて

GYM MATCHプロジェクトの**100%多言語化（7言語）を安全に再実装する方法**について、コーディングパートナーやエキスパートに相談するためのプロンプトです。

---

## 📄 作成されたドキュメント

### 1. **LOCALIZATION_REIMPLEMENTATION_PROMPT_EN.md** (英語版)
- **サイズ:** 15KB
- **用途:** 国際的なFlutterエキスパート、Stack Overflow、GitHub Discussions向け
- **内容:**
  - 現在の状況（緊急ロールバック後）
  - 翻訳資産の棚卸し（ARBファイル状況）
  - 6つの重要な質問
  - 期待する回答形式

### 2. **LOCALIZATION_REIMPLEMENTATION_PROMPT_JP.md** (日本語版)
- **サイズ:** 10KB
- **用途:** 日本語圏のFlutterエキスパート、teratail、Qiita向け
- **内容:** 英語版と同じ内容を日本語で記載

### 3. **LOCALIZATION_REIMPLEMENTATION_USAGE_GUIDE.md** (このファイル)
- **用途:** プロンプトの使用方法ガイド

---

## 🌐 共有先プラットフォーム

### 英語圏

| プラットフォーム | 推奨度 | 理由 |
|----------------|--------|------|
| **Stack Overflow** | ⭐⭐⭐⭐⭐ | Flutter専門家が多数 |
| **GitHub Discussions** | ⭐⭐⭐⭐⭐ | Flutter公式コミュニティ |
| **Reddit r/FlutterDev** | ⭐⭐⭐⭐ | アクティブなコミュニティ |
| **Flutter Discord** | ⭐⭐⭐⭐ | リアルタイムチャット |
| **Upwork / Fiverr** | ⭐⭐⭐⭐⭐ | 有料プロ相談 |

### 日本語圏

| プラットフォーム | 推奨度 | 理由 |
|----------------|--------|------|
| **teratail** | ⭐⭐⭐⭐⭐ | 日本最大のQ&A |
| **Qiita** | ⭐⭐⭐⭐ | 技術記事共有 |
| **Twitter (X)** | ⭐⭐⭐ | #FlutterJP コミュニティ |

---

## 🎯 プロンプトの目的

### 相談したい内容

1. **再実装戦略** - 手動 vs 半自動 vs ハイブリッド
2. **技術的パターン** - Widget、Static、Class-level、Model、Enum
3. **文字列マッピング** - ハードコード文字列 → ARBキー
4. **テスト戦略** - ファイル単位、統合、CI/CD
5. **段階的ロールアウト** - 4週間の優先順位計画
6. **エラー予防** - Phase 4の災害を繰り返さない方法

### 期待する回答

- ✅ 具体的な実装手順
- ✅ コード例とパターン
- ✅ ツールとスクリプトの推奨
- ✅ 週単位のアクションプラン
- ✅ リスク評価とタイムライン

---

## 📝 使用方法

### Stack Overflow に投稿する場合

#### Title:
```
Flutter: Safe Strategy to Re-implement 7-Language Localization After Emergency Rollback
```

#### Body:
```markdown
[LOCALIZATION_REIMPLEMENTATION_PROMPT_EN.md の内容をコピー&ペースト]
```

#### Tags:
```
flutter, dart, localization, internationalization, flutter-intl, arb
```

---

### teratail に投稿する場合

#### タイトル:
```
Flutter: 緊急ロールバック後に7言語ローカライゼーションを安全に再実装する戦略
```

#### 本文:
```markdown
[LOCALIZATION_REIMPLEMENTATION_PROMPT_JP.md の内容をコピー&ペースト]
```

#### タグ:
```
Flutter, Dart, 多言語化, 国際化, ローカライゼーション
```

---

### GitHub Discussions に投稿する場合

#### Title:
```
Strategy for Safe Localization Re-implementation (23,275 strings, 7 languages)
```

#### Category:
```
💬 General Discussion or ❓ Q&A
```

#### Body:
```markdown
# Context
We recently completed an emergency rollback to fix 1,872 compilation errors caused by Phase 4's regex-based localization implementation. Now we need expert guidance to safely re-implement full 7-language support.

[LOCALIZATION_REIMPLEMENTATION_PROMPT_EN.md の内容をコピー&ペースト]
```

---

## 🔍 プロンプトの構造

### セクション1: プロジェクトコンテキスト
- プロジェクト概要
- 現在の状況（ロールバック後）
- ARB翻訳資産の棚卸し

### セクション2: 6つの重要な質問
1. 再実装戦略（手動/半自動/ハイブリッド）
2. 技術的実装パターン（5つのシナリオ）
3. 文字列マッピング方法
4. テストと検証戦略
5. 段階的ロールアウト計画（4週間）
6. エラー予防措置

### セクション3: 期待する回答形式
- 戦略選択と根拠
- パターン検証
- マッピングアプローチ
- テスト計画
- アクションプラン（週単位）

---

## 💡 質問のポイント

### 最も重要な質問

#### Q1: どの戦略が最適か？

```
A) 手動アプローチ（2-4週間）
   - 最も安全
   - 時間がかかる
   - 学習曲線が高い

B) 半自動アプローチ（1-2週間）
   - 中程度の安全性
   - 効率的
   - スクリプト作成が必要

C) ハイブリッド（2週間）
   - バランスが良い
   - 優先度に基づく
   - 推奨？
```

#### Q2: 正しいFlutterパターンは？

```dart
// Widget内での使用
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Text(l10n.keyName);
}

// Static メソッド
static List<String> getOptions(BuildContext context) {
  return [AppLocalizations.of(context)!.option1];
}

// Enum拡張
extension WorkoutTypeExt on WorkoutType {
  String localized(BuildContext context) {
    return AppLocalizations.of(context)!.workoutTypeCardio;
  }
}
```

#### Q3: 文字列マッピングの効率化

```
現在: 1,000+ ハードコード文字列
ARB: 3,325 キー

方法A: grep で検索
方法B: マッピングツール作成
方法C: スプレッドシート管理

どれが最適？
```

---

## 📊 期待される回答例

### 理想的な回答の構造

```markdown
## 1. 推奨戦略

**選択: C (ハイブリッドアプローチ)**

根拠:
- 優先度の高い画面（20%）は手動で慎重に
- 残り80%は半自動化で効率化
- リスクとスピードのバランス

推定タイムライン: 2週間
- Week 1: コアナビゲーション（手動）
- Week 2: 残りの画面（半自動）

---

## 2. 技術的パターン

### Widget内での使用 ✅ 正しい
```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Text(l10n.keyName);
}
```

### Static メソッド ✅ 正しい
```dart
static List<String> getOptions(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return [l10n.option1, l10n.option2];
}
```

### 追加パターン: Provider での使用
```dart
class MyProvider with ChangeNotifier {
  String getMessage(BuildContext context) {
    return AppLocalizations.of(context)!.message;
  }
}
```

---

## 3. 文字列マッピング

推奨: **マッピングツール + スプレッドシート**

ステップ:
1. Dartスクリプトで全ハードコード文字列を抽出
2. ARBファイルから候補キーを検索
3. スプレッドシートで手動レビュー
4. 確認後、一括置換

ツール例:
```dart
void extractHardcodedStrings(String filePath) {
  // 正規表現でハードコード文字列を検出
  // ARBで候補キーを検索
  // 結果をCSVに出力
}
```

---

## 4. テスト戦略

ファイル単位:
- [ ] flutter analyze
- [ ] 手動コードレビュー
- [ ] 画面表示確認
- [ ] 言語切り替え確認

統合:
- [ ] 全画面回帰テスト
- [ ] 7言語動作確認
- [ ] パフォーマンステスト

CI/CD:
- [ ] pre-commit: flutter analyze
- [ ] PR: ARBキー検証
- [ ] merge: 自動ビルドテスト

---

## 5. アクションプラン

### Week 1: コアナビゲーション（手動）
- [ ] Day 1-2: lib/main.dart, home_screen.dart
- [ ] Day 3-4: navigation_bar.dart, map_screen.dart
- [ ] Day 5: テストとレビュー

### Week 2: 残りの画面（半自動）
- [ ] Day 1-2: スクリプト作成とテスト
- [ ] Day 3-4: 一括適用と手動レビュー
- [ ] Day 5: 統合テストと修正

成功指標:
- ✅ 0 compilation errors
- ✅ 7 languages fully functional
- ✅ 100% translation coverage
```

---

## 🚀 投稿後のフォローアップ

### 回答を受け取ったら

1. **回答を分析**
   - 推奨戦略を理解
   - 技術的パターンを確認
   - アクションプランを整理

2. **質問がある場合**
   - 具体的な箇所を明確に
   - コード例を求める
   - タイムラインの詳細を確認

3. **実装開始**
   - Week 1のタスクから開始
   - 進捗を記録
   - 問題が発生したら再相談

4. **結果を報告**
   - 成功した方法を共有
   - コミュニティへのフィードバック

---

## 📋 チェックリスト

### 投稿前

- [ ] プロンプトの内容を理解した
- [ ] プラットフォームを選択した
- [ ] タイトルとタグを準備した
- [ ] 現在のBuild #4の結果を確認した
- [ ] ARBファイルの状態を確認した

### 投稿後

- [ ] 投稿URLを保存した
- [ ] 通知を有効にした
- [ ] 24-48時間以内に回答をチェック
- [ ] 追加質問に回答する準備
- [ ] 実装計画を作成する準備

---

## 🔗 参考リンク

### プロジェクト
- **Repository:** https://github.com/aka209859-max/gym-tracker-flutter
- **PR #3:** https://github.com/aka209859-max/gym-tracker-flutter/pull/3
- **Build #4:** https://github.com/aka209859-max/gym-tracker-flutter/actions/runs/20506554020

### ドキュメント
- **緊急ロールバックレポート:** EMERGENCY_ROLLBACK_COMPLETION_REPORT.md
- **前回のエキスパート回答:** (ユーザー提供)
- **ビルドエラー分析:** COMPREHENSIVE_BUILD_ERROR_REPORT_FOR_PARTNERS.md

---

## 💡 成功のヒント

### より良い回答を得るために

1. **具体的に質問**
   - ✅ "Widget内でAppLocalizations.of(context)を使う正しい方法は？"
   - ❌ "ローカライゼーションの方法を教えて"

2. **コンテキストを提供**
   - プロジェクトの背景
   - 現在の状態
   - 試したこと

3. **回答形式を明示**
   - コード例が欲しい
   - ステップバイステップのガイド
   - ツールの推奨

4. **フォローアップ**
   - 追加質問を恐れない
   - 結果を共有する
   - コミュニティに還元

---

## 🎯 期待される成果

このプロンプトを使用することで:

1. ✅ **明確な戦略** - 手動/半自動/ハイブリッドの選択
2. ✅ **正しいパターン** - Widget、Static、Enum等の実装例
3. ✅ **効率的なマッピング** - 文字列→ARBキーの方法
4. ✅ **包括的なテスト** - 品質保証の戦略
5. ✅ **段階的プラン** - 4週間の具体的アクション
6. ✅ **エラー予防** - Phase 4を繰り返さない保護策

---

## 📞 サポート

質問やフィードバックは:

- **GitHub Issues:** https://github.com/aka209859-max/gym-tracker-flutter/issues
- **PR #3 Comments:** https://github.com/aka209859-max/gym-tracker-flutter/pull/3

---

**作成日:** 2025-12-25 14:50 UTC  
**バージョン:** 1.0  
**目的:** 100%多言語化（7言語）の安全な再実装  
**期待効果:** 2-4週間で完全ローカライゼーション達成

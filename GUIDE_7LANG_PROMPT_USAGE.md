# 📘 7言語100%翻訳プロンプト - 使用ガイド

**作成日**: 2025-12-25  
**対象**: プロジェクトマネージャー、開発チーム

---

## 🎯 このドキュメントの目的

コーディングパートナー（外部エキスパート）から7言語100%翻訳達成のための**具体的な実装アドバイス**をもらうためのプロンプトを作成しました。

---

## 📦 作成したファイル

### 1. コーディングパートナー向けプロンプト

| ファイル名 | 言語 | サイズ | 用途 |
|-----------|------|--------|------|
| **PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_EN.md** | 英語 | 20KB | Stack Overflow, GitHub Discussions, Reddit 等 |
| **PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_JP.md** | 日本語 | 15KB | teratail, Qiita, Twitter (X) 等 |

### 2. AI Coding Assistant の技術的意見

| ファイル名 | 言語 | サイズ | 内容 |
|-----------|------|--------|------|
| **AI_ASSISTANT_TECHNICAL_OPINION_JP.md** | 日本語 | 18KB | 推奨技術パターン、実装計画、テスト戦略 |

---

## 🚀 使い方（3ステップ）

### Step 1: プロンプトを選択

```yaml
英語圏のコミュニティに投稿する場合:
  使用ファイル: PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_EN.md
  対象プラットフォーム:
    - Stack Overflow (タグ: flutter, dart, localization)
    - GitHub Discussions (Flutter リポジトリ)
    - Reddit r/FlutterDev
    - Discord (Flutter Community)

日本語圏のコミュニティに投稿する場合:
  使用ファイル: PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_JP.md
  対象プラットフォーム:
    - teratail (タグ: Flutter, Dart, 多言語化)
    - Qiita (Flutter コミュニティ)
    - Twitter (X) (#FlutterDev #Flutter日本)
    - GitHub Discussions (日本語セクション)
```

### Step 2: プラットフォームに投稿

#### Stack Overflow の場合

```markdown
タイトル:
"How to safely implement 100% 7-language support in Flutter after Phase 4 disaster?"

タグ:
- flutter
- dart
- localization
- internationalization
- arb

本文:
[PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_EN.md の内容をコピー&ペースト]
```

#### teratail の場合

```markdown
タイトル:
「Phase 4災害後、Flutterで7言語100%対応を安全に実装する方法」

タグ:
- Flutter
- Dart
- 多言語化
- 国際化
- ARB

本文:
[PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_JP.md の内容をコピー&ペースト]
```

#### GitHub Discussions の場合

```markdown
Category: Q&A または Help Wanted

Title:
"[Help Needed] Safe strategy for 100% 7-language localization after disaster recovery"

Body:
[PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_EN.md の内容をコピー&ペースト]
```

### Step 3: 回答を待つ & 分析

```yaml
期待回答時間: 24-48時間

重要な質問（優先度順）:
  1. 戦略: 週次 vs 機能ベース vs カスタム？
  2. 技術パターン: 5つのシナリオへの推奨
  5. ロールアウト計画: 具体的な週次計画
  3. マッピング: 1,000文字列 → 3,325キー
  4. テスト: 品質保証の方法
  6. 安全対策: Phase 4 再発防止

回答を受け取ったら:
  1. AI_ASSISTANT_TECHNICAL_OPINION_JP.md と比較
  2. 共通点と相違点を分析
  3. 最良のアプローチを選択
  4. 最終実装計画を策定
```

---

## 📊 プロンプトの内容

### 含まれている情報

```yaml
背景情報:
  - プロジェクト概要（GYM MATCH）
  - 技術スタック（Flutter 3.35.4, Dart等）
  - 現在の状態（v1.0.306+328, ARB 100%完成）
  - Phase 4 災害の詳細（1,872エラー）

質問（6つ）:
  1. 戦略: 一括 vs 段階的？
  2. 技術パターン: 5つのシナリオ
     A) Widget でのローカライゼーション
     B) 静的定数とリスト
     C) クラスレベル定数
     D) Model クラス（Enum）
     E) main() と初期化
  3. マッピング: 文字列 → ARBキー
  4. テスト: 品質保証戦略
  5. ロールアウト: 週次計画
  6. 安全対策: 再発防止

リソース:
  - GitHub リポジトリ URL
  - 関連ドキュメント
  - ARB ファイル情報
  - ビルド履歴

期待する回答形式:
  - 各質問への具体的回答
  - コード例
  - 週次アクションプラン
  - リスク評価
```

---

## 🤖 AI Assistant の推奨（概要）

### 戦略: ハイブリッドアプローチ

```yaml
期間: 3週間実装 + 1週間テスト = 4週間
アプローチ: 週次 × リスクベース × 機能別

Week 1: クリティカルパス UI（4-7画面）
Week 2: 機能画面（10-15画面）
Week 3: 専門機能 + インフラ（15-20画面）
Week 4: テスト週間（品質保証）
```

### 技術パターン

```yaml
Widget: Option 2（build内でローカル変数 l10n）
Static: Option 1（静的メソッド + BuildContext）
Class-level: Option 2（Getter）
Enum: Option 1（Extension method）
main(): Option 1（英語ハードコード）
```

### マッピング: セミ自動

```yaml
Step 1: 自動マッピング（70%）- Python スクリプト
Step 2: 手動レビュー（30%）- Excel/Google Sheets
Step 3: 検証（必須）- flutter analyze + カスタムスクリプト
```

### テスト: 多層アプローチ

```yaml
Layer 1: Unit Tests（80%+ カバレッジ）
Layer 2: Widget Tests（主要画面 100%）
Layer 3: Integration Tests（クリティカルフロー 100%）
Layer 4: Manual Tests（全7言語）
```

### 安全対策: 4層防御

```yaml
Layer 1: Pre-commit Hooks
Layer 2: CI/CD Pipeline
Layer 3: Code Review Checklist
Layer 4: Monitoring & Rollback
```

---

## 📋 両者の意見を統合する方法

### Step 1: 回答を受け取る

```bash
# コーディングパートナーから回答を受け取ったら
# 以下のフォーマットで整理

[回答日時]: 2025-XX-XX
[回答者]: エキスパート名
[プラットフォーム]: Stack Overflow / teratail 等
[回答URL]: https://...

## 質問1への回答
[要約]
- 推奨アプローチ: XXX
- 理由: XXX
- コード例: XXX

## 質問2への回答
...
```

### Step 2: AI Assistant の意見と比較

```yaml
比較表を作成:

| 項目 | AI Assistant | コーディングパートナー | 採用案 |
|------|-------------|---------------------|--------|
| 戦略 | ハイブリッド（3週+1週） | [パートナーの回答] | [決定] |
| Widget | Option 2 | [パートナーの回答] | [決定] |
| Static | Option 1 | [パートナーの回答] | [決定] |
| ... | ... | ... | ... |
```

### Step 3: 最終実装計画を策定

```yaml
最終計画書に含める項目:
  1. 採用した戦略とその理由
  2. 各シナリオの技術パターン（コード例付き）
  3. 週次タスク分解
  4. テスト計画
  5. 安全対策
  6. ロールバック手順
  7. 成功基準

ドキュメント名:
  FINAL_7LANG_IMPLEMENTATION_PLAN_v1.0.md
```

---

## ⚠️ 注意事項

### 質問する際の注意

```yaml
Do:
  ✅ プロンプト全体をコピー&ペースト
  ✅ 背景情報を十分に提供
  ✅ 具体的なコード例を求める
  ✅ 回答に対して追加質問をする
  ✅ 複数のエキスパートから意見を集める

Don't:
  ❌ プロンプトを省略しない
  ❌ 背景情報を隠さない
  ❌ 「とりあえず教えて」のような曖昧な質問
  ❌ 1つの回答だけで決定しない
  ❌ コードだけもらって理由を聞かない
```

### 回答を評価する基準

```yaml
良い回答の特徴:
  ✅ 具体的な技術パターン（コード例付き）
  ✅ Flutter ベストプラクティスに基づく
  ✅ リスク評価が含まれる
  ✅ 理由が明確
  ✅ 代替案も提示

避けるべき回答:
  ❌ 曖昧な回答（「適当にやればいい」等）
  ❌ コードのみで説明なし
  ❌ 古い情報（Flutter 2.x 等）
  ❌ Phase 4 の失敗を考慮していない
  ❌ テストや安全対策に言及なし
```

---

## 📈 期待される成果

### 即時（24-48時間）

```yaml
取得できる情報:
  - エキスパートの推奨戦略
  - 正しい技術パターン
  - 実装時の注意点
  - よくある落とし穴

アクション:
  - AI Assistant の意見と比較
  - 最終実装計画を策定
```

### 短期（1週間）

```yaml
成果物:
  - FINAL_7LANG_IMPLEMENTATION_PLAN_v1.0.md
  - Week 1 タスクリスト
  - テンプレートコード
  - テストフレームワーク

アクション:
  - Week 1 実装開始
  - パターンの確立
```

### 中期（4週間）

```yaml
成果物:
  - 7言語100%対応完了
  - IPA ビルド成功
  - TestFlight デプロイ
  - App Store 申請準備完了

アクション:
  - App Store 申請
  - リリース
```

---

## 🔗 関連ドキュメント

### プロジェクト全体

```yaml
現在の状態:
  - SAFE_ROLLBACK_COMPLETION_REPORT.md（ロールバック完了レポート）
  - CURRENT_APP_STATUS_COMPREHENSIVE_REPORT_JP.md（現在の状態）

Phase 4 災害:
  - ROOT_CAUSE_ANALYSIS_FINAL.md（根本原因分析）
  - COMPREHENSIVE_BUILD_ERROR_REPORT_FOR_PARTNERS.md（エラーレポート）

ロールバック:
  - EMERGENCY_ROLLBACK_COMPLETION_REPORT.md（緊急ロールバック）
  - CRITICAL_CORRECTION_ROLLBACK_TARGET.md（重要な訂正）
```

### 今回作成したドキュメント

```yaml
プロンプト:
  - PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_EN.md（英語版）
  - PROMPT_FOR_CODING_PARTNER_7LANG_100PERCENT_JP.md（日本語版）

意見:
  - AI_ASSISTANT_TECHNICAL_OPINION_JP.md（AI の推奨）

ガイド:
  - GUIDE_7LANG_PROMPT_USAGE.md（このファイル）
```

---

## 🎯 次のアクション

### 即座に実行

```bash
1. プラットフォームを選択（Stack Overflow / teratail 等）
2. 該当するプロンプトをコピー（EN or JP）
3. 投稿
4. 通知を有効化
```

### 24-48時間後

```bash
1. 回答を確認
2. AI Assistant の意見と比較
3. 追加質問（必要なら）
4. 最終実装計画を策定
```

### 1週間後

```bash
1. Week 1 実装開始
2. 進捗報告
3. 問題があれば再度質問
```

---

## ✨ まとめ

```yaml
目的:
  7言語100%翻訳達成のための具体的な実装アドバイスを得る

手段:
  - コーディングパートナー向けプロンプト（英語・日本語）
  - AI Assistant の技術的意見

期待:
  - エキスパートの推奨戦略
  - 正しい技術パターン
  - 週次実装計画

成果:
  - 最終実装計画の策定
  - 4週間で100%達成
  - App Store リリース成功
```

---

**作成**: AI Coding Assistant  
**更新**: 2025-12-25  
**バージョン**: 1.0

**次のステップ**: プロンプトを投稿して、エキスパートの意見を待ちましょう！

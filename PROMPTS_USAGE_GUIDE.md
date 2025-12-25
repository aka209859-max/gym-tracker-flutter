# 📚 プロンプト使用ガイド / Prompt Usage Guide

## 📁 作成したファイル / Created Files

このフォルダには、以下の2つの詳細なプロンプトが含まれています：

1. **BUILD_ERROR_ANALYSIS_PROMPT.md** (日本語版)
2. **BUILD_ERROR_ANALYSIS_PROMPT_EN.md** (English version)

---

## 🎯 使用目的 / Purpose

これらのプロンプトは、**コーディングパートナー**（AI アシスタント、技術コンサルタント、Flutter 開発者）に、現在のビルドエラー状況を詳細に説明し、技術的なアドバイスを求めるために作成されました。

These prompts were created to provide **coding partners** (AI assistants, technical consultants, Flutter developers) with detailed information about current build errors and request technical advice.

---

## 📝 含まれる情報 / Included Information

### 1. プロジェクト基本情報 / Project Basics
- プロジェクト名: GYM MATCH
- 開発環境: Windows + GitHub Actions (macOS runner)
- Flutter バージョン: 3.35.4
- ビルドコマンド: `flutter build ipa --release`

### 2. 問題の経緯 / Issue Timeline
- Phase 4: Google Translation API による7言語対応実装
- Round 1-7: 35ファイルの修正
- Round 8: 4ファイルの致命的エラー修正

### 3. 過去3回のビルドエラー詳細 / Last 3 Build Errors
- Build #1 (Run ID: 20504363338) - FAILED
- Build #2 (Run ID: 20505408543) - FAILED
- Build #3 (Run ID: 20505926743) - IN PROGRESS

### 4. エラーパターンと修正方法 / Error Patterns & Fixes
- パターン1: `static const` → `static getter`
- パターン2: フィールド初期化 → `late` + `didChangeDependencies()`
- パターン3: `main()` → ハードコード
- パターン4: enum マップ → getter
- パターン5: 存在しないARBキー → 復元

### 5. 修正統計 / Fix Statistics
- 合計39ファイル修正 (Phase 4で変更した115ファイルのうち34%)
- 8ラウンドの修正作業
- 500行以上の変更

### 6. 具体的な質問 / Specific Questions
1. 修正方針は正しいか？
2. 見落としている問題はないか？
3. ビルド成功の確率は？
4. 追加で必要な対応は？
5. 長期的なベストプラクティスは？

---

## 🚀 使用方法 / How to Use

### 方法1: AI アシスタントに質問する / Ask AI Assistants

#### ChatGPT (OpenAI)
```
1. ChatGPT を開く
2. 以下のファイルの内容を全てコピー:
   - BUILD_ERROR_ANALYSIS_PROMPT.md (日本語)
   または
   - BUILD_ERROR_ANALYSIS_PROMPT_EN.md (English)
3. ChatGPT に貼り付けて送信
4. 回答を待つ
```

#### Claude (Anthropic)
```
1. Claude を開く
2. 同様にファイル内容をコピー＆ペースト
3. より詳細な技術分析を期待できます
```

#### Gemini (Google)
```
1. Gemini を開く
2. ファイル内容をコピー＆ペースト
3. Flutter/Dart 特有の問題についてのアドバイスを求める
```

---

### 方法2: 開発者コミュニティに投稿 / Post to Developer Communities

#### Stack Overflow
```
1. https://stackoverflow.com/questions/ask にアクセス
2. Title: "Flutter iOS Build Errors After Localization: context in static const"
3. Body: BUILD_ERROR_ANALYSIS_PROMPT_EN.md の内容を貼り付け
4. Tags: flutter, dart, ios, localization, build-errors
5. 投稿
```

#### Reddit (r/FlutterDev)
```
1. https://www.reddit.com/r/FlutterDev/ にアクセス
2. 「Create Post」をクリック
3. Title: "Need help fixing build errors after Phase 4 localization"
4. Body: プロンプトの要約 + GitHub リンク
5. 投稿
```

#### Flutter Discord
```
1. Flutter Discord サーバーに参加
2. #help チャンネルを選択
3. プロンプトの要約を投稿
4. 詳細はGitHubリンクで共有
```

---

### 方法3: 技術コンサルタントに依頼 / Hire Technical Consultants

#### Upwork / Fiverr
```
1. プロジェクト説明にプロンプトを使用
2. 「Flutter iOS build error consultation」で検索
3. 経験豊富な開発者を選択
4. プロンプトファイルを共有
```

---

## 📊 期待される回答 / Expected Responses

### 良い回答の例 / Good Response Examples

1. **修正方針の確認**:
   ```
   ✅ 「static const → static getter への変更は正しいです」
   ✅ 「main() のハードコードは適切です」
   ✅ 「BuildContext の使い方が正しくなりました」
   ```

2. **追加の指摘**:
   ```
   ⚠️ 「XXXファイルでも同じ問題がある可能性があります」
   ⚠️ 「YYY パターンも確認すべきです」
   ```

3. **ビルド成功確率**:
   ```
   🔮 「95-99%の確率で成功すると思います」
   🔮 「ただし、ZZZ に注意してください」
   ```

4. **長期的な推奨事項**:
   ```
   💡 「今後は intl パッケージの使用を推奨」
   💡 「自動テストで静的解析を追加」
   💡 「CI/CD パイプラインに flutter analyze を統合」
   ```

---

## 🔗 重要なリンク / Important Links

- **GitHub リポジトリ**: https://github.com/aka209859-max/gym-tracker-flutter
- **Pull Request #3**: https://github.com/aka209859-max/gym-tracker-flutter/pull/3
- **最新ビルド**: https://github.com/aka209859-max/gym-tracker-flutter/actions/runs/20505926743

---

## ⚠️ 注意事項 / Important Notes

1. **プライバシー**: プロンプトには個人情報は含まれていません
2. **リポジトリアクセス**: GitHubリポジトリは公開設定の場合のみ共有可能
3. **更新**: ビルドが完了したら、最新の結果をコメントとして追加してください

---

## 📞 次のステップ / Next Steps

### ビルドが成功した場合 / If Build Succeeds
1. ✅ PR#3 をマージ
2. ✅ TestFlight へデプロイ
3. ✅ コーディングパートナーに感謝の報告
4. ✅ このプロンプトを学習資料としてアーカイブ

### ビルドが失敗した場合 / If Build Fails
1. ❌ 新しいエラーログを取得
2. ❌ プロンプトを更新（Build #4 として追加）
3. ❌ 再度コーディングパートナーに相談
4. ❌ 追加の修正を適用

---

## 💬 フィードバック / Feedback

このプロンプトを使用して得られた回答や改善点があれば、以下に記録してください：

- **有用だった回答**: 
- **見落としていた問題**: 
- **追加すべき情報**: 
- **改善点**: 

---

**作成日**: 2025-12-25  
**バージョン**: 1.0  
**最終更新**: Round 8 完了時点

# Google Cloud Console - API使用状況確認ガイド

## 🎯 目的
GYM MATCH アプリの Gemini API 使用状況を確認し、429エラーの原因を特定する

## 📍 ナビゲーション手順

### 方法1: APIダッシュボードから（推奨）

1. **Google Cloud Console にアクセス**
   - URL: https://console.cloud.google.com/

2. **プロジェクトを選択**
   - 画面上部のプロジェクト選択ドロップダウンをクリック
   - 「GYM MATCH」または該当プロジェクトを選択

3. **APIダッシュボードへ移動**
   - 左側メニュー（≡ ハンバーガーメニュー）をクリック
   - 「APIs & Services」（APIとサービス）を選択
   - 「Dashboard」（ダッシュボード）をクリック

4. **Generative Language API を選択**
   - API一覧から「Generative Language API」を探してクリック
   - ※見つからない場合は検索ボックスで「generative language」と検索

5. **メトリクスを確認**
   - 「Metrics」（指標）タブをクリック
   - 以下を確認：
     - **Traffic（トラフィック）**: 今日のリクエスト数
     - **Errors（エラー）**: エラー率、429エラーの回数
     - **Latency（レイテンシ）**: 応答時間

### 方法2: Quotas（割り当て）から

1. Google Cloud Console → APIs & Services → **Enabled APIs & services**

2. 「Generative Language API」をクリック

3. 上部メニューから **「Quotas & System Limits」** を選択

4. 確認項目：
   - ✅ **Requests per minute per project**: 15/15 かどうか
   - ✅ **Requests per day per project**: 1,500 のうち何件使用済みか
   - ✅ **リセット時間**: 次回リセットまでの時間

### 方法3: Monitoring（モニタリング）から

1. Google Cloud Console → **Monitoring**（モニタリング）

2. 左メニュー → **Metrics Explorer**

3. 検索ボックスに以下を入力：
   ```
   serviceruntime.googleapis.com/api/request_count
   ```

4. フィルタを追加：
   - **Service**: generativelanguage.googleapis.com
   - **Method**: GenerateContent

5. 時間範囲を「Last 24 hours」に設定

## 🔍 確認すべき重要項目

### ✅ Check 1: 今日のリクエスト総数
- **0-100件**: 正常範囲（少数ユーザー）
- **100-500件**: 中程度使用
- **500-1,000件**: 高使用率
- **1,000-1,500件**: 上限接近（要対策）
- **1,500件以上**: RPD上限到達（429エラー確定）

### ✅ Check 2: RPM（1分あたりリクエスト数）
- **15回/分**: 無料枠の上限
- 超過すると即座に429エラー

### ✅ Check 3: エラー率
- **429エラーの割合**: 5%以上なら深刻
- **時間帯別の傾向**: ピーク時間を特定

### ✅ Check 4: 次回リセット時間
- RPD（Daily）: 太平洋標準時の午前0時（日本時間17時）
- RPM（Minute）: 1分ごと

## 📊 スクリーンショットで提供してほしい情報

以下のいずれかの画面をスクリーンショットで共有してください：

1. **Metrics（指標）画面**
   - Traffic グラフ（過去24時間）
   - Errors グラフ

2. **Quotas（割り当て）画面**
   - Requests per minute: 〇〇/15
   - Requests per day: 〇〇〇/1,500

3. **Monitoring - Metrics Explorer 画面**
   - request_count グラフ

## 🚨 緊急度判定

### 🔴 即対応必要（次のいずれか）
- RPD使用率 > 80%（1,200件以上）
- RPM頻繁超過（複数ユーザー同時使用）
- エラー率 > 10%

→ **対策**: 有料プラン移行、バックエンドプロキシ導入

### 🟡 要監視
- RPD使用率 50-80%（750-1,200件）
- たまに429エラー発生

→ **対策**: v1.0.193のリトライ機能で対応可

### 🟢 正常
- RPD使用率 < 50%（750件未満）
- 429エラーほぼなし

→ **対策**: 現状維持

## 💡 よくある質問

### Q1: ダウンロード数が少ないのに上限に達する？
A: 以下の可能性があります：
- **開発テスト**: 開発中の大量テスト実行
- **特定ユーザーの多用**: 1人が何度も使用
- **APIキー共有**: 全ユーザーで1つのキーを共有しているため

### Q2: 無料枠を超えたらどうなる？
A: 429エラーが返され、アプリでエラーメッセージが表示されます。
   翌日（太平洋時間0時）に自動リセットされます。

### Q3: 有料プランの費用は？
A: Gemini 2.0 Flash の場合：
- 入力: $0.075 / 1M tokens
- 出力: $0.30 / 1M tokens
- 1リクエスト約500トークンとして、1,000リクエストで約$0.19（約28円）

## 🔗 参考リンク

- Google Cloud Console: https://console.cloud.google.com/
- Gemini API Pricing: https://ai.google.dev/pricing
- Quota Management: https://cloud.google.com/docs/quota

---

**次のステップ**: 上記いずれかの方法で確認し、スクリーンショットを共有してください！

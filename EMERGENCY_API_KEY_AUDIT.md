# 🚨 緊急: APIキー監査 & 問題切り分け

## 発見された問題

### ❌ 異常なAPI使用パターン
- **プロジェクト**: GYM MATCH X Automation
- **リクエスト数**: 153,290回（StreamGenerateContent）
- **エラー率**: 99.58%
- **期間**: 不明（要確認）

### ❌ これが GYM MATCH アプリの 429 エラーの原因

もし「GYM MATCH」アプリと「X Automation」で **同じAPIキー** を使用していた場合、
Automation プロジェクトの暴走が GYM MATCH アプリの 429 エラーを引き起こしています。

---

## 🔥 即座に実行すべき対応

### 1️⃣ APIキーの確認と分離（最優先）

#### A. 現在のAPIキーを確認
```dart
// lib/screens/workout/ai_coaching_screen.dart (line 621)
final apiKey = 'AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc'; // ← これ
```

#### B. Google Cloud Console で確認
1. https://console.cloud.google.com/apis/credentials
2. プロジェクト: **GYM MATCH** を選択
3. APIキー一覧で `AIzaSyA9XmQ...` を探す
4. 「使用状況」を確認
   - ✅ このキーが「X Automation」でも使われているか？
   - ✅ 制限設定（Application restrictions）があるか？

---

### 2️⃣ 「GYM MATCH X Automation」の調査

#### 確認項目
1. **このプロジェクトは何のため？**
   - テスト環境？
   - CI/CD パイプライン？
   - バックエンド処理？
   - 不明な自動化スクリプト？

2. **APIキーは共有しているか？**
   - GYM MATCH アプリと同じキーを使用？
   - 独自のキーを使用？

3. **153,290回のリクエストはいつ発生？**
   - Google Cloud Console で確認
   - プロジェクト: **GYM MATCH X Automation** を選択
   - APIs & Services → Dashboard
   - 時系列グラフを確認

---

### 3️⃣ 緊急の暫定対応

#### Option A: APIキーを無効化（推奨）
```
1. Google Cloud Console → APIs & Credentials
2. 現在のAPIキー `AIzaSyA9XmQ...` を選択
3. 「Delete」（削除）または「Restrict」（制限追加）
4. 新しいAPIキーを作成（GYM MATCH アプリ専用）
```

#### Option B: Application Restrictions を設定
```
1. APIキーの編集画面を開く
2. 「Application restrictions」セクション
3. 「iOS apps」を選択
4. Bundle ID を追加: `jp.nexa.fitsync`
5. 保存
```
→ これで「X Automation」からのリクエストをブロック

#### Option C: 「X Automation」を一時停止
```
- そのプロジェクトのスクリプト/サービスを停止
- Cloud Run, Cloud Functions, App Engine などをチェック
```

---

## 📊 データ収集（スクリーンショット依頼）

### 必要な情報

#### 1. 「GYM MATCH X Automation」の使用状況
- プロジェクトを **「GYM MATCH X Automation」** に切り替え
- APIs & Services → Dashboard
- Generative Language API → Metrics
- **過去7日間のトラフィックグラフ** をスクリーンショット

#### 2. 現在のAPIキーの制限設定
- https://console.cloud.google.com/apis/credentials
- プロジェクト: **GYM MATCH**
- APIキー `AIzaSyA9XmQ...` をクリック
- **Application restrictions** セクションをスクリーンショット

#### 3. 「GYM MATCH」アプリの実際の使用状況
- プロジェクト: **GYM MATCH** (gym-match-e560d)
- APIs & Services → Dashboard
- Generative Language API → Metrics
- **今日のリクエスト数** をスクリーンショット

---

## 🎯 根本原因の仮説

### 仮説1: APIキーの不適切な共有（可能性: 90%）
- GYM MATCH アプリと X Automation で同じキーを使用
- X Automation のバグで無限リトライ
- 結果: 両方のプロジェクトで 429 エラー

### 仮説2: X Automation の暴走（可能性: 70%）
- 自動化スクリプトのエラーハンドリング不備
- リトライロジックの無限ループ
- 99.58% エラー率 → ほぼ全リクエストが失敗している

### 仮説3: ソースコードにハードコードされたAPIキーの悪用（可能性: 50%）
- GitHub に公開されたAPIキー
- 第三者による不正使用
- ただし、この場合は「X Automation」ではなく「GYM MATCH」に記録されるはず

---

## ✅ 次のアクション

### 今すぐ実行
1. ✅ プロジェクトを「GYM MATCH X Automation」に切り替え
2. ✅ APIs & Services → Dashboard で詳細確認
3. ✅ 時系列グラフをスクリーンショット
4. ✅ このプロジェクトが何なのか確認

### 今後の対応
1. 📝 APIキーを分離（アプリ専用キーを作成）
2. 🔒 Application Restrictions を設定
3. 🚫 古いAPIキーを削除
4. 🔄 アプリコードを更新（新しいAPIキーに変更）
5. 📊 Firebase Remote Config でAPIキー管理に移行

---

## 💡 重要な気づき

> **「ダウンロード数が少ないのに上限に達した」理由**
> 
> → GYM MATCH アプリ自体は正常に動いているが、
>    「GYM MATCH X Automation」プロジェクトが
>    **15万回以上のリクエスト** を送り続けている！
> 
> しかも **99.58% がエラー** = ほぼ全て失敗している
> = リトライ地獄に陥っている可能性大

---

## 📞 次に確認してほしいこと

1. **「GYM MATCH X Automation」プロジェクトに切り替えて、ダッシュボードのスクリーンショットを撮ってください**
   - これで時系列のリクエスト数が分かります

2. **このプロジェクトの目的を教えてください**
   - テスト用？ 本番用？ 不明？

3. **GYM MATCH アプリと X Automation で APIキーを共有していますか？**
   - 同じキー？ 別々のキー？

これらが分かれば、根本原因を特定して対処できます！

# Firebase Hosting 5分セットアップガイド

## 🎯 目的
プライバシーポリシーを恒久的なURLでホスティングし、App Store審査に対応する。

## 📋 前提条件
- ✅ Firebaseプロジェクト作成済み
- ✅ Firebase CLI インストール済み（ローカルPC）
- ✅ プライバシーポリシーHTML作成済み（`web/privacy_policy.html`）

## 🚀 セットアップ手順

### Step 1: Firebase CLI インストール確認（ローカルPC）

```bash
# Node.js/npm がインストールされていることを確認
node --version
npm --version

# Firebase CLI をグローバルインストール
npm install -g firebase-tools

# Firebase にログイン
firebase login
```

### Step 2: Flutter appディレクトリで初期化

```bash
# プロジェクトディレクトリに移動
cd /path/to/your/flutter_app

# Firebase Hosting を初期化
firebase init hosting
```

**質問への回答**:
1. **プロジェクト選択**: 既存のFirebaseプロジェクトを選択
2. **public directory**: `web` と入力
3. **single-page app**: `No`
4. **GitHub自動デプロイ**: `No`
5. **index.html上書き**: `No`

### Step 3: firebase.json 設定確認

`firebase.json` が以下のようになっていることを確認:

```json
{
  "hosting": {
    "public": "web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
```

### Step 4: デプロイ

```bash
# Firebase Hostingにデプロイ
firebase deploy --only hosting
```

**出力例**:
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/your-project-id/overview
Hosting URL: https://your-project-id.web.app
```

### Step 5: プライバシーポリシーURL確認

デプロイ完了後、以下のURLでアクセス可能:
```
https://your-project-id.web.app/privacy_policy.html
```

## 📝 App Store Connectに設定

1. **App Store Connect** → **マイApp** → **GYM MATCH**
2. **アプリ情報** → **プライバシーポリシー**
3. Firebase Hosting URLを入力:
   ```
   https://your-project-id.web.app/privacy_policy.html
   ```
4. **保存**

## 🔧 トラブルシューティング

### エラー: "Firebase CLI not found"
```bash
npm install -g firebase-tools
```

### エラー: "No project selected"
```bash
firebase use --add
# プロジェクトを選択
```

### privacy_policy.html が表示されない
```bash
# web ディレクトリにファイルがあることを確認
ls web/privacy_policy.html

# 再デプロイ
firebase deploy --only hosting --force
```

## ✅ 完了チェックリスト

- [ ] Firebase Hosting デプロイ完了
- [ ] プライバシーポリシーURLアクセス確認
- [ ] App Store Connect URL更新
- [ ] TestFlightビルドで動作確認

## 🎯 次のステップ

プライバシーポリシーURL更新後、新しいTestFlightビルド（#49）をアップロードし、App Store審査提出準備を完了させる。

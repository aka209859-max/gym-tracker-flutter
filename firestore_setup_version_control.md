# 🔄 強制アップデート機能 - Firestore設定手順

## 📋 概要

GYM MATCHアプリの強制アップデート機能を有効化するためのFirestore設定手順です。

---

## 🔥 Firestore設定手順

### ステップ1: Firebaseコンソールにアクセス

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. プロジェクト `gym-match-e560d` を選択
3. 左メニューから「Firestore Database」をクリック

### ステップ2: コレクション作成

1. 「コレクションを追加」をクリック
2. コレクションID: `app_config` と入力
3. 「次へ」をクリック

### ステップ3: ドキュメント作成

**ドキュメントID**: `version_control`

以下のフィールドを追加：

| フィールド名 | 型 | 値 | 説明 |
|-------------|-----|-----|------|
| `minimum_version` | `string` | `1.0.112` | **必須最低バージョン**（これ以下は強制更新） |
| `recommended_version` | `string` | `1.0.112` | **推奨バージョン**（任意更新ダイアログ表示） |
| `update_message` | `string` | `新しいバージョンのアプリが利用可能です。最新バージョンにアップデートしてください。` | ダイアログに表示されるメッセージ |
| `store_url_ios` | `string` | `https://apps.apple.com/jp/app/gym-match/id6736899896` | App StoreのURL |
| `store_url_android` | `string` | `https://play.google.com/store/apps/details?id=com.gymmatch.app` | Google Play StoreのURL（将来用） |

---

## 📝 JSON形式（コピペ用）

```json
{
  "minimum_version": "1.0.112",
  "recommended_version": "1.0.112",
  "update_message": "新しいバージョンのアプリが利用可能です。最新バージョンにアップデートしてください。",
  "store_url_ios": "https://apps.apple.com/jp/app/gym-match/id6736899896",
  "store_url_android": "https://play.google.com/store/apps/details?id=com.gymmatch.app"
}
```

---

## 🎯 動作の仕組み

### パターン1: 強制更新（Force Update）
- **条件**: 現在のバージョン < `minimum_version`
- **動作**: シンプルなダイアログ表示、「OK」ボタンで App Store へ
- **例**: v1.0.111 のユーザーは v1.0.112 以上に強制更新

### パターン2: 更新不要
- **条件**: 現在のバージョン >= `minimum_version`
- **動作**: ダイアログ非表示、通常起動

---

## 📌 運用例

### 例1: v1.0.113リリース時（強制更新）

```json
{
  "minimum_version": "1.0.113",
  "recommended_version": "1.0.113",
  "update_message": "新しいバージョンのアプリが利用可能です。最新バージョンにアップデートしてください。"
}
```

### 例2: 緊急バグ修正時（強制更新）

```json
{
  "minimum_version": "1.0.114",
  "recommended_version": "1.0.114",
  "update_message": "重要な修正が含まれています。最新バージョンにアップデートしてください。"
}
```

---

## ⚠️ 注意事項

1. **`minimum_version`は慎重に設定**
   - 古いバージョンのユーザーが全員アプリを使えなくなります
   - 重大なバグや互換性問題がある場合のみ使用

2. **バージョン形式**
   - 必ず `x.y.z` 形式（例: `1.0.112`）
   - `pubspec.yaml` の `version` フィールドと一致させる

3. **App Store URL**
   - iOS版の実際のApp Store URLに置き換えてください
   - Android版は将来の準備として記載

---

## 🧪 テスト手順

### テスト1: 強制更新のテスト

1. Firestoreで以下を設定：
   ```json
   {
     "minimum_version": "1.0.113",
     "recommended_version": "1.0.113",
     "update_message": "新しいバージョンのアプリが利用可能です。最新バージョンにアップデートしてください。",
     "store_url_ios": "https://apps.apple.com/jp/app/gym-match/id6736899896"
   }
   ```

2. アプリ（v1.0.112）を起動
3. シンプルなダイアログが表示されることを確認
4. 「OK」ボタンを押してApp Storeに遷移することを確認
5. 戻るボタンでダイアログが閉じないことを確認（強制更新）

### テスト2: 更新不要のテスト

1. Firestoreで以下を設定：
   ```json
   {
     "minimum_version": "1.0.112",
     "recommended_version": "1.0.112"
   }
   ```

2. アプリ（v1.0.112）を起動
3. ダイアログが表示されず、通常起動することを確認

---

## 🚀 本番運用開始

1. 上記のFirestore設定を完了
2. TestFlight v1.0.112 をテスト
3. 問題なければApp Store提出
4. リリース後、必要に応じて `recommended_version` を更新

---

## 📞 サポート

質問や問題が発生した場合は、開発チームに連絡してください。

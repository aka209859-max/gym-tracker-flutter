# 🚨 今すぐ実施：Firestore設定（強制更新）

## ⚡ 緊急度：高

TestFlight v1.0.113 ビルド完了後、**必ずこの設定を行ってください**。

---

## 🎯 設定内容

### Firebase Console での設定手順

1. **Firebase Console にアクセス**
   - URL: https://console.firebase.google.com/
   - プロジェクト: `gym-match-e560d`

2. **Firestore Database を開く**
   - 左メニュー → 「Firestore Database」をクリック

3. **コレクション作成**（初回のみ）
   - 「コレクションを追加」をクリック
   - コレクションID: `app_config`
   - 「次へ」をクリック

4. **ドキュメント作成**
   - ドキュメントID: `version_control`
   - 以下のフィールドを追加：

---

## 📋 設定値（コピペ用）

### フィールド設定

| フィールド名 | 型 | 値 |
|-------------|-----|-----|
| `minimum_version` | `string` | `1.0.148` |
| `recommended_version` | `string` | `1.0.149` |
| `update_message` | `string` | `新しいバージョンのアプリが利用可能です。最新バージョンにアップデートしてください。` |
| `store_url_ios` | `string` | `https://apps.apple.com/jp/app/gym-match/id6736899896` |
| `store_url_android` | `string` | `https://play.google.com/store/apps/details?id=com.gymmatch.app` |

### JSON形式（コピペ用）

```json
{
  "minimum_version": "1.0.148",
  "recommended_version": "1.0.149",
  "update_message": "新しいバージョンのアプリが利用可能です。最新バージョンにアップデートしてください。",
  "store_url_ios": "https://apps.apple.com/jp/app/gym-match/id6736899896",
  "store_url_android": "https://play.google.com/store/apps/details?id=com.gymmatch.app"
}
```

---

## 🔒 セキュリティルール設定

### 手順

1. Firebase Console → Firestore Database → 「ルール」タブ
2. 以下のルールを追加：

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // 🔄 アプリバージョン管理（全ユーザーが読み取り可能）
    match /app_config/version_control {
      allow read: if true;  // 全ユーザー読み取り可
      allow write: if false; // 管理者のみ（Firebaseコンソール）
    }
    
    // 既存のルールはそのまま維持...
  }
}
```

3. 「公開」ボタンをクリック

---

## ⚠️ 重要な注意事項

### この設定の意味

```
minimum_version: 1.0.112
  ↓
v1.0.111 以前のユーザー → 強制更新ダイアログ表示
v1.0.112 以降のユーザー → 通常起動
```

### なぜ 1.0.112 にするのか？

- **v1.0.111以前**: Google Maps API コスト高（¥7,650/月/1000ユーザー）
- **v1.0.112以降**: Google Maps API コスト最適化済み（¥3,603/月/1000ユーザー）
- **コスト差**: 53%削減（年間¥48,564/1000ユーザー）

**= 古いバージョンを使い続けると、アプリ運営コストが無駄に増える**

---

## 🧪 テスト手順

### ステップ1: v1.0.149 で動作確認

1. TestFlight で v1.0.149 をインストール
2. アプリを起動
3. **ダイアログが表示されないこと**を確認（正常動作）

### ステップ2: v1.0.148 で強制更新確認（オプション）

1. TestFlight で v1.0.148 をインストール
2. アプリを起動
3. **ダイアログが表示されないこと**を確認（v1.0.148は現行版）
4. Firestoreで`minimum_version`を`1.0.149`に変更してテスト

---

## 📊 設定後の動作

### 現在のユーザー（10人未満）

| ユーザーのバージョン | 動作 |
|-------------------|------|
| v1.0.147 以前 | 🚨 強制更新ダイアログ → App Store へ |
| v1.0.148 | ✅ 通常起動（ダイアログなし、現行版） |
| v1.0.149 | ✅ 通常起動（ダイアログなし、最新版） |

---

## 🚀 次回以降の運用

### 新バージョンリリース時（例: v1.0.150）

1. TestFlight でテスト完了
2. App Store 審査通過
3. Firestore を更新：

```json
{
  "minimum_version": "1.0.149",
  "recommended_version": "1.0.150"
}
```

4. v1.0.148 以前のユーザーが強制更新される

---

## 📞 トラブルシューティング

### Q: ダイアログが表示されない
A: Firestore設定を確認してください。`minimum_version` が現在のバージョンより大きい必要があります。

### Q: 「後で」ボタンが表示される
A: コードが古い可能性があります。v1.0.113 以降では「OK」ボタンのみです。

### Q: App Store に遷移できない
A: `store_url_ios` が正しいか確認してください。

---

## ✅ 完了チェックリスト

- [ ] Firebase Console にアクセス
- [ ] `app_config/version_control` ドキュメント作成
- [ ] 5つのフィールドを設定
- [ ] セキュリティルール追加
- [ ] v1.0.149 で動作テスト（ダイアログ非表示）
- [ ] v1.0.148 で動作テスト（ダイアログ非表示、現行版）

---

**設定完了後、必ずスクリーンショットを送ってください！** 📸

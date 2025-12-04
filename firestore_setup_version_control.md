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
| `minimum_version` | `string` | `1.0.100` | **必須最低バージョン**（これ以下は強制更新） |
| `recommended_version` | `string` | `1.0.112` | **推奨バージョン**（任意更新ダイアログ表示） |
| `update_message` | `string` | `新機能：永年Proプラン対応 + Google Maps APIコスト最適化（年間¥48,564削減/1000ユーザー）。より快適にご利用いただけます🎉` | ダイアログに表示されるメッセージ |
| `store_url_ios` | `string` | `https://apps.apple.com/jp/app/gym-match/id6736899896` | App StoreのURL |
| `store_url_android` | `string` | `https://play.google.com/store/apps/details?id=com.gymmatch.app` | Google Play StoreのURL（将来用） |

---

## 📝 JSON形式（コピペ用）

```json
{
  "minimum_version": "1.0.100",
  "recommended_version": "1.0.112",
  "update_message": "新機能：永年Proプラン対応 + Google Maps APIコスト最適化（年間¥48,564削減/1000ユーザー）。より快適にご利用いただけます🎉",
  "store_url_ios": "https://apps.apple.com/jp/app/gym-match/id6736899896",
  "store_url_android": "https://play.google.com/store/apps/details?id=com.gymmatch.app"
}
```

---

## 🎯 動作の仕組み

### パターン1: 任意更新（Recommended Update）
- **条件**: 現在のバージョン >= `minimum_version` かつ < `recommended_version`
- **動作**: ダイアログ表示、「後で」ボタンでスキップ可能
- **例**: v1.0.110 のユーザーに v1.0.112 への更新を推奨

### パターン2: 強制更新（Force Update）
- **条件**: 現在のバージョン < `minimum_version`
- **動作**: ダイアログ表示、「今すぐ更新」ボタンのみ（スキップ不可）
- **例**: v1.0.99 のユーザーは v1.0.100 以上に強制更新

### パターン3: 更新不要
- **条件**: 現在のバージョン >= `recommended_version`
- **動作**: ダイアログ非表示、通常起動

---

## 📌 運用例

### 例1: v1.0.113リリース時（任意更新）

```json
{
  "minimum_version": "1.0.100",
  "recommended_version": "1.0.113",
  "update_message": "バグ修正とパフォーマンス向上。更新をお勧めします。"
}
```

### 例2: 緊急バグ修正（強制更新）

```json
{
  "minimum_version": "1.0.113",
  "recommended_version": "1.0.113",
  "update_message": "重要なセキュリティ修正が含まれています。今すぐ更新してください。"
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

### テスト1: 任意更新のテスト

1. Firestoreで以下を設定：
   ```json
   {
     "minimum_version": "1.0.100",
     "recommended_version": "1.0.113"
   }
   ```

2. アプリ（v1.0.112）を起動
3. 「後で」ボタンでスキップできることを確認

### テスト2: 強制更新のテスト

1. Firestoreで以下を設定：
   ```json
   {
     "minimum_version": "1.0.113",
     "recommended_version": "1.0.113"
   }
   ```

2. アプリ（v1.0.112）を起動
3. 「今すぐ更新」ボタンのみ表示され、スキップ不可を確認

---

## 🚀 本番運用開始

1. 上記のFirestore設定を完了
2. TestFlight v1.0.112 をテスト
3. 問題なければApp Store提出
4. リリース後、必要に応じて `recommended_version` を更新

---

## 📞 サポート

質問や問題が発生した場合は、開発チームに連絡してください。

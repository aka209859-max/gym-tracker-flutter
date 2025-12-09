# 🚨 v1.0.195 エラートラブルシューティング

## 報告されたエラー
1. **マップ（GPS）が使えない**
2. **AIコーチ機能が使えない**

---

## 🔍 原因の可能性

### 1. APIキーの制限設定が厳しすぎる可能性

#### Google Places API Key: `AIzaSyBRJG8v0euVbxbMNbwXownQJA3_Ra8EzMM`
**確認事項：**
- ✓ Bundle ID制限: `jp.nexa.fitsync`
- ✓ API制限: Places API のみ

**問題の可能性：**
```
⚠️ iOS Bundle IDが正しいか？
- TestFlightのBundle ID: jp.nexa.fitsync
- 設定したBundle ID: jp.nexa.fitsync
→ 一致していれば問題なし

⚠️ Places API が有効化されているか？
- Google Cloud Console → APIs & Services → Library
- "Places API" を検索
- 有効化されているか確認
```

#### Gemini API Key: `AIzaSyBoexxWDV_0QIH-ePaMUy_euWuYQGcqvEo`
**確認事項：**
- ✓ Bundle ID制限: `jp.nexa.fitsync`
- ✓ API制限: Generative Language API のみ

**問題の可能性：**
```
⚠️ Generative Language API が有効化されているか？
- Google Cloud Console → APIs & Services → Library
- "Generative Language API" を検索
- 有効化されているか確認
```

---

## 📱 デバイス側の問題

### GPS問題
```
iOS設定の確認:
1. 設定 → プライバシーとセキュリティ → 位置情報サービス
2. 位置情報サービスがオン
3. GYM MATCH → "このAppの使用中のみ許可"

TestFlight特有の問題:
- TestFlightアプリは初回起動時に位置情報許可を求める
- 拒否してしまった場合は、iOSの設定から変更が必要
```

### AIコーチ問題
```
ネットワーク接続:
- Wi-Fiまたはモバイルデータがオン
- ファイアウォールやVPNがAPIをブロックしていないか

エラーメッセージ:
- 具体的なエラーメッセージを確認
- "API Error: 403" → API制限の問題
- "API Error: 429" → リクエスト制限超過
- "Network Error" → ネットワーク接続の問題
```

---

## 🔧 緊急対応策

### Plan A: API制限を一時的に緩和（テスト用）

#### 1. Google Places API Key の制限緩和
```
Google Cloud Console:
1. APIs & Services → 認証情報
2. "GYM MATCH - Places API (iOS)" をクリック
3. アプリケーションの制限:
   【現在】iOS アプリ（jp.nexa.fitsync）
   ↓
   【テスト】なし（一時的に全て許可）
4. 保存
5. TestFlightで動作確認
```

#### 2. Gemini API Key の制限緩和
```
Google Cloud Console:
1. APIs & Services → 認証情報
2. "GYM MATCH - Gemini API (iOS)" をクリック
3. アプリケーションの制限:
   【現在】iOS アプリ（jp.nexa.fitsync）
   ↓
   【テスト】なし（一時的に全て許可）
4. 保存
5. TestFlightで動作確認
```

**⚠️ 注意：** テストが完了したら、必ずiOS制限に戻すこと！

---

### Plan B: 新しいAPIキーを作成（制限なし版）

#### テスト用 Places API Key
```
1. Google Cloud Console → APIs & Services → 認証情報
2. "+ 認証情報を作成" → "APIキー"
3. 名前: "GYM MATCH - Places API (Test - No Restrictions)"
4. アプリケーション制限: なし
5. API制限: Places API のみ
6. 作成
7. キーをコピー
```

#### テスト用 Gemini API Key
```
1. Google Cloud Console → APIs & Services → 認証情報
2. "+ 認証情報を作成" → "APIキー"
3. 名前: "GYM MATCH - Gemini API (Test - No Restrictions)"
4. アプリケーション制限: なし
5. API制限: Generative Language API のみ
6. 作成
7. キーをコピー
```

#### コードに適用
```dart
// lib/config/api_keys.dart
static const String googlePlacesApiKey = 'NEW_TEST_KEY_HERE';

// lib/screens/workout/ai_coaching_screen.dart
Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=NEW_TEST_KEY_HERE'),
```

---

## 🔍 デバッグ手順

### 1. Firebase Crashlytics でエラー確認
```
Firebase Console:
1. プロジェクト "GYM MATCH" を選択
2. Crashlytics → Dashboard
3. 最新のクラッシュを確認
4. スタックトレースを確認
```

### 2. Google Cloud Console でAPI使用状況確認
```
Google Cloud Console:
1. プロジェクト "GYM MATCH" (gym-match-e560d) を選択
2. APIs & Services → Dashboard
3. "Generative Language API" をクリック
4. Metrics タブ → Traffic を確認
5. エラーが発生しているか？
   - 200: 成功
   - 403: 権限エラー（API制限の問題）
   - 429: リクエスト制限超過
```

### 3. Places API のメトリクス確認
```
Google Cloud Console:
1. APIs & Services → Dashboard
2. "Places API" を検索して選択
3. Metrics タブ → Traffic を確認
4. エラーステータスを確認
```

---

## 📊 エラーコード別対応

### 403 Forbidden
```
原因: APIキーの制限設定
対応:
1. Bundle ID が正しいか確認（jp.nexa.fitsync）
2. API が有効化されているか確認
3. 一時的に制限を「なし」にしてテスト
```

### 429 Too Many Requests
```
原因: リクエスト制限超過（1日1,500リクエスト）
対応:
1. Google Cloud Console でクォータ確認
2. 翌日まで待つ
3. または有料プランにアップグレード
```

### Network Error
```
原因: ネットワーク接続の問題
対応:
1. Wi-Fi/モバイルデータを確認
2. VPNをオフにする
3. 別のネットワークで試す
```

---

## 📝 報告してほしい情報

### GPSエラーの場合
```
1. iOS設定 → GYM MATCH → 位置情報 のスクリーンショット
2. マップ画面のエラーメッセージ（あれば）
3. Firebase Crashlytics のエラーログ
```

### AIコーチエラーの場合
```
1. AIコーチ画面のエラーメッセージ（全文）
2. Firebase Crashlytics のエラーログ
3. Google Cloud Console → Generative Language API → Metrics のスクリーンショット
```

---

## 🚀 次のステップ

### 即座に実行
1. **Google Cloud Console で API 有効化を確認**
   - Places API
   - Generative Language API

2. **API制限を一時的に緩和してテスト**
   - アプリケーション制限: なし
   - 動作すれば → Bundle ID の問題
   - 動作しなければ → 別の問題

3. **エラーメッセージを詳細に報告**
   - スクリーンショット
   - Firebase Crashlytics
   - Google Cloud Console のメトリクス

### 根本解決（テスト後）
1. Bundle ID が正しいことを確認
2. API制限を元に戻す（iOS制限）
3. v1.0.198 で修正版をリリース

---

**緊急連絡先**: Google Cloud Console でエラーメッセージとメトリクスのスクリーンショットを共有してください！

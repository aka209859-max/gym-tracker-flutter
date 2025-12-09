# 🔍 APIエラー デバッグガイド

## 📋 必要な情報

### 1. 具体的なエラーメッセージ
以下をスクリーンショットで共有してください：

#### マップ画面のエラー
- エラーメッセージの全文
- エラーが表示されるタイミング

#### AIコーチ画面のエラー
- エラーメッセージの全文
- エラーが表示されるタイミング

---

## 🔍 確認すべきポイント

### Google Cloud Console での確認

#### 1. Bundle ID が正しく保存されたか
```
Google Cloud Console:
1. APIs & Services → 認証情報
2. "GYM MATCH - Places API (iOS)" をクリック
3. アプリケーションの制限を確認:
   
   ✅ iOS アプリ が選択されている
   ✅ Bundle ID: com.nexa.gymmatch
   
   ※スクリーンショットを撮ってください
```

```
同様に:
"GYM MATCH - Gemini API (iOS)" も確認
   
   ✅ iOS アプリ が選択されている
   ✅ Bundle ID: com.nexa.gymmatch
   
   ※スクリーンショットを撮ってください
```

#### 2. APIが有効化されているか
```
Google Cloud Console:
1. APIs & Services → ライブラリ
2. "Places API" を検索
   - 有効化されているか確認
   - ※スクリーンショットを撮ってください
3. "Generative Language API" を検索
   - 有効化されているか確認
   - ※スクリーンショットを撮ってください
```

#### 3. API使用状況とエラー確認
```
Google Cloud Console:
1. APIs & Services → Dashboard
2. "Generative Language API" をクリック
3. "Metrics" タブをクリック
4. Traffic グラフを確認:
   - リクエストが送信されているか？
   - エラーコード（200/403/429）は何か？
   
   ※スクリーンショットを撮ってください
```

```
同様に:
"Places API" のメトリクスも確認
   
   ※スクリーンショットを撮ってください
```

---

## 🔧 チェックリスト

### Bundle ID の確認
- [ ] Places API Key: `com.nexa.gymmatch` （タイプミスなし）
- [ ] Gemini API Key: `com.nexa.gymmatch` （タイプミスなし）
- [ ] 両方とも「保存」ボタンを押した

### API の有効化
- [ ] Places API が有効化されている
- [ ] Generative Language API が有効化されている

### API制限の設定
- [ ] Places API: API制限 = "Places API" のみ
- [ ] Gemini API: API制限 = "Generative Language API" のみ

---

## 🚨 よくある問題

### 問題1: Bundle ID のタイプミス
```
正しい: com.nexa.gymmatch
間違い例:
- com.nexa.gym-match （ハイフン）
- com.nexa.gymmatch. （末尾のドット）
- com.nexa. gymmatch （スペース）
- Com.nexa.gymmatch （大文字）
```

### 問題2: API が有効化されていない
```
症状: 403 Forbidden エラー

対応:
1. APIs & Services → ライブラリ
2. "Places API" を検索 → 有効化
3. "Generative Language API" を検索 → 有効化
```

### 問題3: API制限の設定ミス
```
症状: 403 Forbidden エラー

確認:
Places API Key の API制限:
✅ Places API (New) または Places API

Gemini API Key の API制限:
✅ Generative Language API
```

### 問題4: 複数のAPI制限が必要
```
Places API Key には以下が必要かも:
- Places API (New)
- Maps SDK for iOS
- Maps JavaScript API
- Geocoding API

試してみる:
1. Places API Key をクリック
2. API の制限 → 「キーを制限」
3. 上記4つにチェックを入れる
4. 保存
```

---

## 🔄 代替案：制限なしでテスト

### 一時的に制限を外してテスト

#### Places API Key
```
1. Google Cloud Console → 認証情報
2. "GYM MATCH - Places API (iOS)" をクリック
3. アプリケーションの制限:
   【現在】iOS アプリ
   ↓
   【テスト】なし
4. 保存
5. TestFlight でテスト
```

#### Gemini API Key
```
同様に制限を「なし」にしてテスト
```

**⚠️ 動作確認後、必ずiOS制限に戻すこと**

---

## 📊 エラーコード別対応

### 403 Forbidden
```
原因:
- Bundle ID が間違っている
- API が有効化されていない
- API制限の設定ミス

対応:
1. Bundle ID を再確認（タイプミスなし）
2. API が有効化されているか確認
3. 一時的に制限を「なし」にしてテスト
```

### 429 Too Many Requests
```
原因:
- 1日1,500リクエスト制限に到達

対応:
1. Google Cloud Console → Quotas で確認
2. 翌日まで待つ
3. または有料プランにアップグレード
```

### Network Error / Timeout
```
原因:
- インターネット接続の問題
- VPN/ファイアウォールのブロック

対応:
1. Wi-Fi/モバイルデータを確認
2. VPN をオフにする
3. 別のネットワークで試す
```

---

## 📝 報告してほしい情報

以下のスクリーンショットを共有してください：

### 1. エラーメッセージ
- [ ] マップ画面のエラー（全文）
- [ ] AIコーチ画面のエラー（全文）

### 2. Google Cloud Console
- [ ] Places API Key の設定画面（Bundle ID確認）
- [ ] Gemini API Key の設定画面（Bundle ID確認）
- [ ] APIs & Services → ライブラリ（Places API有効化確認）
- [ ] APIs & Services → ライブラリ（Generative Language API有効化確認）
- [ ] Generative Language API → Metrics（エラーコード確認）
- [ ] Places API → Metrics（エラーコード確認）

### 3. iOS設定
- [ ] 設定 → GYM MATCH → 位置情報（権限確認）

---

## 🚀 次のステップ

### 即座に実行
1. **Google Cloud Console のスクリーンショットを全て共有**
   - 認証情報（2個のAPIキー設定）
   - ライブラリ（2個のAPI有効化状況）
   - メトリクス（2個のAPIのエラー状況）

2. **TestFlight のエラーメッセージを共有**
   - マップ画面
   - AIコーチ画面

3. **一時的に制限を「なし」にしてテスト**
   - 動作すれば → Bundle ID の問題
   - 動作しなければ → 別の問題

---

**上記の情報を共有してください。原因を特定します！** 🔍

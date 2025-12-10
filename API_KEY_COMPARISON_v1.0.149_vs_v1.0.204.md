# 🔍 API Key 比較: v1.0.149 (公開版) vs v1.0.204 (ビルド中)

## 📊 API Key 一覧表

| サービス | v1.0.149 (公開版・動作中✅) | v1.0.204 (ビルド中) | 状態 |
|---------|---------------------------|---------------------|------|
| **Gemini API (共通)** | `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc` | `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY` | 🔄 変更 |
| - AIコーチング | 上記と同じ | 上記と同じ | 🔄 |
| - AI予測 | 上記と同じ | 上記と同じ | 🔄 |
| - トレーニング分析 | 上記と同じ | 上記と同じ | 🔄 |
| - ワークアウトインポート | 上記と同じ | 上記と同じ | 🔄 |
| **Google Places API** | `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc` | `AIzaSyBRJG8v0euVbxbMNbwXownQJA3_Ra8EzMM` | 🔄 変更 |
| **Firebase (iOS)** | N/A | `AIzaSyDYwD-_fz9m4vSQsbdXuQpKtbHguIl4LaM` | ➕ 新規 |
| **Firebase (Android)** | N/A | `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY` | ➕ 新規 |

---

## 🔑 API Key 詳細分析

### v1.0.149 (公開版・動作中✅)
```
単一のAPI Keyで全て統一:
AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc

使用箇所:
✅ Gemini API (AIコーチ、AI予測、トレーニング分析、ワークアウトインポート)
✅ Google Places API (ジム検索)
✅ Google Maps Photo API (ジム写真表示)

特徴:
- シンプル: 1つのAPI Keyで全サービス
- 動作確認済み: 世の中で稼働中
- 制限なし or 適切な制限設定
```

### v1.0.204 (ビルド中)
```
複数のAPI Keyを使い分け:

1. Gemini API用:
   AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY
   - AIコーチング
   - AI予測
   - トレーニング分析
   - ワークアウトインポート

2. Google Places API用:
   AIzaSyBRJG8v0euVbxbMNbwXownQJA3_Ra8EzMM
   - ジム検索
   - ジム写真表示

3. Firebase iOS用:
   AIzaSyDYwD-_fz9m4vSQsbdXuQpKtbHguIl4LaM

4. Firebase Android用:
   AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY (Geminiと同じ)

特徴:
- 複雑: 4つのAPI Keyを使い分け
- セキュリティ向上: 各APIで専用キー
- テスト中: まだ動作未確認
```

---

## 🚨 重要な発見

### 問題の根本原因候補

1. **v1.0.149の成功要因**:
   - **単一のAPI Key** `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc` で全て統一
   - Google Cloud Consoleで適切に設定されている
   - Gemini API、Places APIの両方で動作

2. **v1.0.198-203の失敗要因**:
   - 新しいAPI Key `AIzaSyBoexxWDV_0QIH-ePaMUy_euWuYQGcqvEo` に変更
   - API制限設定の問題？
   - Bundle ID Headerの追加（後に削除）

3. **v1.0.204の期待**:
   - v1.0.196-197で動いていたAPI Key `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY` を使用
   - この期間はv1.0.149より後だが、確実に動作していた

---

## 💡 推奨アクション

### オプションA: v1.0.149のAPI Keyに完全復元 (最も確実)
```
全てのサービスで:
AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc

メリット:
✅ 公開版で実証済み
✅ シンプル（1つのキーのみ）
✅ 確実に動く

デメリット:
❌ セキュリティ面でやや弱い（1つのキーで全て）
```

### オプションB: v1.0.204のままテスト (現在のアプローチ)
```
Gemini: AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY
Places: AIzaSyBRJG8v0euVbxbMNbwXownQJA3_Ra8EzMM

メリット:
✅ セキュリティ向上（API分離）
✅ v1.0.196-197で動作実績あり

デメリット:
❌ 複雑（複数キー管理）
❌ まだ未検証
```

### オプションC: ハイブリッド (推奨🔴)
```
v1.0.204でテスト → 失敗した場合 → v1.0.149のキーに戻す

理由:
- v1.0.196-197で動いたキーなので成功可能性高い
- 失敗しても、確実な回避策がある
```

---

## 📋 次のステップ

### 1. v1.0.204のテスト (13:45-13:55)
- TestFlight Build 204でAIコーチをテスト
- 結果を報告

### 2-A. 成功した場合
- v1.0.204を本番デプロイ
- API Key設定を文書化

### 2-B. 失敗した場合
- v1.0.205で v1.0.149のAPI Keyに完全復元
- 確実な動作を最優先

---

## 🔐 Google Cloud Console確認項目

各API Keyの設定を確認してください:

### 1. `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc` (v1.0.149・公開版)
- アプリケーション制限: ?
- API制限: ?
- 有効/無効: ?

### 2. `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY` (v1.0.204 Gemini用)
- アプリケーション制限: ?
- API制限: ?
- 有効/無効: ?

### 3. `AIzaSyBRJG8v0euVbxbMNbwXownQJA3_Ra8EzMM` (v1.0.204 Places用)
- アプリケーション制限: ?
- API制限: ?
- 有効/無効: ?

これらの設定差異が問題の鍵です！

---

**結論**: v1.0.204でテストし、失敗した場合はv1.0.149のAPI Key (`AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc`) に完全復元するのが最速の解決策です。

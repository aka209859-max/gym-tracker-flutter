# ✅ 最終確定: 正しいAPI Key構成

## 🔑 正しいAPI Key割り当て

### 1. Gemini API用（AI機能全般）
```
API Key: AIzaSyBoexxWDV_0QIH-ePaMUy_euWuYQGcqvEo
Google Cloud Console名: GYM MATCH - Gemini API (iOS)

使用箇所:
✅ lib/screens/workout/ai_coaching_screen.dart (AIコーチング)
✅ lib/screens/workout/ai_coaching_screen_tabbed.dart (AIコーチングTabbed)
✅ lib/services/ai_prediction_service.dart (AI予測)
✅ lib/services/training_analysis_service.dart (トレーニング分析)
✅ lib/services/workout_import_service.dart (ワークアウトインポート)

重要度: 🔴 最重要 - 削除厳禁
```

### 2. Firebase用
```
API Key: AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY
Google Cloud Console名: iOS key (auto created by Firebase)

使用箇所:
✅ lib/firebase_options.dart (Firebase iOS/Android設定)

重要度: 🔴 最重要 - Firebase自動生成、削除厳禁
```

### 3. Google Places API用（ジム検索）
```
API Key: AIzaSyBRJG8v0euVbxbMNbwXownQJA3_Ra8EzMM
Google Cloud Console名: GYM MATCH - Places API (iOS)

使用箇所:
✅ lib/config/api_keys.dart (Places API設定)
✅ lib/services/google_places_service.dart (ジム検索機能)
✅ lib/models/google_place.dart (ジム写真表示)

重要度: 🔴 最重要 - 削除厳禁
```

---

## ⚠️ 過去の混乱の経緯

### v1.0.204-205の問題
```
❌ 間違った使用:
   Gemini API箇所でFirebase用キーを使用
   AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY（Firebase用）

結果:
   - 403エラーの可能性
   - API Key用途の混在
```

### v1.0.206の問題
```
❌ 間違った使用:
   世の中のバージョンと異なるAPI Keyを使用
   AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc（v1.0.149用）

結果:
   - v1.0.149とは異なる構成
   - 混乱を招く
```

### v1.0.207の解決 ✅
```
✅ 正しい使用:
   Gemini API用キーをGemini機能に使用
   AIzaSyBoexxWDV_0QIH-ePaMUy_euWuYQGcqvEo（Gemini専用）

結果:
   - 各API Keyが適切な役割
   - 明確な責任分離
   - 安定動作が期待される
```

---

## 🎯 Google Cloud Consoleでの管理

### 保持すべきAPI Key（3つ全て）:

1. ✅ **GYM MATCH - Gemini API (iOS)**
   - `AIzaSyBoexxWDV_0QIH-ePaMUy_euWuYQGcqvEo`
   - 用途: Gemini AI機能全般
   - 状態: 有効
   - **絶対に削除しないでください**

2. ✅ **iOS key (auto created by Firebase)**
   - `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY`
   - 用途: Firebase iOS/Android
   - 状態: 有効
   - **絶対に削除しないでください**

3. ✅ **GYM MATCH - Places API (iOS)**
   - `AIzaSyBRJG8v0euVbxbMNbwXownQJA3_Ra8EzMM`
   - 用途: Google Places APIジム検索
   - 状態: 有効
   - **絶対に削除しないでください**

### 削除して良いAPI Key:
- **なし！全て必要です！**

---

## 📊 バージョン履歴とAPI Key使用状況

| バージョン | Gemini API Key | 状態 | 備考 |
|-----------|---------------|------|------|
| v1.0.149 (公開版) | AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc | ✅ | 世の中で動作中 |
| v1.0.204 | AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY | ⚠️ | Firebase用キーを誤用 |
| v1.0.205 | AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY | ⚠️ | Firebase用キーを誤用 |
| v1.0.206 | AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc | ❌ | v1.0.149用キーを誤用 |
| v1.0.207 | AIzaSyBoexxWDV_0QIH-ePaMUy_euWuYQGcqvEo | ✅ | **正しい構成** |

---

## ✅ 最終確認チェックリスト

### コード側:
- [x] AIコーチング: Gemini用キー使用
- [x] AI予測: Gemini用キー使用
- [x] トレーニング分析: Gemini用キー使用
- [x] ワークアウトインポート: Gemini用キー使用
- [x] Firebase: Firebase用キー使用
- [x] Places API: Places用キー使用

### Google Cloud Console側:
- [ ] Gemini API Key有効
- [ ] Firebase API Key有効
- [ ] Places API Key有効
- [ ] 各API Keyの制限設定確認
- [ ] 不要なAPI Keyは存在しない

---

## 🚀 v1.0.207デプロイ状況

```
✅ コミット完了: fb3d61a
✅ タグ作成: v1.0.207
✅ GitHub Actionsビルド中
⏳ TestFlight配信待ち

期待される結果:
- AIコーチ正常動作
- 403エラーなし
- 全AI機能が正常に動作
```

---

## 📝 今後の注意事項

1. **API Keyは絶対に削除しない**
   - 3つとも必要不可欠
   - 削除するとアプリが壊れる

2. **API Key用途を混在させない**
   - Gemini用はGeminiのみ
   - Firebase用はFirebaseのみ
   - Places用はPlacesのみ

3. **新しいAPI Keyを作成する前に相談**
   - 既存のキー構成を理解してから
   - 不要な混乱を避けるため

---

**この構成が最終確定版です。変更しないでください。**

作成日: 2024-12-10
最終更新: v1.0.207

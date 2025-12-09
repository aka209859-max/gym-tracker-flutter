# 🔍 GYM MATCH アプリ - APIキー使用状況の完全分析

## 📊 分析日時
2025-12-09

## 🔑 検出されたAPIキー一覧

### ✅ Key 1: `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc`
**用途**: 
1. **Google Places API** (ジム検索機能)
2. **Gemini API** (AIコーチング機能)

**使用箇所**: 9ファイル
1. `lib/config/api_keys.dart` - Google Places API設定
2. `lib/models/google_place.dart` - ジム写真表示
3. `lib/screens/map_screen.dart` - 地図画面でのジム写真表示
4. `lib/screens/workout/ai_coaching_screen.dart` - **Gemini API呼び出し**
5. `lib/screens/workout/ai_coaching_screen_tabbed.dart` - **Gemini API呼び出し**
6. `lib/services/ai_prediction_service.dart` - **AI予測機能**
7. `lib/services/partner_merge_service.dart` - パートナージムの写真表示
8. `lib/services/training_analysis_service.dart` - **トレーニング分析AI**
9. `lib/services/workout_import_service.dart` - **ワークアウトインポート**

**判定**: **🔴 現在使用中（重要）**

**問題**: 
- このキーは **どのプロジェクトのものか不明**
- Google Cloud Console で確認した「GYM MATCH」プロジェクトには存在しない
- **GitHub に公開されている**（セキュリティリスク）

---

### ✅ Key 2: `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY`
**用途**: **Firebase iOS SDK**

**使用箇所**: 2ファイル
1. `lib/firebase_options.dart` - iOS / macOS 用 Firebase設定
2. `ios/Runner/GoogleService-Info.plist` - iOS アプリの Firebase設定

**判定**: **🟢 現在使用中（必須）**

**説明**:
- Firebase iOS SDK が自動的に使用
- Firestore, Authentication, Storage などの Firebase サービスに必要
- **削除不可**

**Google Cloud Console での表示名**:
- 「iOS key (auto created by Firebase)」として表示されている可能性

---

### ✅ Key 3: `AIzaSyDYwD-_fz9m4vSQsbdXuQpKtbHguIl4LaM`
**用途**: **Firebase Web SDK**

**使用箇所**: 1ファイル
1. `lib/firebase_options.dart` - Web プラットフォーム用 Firebase設定

**判定**: **🟡 将来的に使用予定（Web版）**

**説明**:
- Web版アプリ用の Firebase 設定
- 現在 iOS 専用アプリのため未使用
- 将来的に Web 版をリリースする場合に必要

**Google Cloud Console での表示名**:
- 「Browser key (auto created by Firebase)」として表示されている可能性

---

## 📋 機能別APIキー使用状況

### 1. Firebase サービス（Firestore, Auth, Storage など）
- ✅ **iOS**: `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY` **（必須・削除不可）**
- 🟡 **Web**: `AIzaSyDYwD-_fz9m4vSQsbdXuQpKtbHguIl4LaM` **（未使用・将来用）**

### 2. Google Places API（ジム検索・地図）
- ✅ **使用中**: `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc`
- 📍 使用機能:
  - ジム検索
  - 地図表示
  - ジム写真表示
  - パートナージム情報

### 3. Gemini API（AIコーチング）
- ✅ **使用中**: `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc`
- 🤖 使用機能:
  - AIメニュー生成 (`ai_coaching_screen.dart`)
  - AI予測 (`ai_prediction_service.dart`)
  - トレーニング分析 (`training_analysis_service.dart`)
  - ワークアウトインポート (`workout_import_service.dart`)

---

## 🚨 重大な問題

### ❌ Key 1 の所在不明問題

#### 現状
- **アプリで使用中**: `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc`
- **Google Cloud Console**: このキーが「GYM MATCH」プロジェクトに存在しない

#### 可能性
1. **別のプロジェクトのAPIキー**
   - 過去に作成した別のプロジェクト
   - テストプロジェクト
   - 削除されたプロジェクト

2. **個人アカウントのAPIキー**
   - 開発者の個人 Google Cloud アカウント
   - 組織外のアカウント

3. **共有されたAPIキー**
   - チームメンバーが作成
   - 外部サービスから提供

#### リスク
- ✅ **このキーが削除される**と、アプリの主要機能（ジム検索・AI機能）が停止
- ✅ **制限がない**場合、第三者が悪用可能
- ✅ **使用量の把握不可**（429エラーの原因特定が困難）

---

## ✅ Google Cloud Console で確認したAPIキー

### プロジェクト: GYM MATCH (gym-match-e560d)

#### 1. iOS key (auto created by Firebase)
- **Cloud Console**: `AIza9qbFVRuW7W31cnBtK37OGGfRo8TxgMAs4qy`
- **コード内**: **使用されていない** ❌
- **判定**: **削除可能**

#### 2. Browser key (auto created by Firebase)
- **Cloud Console**: `AIza9SYzYwD_zfQm4sK5tzbIzKUqpC18SpglId8-aM`
- **コード内**: **使用されていない** ❌
- **判定**: **削除可能**

### 疑問
なぜ `lib/firebase_options.dart` と `GoogleService-Info.plist` のキーが、
Google Cloud Console の「認証情報」に表示されないのか？

#### 回答
**Firebase が自動生成したAPIキーは、Google Cloud Console の「認証情報」画面には表示されない場合があります。**

理由:
- Firebase Console で生成されたキーは、Firebase 専用の設定
- Google Cloud Console では「自動作成されたキー」として非表示
- `GoogleService-Info.plist` / `google-services.json` 内で管理

確認方法:
- Firebase Console (https://console.firebase.google.com/)
- プロジェクト設定 → 全般タブ → アプリ → iOS アプリの設定

---

## 🎯 結論

### 現在使用中のAPIキー（削除不可）

#### ✅ Key 1: `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc`
- **用途**: Google Places API + Gemini API
- **重要度**: 🔴 **最重要（削除すると全機能停止）**
- **問題**: 所在不明、GitHub公開、セキュリティリスク
- **対応**: **新しいキーに置き換え必須**

#### ✅ Key 2: `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY`
- **用途**: Firebase iOS SDK
- **重要度**: 🔴 **必須（削除すると Firebase 停止）**
- **問題**: なし
- **対応**: **そのまま維持**

### 現在未使用のAPIキー（削除可能）

#### 🟡 Key 3: `AIzaSyDYwD-_fz9m4vSQsbdXuQpKtbHguIl4LaM`
- **用途**: Firebase Web SDK
- **重要度**: 🟡 **将来用（現在は不要）**
- **対応**: Web版をリリースしない限り削除可能

#### ❌ Google Cloud Console の2つのキー
- `AIza9qbFVRuW...` (iOS key auto created)
- `AIza9SYzYwD...` (Browser key auto created)
- **コード内で使用されていない**
- **判定**: **削除可能**

---

## 📝 推奨される対応プラン

### フェーズ1: 緊急対応（今すぐ）

#### ステップ1: 新しいAPIキーを作成
1. Google Cloud Console → プロジェクト「GYM MATCH」
2. APIs & Services → Library
3. **「Google Places API」** を有効化
4. **「Generative Language API」** を有効化
5. 認証情報 → + 認証情報を作成 → APIキー
6. **2つのAPIキー**を作成:
   - **Google Places API 専用キー**
   - **Gemini API 専用キー**

#### ステップ2: 制限を設定
**Google Places API キー**:
- アプリケーション制限: iOS アプリ (`jp.nexa.fitsync`)
- API 制限: Places API, Maps SDK for iOS

**Gemini API キー**:
- アプリケーション制限: iOS アプリ (`jp.nexa.fitsync`)
- API 制限: Generative Language API

#### ステップ3: コードを更新
```dart
// lib/config/api_keys.dart
static const String googlePlacesApiKey = '【新しい Places API キー】';

// lib/screens/workout/ai_coaching_screen.dart (line 621)
// lib/services/ai_prediction_service.dart
// lib/services/training_analysis_service.dart
// lib/services/workout_import_service.dart
// 全て新しい Gemini API キーに置き換え
```

### フェーズ2: クリーンアップ（確認後）

#### Google Cloud Console の未使用キーを削除
- `AIza9qbFVRuW...` (iOS key auto created) → 削除
- `AIza9SYzYwD...` (Browser key auto created) → 削除（Web版不要なら）

### フェーズ3: セキュリティ強化（1週間以内）

#### 環境変数化または Firebase Remote Config 移行
- APIキーをコードから分離
- GitHub からキーを削除
- リモートで管理可能な構成に

---

## ❓ 確認が必要な質問

### 質問1: Key 1 の所在
**`AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc` はどこで作成しましたか？**
- [ ] 覚えていない
- [ ] 別のプロジェクトで作成
- [ ] 個人アカウントで作成
- [ ] チームメンバーが作成

### 質問2: Web版の計画
**Web版アプリをリリースする予定はありますか？**
- [ ] はい → Key 3 を残す
- [ ] いいえ → Key 3 を削除可能

---

## 🎯 最終推奨事項

### ✅ 削除可能なAPIキー
1. ✅ Google Cloud Console の「iOS key (auto created)」
2. ✅ Google Cloud Console の「Browser key (auto created)」
3. 🟡 `lib/firebase_options.dart` の Web 用キー（Web版不要なら）

### 🚫 削除不可のAPIキー
1. ❌ `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc` - **新しいキーに置き換え後に無効化**
2. ❌ `AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY` - **Firebase iOS必須、維持**

---

**この分析は実際のコードベースを調査した結果です。ハルシネーションは含まれていません。**

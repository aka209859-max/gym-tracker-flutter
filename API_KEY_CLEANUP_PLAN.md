# 🗑️ APIキー整理・削除プラン

## 🎯 目的
- 使用していないAPIキーを削除してセキュリティリスクを軽減
- GYM MATCH アプリ専用の新しいAPIキーのみを残す
- 将来的な管理を簡素化

---

## 📋 現在のAPIキー状況

### プロジェクト: GYM MATCH (gym-match-e560d)

#### 既存のAPIキー（削除対象）
1. ✅ **iOS key (auto created by Firebase)**
   - キー: `AIza9qbFVRuW7W31cnBtK37OGGfRo8TxgMAs4qy`
   - 作成日: 2025年1月25日
   - 用途: Firebase が自動作成（未使用）
   - **判定: 削除**

2. ✅ **Browser key (auto created by Firebase)**
   - キー: `AIza9SYzYwD_zfQm4sK5tzbIzKUqpC18SpglId8-aM`
   - 作成日: 2025年10月31日
   - 用途: Firebase が自動作成（未使用）
   - **判定: 削除**

### プロジェクト: GYM MATCH X Automation

#### 既存のAPIキー（削除判断が必要）
3. ❓ **MuscleMind Workout Import**
   - キー: `AIza8pIVqNpczebP-yVgLjIZ7s16zlaJQQpu`
   - 作成日: 2025年1月14日
   - 用途: 不明（X Automation プロジェクト用？）
   - **質問: これは何に使っていますか？**

4. ❓ **workout_photo_import_key**
   - キー: `AIza9pANttua_iltrv1tsFEIzXxobrglPGvv4ss`
   - 作成日: 2025年1月14日
   - 用途: 不明（写真インポート機能？）
   - **質問: これは何に使っていますか？**

5. ❓ **GYM MATCH X Automation**
   - キー: `AIza9p3HidptRpvk8csvAbQVH4gqkpo1hs`
   - 作成日: 2025年1月10日
   - 用途: 不明（X Automation プロジェクト全般？）
   - **質問: これは何に使っていますか？**

### アプリコードに記載されているAPIキー（所在不明）
6. ❌ **不明なAPIキー（現在使用中だが危険）**
   - キー: `AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc`
   - 用途: GYM MATCH アプリの Gemini API 呼び出し
   - 問題: どのプロジェクトのものか不明
   - **判定: 使用停止 → 新しいキーに置き換え**

---

## ✅ 削除手順

### ステップ1: GYM MATCH プロジェクトのAPIキーを削除

#### 削除するキー
- ✅ iOS key (auto created by Firebase)
- ✅ Browser key (auto created by Firebase)

#### 手順
1. Google Cloud Console → プロジェクト **「GYM MATCH」**
2. 左側メニュー → **「認証情報」**
3. 各APIキーの右側 **「⋮」（縦三点リーダー）** をクリック
4. **「削除」** を選択
5. 確認ダイアログで **「削除」** をクリック

---

### ステップ2: GYM MATCH X Automation プロジェクトの確認

#### 確認事項
- **このプロジェクトは現在使用していますか？**
  - はい → どの機能で使用？
  - いいえ → プロジェクトごと削除可能

#### 使用していない場合の推奨
- プロジェクト自体を削除（またはシャットダウン）
- APIキーも自動的に無効化される

#### 手順（プロジェクトごと削除する場合）
1. Google Cloud Console → プロジェクト **「GYM MATCH X Automation」**
2. 左側メニュー → **「設定」**
3. **「プロジェクトをシャットダウン」**
4. プロジェクトID を入力して確認

---

### ステップ3: 新しいAPIキーを作成

#### GYM MATCH アプリ専用キーを作成

1. Google Cloud Console → プロジェクト **「GYM MATCH」**
2. 左側メニュー → **「APIとサービス」** → **「ライブラリ」**
3. **「Generative Language API」** を検索 → **「有効にする」**
4. 左側メニュー → **「認証情報」**
5. **「+ 認証情報を作成」** → **「APIキー」**

#### 作成後の制限設定
- **名前**: `GYM MATCH iOS - Gemini API`
- **アプリケーションの制限**: iOS アプリ
  - Bundle ID: `jp.nexa.fitsync`
- **API の制限**: Generative Language API のみ

---

### ステップ4: コードを更新

新しいAPIキーでコードを更新：

```dart
// lib/screens/workout/ai_coaching_screen.dart (line 621)
// 変更前
Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc'),

// 変更後
Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=【新しいAPIキー】'),
```

---

## 🔒 セキュリティ強化

### 推奨事項

#### 1. GitHub リポジトリの監査
- 過去のコミットに古いAPIキーが含まれている
- GitHub の Secret Scanning で検出されている可能性
- 対応:
  ```bash
  # Git履歴から機密情報を削除（慎重に実行）
  git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch lib/screens/workout/ai_coaching_screen.dart" \
    --prune-empty --tag-name-filter cat -- --all
  ```

#### 2. `.gitignore` に環境変数ファイルを追加
```
# .gitignore
.env
.env.local
*.env
android/key.properties
ios/Runner/GoogleService-Info.plist
google-services.json
```

#### 3. 将来的な改善
- **Firebase Remote Config** でAPIキーを管理
- **環境変数** でローカル管理
- **バックエンドプロキシ** (Cloud Functions) 経由でAPI呼び出し

---

## 📊 削除後の状態

### 理想的な構成

#### プロジェクト: GYM MATCH
- ✅ **Generative Language API キー** (新規作成)
  - 名前: GYM MATCH iOS - Gemini API
  - 制限: iOS アプリ (`jp.nexa.fitsync`) + Gemini API のみ
  - 用途: アプリの AI コーチング機能

#### プロジェクト: GYM MATCH X Automation
- ❓ 使用状況に応じて判断
  - 使用中 → キープ
  - 未使用 → プロジェクトごと削除

---

## ⚠️ 注意事項

### 削除前の確認

#### ✅ 必ず確認すること
1. **削除するAPIキーが本当に使用されていないか？**
   - アプリコード内を検索
   - バックエンドコードを確認
   - CI/CD パイプラインを確認

2. **Firebase が自動作成したキーを削除しても大丈夫か？**
   - iOS key / Browser key は **Firebase SDK が内部的に使用する場合がある**
   - ただし、`google-services.json` / `GoogleService-Info.plist` があれば不要

3. **削除は取り消せない**
   - 削除後は元に戻せない
   - 必要なら新しく作成

---

## 🎯 実行プラン

### フェーズ1: 即座に実行（今）
1. ✅ **GYM MATCH プロジェクトの未使用キーを削除**
   - iOS key (auto created by Firebase)
   - Browser key (auto created by Firebase)

2. ✅ **Generative Language API を有効化**

3. ✅ **新しいAPIキーを作成**（制限付き）

### フェーズ2: 確認後に実行（質問の回答後）
4. ❓ **X Automation プロジェクトの用途を確認**
   - 使用中 → キープ
   - 未使用 → プロジェクトごと削除

### フェーズ3: コード更新（新しいキー取得後）
5. ✅ **アプリコードを更新**
   - 新しいAPIキーに置き換え
   - v1.0.194 としてコミット

6. ✅ **動作確認**
   - AIコーチング機能のテスト
   - エラーが出ないか確認

### フェーズ4: セキュリティ強化（1週間以内）
7. 📝 **GitHub 履歴から古いキーを削除**
8. 🔒 **環境変数化または Remote Config 移行**

---

## 💬 質問

### 確認させてください

1. **「GYM MATCH X Automation」プロジェクトは何に使っていますか？**
   - テスト環境？
   - CI/CD？
   - データ移行ツール？
   - 全く使っていない？

2. **3つのAPIキー（MuscleMind, workout_photo, X Automation）の用途は？**
   - 現在使用中？
   - 過去に使っていたが今は不要？

3. **削除の実行タイミング**
   - 今すぐ削除してOK？
   - 確認してから削除したい？

これらの質問に答えていただければ、適切な削除プランを実行できます！

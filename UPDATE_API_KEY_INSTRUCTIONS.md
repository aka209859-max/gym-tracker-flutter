# 🔑 APIキー更新手順（緊急対応）

## 📋 現状の問題

### 問題1: 不明なAPIキーがハードコードされている
```dart
// lib/screens/workout/ai_coaching_screen.dart (line 621)
AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc
```
- このキーは **どのプロジェクトのものか不明**
- GitHub に公開されている
- 第三者が使用している可能性

### 問題2: GYM MATCH プロジェクトで Gemini API が有効化されていない
- 3枚目のスクリーンショットで確認
- Generative Language API がリストにない

---

## ✅ 解決手順

### ステップ1: Generative Language API を有効化

1. Google Cloud Console → プロジェクト **「GYM MATCH」** (gym-match-e560d)
2. 左側メニュー → **「APIとサービス」** → **「ライブラリ」**
3. 検索ボックスで **「Generative Language API」** を検索
4. **「有効にする」** をクリック

---

### ステップ2: 新しいAPIキーを作成

1. 左側メニュー → **「認証情報」**
2. 上部の **「+ 認証情報を作成」** → **「APIキー」**
3. 新しいキーが作成される（例: `AIzaXXXXXXXXXXXXXXXXXXXXXXXX`）
4. ✅ **このキーをコピーしておく**

---

### ステップ3: APIキーに制限を設定（重要！）

作成されたAPIキーの **「キーを制限」** をクリック：

#### 1. 名前を変更
```
GYM MATCH iOS App - Gemini API
```

#### 2. アプリケーションの制限
- ✅ **「iOS アプリ」** を選択
- Bundle ID を追加:
  ```
  jp.nexa.fitsync
  ```

#### 3. API の制限
- ✅ **「キーを制限」** を選択
- **「Generative Language API」** のみにチェック

#### 4. 保存
- **「保存」** をクリック

---

### ステップ4: コードを更新

新しいAPIキーでコードを更新します。

#### 方法A: 直接ハードコード（簡易版）

```dart
// lib/screens/workout/ai_coaching_screen.dart (line 621)
// 変更前
Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc'),

// 変更後（新しいAPIキーに置き換え）
Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=【ここに新しいAPIキーを貼り付け】'),
```

#### 方法B: Firebase Remote Config（推奨）

将来的には Firebase Remote Config で管理することを推奨します。
これにより、アプリを再リリースせずにAPIキーを変更できます。

---

### ステップ5: 古いAPIキーの無効化

**重要**: 新しいキーに切り替えた後、古いキーを削除してください。

ただし、古いキー `AIzaSyA9XmQ...` は **GYM MATCH プロジェクトには存在しない** ため、
どのプロジェクトのものか確認する必要があります。

---

## 🔍 追加調査が必要

### 古いAPIキーはどこのプロジェクト？

以下の方法で確認できます：

#### 方法1: Google Cloud Console で検索
1. https://console.cloud.google.com/ にアクセス
2. **すべてのプロジェクト** を確認
3. 各プロジェクトの **「認証情報」** で `AIzaSyA9XmQ...` を探す

#### 方法2: APIキーが属するプロジェクトを特定
```bash
# Google Cloud CLI がインストールされている場合
gcloud projects list
gcloud auth list
```

---

## 📊 確認事項

### ✅ 新しいAPIキーで動作確認

1. コードを更新
2. ローカルでビルド
3. AIコーチング機能をテスト
4. エラーが出ないか確認

### ✅ 使用量のモニタリング

1. Google Cloud Console → プロジェクト **「GYM MATCH」**
2. APIs & Services → Dashboard
3. **Generative Language API** → **Metrics**
4. 定期的に確認

---

## 🚨 緊急度

### 🔴 最優先（今すぐ）
1. ✅ Generative Language API を有効化
2. ✅ 新しいAPIキーを作成
3. ✅ 制限を設定（iOS アプリ + Gemini API のみ）

### 🟡 優先（24時間以内）
4. ✅ コードを更新（新しいAPIキーに変更）
5. ✅ v1.0.194 としてコミット・デプロイ

### 🟢 推奨（1週間以内）
6. 📝 古いAPIキーの所在を特定
7. 🚫 古いAPIキーを削除
8. 🔄 Firebase Remote Config への移行を検討

---

## 💡 今後の改善案

### セキュリティ向上
1. **環境変数化**: `.env` ファイルでAPIキーを管理
2. **Firebase Remote Config**: リモートでキーを管理
3. **バックエンドプロキシ**: Cloud Functions 経由でAPI呼び出し

### コスト管理
1. **使用量アラート**: 一定量を超えたら通知
2. **Quota 設定**: 1日の上限を設定
3. **有料プラン検討**: RPM/RPD を増やす

---

## 📞 次のステップ

1. **Generative Language API を有効化** してください
   - Google Cloud Console → ライブラリ → 検索 → 有効化

2. **新しいAPIキーを作成** してください
   - 認証情報 → + 認証情報を作成 → APIキー

3. **スクリーンショットを共有** してください
   - 新しいAPIキーの確認画面
   - 制限設定の画面

これで、私がコードを更新します！

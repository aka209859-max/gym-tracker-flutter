# 🚨 403 Forbidden エラー 解決ガイド

## 現状
- ✅ Bundle ID: `com.nexa.gymmatch` に変更済み
- ❌ AIコーチで403エラー発生
- ❓ マップ（GPS）の状況は？

---

## 🔍 403エラーの原因

### 原因1: Generative Language API が有効化されていない（最も可能性高い）

#### 確認方法
```
Google Cloud Console:
1. プロジェクト "GYM MATCH" (gym-match-e560d) を選択
2. APIs & Services → ライブラリ
3. 検索ボックスに "Generative Language API" と入力
4. 結果をクリック
5. ステータスを確認:
   
   【有効化されている場合】
   ✅ "API が有効です" と表示
   ✅ "無効にする" ボタンが表示
   
   【有効化されていない場合】
   ❌ "有効にする" ボタンが表示
```

#### 対応方法
```
1. "有効にする" ボタンをクリック
2. 数秒待つ
3. "API が有効です" と表示されることを確認
4. TestFlight でテスト
```

---

### 原因2: API制限の設定ミス

#### 確認方法
```
Google Cloud Console:
1. APIs & Services → 認証情報
2. "GYM MATCH - Gemini API (iOS)" をクリック
3. 以下を確認:

【アプリケーションの制限】
✅ iOS アプリ を選択
✅ Bundle ID: com.nexa.gymmatch（タイプミスなし）

【API の制限】
✅ キーを制限 を選択
✅ Generative Language API にチェック
```

#### よくあるミス
```
❌ Bundle ID のタイプミス:
   com.nexa.gym match （スペース）
   com.nexa.gym-match （ハイフン）
   com.nexa.gymmatch. （末尾のドット）

❌ API制限で別のAPIを選択:
   "Generative AI SDK" ❌
   "Generative Language API" ✅
```

---

### 原因3: APIキーが正しく保存されていない

#### 確認方法
```
Google Cloud Console:
1. APIs & Services → 認証情報
2. "GYM MATCH - Gemini API (iOS)" をクリック
3. "キーの文字列" を確認:
   
   AIzaSyBoexxWDV_0QIH-ePaMUy_euWuYQGcqvEo
   
   ↑このキーで間違いないか確認
```

---

## 🔧 デバッグ手順

### ステップ1: API有効化を確認（最優先）

```
Google Cloud Console:
1. APIs & Services → ライブラリ
2. "Generative Language API" を検索
3. 有効化されているか確認
4. 有効化されていなければ → "有効にする" をクリック
```

**⚠️ これが最も可能性の高い原因です！**

---

### ステップ2: 一時的に制限を外してテスト

```
Google Cloud Console:
1. APIs & Services → 認証情報
2. "GYM MATCH - Gemini API (iOS)" をクリック
3. アプリケーションの制限:
   
   【現在】iOS アプリ（com.nexa.gymmatch）
   ↓
   【テスト】なし
   
4. 保存
5. TestFlight でテスト
```

#### 結果の判定
```
✅ 動作した場合:
   → Bundle ID の設定に問題あり
   → タイプミスを再確認
   → または iOS SDK の証明書問題

❌ まだ403エラーの場合:
   → API が有効化されていない
   → APIキーが間違っている
   → プロジェクトが間違っている
```

---

### ステップ3: Google Cloud Console のメトリクスを確認

```
Google Cloud Console:
1. APIs & Services → Dashboard
2. "Generative Language API" をクリック
   
   【API が有効化されている場合】
   ✅ API 名が表示される
   ✅ Metrics タブがある
   
   【API が有効化されていない場合】
   ❌ API が表示されない
   ❌ または "有効にする" ボタンが表示される
   
3. Metrics タブをクリック
4. Traffic グラフを確認:
   - リクエスト数: 0より大きい？
   - エラーコード: 403が表示されているか？
```

---

## 📊 エラーコード詳細

### 403 Forbidden の意味
```
Google側の判定:
"このAPIキーには、このリソースへのアクセス権限がありません"

原因:
1. API が有効化されていない（70%の確率）
2. Bundle ID が一致しない（20%の確率）
3. API制限の設定ミス（10%の確率）
```

---

## 🎯 推奨アクション（優先順位順）

### 1. API有効化を確認（最優先）⭐⭐⭐
```
APIs & Services → ライブラリ
→ "Generative Language API" → 有効化
```

### 2. 一時的に制限を外してテスト ⭐⭐
```
認証情報 → Gemini API Key
→ アプリケーションの制限: なし
```

### 3. Bundle ID を再確認 ⭐
```
認証情報 → Gemini API Key
→ Bundle ID: com.nexa.gymmatch（タイプミスなし）
```

---

## 📝 報告してほしい情報

以下のスクリーンショットを共有してください：

### 1. Generative Language API の状態
```
Google Cloud Console:
APIs & Services → ライブラリ
→ "Generative Language API" の詳細画面

スクリーンショット:
- API が有効化されているか
- "API が有効です" または "有効にする" ボタンが表示されているか
```

### 2. APIキーの設定
```
Google Cloud Console:
APIs & Services → 認証情報
→ "GYM MATCH - Gemini API (iOS)" の設定画面

スクリーンショット:
- アプリケーションの制限（iOS アプリ、Bundle ID）
- API の制限（Generative Language API）
```

### 3. メトリクス（可能であれば）
```
Google Cloud Console:
APIs & Services → Dashboard
→ "Generative Language API" → Metrics

スクリーンショット:
- Traffic グラフ
- エラーコード（403）
```

---

## 🚀 次のステップ

### 即座に実行
1. **Generative Language API を有効化**
   - APIs & Services → ライブラリ
   - "Generative Language API" を検索
   - "有効にする" をクリック

2. **TestFlight でテスト**
   - AIコーチ機能を試す
   - エラーが出るか確認

3. **スクリーンショットを共有**
   - API有効化状態
   - APIキー設定
   - エラーメッセージ（あれば）

---

## 💡 追加情報

### Places API（マップ）の状況
```
マップ（GPS）も403エラーですか？

【Yes の場合】
→ Places API も有効化が必要

【No の場合】
→ Generative Language API のみの問題
```

**マップの状況も教えてください！**

---

**最も可能性が高いのは「Generative Language APIが有効化されていない」です。**
**Google Cloud Console → APIs & Services → ライブラリ で確認してください！** 🔍

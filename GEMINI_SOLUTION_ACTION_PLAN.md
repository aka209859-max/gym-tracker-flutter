# 🎯 Gemini の回答に基づく解決策

## ✅ 最も可能性が高い原因

### **Places API (New) が設定されていない**

Google は現在、**Places API（旧）** と **Places API (New)** の2つを提供しています。
iOS SDK が新しいバージョンの場合、裏側で `Places API (New)` が呼ばれている可能性があります。

---

## 🚀 即座に実行：Places API (New) を追加

### ステップ1: Places API (New) を有効化

```
Google Cloud Console:
1. APIs & Services → ライブラリ
2. 検索ボックスに "Places API (New)" と入力
3. "Places API (New)" を選択
4. "有効にする" をクリック
```

### ステップ2: API キーに Places API (New) を追加

```
Google Cloud Console:
1. APIs & Services → 認証情報
2. "GYM MATCH - Places API (iOS)" をクリック
3. API の制限:
   ☑ キーを制限
   ☑ Places API にチェック ✅（既存）
   ☑ Places API (New) にチェック ✅（追加）
4. 保存
```

---

## 🔧 Gemini API のテスト：一時的に制限を完全に外す

### ステップ3: Gemini API Key の制限を完全に外す（テスト用）

```
Google Cloud Console:
1. APIs & Services → 認証情報
2. "GYM MATCH - Gemini API (iOS)" をクリック
3. API の制限:
   【現在】キーを制限（Generative Language API）
   ↓
   【テスト】キーを制限しない ✅
4. 保存
5. 5分待つ
6. TestFlight でテスト
```

#### 結果の判定
```
✅ 動作した場合:
   → API 制限の設定ミス
   → "Generative Language API" 以外のAPIが必要な可能性

❌ まだ403の場合:
   → コード側の実装問題
   → または別の根本的な問題
```

---

## ⏱️ 反映時間

```
API キーの設定変更後、5分程度待ってください。
→ Google Cloud 側で設定が伝播するまで時間がかかります。
```

---

## 📋 チェックリスト

### Places API
- [ ] Places API (旧) が有効化されている
- [ ] **Places API (New) が有効化されている** ← 重要！
- [ ] API キーに両方が設定されている

### Gemini API
- [ ] Generative Language API が有効化されている
- [ ] 一時的に「キーを制限しない」に変更
- [ ] 5分待機
- [ ] TestFlight でテスト

### 請求先アカウント
- [ ] 請求先アカウントがリンクされている
- [ ] クレジットカードが有効
- [ ] 支払いエラーがない

---

## 🎯 優先順位

### 最優先：Places API (New) を追加
1. Places API (New) を有効化
2. API キーに Places API (New) を追加
3. TestFlight でマップ機能をテスト

### 次：Gemini API の制限を外してテスト
1. Gemini API Key の制限を「キーを制限しない」に変更
2. 5分待つ
3. TestFlight で AI コーチをテスト

---

## 📝 結果の報告

以下を報告してください：

### Places API (New) 追加後
```
マップ機能: 動作した / まだエラー
エラー内容: （あれば）
```

### Gemini API 制限解除後
```
AI コーチ: 動作した / まだエラー
エラー内容: （あれば）
```

---

**まず Places API (New) を追加してください！** 🚀

# 🔑 新しいAPIキーを作成（完全に制限なし版）

## 🚨 現状
- 既存のAPIキーで403エラー
- 制限を「なし」に変更しても解決しない
- → APIキー自体に問題がある可能性

---

## ✅ 解決策：新しいAPIキーを作成

### ステップ1: 新しい Gemini API Key を作成

```
Google Cloud Console:
1. プロジェクト "GYM MATCH" を選択
2. APIs & Services → 認証情報
3. 上部の "+ 認証情報を作成" をクリック
4. "API キー" を選択
5. APIキーが作成される（コピーする）

例: AIzaSyC_XXXXXXXXXXXXXXXXXXXXXXXXXXX
```

#### 制限設定（重要）
```
6. "キーを制限" をクリック
7. 名前: GYM MATCH - Gemini API (No Restrictions)
8. アプリケーションの制限:
   ☑ なし ✅
9. API の制限:
   ☑ キーを制限
   ☑ Generative Language API にチェック ✅
10. 保存
```

**新しいAPIキーをメモしてください！**

---

### ステップ2: 新しい Places API Key を作成

```
同じ手順で:
1. "+ 認証情報を作成" → "API キー"
2. キーが作成される（コピーする）
3. "キーを制限" をクリック
4. 名前: GYM MATCH - Places API (No Restrictions)
5. アプリケーションの制限: なし
6. API の制限: キーを制限
7. Places API にチェック
8. 保存
```

**新しいAPIキーをメモしてください！**

---

## 📝 作成した新しいAPIキー

以下をメモしてください：

```
Gemini API Key (新):
AIzaSyC_XXXXXXXXXXXXXXXXXXXXXXXXXXX

Places API Key (新):
AIzaSyD_XXXXXXXXXXXXXXXXXXXXXXXXXXX
```

---

## 🔧 コードに新しいAPIキーを適用

新しいAPIキーを共有してください。
こちらでコードを更新してv1.0.198をリリースします。

---

## ⚠️ 重要な確認事項

### APIが有効化されているか再確認
```
Google Cloud Console:
1. APIs & Services → ライブラリ
2. "Generative Language API" を検索
   ✅ "API が有効です" と表示されているか
3. "Places API" を検索
   ✅ "API が有効です" と表示されているか
```

### プロジェクトが正しいか確認
```
Google Cloud Console 左上:
✅ プロジェクト名: GYM MATCH
✅ プロジェクトID: gym-match-e560d
```

---

## 📊 新しいAPIキーの設定まとめ

| 項目 | 設定値 |
|------|--------|
| **Gemini API Key** | |
| 名前 | GYM MATCH - Gemini API (No Restrictions) |
| アプリケーション制限 | なし |
| API制限 | Generative Language API のみ |
| | |
| **Places API Key** | |
| 名前 | GYM MATCH - Places API (No Restrictions) |
| アプリケーション制限 | なし |
| API制限 | Places API のみ |

---

## 🚀 次のステップ

1. **新しいAPIキーを2個作成**
2. **APIキーを共有**
3. **コードを更新してv1.0.198をリリース**
4. **TestFlight でテスト**

---

**今すぐ新しいAPIキーを作成してください！** 🔑

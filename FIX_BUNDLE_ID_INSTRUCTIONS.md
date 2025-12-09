# 🔧 Bundle ID 修正手順（3分で完了）

## ✅ 正しいBundle ID
```
com.nexa.gymmatch
```

---

## 📋 修正手順

### ステップ1：Google Cloud Console を開く
https://console.cloud.google.com/

---

### ステップ2：プロジェクトを選択
1. 左上のプロジェクト選択ドロップダウンをクリック
2. **"GYM MATCH"** (gym-match-e560d) を選択

---

### ステップ3：認証情報ページを開く
1. 左メニュー → **"APIs & Services"**
2. **"認証情報"** または **"Credentials"** をクリック

---

### ステップ4：Places API Key を修正

#### 4-1. キーを開く
- **"GYM MATCH - Places API (iOS)"** をクリック

#### 4-2. Bundle IDを修正
```
アプリケーションの制限:
├─ iOS アプリ を選択
└─ Bundle ID:
   【現在】jp.nexa.fitsync ❌
   【修正】com.nexa.gymmatch ✅
```

#### 4-3. 保存
- 画面下部の **"保存"** ボタンをクリック

---

### ステップ5：Gemini API Key を修正

#### 5-1. 認証情報ページに戻る
- 左メニュー → **"認証情報"**

#### 5-2. キーを開く
- **"GYM MATCH - Gemini API (iOS)"** をクリック

#### 5-3. Bundle IDを修正
```
アプリケーションの制限:
├─ iOS アプリ を選択
└─ Bundle ID:
   【現在】jp.nexa.fitsync ❌
   【修正】com.nexa.gymmatch ✅
```

#### 5-4. 保存
- 画面下部の **"保存"** ボタンをクリック

---

## ✅ 修正完了後のチェックリスト

### APIキー設定確認
- [ ] Places API Key のBundle ID: `com.nexa.gymmatch`
- [ ] Gemini API Key のBundle ID: `com.nexa.gymmatch`
- [ ] API制限が正しく設定されている

### TestFlightでテスト
- [ ] アプリを再起動（変更は即座に反映）
- [ ] マップタブ → GPS検索 → ジムが表示される
- [ ] AIコーチタブ → メニュー生成 → AIメニューが生成される
- [ ] エラーメッセージが表示されない

---

## 📱 TestFlight テスト手順

### 1. GPS機能のテスト
```
1. GYM MATCH アプリを開く
2. 下部のマップアイコンをタップ
3. 位置情報の許可を求められたら「このAppの使用中のみ許可」を選択
4. 近隣のジムが地図/リストに表示される ✅
```

### 2. AIコーチ機能のテスト
```
1. 下部のAIコーチアイコンをタップ
2. プロフィール情報を入力（年齢、体重など）
3. 「AIメニュー生成」ボタンをタップ
4. 数秒でAIメニューが表示される ✅
```

---

## 🔍 トラブルシューティング

### まだエラーが出る場合

#### 1. APIが有効化されているか確認
```
Google Cloud Console:
1. APIs & Services → ライブラリ
2. "Places API" を検索 → 有効化されているか確認
3. "Generative Language API" を検索 → 有効化されているか確認
```

#### 2. Bundle IDのタイプミスをチェック
```
正しい: com.nexa.gymmatch
間違い: com.nexa.gym-match （ハイフン）
間違い: com.nexa.gymmatch. （末尾のドット）
間違い: com.nexa. gymmatch （スペース）
```

#### 3. APIキーが正しく保存されたか確認
```
1. Google Cloud Console → 認証情報
2. Places API Key をクリック
3. Bundle ID が com.nexa.gymmatch になっているか確認
4. 同様に Gemini API Key も確認
```

---

## 📊 変更の反映時間

| 項目 | 反映時間 |
|------|----------|
| APIキーのBundle ID変更 | **即座（0秒）** |
| TestFlight アプリでの動作 | **即座（再起動のみ）** |

**アプリの再ビルドは不要です！**

---

## 🎯 期待される結果

### 修正前（v1.0.195）
```
❌ マップ: 位置情報取得失敗
❌ AIコーチ: API Error 403
❌ Google Cloud Console: 100% エラー率
```

### 修正後
```
✅ マップ: 近隣のジムが表示される
✅ AIコーチ: AIメニューが生成される
✅ Google Cloud Console: 0% エラー率
```

---

## 📞 サポート

### 修正完了後の報告

以下をスクリーンショットで共有してください：

1. **Google Cloud Console の認証情報画面**
   - Places API Key の設定（Bundle IDが `com.nexa.gymmatch`）
   - Gemini API Key の設定（Bundle IDが `com.nexa.gymmatch`）

2. **TestFlight アプリのスクリーンショット**
   - マップ画面（ジムが表示されている）
   - AIコーチ画面（メニューが生成されている）

3. **Google Cloud Console のメトリクス**
   - Generative Language API → Metrics → エラー率が0%

---

## ⏱️ 作業時間の目安

| ステップ | 所要時間 |
|----------|----------|
| Google Cloud Console ログイン | 30秒 |
| Places API Key の Bundle ID 修正 | 1分 |
| Gemini API Key の Bundle ID 修正 | 1分 |
| TestFlight でテスト | 1分 |
| **合計** | **約3.5分** |

---

**今すぐ修正を開始してください！** 🚀

修正が完了したら、TestFlight でアプリが正常に動作することを確認してください。

# 🚀 GitHub Actionsで手動ビルド実行

## 📋 手順（2分で完了）

### **ステップ1: GitHub Actionsページを開く**
```
https://github.com/aka209859-max/gym-tracker-flutter/actions
```

### **ステップ2: ワークフローを選択**
左側のメニューから **"iOS TestFlight Release"** をクリック

### **ステップ3: 手動実行**
1. 右上の **"Run workflow"** ボタンをクリック
2. "Branch" は **main** のままにする
3. 緑色の **"Run workflow"** ボタンをクリック

### **ステップ4: ビルド進行状況を確認**
- 新しいワークフロー実行が開始されます
- クリックして詳細ログを確認できます

---

## ⚠️ 重要: Flutterバージョンの修正が必要

現在のワークフローには**無効なFlutterバージョン（3.35.4）**が設定されています。
ビルドを実行する前に、以下の修正が必要です：

### **事前修正（必須）:**

1. **ワークフローファイルを開く:**
   https://github.com/aka209859-max/gym-tracker-flutter/blob/main/.github/workflows/ios-release.yml

2. **編集ボタン（✏️）をクリック**

3. **20行目を修正:**
   ```yaml
   flutter-version: '3.24.5'  # 3.35.4 から変更
   ```

4. **コミット:**
   - メッセージ: `fix: Correct Flutter version to 3.24.5`
   - "Commit directly to main"

5. **その後、上記のステップ1-4で手動実行**

---

## 📊 ビルド実行内容

ワークフローが実行すること：
1. ✅ Flutter 3.24.5セットアップ（修正後）
2. ✅ `flutter pub get`
3. ✅ **`flutter gen-l10n`** （7言語生成）
4. ✅ CocoaPods install
5. ✅ 証明書・プロビジョニング設定
6. ✅ `flutter build ipa`
7. ✅ TestFlightアップロード

**推定時間:** 20-30分

---

## 🎯 代替方法: 新しいタグでトリガー

もし手動実行ができない場合、新しいタグを作成：

```bash
# ローカルマシンで実行（Flutter環境がある場合）
git tag v1.0.281
git push origin v1.0.281
```

これにより自動的にビルドがトリガーされます。

---

## ✅ 成功の確認

ビルドが成功すると：
- ✅ GitHub ActionsページでGreen checkmark
- ✅ App Store Connectに新しいビルドが表示
- ✅ TestFlightで配信可能

---

**まず上記の修正を行ってから、手動実行してください！** 🚀

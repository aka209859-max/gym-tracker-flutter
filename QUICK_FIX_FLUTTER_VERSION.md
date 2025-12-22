# 🔧 緊急修正: Flutterバージョンエラー

## ❌ 問題
iOS TestFlightビルドが失敗しています。原因は**無効なFlutterバージョン**です。

```
flutter-version: '3.35.4'  ← このバージョンは存在しません
```

## ✅ 解決方法（1分で完了）

### GitHub UIで直接修正:

1. **GitHubでファイルを開く:**
   https://github.com/aka209859-max/gym-tracker-flutter/blob/main/.github/workflows/ios-release.yml

2. **編集ボタン（✏️）をクリック**

3. **20行目を修正:**
   ```yaml
   # 修正前
   flutter-version: '3.35.4'
   
   # 修正後
   flutter-version: '3.24.5'
   ```

4. **"Commit changes"をクリック**
   - コミットメッセージ: `fix: Correct Flutter version to 3.24.5`
   - "Commit directly to the main branch"を選択
   - "Commit changes"ボタンをクリック

5. **v1.0.280タグを再プッシュ（自動トリガー）:**
   
   修正後、v1.0.280のビルドが自動的に再実行されます。
   または、GitHub Actionsページで手動実行:
   - https://github.com/aka209859-max/gym-tracker-flutter/actions
   - "iOS TestFlight Release" → "Run workflow"

## 📊 修正内容の詳細

| 項目 | 修正前 | 修正後 |
|------|--------|--------|
| Flutterバージョン | 3.35.4 ❌ | 3.24.5 ✅ |
| ステータス | 無効（存在しない） | 最新安定版 |

## ⏱️ 推定時間
- **修正作業:** 1分
- **ビルド再実行:** 20-30分

---

**修正後、ビルドが成功するはずです！** 🚀

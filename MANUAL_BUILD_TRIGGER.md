# 🚀 GitHub Actions ビルドを手動で開始する方法

## 📋 現状確認

✅ **コードプッシュ済み**: commit `f3fab43`
✅ **タグプッシュ済み**: `v1.0.185`, `v1.0.186`, `v1.0.187`
❓ **GitHub Actions**: 自動起動していない可能性

---

## 🔧 手動ビルド開始手順

### 方法1: GitHub Web UI から起動（推奨）

1. **GitHub Actions ページを開く**
   ```
   https://github.com/aka209859-max/gym-tracker-flutter/actions
   ```

2. **ワークフローを選択**
   - 左サイドバーから「**iOS TestFlight Release**」をクリック

3. **手動実行**
   - 右上の「**Run workflow**」ボタンをクリック
   - Branch: `main` を選択
   - 「**Run workflow**」ボタンをクリック

4. **ビルド開始確認**
   - ワークフローが開始され、進行状況が表示されます
   - 約15-20分でビルド完了

---

### 方法2: GitHub CLI で起動（コマンドライン）

```bash
# GitHub CLI がインストールされている場合
gh workflow run "iOS TestFlight Release" --ref main
```

---

### 方法3: 新しいタグをプッシュして再トリガー

```bash
# 新しいタグを作成（v1.0.188 など）
git tag -a v1.0.188 -m "Trigger build"
git push origin v1.0.188
```

---

## 🔍 トラブルシューティング

### ケース1: ワークフローが表示されない
- **原因**: `.github/workflows/` フォルダがリポジトリにない
- **確認**: https://github.com/aka209859-max/gym-tracker-flutter/tree/main/.github/workflows

### ケース2: "Run workflow" ボタンが無効
- **原因**: `workflow_dispatch` トリガーが設定されていない
- **確認**: ワークフローファイルに `workflow_dispatch:` が含まれているか確認
- **状態**: ✅ 設定済み（line 4）

### ケース3: ワークフローが失敗する
- **シークレット確認**:
  - `IOS_CERTIFICATE_BASE64`
  - `IOS_CERTIFICATE_PASSWORD`
  - `IOS_PROVISIONING_PROFILE_BASE64`
  - `APP_STORE_CONNECT_KEY_IDENTIFIER`
  - `APP_STORE_CONNECT_ISSUER_ID`
  - `APP_STORE_CONNECT_PRIVATE_KEY`

---

## 📊 期待されるビルド結果

### 成功時のログ
```
✅ Checkout repository
✅ Set up Flutter (3.35.4)
✅ Install dependencies
✅ Install Apple Certificate and Provisioning Profile
✅ Configure Xcode project for manual signing
✅ Create ExportOptions.plist
✅ Build Flutter IPA
✅ Upload IPA artifact
✅ Upload to App Store Connect
```

### ビルド時間
- **合計**: 約15-20分
  - Flutter セットアップ: 3-5分
  - 依存関係インストール: 3-5分
  - iOS ビルド: 8-10分
  - アップロード: 2-3分

---

## 🔗 便利なリンク

- **GitHub Actions**: https://github.com/aka209859-max/gym-tracker-flutter/actions
- **Workflows**: https://github.com/aka209859-max/gym-tracker-flutter/actions/workflows/ios-release.yml
- **App Store Connect**: https://appstoreconnect.apple.com/
- **TestFlight**: https://apps.apple.com/app/testflight/id899247664

---

## 📱 ビルド後の確認

### TestFlight 配信確認
1. App Store Connect にログイン
2. 「マイApp」→「GYM MATCH」
3. 「TestFlight」タブ
4. ビルド番号を確認（例: 1.0.187）
5. テスターグループに配信

### ダウンロード
1. iPhone/iPad で TestFlight アプリを開く
2. GYM MATCH を選択
3. 新しいビルドが表示されたらインストール

---

**次のアクション**: GitHub Actions ページで手動実行してください 🚀

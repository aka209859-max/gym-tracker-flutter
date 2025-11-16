# 🔧 GitHub Workflow手動更新ガイド

GitHub Personal Access Tokenの`workflow`スコープ制限により、ワークフローファイルの自動プッシュができません。

---

## ⚠️ 問題

```
error: refusing to allow a Personal Access Token to create or update workflow 
`.github/workflows/ios-release.yml` without `workflow` scope
```

---

## 🎯 解決策：GitHub Web UIで手動編集

### ステップ1: GitHubのファイル編集画面を開く

```
https://github.com/aka209859-max/gym-tracker-flutter/blob/main/.github/workflows/ios-release.yml
```

### ステップ2: 「Edit this file」（鉛筆アイコン）をクリック

### ステップ3: 4-7行目を以下に変更

**変更前**:
```yaml
on:
  workflow_dispatch:
  push:
    branches:
      - main
```

**変更後**:
```yaml
on:
  workflow_dispatch:  # 手動実行可能
  push:
    tags:
      - 'v*'  # v1.0.0, v1.1.0 等のタグでのみ自動実行
```

### ステップ4: コミット

```
Commit message: 🔒 Secure iOS release: Change trigger from push to tag-based release

Commit directly to the main branch
↓
「Commit changes」ボタンをクリック
```

---

## ✅ 完了確認

変更後、以下のように動作します：

**mainブランチへのプッシュ**:
```bash
git push origin main
# ← TestFlight配信されない（安全）
```

**タグのプッシュ**:
```bash
git tag -a v1.0.17 -m "Release"
git push origin v1.0.17
# ← TestFlight配信開始！
```

---

## 🎯 今後のリリース方法

詳細は `IOS_RELEASE_GUIDE.md` を参照してください。

**要約**:
```bash
# 通常の開発
git add .
git commit -m "機能追加"
git push origin main  # ← 配信されない

# リリース時
git tag -a v1.0.17 -m "Release v1.0.17"
git push origin v1.0.17  # ← 配信開始！
```

# 🍎 iOS TestFlight リリースガイド

このドキュメントは、iOS TestFlightへの安全なリリース方法を説明します。

---

## 🎯 リリース戦略：タグベース

### なぜタグベース？

**問題**:
- ❌ mainブランチへのプッシュ = 即TestFlight配信
- ❌ ドキュメント追加でもテスターに通知
- ❌ テスト中のコードも配信される

**解決策**:
- ✅ タグを作成したときだけTestFlight配信
- ✅ CEOが意図的にリリースを決定
- ✅ 余計なプッシュは配信されない

---

## 📋 リリースフロー

### ステップ1: 通常の開発（自由にプッシュ）

```bash
# 機能追加・修正
git add .
git commit -m "新機能追加"
git push origin main

# ← TestFlightには配信されない！安全！
```

### ステップ2: リリース準備完了時

**バージョン番号の決定**:
```
メジャーバージョン.マイナーバージョン.パッチバージョン

例:
v1.0.17 - 次のリリース
v1.1.0  - 新機能追加時
v2.0.0  - 大幅な変更時
```

### ステップ3: タグ作成 & プッシュ（TestFlight配信トリガー）

```bash
cd /home/user/flutter_app

# タグ作成
git tag -a v1.0.17 -m "Release v1.0.17: 疲労管理とキャンペーン機能追加"

# タグをプッシュ（これでTestFlight配信開始！）
git push origin v1.0.17
```

### ステップ4: GitHub Actions自動実行

```
タグプッシュ検知
    ↓
GitHub Actions 自動起動 🤖
    ↓
iOSビルド作成
    ↓
App Store Connectアップロード
    ↓
TestFlight配信
    ↓
✅ テスターに通知
```

---

## 🎯 2つのリリース方法

### 方法1: タグベース自動リリース（推奨）⭐

**いつ使う**: 本格的なリリース時

```bash
# 1. 最新コードをmainにプッシュ
git add .
git commit -m "Release準備完了"
git push origin main

# 2. タグ作成 & プッシュ
git tag -a v1.0.17 -m "Release v1.0.17"
git push origin v1.0.17

# ← これでTestFlight配信開始！
```

**メリット**:
- ✅ リリース履歴が明確（タグで管理）
- ✅ いつでもロールバック可能
- ✅ バージョン管理が明確

### 方法2: 手動実行（緊急時）

**いつ使う**: 緊急修正、テスト配信

```
1. GitHub: https://github.com/aka209859-max/gym-tracker-flutter
2. 「Actions」タブ
3. 「iOS TestFlight Release」
4. 「Run workflow」ボタン
5. ブランチ選択（通常はmain）
6. 「Run workflow」確定

← GitHub Actionsが即座に実行！
```

**メリット**:
- ✅ 即座に配信可能
- ✅ タグ不要
- ❌ バージョン履歴が不明確

---

## 📊 バージョン番号の管理

### セマンティックバージョニング

```
v[メジャー].[マイナー].[パッチ]

例:
v1.0.17 → v1.0.18  パッチ（バグ修正）
v1.0.18 → v1.1.0   マイナー（新機能追加）
v1.1.0  → v2.0.0   メジャー（大幅変更）
```

### GitHub Actions ビルド番号

```yaml
--build-name=1.0.${{ github.run_number }}
--build-number=${{ github.run_number }}
```

**自動インクリメント**:
- Run #17 → 1.0.17 (17)
- Run #18 → 1.0.18 (18)
- Run #19 → 1.0.19 (19)

---

## 🔄 実例：今回のケース

### 現状

```bash
最新コミット: 8c63d0d
内容: ドキュメント追加
状態: まだタグなし

→ TestFlight配信されない（安全）
```

### リリースしたい場合

```bash
cd /home/user/flutter_app

# オプション1: 今すぐリリース
git tag -a v1.0.17 -m "Release v1.0.17: キャンペーン機能追加"
git push origin v1.0.17

# オプション2: もう少し修正してからリリース
# 普通にコード修正してプッシュ（配信されない）
git add .
git commit -m "細かい修正"
git push origin main

# 準備完了後にタグ作成
git tag -a v1.0.17 -m "Release v1.0.17"
git push origin v1.0.17
```

---

## 📱 テスターへの通知制御

### タグベースの利点

**before（危険）**:
```
ドキュメント追加 → プッシュ → TestFlight配信 → テスターに通知
細かい修正     → プッシュ → TestFlight配信 → テスターに通知
実験的機能     → プッシュ → TestFlight配信 → テスターに通知

→ テスターが混乱！
```

**after（安全）**:
```
ドキュメント追加 → プッシュ → 何も起きない
細かい修正     → プッシュ → 何も起きない
実験的機能     → プッシュ → 何も起きない

【リリース準備完了】
タグ作成 → プッシュ → TestFlight配信 → テスターに通知

→ テスターは本当のリリースのみ受け取る！
```

---

## 🎯 リリースチェックリスト

### リリース前

- [ ] 全ての機能が完成している
- [ ] flutter analyze でエラーなし
- [ ] テストが通過
- [ ] READMEやドキュメントが更新済み
- [ ] バージョン番号を決定（例: v1.0.17）

### リリース実行

```bash
# 1. 最終コミット
git add .
git commit -m "Release v1.0.17 準備完了"
git push origin main

# 2. タグ作成
git tag -a v1.0.17 -m "Release v1.0.17: [機能説明]"

# 3. タグプッシュ（TestFlight配信トリガー）
git push origin v1.0.17
```

### リリース後

- [ ] GitHub Actions成功確認
- [ ] App Store Connectでビルド確認
- [ ] TestFlight配信完了確認（30-60分）
- [ ] 自分のTestFlightアプリで更新確認
- [ ] リリースノート更新（CHANGELOG.md等）

---

## 🔍 タグ管理コマンド

### タグ一覧表示

```bash
git tag

# 出力例:
# v1.0.15
# v1.0.16
# v1.0.17
```

### タグの詳細表示

```bash
git show v1.0.17

# 出力:
# tag v1.0.17
# Tagger: CEO <ceo@nexajp.com>
# Date:   2024-11-16
# 
# Release v1.0.17: キャンペーン機能追加
# 
# commit 8c63d0d...
```

### タグの削除（間違えた場合）

```bash
# ローカルタグ削除
git tag -d v1.0.17

# リモートタグ削除
git push origin :refs/tags/v1.0.17

# または
git push origin --delete v1.0.17
```

---

## 🚨 緊急ロールバック

### 問題のあるビルドを配信してしまった場合

**App Store Connect側**:
```
1. App Store Connect → TestFlight
2. 問題のあるビルドを選択
3. 「テストを停止」
```

**GitHubリポジトリ側**:
```bash
# 前のバージョンにロールバック
git checkout v1.0.16

# 修正を加える
# ...

# 新しいパッチバージョンとしてリリース
git tag -a v1.0.18 -m "Hotfix: v1.0.17の問題修正"
git push origin v1.0.18
```

---

## 📊 リリース履歴の例

```
v1.0.15 (2024-11-10) - 初回TestFlightリリース
v1.0.16 (2024-11-15) - Phase 2b/2c疲労管理追加
v1.0.17 (2024-11-16) - キャンペーンシステム追加
v1.0.18 (2024-11-17) - バグ修正
v1.1.0  (2024-11-20) - 新機能：パートナー検索
v2.0.0  (2024-12-01) - メジャーアップデート
```

---

## 🎉 まとめ

### タグベースリリースの利点

1. **意図的なリリース**
   - CEOが決めたタイミングでのみ配信
   - 余計なプッシュは配信されない

2. **明確なバージョン管理**
   - タグでリリース履歴が明確
   - いつでもロールバック可能

3. **テスター体験の向上**
   - 本当のリリースのみ通知
   - 無駄な通知なし

4. **柔軟性**
   - 通常開発: 自由にプッシュ
   - リリース時: タグ作成

---

## 📞 クイックリファレンス

### 日常開発（自由にプッシュ）

```bash
git add .
git commit -m "機能追加"
git push origin main
# ← TestFlight配信されない
```

### リリース時（TestFlight配信）

```bash
git tag -a v1.0.17 -m "Release v1.0.17"
git push origin v1.0.17
# ← TestFlight配信開始！
```

### 緊急リリース（手動実行）

```
GitHub → Actions → iOS TestFlight Release → Run workflow
```

---

**CEO、これで安全にリリース管理ができます！余計なものが配信される心配はもうありません！** 🎯🛡️

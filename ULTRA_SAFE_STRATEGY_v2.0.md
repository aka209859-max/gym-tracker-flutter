# 🛡️ 超安全戦略 v2.0 - エラー・バグ・クラッシュ絶対回避

**作成日**: 2025-12-25  
**方針**: **確実性100%優先、スピードは二の次**  
**絶対条件**: エラー・バグ・クラッシュは1つも許さない

---

## 🎯 基本方針の変更

### ❌ v1.0の問題点

```yaml
v1.0の計画:
  - セミ自動化（70%自動）
  - 2週間の短縮コース
  - スクリプトによる一括置換

リスク:
  ⚠️ スクリプトのバグで壊れる可能性
  ⚠️ 見落としがある可能性
  ⚠️ スピード重視で確認が甘くなる
```

### ✅ v2.0の新方針

```yaml
超安全戦略:
  - 100%手動（自動化は一切なし）
  - 1ファイルずつ慎重に
  - 毎回3段階チェック
  - 期間は4週間（余裕を持つ）

保証:
  ✅ エラー絶対回避
  ✅ バグ絶対回避
  ✅ クラッシュ絶対回避
```

---

## 📋 超安全実装手順（1ファイルあたり）

### ステップ1: 準備（毎回）

```bash
# 1. 現在のブランチを確認
git branch
# 期待: localization-perfect

# 2. 最新の状態を確認
git status
# 期待: nothing to commit, working tree clean

# 3. バックアップブランチを作成
git branch backup-before-[ファイル名]-$(date +%Y%m%d-%H%M%S)
# 例: backup-before-home-screen-20251225-160000
```

---

### ステップ2: 1ファイルのみ編集（手動）

```yaml
ルール:
  1. 一度に1ファイルのみ編集
  2. 自動置換は使わない（全て目視確認）
  3. 変更は10行以内から始める
  4. わからない箇所は絶対に触らない
```

**例: home_screen.dart の最初の10行だけ**

```dart
// Before（元のコード）
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ホーム"), // ← ここだけ変更
      ),
    );
  }
}

// After（変更後）
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ← 追加
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle), // ← 変更
      ),
    );
  }
}
```

---

### ステップ3: 3段階チェック（必須）

#### チェック1: コンパイル確認

```bash
cd /home/user/webapp && flutter analyze
```

**判定基準**:
```yaml
✅ 合格: "No issues found!"
❌ 不合格: 1つでもエラー/警告があればロールバック
```

#### チェック2: ビルド確認

```bash
cd /home/user/webapp && flutter build apk --debug
```

**判定基準**:
```yaml
✅ 合格: ビルド成功
❌ 不合格: ビルド失敗したらロールバック
```

#### チェック3: 実機確認

```yaml
テスト項目:
  1. アプリが起動する
  2. 変更した画面が開く
  3. 文字列が正しく表示される
  4. クラッシュしない
  5. 言語を切り替えても動く

判定基準:
  ✅ 合格: すべてOK
  ❌ 不合格: 1つでも問題あればロールバック
```

---

### ステップ4: コミット（合格時のみ）

```bash
# すべてのチェックが合格した場合のみコミット
cd /home/user/webapp && git add lib/screens/home_screen.dart
cd /home/user/webapp && git commit -m "feat: Localize home_screen.dart - 10 lines

- Changed: AppBar title
- Pattern: Widget (A)
- Test: ✅ flutter analyze passed
- Test: ✅ build succeeded
- Test: ✅ manual test passed
- Safe to proceed"
```

---

### ステップ5: 次のファイルへ（合格時のみ）

```yaml
合格した場合:
  → 次のファイルの10行を編集

不合格の場合:
  → 即座にロールバック
  → 原因を調査
  → 理解してから再挑戦
```

---

## 🚨 ロールバック手順（エラー発生時）

### 即座に実行

```bash
# 1. 変更を破棄
cd /home/user/webapp && git checkout lib/screens/home_screen.dart

# 2. 確認
cd /home/user/webapp && flutter analyze
# 期待: No issues found!

# 3. 再ビルド
cd /home/user/webapp && flutter build apk --debug
# 期待: ビルド成功

# 4. 実機確認
# 期待: 正常動作
```

### ロールバック後

```yaml
次のアクション:
  1. 何が問題だったか記録
  2. 解決方法を調べる
  3. 理解してから再挑戦
  4. わからなければスキップ
```

---

## 📅 新しいスケジュール（4週間、余裕重視）

### Week 1: 最優先画面（5ファイル）

```yaml
目標: 最も重要な画面だけを完璧に

対象ファイル（5つのみ）:
  1. lib/screens/home_screen.dart
  2. lib/screens/map_screen.dart
  3. lib/screens/profile_screen.dart
  4. lib/screens/splash_screen.dart
  5. lib/screens/search_screen.dart

作業方法:
  - 1ファイルあたり1-2日
  - 10行ずつ慎重に
  - 毎回3段階チェック
  - 完璧になるまで次に進まない

期待成果:
  - 5ファイル完了
  - エラー0
  - 信頼できるパターン確立
```

### Week 2: 機能画面（10ファイル）

```yaml
目標: Week 1の経験を活かして10ファイル

対象ファイル:
  - lib/screens/workout/*.dart（5ファイル）
  - lib/screens/settings/*.dart（5ファイル）

作業方法:
  - 同じパターンのみ適用
  - 新しいパターンは避ける
  - 毎回3段階チェック

期待成果:
  - 10ファイル完了
  - エラー0
  - パターン習熟
```

### Week 3: 残りの画面（15ファイル）

```yaml
目標: 同じパターンで残りを完了

対象ファイル:
  - lib/screens/partner/*.dart（5ファイル）
  - lib/screens/campaign/*.dart（3ファイル）
  - その他（7ファイル）

作業方法:
  - 確立されたパターンのみ
  - 毎回3段階チェック

期待成果:
  - 15ファイル完了
  - エラー0
```

### Week 4: 総合テスト & 予備週

```yaml
目標: 完璧を確認し、問題があれば対応

作業:
  Day 1-3: 全7言語での総合テスト
  Day 4-5: 問題があれば修正（なければ予備日）

期待成果:
  - 全画面動作確認済み
  - 全7言語確認済み
  - エラー0
  - App Store申請準備完了
```

---

## 🛡️ 絶対に守るルール

### Rule 1: 一度に1ファイルのみ

```yaml
❌ 禁止:
  - 複数ファイルを同時に編集
  - 大量の行を一度に変更
  - 自動置換ツールの使用

✅ 許可:
  - 1ファイルずつ
  - 10行ずつ
  - 全て手動
```

### Rule 2: 3段階チェックを省略しない

```yaml
❌ 禁止:
  - 「多分大丈夫だろう」
  - チェックをスキップ
  - まとめてテスト

✅ 必須:
  - 毎回 flutter analyze
  - 毎回 build
  - 毎回 実機確認
```

### Rule 3: エラーが出たら即ロールバック

```yaml
❌ 禁止:
  - 「後で直せばいい」
  - エラーを放置
  - 次に進む

✅ 必須:
  - 即座にロールバック
  - 原因を理解
  - 解決してから再挑戦
```

### Rule 4: わからない箇所は触らない

```yaml
❌ 禁止:
  - 「試しにやってみる」
  - わからないまま変更
  - 複雑な箇所に挑戦

✅ 許可:
  - わかる箇所のみ
  - シンプルな箇所から
  - 確実な変更のみ
```

### Rule 5: 毎日バックアップ

```yaml
作業前:
  - バックアップブランチ作成

作業後:
  - 成功したらコミット
  - 失敗したらロールバック

毎日:
  - 動作する状態を維持
```

---

## 📊 進捗管理（超詳細）

### 1ファイルあたりのチェックリスト

```yaml
[ ] ファイルを開く
[ ] バックアップブランチ作成
[ ] 10行のみ編集
[ ] 保存
[ ] flutter analyze 実行
[ ] 結果確認: No issues found!
[ ] flutter build apk 実行
[ ] ビルド成功確認
[ ] 実機転送
[ ] アプリ起動確認
[ ] 該当画面開く
[ ] 文字列表示確認
[ ] 言語切り替え確認
[ ] クラッシュしないことを確認
[ ] git add
[ ] git commit
[ ] 次の10行へ（or 次のファイルへ）
```

### 週次チェックリスト

```yaml
Week 1:
  [ ] home_screen.dart 完了
  [ ] map_screen.dart 完了
  [ ] profile_screen.dart 完了
  [ ] splash_screen.dart 完了
  [ ] search_screen.dart 完了
  [ ] 全てエラー0
  [ ] 全て動作確認済み

Week 2:
  [ ] workout 5ファイル完了
  [ ] settings 5ファイル完了
  [ ] 全てエラー0
  [ ] 全て動作確認済み

Week 3:
  [ ] 残り15ファイル完了
  [ ] 全てエラー0
  [ ] 全て動作確認済み

Week 4:
  [ ] 全7言語テスト完了
  [ ] 全画面動作確認
  [ ] IPA生成成功
  [ ] App Store準備完了
```

---

## 🎯 成功の定義

```yaml
Week 1終了時:
  ✅ 5ファイル完璧に完了
  ✅ エラー: 0個
  ✅ バグ: 0個
  ✅ クラッシュ: 0回
  ✅ 動作: 100%確認済み

Week 2終了時:
  ✅ 15ファイル完璧に完了
  ✅ エラー: 0個
  ✅ バグ: 0個
  ✅ クラッシュ: 0回
  ✅ 動作: 100%確認済み

Week 3終了時:
  ✅ 30ファイル完璧に完了
  ✅ エラー: 0個
  ✅ バグ: 0個
  ✅ クラッシュ: 0回
  ✅ 動作: 100%確認済み

Week 4終了時:
  ✅ 全画面完璧に完了
  ✅ エラー: 0個
  ✅ バグ: 0個
  ✅ クラッシュ: 0回
  ✅ 全7言語動作確認済み
  ✅ App Store申請可能
```

---

## 💡 なぜこの方法が確実か

### 1. 自動化を一切使わない

```
自動化のリスク:
  - スクリプトにバグがある
  - 想定外のケースがある
  - 一気に壊れる

手動のメリット:
  - 1つずつ目で確認
  - 理解しながら進む
  - 問題を即座に発見
```

### 2. 毎回テストする

```
まとめてテストのリスク:
  - どこで壊れたかわからない
  - 修正が大変

毎回テストのメリット:
  - 問題の原因が明確
  - すぐに直せる
  - 積み重ね式で確実
```

### 3. 小さく進む

```
大きく変更するリスク:
  - 影響範囲が広い
  - ロールバックが大変

小さく進むメリット:
  - 影響範囲が小さい
  - ロールバックが簡単
  - 安心して進める
```

### 4. 余裕を持つ

```
急ぐリスク:
  - 確認が甘くなる
  - ミスが増える

余裕のメリット:
  - 丁寧に確認できる
  - 問題があっても対応できる
  - 品質が上がる
```

---

## 🚀 明日から始めること

### Day 1: home_screen.dart の最初の10行

```yaml
1. バックアップ作成
   git branch backup-before-home-screen-day1

2. home_screen.dart を開く

3. 最初の10行だけ編集
   - Text("ホーム") → Text(l10n.homeTitle)
   - 他は触らない

4. 保存

5. flutter analyze
   → No issues found! を確認

6. flutter build apk --debug
   → ビルド成功を確認

7. 実機で確認
   → 正常動作を確認

8. コミット
   git commit -m "feat: Localize home_screen - first 10 lines"

9. 次の10行へ
   （または明日続き）
```

---

## ✅ まとめ

```yaml
新しい方針:
  ✅ 100%手動
  ✅ 1ファイルずつ
  ✅ 10行ずつ
  ✅ 毎回3段階チェック
  ✅ エラーは即ロールバック
  ✅ 4週間の余裕

保証:
  ✅ エラー: 0個
  ✅ バグ: 0個
  ✅ クラッシュ: 0回
  ✅ 確実に100%達成

スピード < 確実性
早さより、正確さ！
```

---

**この方法なら絶対に安全です。1つずつ、確実に、完璧に進めましょう！** 🛡️

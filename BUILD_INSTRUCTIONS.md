# GYM MATCH - ビルド手順書

## 📋 前提条件

このプロジェクトは以下の環境でビルドしてください：
- Flutter SDK (最新安定版推奨)
- Dart SDK (Flutter同梱)
- Android SDK (Android向けビルド)
- Xcode (iOS向けビルド - macOSのみ)

## 🔨 ビルド手順

### 1. 依存関係のインストール

```bash
cd /home/user/webapp
flutter pub get
```

### 2. ローカライゼーションファイルの生成

```bash
flutter gen-l10n
```

このコマンドで以下が生成されます：
- `lib/gen/app_localizations.dart`
- 7言語分のローカライゼーションクラス

### 3. クリーンビルド（推奨）

```bash
flutter clean
flutter pub get
flutter gen-l10n
```

### 4. ビルド実行

#### デバッグビルド（Android）
```bash
flutter build apk --debug
```

#### リリースビルド（Android）
```bash
flutter build apk --release
```

#### iOS（macOSのみ）
```bash
flutter build ios --release
```

## ✅ ビルド後の確認事項

### 1. ローカライゼーションの確認
- [ ] 7言語すべてでアプリが起動する
- [ ] 言語切り替えが正常に動作する
- [ ] UIテキストが正しく表示される

### 2. 主要画面の確認
- [ ] ホーム画面
- [ ] マップ画面
- [ ] ワークアウト記録画面
- [ ] 設定画面

### 3. 言語別確認
- [ ] 🇯🇵 日本語 (ja)
- [ ] 🇬🇧 英語 (en)
- [ ] 🇩🇪 ドイツ語 (de)
- [ ] 🇪🇸 スペイン語 (es)
- [ ] 🇰🇷 韓国語 (ko)
- [ ] 🇨🇳 中国語簡体字 (zh)
- [ ] 🇹🇼 中国語繁体字 (zh_TW)

## 🐛 トラブルシューティング

### エラー: "The method 'xxx' isn't defined for the type 'AppLocalizations'"

**原因**: `flutter gen-l10n` が未実行  
**解決**: 
```bash
flutter gen-l10n
flutter pub get
```

### エラー: ICU format error

**原因**: ARBファイルのICU構文エラー  
**現状**: ✅ 全て解決済み（ICUエラー0件）

### ビルドが遅い

**推奨**: 初回ビルドは時間がかかります（10-20分）  
2回目以降は増分ビルドで高速化されます。

## 📊 プロジェクト統計

- **ARBキー数**: 3,335キー/言語
- **総エントリ数**: 23,345 (3,335 × 7言語)
- **ICUエラー**: 0件
- **日本語ハードコード**: 0件
- **7言語対応率**: 100%

## 🚀 CI/CD

GitHub Actionsでの自動ビルド:
https://github.com/aka209859-max/gym-tracker-flutter/actions

## 📝 注意事項

1. **初回ビルド**: `flutter gen-l10n` を必ず実行してください
2. **ARBファイル変更後**: 再度 `flutter gen-l10n` を実行してください
3. **クリーンビルド推奨**: 問題が発生した場合は `flutter clean` から再実行

## 🔗 関連リンク

- **プルリクエスト**: https://github.com/aka209859-max/gym-tracker-flutter/pull/3
- **完了レポート**: `FINAL_100PERCENT_REPORT.txt`

---

**最終更新**: 2025-12-24  
**ブランチ**: localization-perfect  
**ステータス**: ✅ ビルド準備完了

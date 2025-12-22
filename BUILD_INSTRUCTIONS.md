# 🔨 GYM MATCH ビルド手順 v1.0.280

## ⚠️ 重要: Sandbox環境の制限

このSandbox環境には**Flutterがインストールされていません**。そのため、ローカルビルドはできません。

## ✅ 推奨ビルド方法

### 方法1: GitHub Actions（自動）
既存の`ios-release.yml`ワークフローが、Flutterビルドとl10n生成を自動実行します。

**トリガー方法:**
```bash
# 1. タグを作成してプッシュ（iOS TestFlight用）
git tag v1.0.280
git push origin v1.0.280

# 2. または、GitHub UIで手動実行
# リポジトリ → Actions → "iOS TestFlight Release" → "Run workflow"
```

**ワークフローの実行内容:**
- Flutter 3.35.4のセットアップ
- 依存関係のインストール（`flutter pub get`）
- **L10n生成** (`flutter gen-l10n`) ← 7言語分
- iOSビルド
- TestFlightへアップロード

### 方法2: ローカルマシンでビルド（Flutter環境必要）

**前提条件:**
- Flutter 3.24.0以降
- Dart 3.0以降
- Xcode（iOS）またはAndroid Studio（Android）

**手順:**
```bash
# 1. リポジトリをクローン
git clone https://github.com/aka209859-max/gym-tracker-flutter.git
cd gym-tracker-flutter

# 2. 依存関係をインストール
flutter clean
flutter pub get

# 3. L10n生成（重要！）
flutter gen-l10n

# 4. ビルド
# iOS
flutter build ios --release

# Android
flutter build appbundle --release
# または
flutter build apk --release
```

## 📊 L10n生成の確認

生成されるファイル（`flutter gen-l10n`実行後）:
```
lib/generated/
├── app_localizations.dart       # ベースクラス
├── app_localizations_ja.dart    # 日本語
├── app_localizations_en.dart    # 英語
├── app_localizations_ko.dart    # 韓国語
├── app_localizations_zh.dart    # 中国語（簡体字）
├── app_localizations_zh_TW.dart # 中国語（繁体字）
├── app_localizations_de.dart    # ドイツ語
└── app_localizations_es.dart    # スペイン語
```

**確認コマンド:**
```bash
flutter gen-l10n
ls -la lib/generated/
```

## 🚨 L10n Validationワークフローについて

`.github/workflows/l10n-validation.yml`が作成されていますが、GitHub App の`workflows`権限制限により、自動プッシュできません。

**手動追加方法:**
1. GitHubリポジトリを開く
2. `.github/workflows/`に移動
3. "Add file" → "Create new file"
4. ファイル名: `l10n-validation.yml`
5. 内容をコピー&ペースト（ローカルの`.github/workflows/l10n-validation.yml`から）
6. "Commit new file"

**または:**
ローカルFlutter環境がある別のマシンから、直接プッシュする：
```bash
git clone https://github.com/aka209859-max/gym-tracker-flutter.git
cd gym-tracker-flutter
git add .github/workflows/l10n-validation.yml
git commit -m "ci(workflow): Add L10n validation workflow"
git push origin main
```

## ✅ 現在の状態確認

**最新コミット:**
```bash
git log --oneline -5
```

**期待される出力:**
```
2fa2436 docs(l10n): Add comprehensive Phase 2 completion report v1.0.280
fc1c9e2 feat(l10n): Apply localization to 65 remaining screens (485 replacements)
24e932d feat(i18n): Add 176 comprehensive l10n keys + machine translation
5e1bd02 docs(i18n): Add comprehensive multilingual completion summary v1.0.278
b7155ce feat(i18n): Complete machine translation for all 7 languages
```

**ARBファイル確認:**
```bash
cd lib/l10n
wc -l app_*.arb  # 各ファイルの行数
python3 -c "import json; print('app_ja.arb:', len([k for k in json.load(open('app_ja.arb')) if not k.startswith('@')]), 'keys')"
```

**期待される出力:**
- 全7ファイル: 944キー（100%パリティ）

## 🎯 推奨アクション

### すぐ実行すべき:
1. **GitHub Actionsで自動ビルド実行**
   ```bash
   git tag v1.0.280
   git push origin v1.0.280
   ```
   → GitHub Actionsタブで進行状況を確認

2. **または、ローカルFlutter環境でテストビルド**
   ```bash
   flutter pub get
   flutter gen-l10n
   flutter build apk --debug  # 動作確認用
   ```

### 後で実行:
1. **L10n Validationワークフローを手動追加**（GitHub UI経由）
2. **実機/エミュレータでの7言語テスト**
3. **ネイティブスピーカーレビュー開始**

## 📝 トラブルシューティング

### 問題: `flutter gen-l10n`が失敗
```bash
# l10n.yamlの確認
cat l10n.yaml

# ARBファイルのJSON構文チェック
python3 -m json.tool lib/l10n/app_ja.arb > /dev/null && echo "✅ Valid JSON"
```

### 問題: ビルド時にAppLocalizationsが見つからない
```dart
// インポートを確認
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MaterialAppの設定を確認
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // ...
)
```

### 問題: 特定の言語で翻訳が表示されない
```bash
# ARBキー数を確認
cd lib/l10n
for f in app_*.arb; do 
  echo "$f: $(python3 -c "import json; print(len([k for k in json.load(open('$f')) if not k.startswith('@')]))" keys"
done
```

## 🔗 関連ドキュメント

- `LOCALIZATION_COMPLETE_v1.0.280.md` - Phase 2完了レポート
- `NATIVE_SPEAKER_REVIEW_CHECKLIST.md` - レビューガイド
- `l10n.yaml` - L10n設定
- `.github/workflows/ios-release.yml` - iOSビルドワークフロー

---

**Repository:** https://github.com/aka209859-max/gym-tracker-flutter  
**Latest Commit:** 2fa2436  
**Date:** 2025-12-21

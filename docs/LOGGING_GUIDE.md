# ロギングガイド

## 概要

GYM MATCHアプリでは、統一されたロギングシステム `AppLogger` を使用しています。

## 使用方法

### 基本的な使用例

```dart
import '../../utils/app_logger.dart';

// デバッグログ（開発環境のみ）
AppLogger.debug('変数の値: $value', tag: 'FEATURE_NAME');

// 情報ログ（開発環境のみ）
AppLogger.info('処理開始', tag: 'FEATURE_NAME');

// 警告ログ（すべての環境）
AppLogger.warn('推奨されない操作', tag: 'FEATURE_NAME');

// エラーログ（すべての環境）
AppLogger.error('エラー発生', tag: 'FEATURE_NAME', error: e, stackTrace: stackTrace);

// ユーザーアクションログ（すべての環境、分析用）
AppLogger.userAction('BUTTON_CLICKED', data: {'buttonId': 'submit'});

// パフォーマンス測定（開発環境のみ）
AppLogger.performance('API Call', duration);
```

### ログレベル（環境適応型）

| レベル | Web環境 | Mobile Debug | Mobile Release | 用途 |
|--------|---------|-------------|---------------|------|
| `debug()` | ✅ 常時出力 | ✅ 出力 | ❌ 非出力 | デバッグ情報、変数の値 |
| `info()` | ✅ 常時出力 | ✅ 出力 | ❌ 非出力 | 一般的な情報、処理の流れ |
| `warn()` | ✅ 出力 | ✅ 出力 | ✅ 出力 | 警告、推奨されない操作 |
| `error()` | ✅ 出力 | ✅ 出力 | ✅ 出力 | エラー、例外 |
| `userAction()` | ✅ 出力 | ✅ 出力 | ✅ 出力 | ユーザー行動分析 |
| `performance()` | ✅ 常時出力 | ✅ 出力 | ❌ 非出力 | パフォーマンス測定 |

**環境適応型の設計哲学**:
- **Web環境**: リリースビルドでも全ログを出力（開発効率優先）
- **Mobile環境**: リリースビルドでは重要ログのみ（パフォーマンス優先）

### タグ付け

ログにタグを付けることで、特定の機能のログをフィルタリングできます。

```dart
AppLogger.info('認証成功', tag: 'AUTH');
AppLogger.info('データ保存完了', tag: 'DATABASE');
AppLogger.info('AI分析開始', tag: 'AI_COACHING');
```

### ユーザーアクションログ

ユーザーの行動を追跡するために、`userAction()` を使用します。

```dart
// ボタンクリック
AppLogger.userAction('BUTTON_CLICKED', data: {'screen': 'home', 'buttonId': 'search'});

// 画面遷移
AppLogger.userAction('SCREEN_VIEW', data: {'screenName': 'ProfileScreen'});

// 機能使用
AppLogger.userAction('FEATURE_USED', data: {'feature': 'ai_coaching', 'bodyParts': ['chest', 'back']});
```

### パフォーマンス測定

```dart
final startTime = DateTime.now();

// 処理実行
await heavyOperation();

final duration = DateTime.now().difference(startTime);
AppLogger.performance('Heavy Operation', duration);
```

## ベストプラクティス

### ✅ 推奨

```dart
// タグを使用して機能を識別
AppLogger.info('処理開始', tag: 'AI_COACHING');

// エラーは詳細情報を含める
AppLogger.error('API呼び出し失敗', tag: 'API', error: e, stackTrace: stackTrace);

// ユーザーアクションは具体的に
AppLogger.userAction('AI_MENU_GENERATE_BUTTON_CLICKED', data: {'bodyParts': ['chest', 'back']});
```

### ❌ 非推奨

```dart
// タグなしで曖昧なメッセージ
AppLogger.info('処理開始');

// エラー情報なし
AppLogger.error('エラー');

// 曖昧なユーザーアクション
AppLogger.userAction('clicked');
```

## リリースビルドでのログ

### Web Release Build
Web環境では、**すべてのログレベルが常時出力**されます。これは開発・デバッグ効率を優先した設計です。

### Mobile Release Build
Mobile環境では、以下のログのみが出力されます：

- `warn()`: 警告
- `error()`: エラー
- `userAction()`: ユーザーアクション（分析用）

`debug()`, `info()`, `performance()` はパフォーマンスのため自動的に削除されます。

### 環境判定
システムは自動的に環境を判定し、適切なログレベルを適用します：
```dart
// Web環境かどうかを自動判定
static bool get _isWeb => kIsWeb;

// Web環境ではデバッグログも常時出力
if (_isWeb || kDebugMode) {
  // ログ出力
}
```

## 既存コードの移行

### debugPrint → AppLogger

```dart
// Before
debugPrint('🔍 デバッグ情報: $value');

// After
AppLogger.debug('デバッグ情報: $value', tag: 'FEATURE');
```

### print → AppLogger

```dart
// Before
print('✅ 処理成功');

// After
AppLogger.info('処理成功', tag: 'FEATURE');
```

## まとめ

- **統一されたログ**: すべてのログは `AppLogger` を使用
- **環境に応じた出力**: 開発環境とリリース環境で自動切り替え
- **タグ付け**: 機能ごとにタグを付けて管理
- **ユーザー分析**: `userAction()` でユーザー行動を追跡
- **パフォーマンス測定**: `performance()` で処理時間を測定

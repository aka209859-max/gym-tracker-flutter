import 'dart:js_interop';

/// JavaScript Console への直接アクセス（Web Release Build でも動作）
@JS('console.log')
external void _consoleLog(JSString message);

@JS('console.error')
external void _consoleError(JSString message);

@JS('console.warn')
external void _consoleWarn(JSString message);

@JS('console.info')
external void _consoleInfo(JSString message);

@JS('console.debug')
external void _consoleDebug(JSString message);

/// Production-safe ログ出力クラス
/// 
/// 特徴:
/// - Web Release Build でも確実に出力される
/// - dart2js の Tree Shaking で削除されない
/// - JavaScript console への直接バインディング
class ConsoleLogger {
  /// デバッグログ（Web環境では常に出力）
  static void debug(String message, {String? tag}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final tagStr = tag != null ? '[$tag] ' : '';
    final output = '🔍 DEBUG [$timestamp] $tagStr$message';
    _consoleDebug(output.toJS);
  }
  
  /// 情報ログ（Web環境では常に出力）
  static void info(String message, {String? tag}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final tagStr = tag != null ? '[$tag] ' : '';
    final output = '✅ INFO [$timestamp] $tagStr$message';
    _consoleInfo(output.toJS);
  }
  
  /// 警告ログ
  static void warn(String message, {String? tag}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final tagStr = tag != null ? '[$tag] ' : '';
    final output = '⚠️ WARN [$timestamp] $tagStr$message';
    _consoleWarn(output.toJS);
  }
  
  /// エラーログ
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final tagStr = tag != null ? '[$tag] ' : '';
    final output = '❌ ERROR [$timestamp] $tagStr$message';
    _consoleError(output.toJS);
    
    if (error != null) {
      _consoleError('   Error: $error'.toJS);
    }
    if (stackTrace != null) {
      _consoleError('   StackTrace: $stackTrace'.toJS);
    }
  }
  
  /// ユーザーアクションログ
  static void userAction(String action, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final dataStr = data != null ? ' | Data: $data' : '';
    final output = '👤 USER_ACTION [$timestamp] $action$dataStr';
    _consoleLog(output.toJS);
  }
  
  /// 初期化ログ
  static void init() {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _consoleLog('🚀 ConsoleLogger initialized [WEB RELEASE - JS INTEROP] [$timestamp]'.toJS);
  }
}

/// 🛡️ v1.0.307: グローバル非同期エラーハンドリングユーティリティ
/// 
/// 未処理の非同期エラーを安全にキャッチし、アプリクラッシュを防止
import 'package:flutter/foundation.dart';

/// 非同期処理を安全に実行するラッパー
/// 
/// エラーが発生してもアプリはクラッシュせず、エラーログのみ出力
/// 
/// 使用例:
/// ```dart
/// await safeAsync(() async {
///   final data = await FirebaseFirestore.instance.collection('xxx').get();
///   // 処理
/// });
/// ```
Future<T?> safeAsync<T>(
  Future<T> Function() operation, {
  String? debugLabel,
  T? fallbackValue,
}) async {
  try {
    return await operation();
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('🛡️ SafeAsync Error ${debugLabel != null ? "[$debugLabel]" : ""}: $e');
      print('StackTrace: $stackTrace');
    }
    return fallbackValue;
  }
}

/// void戻り値の非同期処理用ラッパー
Future<void> safeAsyncVoid(
  Future<void> Function() operation, {
  String? debugLabel,
}) async {
  try {
    await operation();
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('🛡️ SafeAsyncVoid Error ${debugLabel != null ? "[$debugLabel]" : ""}: $e');
      print('StackTrace: $stackTrace');
    }
  }
}

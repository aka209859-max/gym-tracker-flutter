// lib/services/ai_response_optimizer.dart
// AI応答時間最適化サービス

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// AI応答時間最適化サービス
/// キャッシング戦略でAPI呼び出しを削減し、応答時間を短縮
class AIResponseOptimizer {
  static const String _cachePrefix = 'ai_response_cache_';
  static const Duration _cacheExpiry = Duration(hours: 24); // 24時間有効
  
  /// AIレスポンスをキャッシュから取得（キャッシュがあれば即座に返す）
  /// 
  /// [cacheKey] キャッシュキー（通常はリクエストパラメータのハッシュ）
  /// 戻り値: キャッシュされたレスポンス（なければnull）
  static Future<String?> getCachedResponse(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('$_cachePrefix$cacheKey');
      
      if (cachedData == null) return null;
      
      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      final response = data['response'] as String;
      
      // キャッシュの有効期限をチェック
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        // 期限切れ: キャッシュを削除
        await prefs.remove('$_cachePrefix$cacheKey');
        return null;
      }
      
      return response;
    } catch (e) {
      print('Error getting cached response: $e');
      return null;
    }
  }
  
  /// AIレスポンスをキャッシュに保存
  /// 
  /// [cacheKey] キャッシュキー
  /// [response] 保存するレスポンス
  static Future<void> cacheResponse(String cacheKey, String response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'response': response,
      };
      await prefs.setString('$_cachePrefix$cacheKey', jsonEncode(data));
    } catch (e) {
      print('Error caching response: $e');
    }
  }
  
  /// リクエストパラメータからキャッシュキーを生成
  /// 
  /// [params] パラメータのマップ
  /// 戻り値: ハッシュ化されたキャッシュキー
  static String generateCacheKey(Map<String, dynamic> params) {
    final sortedKeys = params.keys.toList()..sort();
    final normalized = sortedKeys.map((key) => '$key:${params[key]}').join('|');
    final bytes = utf8.encode(normalized);
    final hash = md5.convert(bytes);
    return hash.toString();
  }
  
  /// 全てのキャッシュをクリア
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
  
  /// 期限切れのキャッシュを削除
  static Future<void> cleanExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final cachedData = prefs.getString(key);
          if (cachedData != null) {
            try {
              final data = jsonDecode(cachedData) as Map<String, dynamic>;
              final timestamp = DateTime.parse(data['timestamp'] as String);
              
              if (now.difference(timestamp) > _cacheExpiry) {
                await prefs.remove(key);
              }
            } catch (e) {
              // 不正なデータは削除
              await prefs.remove(key);
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning expired cache: $e');
    }
  }
  
  /// キャッシュ統計を取得
  /// 
  /// 戻り値: {count: キャッシュ数, totalSize: 合計サイズ(bytes)}
  static Future<Map<String, int>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int count = 0;
      int totalSize = 0;
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final value = prefs.getString(key);
          if (value != null) {
            count++;
            totalSize += utf8.encode(value).length;
          }
        }
      }
      
      return {'count': count, 'totalSize': totalSize};
    } catch (e) {
      print('Error getting cache stats: $e');
      return {'count': 0, 'totalSize': 0};
    }
  }
}

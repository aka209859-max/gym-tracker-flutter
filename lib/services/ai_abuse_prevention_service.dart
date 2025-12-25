import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:gym_match/gen/app_localizations.dart';
/// AI悪用防止サービス（5層防御）
/// 
/// Phase 1実装:
/// - 第1層: レート制限（1時間10回、1日50回、月500回）
/// - 第2層: 異常パターン検出（ボット、自動化、アカウント共有）
class AIAbusePreventionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Pro会員のレート制限（実質無制限だが悪用防止）
  static const int MAX_AI_CALLS_PER_HOUR = 10;
  static const int MAX_AI_CALLS_PER_DAY = 50;
  static const int MAX_AI_CALLS_PER_MONTH = 500;
  
  /// AI利用前のレート制限チェック
  Future<RateLimitResult> checkRateLimit(String userId) async {
    try {
      final now = DateTime.now();
      
      // 1. 時間単位チェック
      final lastHourCalls = await _getCallsInLastHour(userId);
      if (lastHourCalls >= MAX_AI_CALLS_PER_HOUR) {
        return RateLimitResult(
          allowed: false,
          reason: AppLocalizations.of(context)!.generatedKey_fc1a79ee,
          retryAfter: Duration(hours: 1),
        );
      }
      
      // 2. 日単位チェック
      final todayCalls = await _getCallsToday(userId);
      if (todayCalls >= MAX_AI_CALLS_PER_DAY) {
        return RateLimitResult(
          allowed: false,
          reason: AppLocalizations.of(context)!.generatedKey_8ed6a095,
          retryAfter: Duration(hours: 24 - now.hour),
        );
      }
      
      // 3. 月単位チェック
      final monthCalls = await _getCallsThisMonth(userId);
      if (monthCalls >= MAX_AI_CALLS_PER_MONTH) {
        return RateLimitResult(
          allowed: false,
          reason: AppLocalizations.of(context)!.generatedKey_4cf248d0
                 AppLocalizations.of(context)!.generatedKey_0efa33de
                 AppLocalizations.of(context)!.general_357589c3,
          retryAfter: null,
        );
      }
      
      return RateLimitResult(allowed: true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ レート制限チェックエラー: $e');
      }
      // エラー時は許可（UX優先）
      return RateLimitResult(allowed: true);
    }
  }
  
  Future<int> _getCallsInLastHour(String userId) async {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    
    final calls = await _firestore
        .collection('ai_usage_logs')
        .where('user_id', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(oneHourAgo))
        .get();
    
    return calls.docs.length;
  }
  
  Future<int> _getCallsToday(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final calls = await _firestore
        .collection('ai_usage_logs')
        .where('user_id', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfDay))
        .get();
    
    return calls.docs.length;
  }
  
  Future<int> _getCallsThisMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final calls = await _firestore
        .collection('ai_usage_logs')
        .where('user_id', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfMonth))
        .get();
    
    return calls.docs.length;
  }
  
  /// AI利用ログを記録
  Future<void> logAIUsage(String userId, String featureType) async {
    try {
      final deviceId = await _getDeviceId();
      
      await _firestore.collection('ai_usage_logs').add({
        'user_id': userId,
        'feature_type': featureType, // 'menu', 'prediction', 'analysis'
        'timestamp': FieldValue.serverTimestamp(),
        'device_id': deviceId,
      });
      
      if (kDebugMode) {
        print('✅ AI利用ログ記録: $userId - $featureType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AI利用ログ記録エラー: $e');
      }
    }
  }
  
  /// 異常パターン検出
  Future<AnomalyDetectionResult> detectAnomalies(String userId) async {
    try {
      final logs = await _getRecentLogs(userId, hours: 24);
      
      // ログが少ない場合はスキップ
      if (logs.length < 5) {
        return AnomalyDetectionResult(isAnomaly: false);
      }
      
      // 1. 短時間連続呼び出しチェック（5分以内に10回以上）
      final recentCalls = logs.where((log) {
        final timestamp = (log['timestamp'] as Timestamp).toDate();
        return DateTime.now().difference(timestamp).inMinutes <= 5;
      }).length;
      
      if (recentCalls >= 10) {
        await _flagUser(userId, 'rapid_calls', AppLocalizations.of(context)!.general_c85634b2);
        return AnomalyDetectionResult(
          isAnomaly: true,
          reason: AppLocalizations.of(context)!.general_497a2aa7,
          action: AnomalyAction.temporaryBlock,
        );
      }
      
      // 2. 深夜集中利用チェック（3-5時に50%以上の利用）
      final nightCalls = logs.where((log) {
        final timestamp = (log['timestamp'] as Timestamp).toDate();
        final hour = timestamp.hour;
        return hour >= 3 && hour <= 5;
      }).length;
      
      if (logs.length > 20 && nightCalls / logs.length > 0.5) {
        await _flagUser(userId, 'night_usage', AppLocalizations.of(context)!.general_98d5d34b);
        return AnomalyDetectionResult(
          isAnomaly: true,
          reason: AppLocalizations.of(context)!.general_15574875,
          action: AnomalyAction.warning,
        );
      }
      
      // 3. API呼び出しの間隔が極端に短い（人間的でない）
      if (logs.length >= 10) {
        final intervals = <int>[];
        for (int i = 1; i < logs.length; i++) {
          final prev = (logs[i - 1]['timestamp'] as Timestamp).toDate();
          final current = (logs[i]['timestamp'] as Timestamp).toDate();
          intervals.add(current.difference(prev).inSeconds);
        }
        
        // 平均間隔が30秒未満（人間は考える時間が必要）
        final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
        if (avgInterval < 30) {
          await _flagUser(userId, 'rapid_automation', AppLocalizations.of(context)!.general_6474d3c8);
          return AnomalyDetectionResult(
            isAnomaly: true,
            reason: AppLocalizations.of(context)!.general_84f740ea,
            action: AnomalyAction.permanentBlock,
          );
        }
      }
      
      return AnomalyDetectionResult(isAnomaly: false);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 異常検出エラー: $e');
      }
      return AnomalyDetectionResult(isAnomaly: false);
    }
  }
  
  Future<List<Map<String, dynamic>>> _getRecentLogs(String userId, {required int hours}) async {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    
    final snapshot = await _firestore
        .collection('ai_usage_logs')
        .where('user_id', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
  
  Future<void> _flagUser(String userId, String flagType, String reason) async {
    try {
      await _firestore.collection('abuse_flags').add({
        'user_id': userId,
        'flag_type': flagType,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending_review',
      });
      
      if (kDebugMode) {
        print(AppLocalizations.of(context)!.generatedKey_4d7afd8b);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ フラグ記録エラー: $e');
      }
    }
  }
  
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      // iOS専用アプリ
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
      
      return 'unknown_platform';
    } catch (e) {
      if (kDebugMode) {
        print('❌ デバイスID取得エラー: $e');
      }
      return 'unknown_device';
    }
  }
  
  /// ユーザーがブロックされているかチェック
  Future<bool> isUserBlocked(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['ai_blocked'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ブロックチェックエラー: $e');
      }
      return false;
    }
  }
}

/// レート制限結果
class RateLimitResult {
  final bool allowed;
  final String? reason;
  final Duration? retryAfter;
  
  RateLimitResult({
    required this.allowed,
    this.reason,
    this.retryAfter,
  });
}

/// 異常検出結果
class AnomalyDetectionResult {
  final bool isAnomaly;
  final String? reason;
  final AnomalyAction? action;
  
  AnomalyDetectionResult({
    required this.isAnomaly,
    this.reason,
    this.action,
  });
}

/// 異常検出時のアクション
enum AnomalyAction {
  warning,          // 警告表示のみ
  temporaryBlock,   // 24時間ブロック
  permanentBlock,   // 永久ブロック（サポート解除まで）
}

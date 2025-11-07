import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/gym.dart';

/// 訪問履歴データモデル
class VisitHistory {
  final String id;
  final String userId;
  final String gymId;
  final String gymName;
  final String gymAddress;
  final DateTime visitedAt;
  final double? rating;

  VisitHistory({
    required this.id,
    required this.userId,
    required this.gymId,
    required this.gymName,
    required this.gymAddress,
    required this.visitedAt,
    this.rating,
  });

  factory VisitHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      gymId: data['gymId'] ?? '',
      gymName: data['gymName'] ?? '',
      gymAddress: data['gymAddress'] ?? '',
      visitedAt: (data['visitedAt'] as Timestamp).toDate(),
      rating: data['rating'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gymId': gymId,
      'gymName': gymName,
      'gymAddress': gymAddress,
      'visitedAt': Timestamp.fromDate(visitedAt),
      'rating': rating,
    };
  }
}

/// 訪問履歴管理サービス
class VisitHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 現在のユーザーIDを取得
  String? get _currentUserId => _auth.currentUser?.uid;

  /// ジムにチェックイン
  Future<bool> checkIn(Gym gym, {double? rating}) async {
    try {
      if (_currentUserId == null) {
        if (kDebugMode) {
          debugPrint('❌ ユーザーがログインしていません');
        }
        return false;
      }

      final visitHistory = VisitHistory(
        id: '', // Firestoreが自動生成
        userId: _currentUserId!,
        gymId: gym.id,
        gymName: gym.name,
        gymAddress: gym.address,
        visitedAt: DateTime.now(),
        rating: rating,
      );

      await _firestore.collection('visit_history').add(visitHistory.toMap());

      if (kDebugMode) {
        debugPrint('✅ チェックイン成功: ${gym.name}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ チェックイン失敗: $e');
      }
      return false;
    }
  }

  /// ユーザーの訪問履歴を取得（新しい順）
  Future<List<VisitHistory>> getVisitHistory() async {
    try {
      if (_currentUserId == null) {
        if (kDebugMode) {
          debugPrint('❌ ユーザーがログインしていません');
        }
        return [];
      }

      final querySnapshot = await _firestore
          .collection('visit_history')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final histories = querySnapshot.docs
          .map((doc) => VisitHistory.fromFirestore(doc))
          .toList();

      // メモリ内でソート（Firestoreインデックス不要）
      histories.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

      if (kDebugMode) {
        debugPrint('✅ 訪問履歴取得: ${histories.length}件');
      }
      return histories;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 訪問履歴取得失敗: $e');
      }
      return [];
    }
  }

  /// 特定のジムの訪問回数を取得
  Future<int> getVisitCount(String gymId) async {
    try {
      if (_currentUserId == null) return 0;

      final querySnapshot = await _firestore
          .collection('visit_history')
          .where('userId', isEqualTo: _currentUserId)
          .where('gymId', isEqualTo: gymId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 訪問回数取得失敗: $e');
      }
      return 0;
    }
  }

  /// 最後の訪問日時を取得
  Future<DateTime?> getLastVisitDate(String gymId) async {
    try {
      if (_currentUserId == null) return null;

      final querySnapshot = await _firestore
          .collection('visit_history')
          .where('userId', isEqualTo: _currentUserId)
          .where('gymId', isEqualTo: gymId)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final histories = querySnapshot.docs
          .map((doc) => VisitHistory.fromFirestore(doc))
          .toList();

      histories.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

      return histories.first.visitedAt;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 最終訪問日取得失敗: $e');
      }
      return null;
    }
  }

  /// 訪問履歴を削除
  Future<bool> deleteVisitHistory(String historyId) async {
    try {
      await _firestore.collection('visit_history').doc(historyId).delete();
      if (kDebugMode) {
        debugPrint('✅ 訪問履歴削除成功');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 訪問履歴削除失敗: $e');
      }
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// メッセージデータモデル
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}

/// 会話（チャットルーム）データモデル
class Conversation {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCounts;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCounts,
  });

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'unreadCounts': unreadCounts,
    };
  }
}

/// メッセージング管理サービス
class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 現在のユーザーIDを取得
  String? get _currentUserId => _auth.currentUser?.uid;

  /// 会話IDを生成（2人のユーザーIDをソートして結合）
  String _generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// メッセージを送信
  Future<bool> sendMessage(String receiverId, String content) async {
    try {
      if (_currentUserId == null) {
        if (kDebugMode) {
          debugPrint('❌ ユーザーがログインしていません');
        }
        return false;
      }

      final conversationId = _generateConversationId(_currentUserId!, receiverId);
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      
      // 会話が存在しない場合は作成
      final conversationDoc = await conversationRef.get();
      if (!conversationDoc.exists) {
        await conversationRef.set({
          'participantIds': [_currentUserId, receiverId],
          'lastMessage': content,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'unreadCounts': {
            _currentUserId!: 0,
            receiverId: 1,
          },
        });
      } else {
        // 既存の会話を更新
        final currentUnreadCounts = Map<String, int>.from(conversationDoc.data()?['unreadCounts'] ?? {});
        currentUnreadCounts[receiverId] = (currentUnreadCounts[receiverId] ?? 0) + 1;
        
        await conversationRef.update({
          'lastMessage': content,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'unreadCounts': currentUnreadCounts,
        });
      }

      // メッセージを追加
      await conversationRef.collection('messages').add({
        'senderId': _currentUserId,
        'receiverId': receiverId,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (kDebugMode) {
        debugPrint('✅ メッセージ送信成功');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ メッセージ送信失敗: $e');
      }
      return false;
    }
  }

  /// ユーザーの会話一覧を取得（リアルタイム）
  Stream<List<Conversation>> getConversationsStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: _currentUserId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromFirestore(doc))
          .toList();
    });
  }

  /// 特定の会話のメッセージ一覧を取得（リアルタイム）
  Stream<List<Message>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromFirestore(doc))
          .toList();
    });
  }

  /// 未読メッセージ数を取得
  Future<int> getUnreadCount() async {
    try {
      if (_currentUserId == null) return 0;

      final querySnapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: _currentUserId)
          .get();

      int totalUnread = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final unreadCounts = Map<String, int>.from(data['unreadCounts'] ?? {});
        totalUnread += unreadCounts[_currentUserId] ?? 0;
      }

      return totalUnread;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 未読数取得失敗: $e');
      }
      return 0;
    }
  }

  /// メッセージを既読にする
  Future<bool> markAsRead(String conversationId) async {
    try {
      if (_currentUserId == null) return false;

      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      final conversationDoc = await conversationRef.get();

      if (!conversationDoc.exists) return false;

      final currentUnreadCounts = Map<String, int>.from(conversationDoc.data()?['unreadCounts'] ?? {});
      currentUnreadCounts[_currentUserId!] = 0;

      await conversationRef.update({
        'unreadCounts': currentUnreadCounts,
      });

      if (kDebugMode) {
        debugPrint('✅ メッセージを既読にしました');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 既読処理失敗: $e');
      }
      return false;
    }
  }

  /// 相手のユーザー情報を取得
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;
      return userDoc.data();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ユーザー情報取得失敗: $e');
      }
      return null;
    }
  }
}

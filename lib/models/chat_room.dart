import 'package:cloud_firestore/cloud_firestore.dart';

/// チャットルームモデル
class ChatRoom {
  final String roomId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount;

  ChatRoom({
    required this.roomId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ChatRoom.fromFirestore(Map<String, dynamic> data, String roomId) {
    return ChatRoom(
      roomId: roomId,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['last_message'] as String? ?? '',
      lastMessageTime: (data['last_message_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(data['unread_count'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'room_id': roomId,
      'participants': participants,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
    };
  }
}

/// チャットメッセージモデル
class ChatMessage {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool read;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.read,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data, String messageId) {
    return ChatMessage(
      messageId: messageId,
      senderId: data['sender_id'] as String,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'text': text,
      'timestamp': timestamp,
      'read': read,
    };
  }
}

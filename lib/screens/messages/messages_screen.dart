import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message.dart';
import 'chat_detail_screen.dart';

/// メッセージ一覧画面
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatService _chatService = ChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'メッセージ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: _chatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.diamond_outlined, 
                      size: 80, 
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'メッセージ機能',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'プレミアム会員限定',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎯 プレミアム会員の特典',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureRow('💬 トレーナーとの直接メッセージ'),
                          _buildFeatureRow('🤖 AIパーソナルコーチング'),
                          _buildFeatureRow('📊 高度な統計分析'),
                          _buildFeatureRow('🎨 カスタムテーマ'),
                          _buildFeatureRow('☁️ 無制限クラウドバックアップ'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: プレミアム購入画面への遷移
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('プレミアム機能は近日公開予定です'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'プレミアムにアップグレード',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'メッセージはありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'トレーニングパートナーとメッセージを\n始めましょう！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUserName = conversation.getOtherParticipantName(_currentUserId ?? '');
              final otherUserPhoto = conversation.getOtherParticipantPhoto(_currentUserId ?? '');
              final unreadCount = conversation.getUnreadCount(_currentUserId ?? '');
              final isCurrentUserSender = conversation.lastMessageSenderId == _currentUserId;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: otherUserPhoto.isNotEmpty
                      ? NetworkImage(otherUserPhoto)
                      : null,
                  child: otherUserPhoto.isEmpty
                      ? Icon(Icons.person, size: 32, color: Colors.grey[600])
                      : null,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        otherUserName,
                        style: TextStyle(
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      if (isCurrentUserSender)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      Expanded(
                        child: Text(
                          conversation.lastMessage.isEmpty
                              ? '会話を開始しましょう'
                              : conversation.lastMessage,
                          style: TextStyle(
                            color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Text(
                  _formatTime(conversation.lastMessageTime),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        conversationId: conversation.id,
                        otherUserName: otherUserName,
                        otherUserPhotoUrl: otherUserPhoto,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// 時刻をフォーマット
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return '昨日';
    } else if (now.difference(time).inDays < 7) {
      const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.month}/${time.day}';
    }
  }
  
  /// プレミアム機能の行を生成
  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

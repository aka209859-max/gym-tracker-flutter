import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pt_member.dart';

/// PO会員詳細画面
class POMemberDetailScreen extends StatelessWidget {
  final PTMember member;

  const POMemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('編集機能は近日公開予定です')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 基本情報
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '基本情報',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: '名前', value: member.name),
                  _InfoRow(label: 'メール', value: member.email),
                  if (member.phoneNumber != null)
                    _InfoRow(label: '電話番号', value: member.phoneNumber!),
                  _InfoRow(
                    label: '入会日',
                    value: DateFormat('yyyy/MM/dd').format(member.joinedAt),
                  ),
                  _InfoRow(label: '担当トレーナー', value: member.trainerName),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 契約情報
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '契約情報',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'プラン', value: member.planName),
                  _InfoRow(
                    label: '総セッション数',
                    value: '${member.totalSessions}回',
                  ),
                  _InfoRow(
                    label: '残りセッション',
                    value: '${member.remainingSessions}回',
                  ),
                  if (member.lastSessionAt != null)
                    _InfoRow(
                      label: '最終セッション',
                      value: DateFormat('yyyy/MM/dd')
                          .format(member.lastSessionAt!),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ステータス
          Card(
            color: member.isActive ? Colors.green[50] : Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    member.isActive ? Icons.check_circle : Icons.warning,
                    color: member.isActive ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      member.isActive
                          ? 'アクティブ会員です'
                          : '休眠中です（2週間以上セッションなし）',
                      style: TextStyle(
                        fontSize: 14,
                        color: member.isActive
                            ? Colors.green[800]
                            : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // アクションボタン
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('メッセージ機能は近日公開予定です')),
              );
            },
            icon: const Icon(Icons.message),
            label: const Text('メッセージを送信'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('セッション履歴は近日公開予定です')),
              );
            },
            icon: const Icon(Icons.history),
            label: const Text('セッション履歴を見る'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

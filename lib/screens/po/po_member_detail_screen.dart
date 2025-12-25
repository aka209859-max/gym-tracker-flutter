import 'package:gym_match/gen/app_localizations.dart';
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
            icon: Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.edit)),
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
                  Text(
                    l10n.gym_0179630e,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _InfoRow(label: l10n.name, value: member.name),
                  _InfoRow(label: AppLocalizations.of(context)!.email, value: member.email),
                  if (member.phoneNumber != null)
                    _InfoRow(label: AppLocalizations.of(context)!.gymPhone, value: member.phoneNumber!),
                  _InfoRow(
                    label: l10n.general_d583e5d0,
                    value: DateFormat('yyyy/MM/dd').format(member.joinedAt),
                  ),
                  _InfoRow(label: l10n.general_a82f5771, value: member.trainerName),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // 契約情報
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.general_f499f3a7,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _InfoRow(label: AppLocalizations.of(context)!.upgradePlan, value: member.planName),
                  _InfoRow(
                    label: l10n.general_71becd2b,
                    value: '${member.totalSessions}回',
                  ),
                  _InfoRow(
                    label: l10n.general_520812b8,
                    value: '${member.remainingSessions}回',
                  ),
                  if (member.lastSessionAt != null)
                    _InfoRow(
                      label: l10n.general_49c6c5b4,
                      value: DateFormat('yyyy/MM/dd')
                          .format(member.lastSessionAt!),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

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
                  SizedBox(width: 12),
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

          SizedBox(height: 24),

          // アクションボタン
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(l10n.general_0dfb3c3b)),
              );
            },
            icon: Icon(Icons.message),
            label: Text(l10n.general_ed353b30),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(l10n.general_75a6ecb5)),
              );
            },
            icon: Icon(Icons.history),
            label: Text(l10n.general_5573bee6),
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

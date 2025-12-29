import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pt_member.dart';

/// PO分析ダッシュボード画面
class POAnalyticsScreen extends StatelessWidget {
  final String partnerId;

  const POAnalyticsScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('personalTrainingMembers')
          .where('partnerId', isEqualTo: partnerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = snapshot.hasData
            ? snapshot.data!.docs
                .map((doc) => PTMember.fromFirestore(
                    doc.data() as Map<String, dynamic>, doc.id))
                .toList()
            : <PTMember>[];

        final totalMembers = members.length;
        final activeMembers = members.where((m) => m.isActive).length;
        final dormantMembers = members.where((m) => !m.isActive).length;
        final totalSessions =
            members.fold<int>(0, (sum, m) => sum + m.totalSessions);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '今月のKPI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // KPIカード
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _KPICard(
                  label: 'パーソナル会員数',
                  value: '$totalMembers名',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _KPICard(
                  label: 'アクティブ会員',
                  value: '$activeMembers名',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _KPICard(
                  label: '休眠会員',
                  value: '$dormantMembers名',
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
                _KPICard(
                  label: '総セッション数',
                  value: '$totalSessions回',
                  icon: Icons.fitness_center,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // アラートセクション
            if (dormantMembers > 0) ...[
              const Text(
                'アラート',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.orange[50],
                child: ListTile(
                  leading: const Icon(Icons.error, color: Colors.orange),
                  title: Text(AppLocalizations.of(context)!.poAnalytics_dormantMembers(dormantMembers.toString())),
                  subtitle: Text(AppLocalizations.of(context)!.poAnalytics_dormantDescription),
                  trailing: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!.poAnalytics_broadcastComingSoon)),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.poAnalytics_respond),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

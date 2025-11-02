import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'po_members_screen.dart';
import 'po_sessions_screen.dart';
import 'po_analytics_screen.dart';

/// PO管理ダッシュボード（メイン画面）
class PODashboardScreen extends StatefulWidget {
  final String partnerId;
  final String partnerName;

  const PODashboardScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<PODashboardScreen> createState() => _PODashboardScreenState();
}

class _PODashboardScreenState extends State<PODashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      POAnalyticsScreen(partnerId: widget.partnerId),
      POMembersScreen(partnerId: widget.partnerId),
      POSessionsScreen(partnerId: widget.partnerId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PO管理ダッシュボード'),
            Text(
              widget.partnerName,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 通知機能（今後実装）
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'ダッシュボード',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '会員管理',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'セッション',
          ),
        ],
      ),
    );
  }
}

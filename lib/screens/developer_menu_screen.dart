import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/subscription_service.dart';
import '../services/onboarding_service.dart';

/// 開発者専用メニュー画面（リリースビルドでは非表示）
class DeveloperMenuScreen extends StatefulWidget {
  const DeveloperMenuScreen({super.key});

  @override
  State<DeveloperMenuScreen> createState() => _DeveloperMenuScreenState();
}

class _DeveloperMenuScreenState extends State<DeveloperMenuScreen> {
  final _subscriptionService = SubscriptionService();
  final _onboardingService = OnboardingService();
  SubscriptionType? _currentPlan;
  String? _aiUsageStatus;
  bool _isLoading = true;
  String? _currentUserUid;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  Future<void> _loadCurrentStatus() async {
    setState(() => _isLoading = true);
    
    final plan = await _subscriptionService.getCurrentPlan();
    final status = await _subscriptionService.getAIUsageStatus();
    final user = FirebaseAuth.instance.currentUser;
    
    setState(() {
      _currentPlan = plan;
      _aiUsageStatus = status;
      _currentUserUid = user?.uid;
      _isLoading = false;
    });
  }

  /// UIDをクリップボードにコピー
  Future<void> _copyUidToClipboard() async {
    if (_currentUserUid != null) {
      await Clipboard.setData(ClipboardData(text: _currentUserUid!));
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ UIDをコピーしました\n$_currentUserUid'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // _changePlan関数は削除（Apple審査対応）
  // プラン変更はRevenueCat経由のみ許可

  Future<void> _resetAIUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ai_usage_count', 0);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ AI使用回数をリセットしました'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadCurrentStatus();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ リセット失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// オンボーディングをリセット（デバッグ用）
  Future<void> _resetOnboarding() async {
    try {
      await _onboardingService.resetOnboarding();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ オンボーディングをリセットしました\nアプリを再起動してください'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ リセット失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Phase 1機能の状態をすべてリセット
  Future<void> _resetAllPhase1Features() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // オンボーディング
      await _onboardingService.resetOnboarding();
      
      // レビュー依頼
      await prefs.remove('has_reviewed');
      await prefs.remove('reviewed_at');
      await prefs.remove('review_request_shown');
      await prefs.remove('review_request_shown_at');
      await prefs.remove('review_declined_at');
      
      // 紹介バナー
      await prefs.remove('last_referral_banner_date');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Phase 1機能をすべてリセットしました\nアプリを再起動してください'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ リセット失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.developerMenu),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 警告メッセージ
                Card(
                  color: Colors.orange.shade50,
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.orange, size: 32),
                    title: Text(
                      '⚠️ 開発者専用',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.generatedKey_24950e16,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 🆔 現在のユーザーUID表示（CEO用）
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.fingerprint, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.general_7a182a17,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_currentUserUid != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    _currentUserUid!,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, color: Colors.green),
                                  onPressed: _copyUidToClipboard,
                                  tooltip: AppLocalizations.of(context)!.copy,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.general_7a793789,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ] else
                          Text(AppLocalizations.of(context)!.signInRequired,
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 現在のプラン表示
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.currentPlan,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _currentPlan != null
                                  ? _subscriptionService.getPlanName(_currentPlan!)
                                  : AppLocalizations.of(context)!.loadingWorkouts,
                              style: const TextStyle(fontSize: 18),
                            ),
                            if (_currentPlan != null)
                              _getPlanBadge(_currentPlan!),
                          ],
                        ),
                        if (_currentPlan != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _subscriptionService.getPlanDescription(_currentPlan!),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subscriptionService.getPlanPrice(_currentPlan!),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // ⚠️ プラン変更機能は削除（Apple審査対応）
                Card(
                  color: Colors.red.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.block, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              '⚠️ プラン変更機能を無効化',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.generatedKey_de9021b8
                          AppLocalizations.of(context)!.generatedKey_25deda5a
                          AppLocalizations.of(context)!.general_2474b23c,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // AI使用状況
                Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.general_fad83375,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_aiUsageStatus != null)
                          Text(
                            _aiUsageStatus!,
                            style: const TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // AI使用回数リセットボタン
                ElevatedButton.icon(
                  onPressed: _resetAIUsage,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.general_072d6e04),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // オンボーディングリセットボタン
                ElevatedButton.icon(
                  onPressed: _resetOnboarding,
                  icon: const Icon(Icons.school),
                  label: Text(AppLocalizations.of(context)!.general_3d79955d),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Phase 1機能全リセットボタン
                ElevatedButton.icon(
                  onPressed: _resetAllPhase1Features,
                  icon: const Icon(Icons.delete_forever),
                  label: Text(AppLocalizations.of(context)!.general_d5890bfa),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // リセット後の説明
                Card(
                  color: Colors.red.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      '⚠️ Phase 1リセット後は必ずアプリを再起動してください\n'
                      AppLocalizations.of(context)!.sets
                      AppLocalizations.of(context)!.generatedKey_5657d91f
                      AppLocalizations.of(context)!.generatedKey_9c5698dd
                      AppLocalizations.of(context)!.general_48d1e7eb,
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 使い方ガイド
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.workout_9e8d8121,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.generatedKey_91c9449a
                          AppLocalizations.of(context)!.generatedKey_734a59b9
                          AppLocalizations.of(context)!.generatedKey_a0b3c8d7
                          AppLocalizations.of(context)!.general_d423a462,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // _buildPlanButton関数は削除（Apple審査対応）
  // プラン変更機能を完全に無効化しました

  Widget _getPlanBadge(SubscriptionType plan) {
    final color = switch (plan) {
      SubscriptionType.free => Colors.grey,
      SubscriptionType.premium => Colors.blue,
      SubscriptionType.pro => Colors.deepPurple,
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        switch (plan) {
          SubscriptionType.free => 'FREE',
          SubscriptionType.premium => 'PREMIUM',
          SubscriptionType.pro => 'PRO',
        },
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

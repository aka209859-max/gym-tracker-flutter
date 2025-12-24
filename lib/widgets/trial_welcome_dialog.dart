import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/settings/trial_progress_screen.dart';

import 'package:gym_match/gen/app_localizations.dart';
/// 無料トライアル案内ダイアログ
/// 
/// アプリ初回起動時に表示
/// トライアル条件と特典を案内
class TrialWelcomeDialog extends StatelessWidget {
  const TrialWelcomeDialog({super.key});

  /// 初回起動チェック＆ダイアログ表示
  /// 
  /// ⚠️ 注意: 7日間トライアルは廃止されました
  /// 新システム: 乗り換え割キャンペーン（SNSシェアで無料）
  /// このダイアログは表示されません
  static Future<void> showIfFirstLaunch(BuildContext context) async {
    // 7日間トライアルシステムは廃止
    // 乗り換え割キャンペーン（SNSシェア）に移行済み
    // このダイアログは表示しない
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー（グラデーション背景）
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.celebration,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppLocalizations.of(context)!.subscription_e1e85327,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.subscription_55b8a61a,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              // コンテンツ
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // トライアル特典タイトル
                    Row(
                      children: [
                        Icon(Icons.card_giftcard, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          AppLocalizations.of(context)!.subscription_2c0c51fb,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // トライアル条件カード
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                AppLocalizations.of(context)!.subscription_1d16adbb,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            AppLocalizations.of(context)!.subscription_3dd87f02,
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          _buildConditionItem('1. プロフィール設定を完了'),
                          _buildConditionItem(AppLocalizations.of(context)!.subscription_f50d3215),
                          _buildConditionItem(AppLocalizations.of(context)!.subscription_2ae35955),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // プレミアム特典リスト
                    const Text(
                      AppLocalizations.of(context)!.subscription_a2e75082,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem(AppLocalizations.of(context)!.subscription_a1d7b68f),
                    _buildBenefitItem(AppLocalizations.of(context)!.subscription_87af865e),
                    _buildBenefitItem(AppLocalizations.of(context)!.subscription_3a23222d),
                    _buildBenefitItem(AppLocalizations.of(context)!.subscription_823a5d48),
                    _buildBenefitItem(AppLocalizations.of(context)!.subscription_715332a5),
                    const SizedBox(height: 16),
                    
                    // 注意事項
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.subscription_b2159b40,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // ボタン
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrialProgressScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          AppLocalizations.of(context)!.subscription_f9d161bd,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.subscription_441ff03f),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

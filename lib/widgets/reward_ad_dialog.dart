import 'package:flutter/material.dart';
import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/reward_ad_service.dart';
import '../services/ai_credit_service.dart';

/// リワード動画広告ダイアログ
/// 
/// 機能:
/// - 無料ユーザーがAI機能を使用する際に表示
/// - 動画視聴完了でAIクレジット1回分付与
/// - CEO戦略: 月3回まで視聴可能（これ以上は有料プランへ誘導）
class RewardAdDialog extends StatefulWidget {
  const RewardAdDialog({super.key});

  @override
  State<RewardAdDialog> createState() => _RewardAdDialogState();
}

class _RewardAdDialogState extends State<RewardAdDialog> {
  final RewardAdService _adService = RewardAdService();
  final AICreditService _creditService = AICreditService();
  
  bool _isLoading = false;
  int _remainingAds = 3;

  @override
  void initState() {
    super.initState();
    _loadRemainingAds();
  }

  Future<void> _loadRemainingAds() async {
    // canEarnCreditFromAdを使って残り回数を計算
    final canEarn = await _creditService.canEarnCreditFromAd();
    if (!canEarn) {
      setState(() {
        _remainingAds = 0;
      });
    } else {
      // 正確な残り回数を取得するため、SharedPreferencesを直接読む
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final currentMonth = '${now.year}-${now.month}';
      final lastResetDate = prefs.getString('ai_credit_last_reset_date');
      
      // 月が変わったらリセット
      int earned = 0;
      if (lastResetDate == currentMonth) {
        earned = prefs.getInt('ai_credit_count_earned_count') ?? 0;
      }
      
      setState(() {
        _remainingAds = 3 - earned;
      });
    }
  }

  Future<void> _watchAd() async {
    setState(() {
      _isLoading = true;
    });

    // Web環境の場合はモック広告（テスト用）
    if (kIsWeb) {
      debugPrint(AppLocalizations.of(context)!.general_80e87040);
      await Future.delayed(const Duration(seconds: 2)); // 広告視聴をシミュレート
      
      // クレジット付与
      await _creditService.addAICredit(1);
      await _creditService.recordAdEarned();
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        Navigator.of(context).pop(true); // trueを返して成功を通知
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ AIクレジット1回分を獲得しました！（テストモード）'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // モバイル環境: 実際のAdMob広告
    // 広告が読み込まれていなければ読み込む
    if (!_adService.isAdReady()) {
      await _adService.loadRewardedAd();
      
      // 広告読み込み失敗チェック
      if (!_adService.isAdReady()) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppLocalizations.of(context)!.error_6a111b24),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // 広告表示
    final success = await _adService.showRewardedAd();

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // 広告視聴成功
      if (mounted) {
        Navigator.of(context).pop(true); // trueを返して成功を通知
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ AIクレジット1回分を獲得しました！'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // 広告表示失敗
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppLocalizations.of(context)!.error_31ac752d),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.play_circle, color: Colors.red[600], size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              AppLocalizations.of(context)!.general_bc95e298,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kIsWeb
                ? AppLocalizations.of(context)!.generatedKey_5db1bca7
                : AppLocalizations.of(context)!.general_a6551e30,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.generatedKey_54f0f5d8,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                if (_remainingAds == 0) ...[
                  const SizedBox(height: 8),
                  const Text(
                    AppLocalizations.of(context)!.general_d3b805fc,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppLocalizations.of(context)!.generatedKey_ee3d2398,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.buttonCancel),
        ),
        ElevatedButton(
          onPressed: _isLoading || _remainingAds == 0 ? null : _watchAd,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(AppLocalizations.of(context)!.general_3968b846),
        ),
      ],
    );
  }
}

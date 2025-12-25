import 'package:flutter/material.dart';
import 'confetti_animation.dart';

import 'package:gym_match/gen/app_localizations.dart';
/// 紹介成功ダイアログ（v1.02強化版）
/// 
/// 紹介コード適用時・友達が参加した時に表示
class ReferralSuccessDialog {
  /// 紹介コード入力成功ダイアログ（被紹介者用）
  static void showRefereeSuccess(
    BuildContext context, {
    required int aiBonus,
    required int premiumDays,
  }) {
    // 紙吹雪アニメーション表示
    ConfettiAnimation.show(context);

    // 成功ダイアログ表示
    Future.delayed(Duration(milliseconds: 500), () {
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.celebration,
                color: Colors.orange,
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.general_85d1b5d2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.general_31ec114c,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.general_e1cf09e4,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildBonusItem(
                      icon: Icons.smart_toy,
                      title: AppLocalizations.of(context)!.aiCoaching,
                      value: AppLocalizations.of(context)!.reps,
                      description: AppLocalizations.of(context)!.general_ffe34333,
                    ),
                    SizedBox(height: 8),
                    _buildBonusItem(
                      icon: Icons.workspace_premium,
                      title: AppLocalizations.of(context)!.general_7db414f2,
                      value: AppLocalizations.of(context)!.generatedKey_1397c615,
                      description: AppLocalizations.of(context)!.general_9b63b1e6,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                '💪 今すぐトレーニングを記録して、AIコーチングを試してみましょう！',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.general_81e13f3b,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 紹介成功ダイアログ（紹介者用）
  static void showReferrerSuccess(
    BuildContext context, {
    required int aiBonus,
    required int premiumDays,
    required String friendName,
  }) {
    // 紙吹雪アニメーション表示
    ConfettiAnimation.show(context);

    // 成功ダイアログ表示
    Future.delayed(Duration(milliseconds: 500), () {
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.celebration,
                color: Colors.green,
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.general_99c96084,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.generatedKey_32518a63,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.generatedKey_3efd8f7d,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildBonusItem(
                      icon: Icons.smart_toy,
                      title: AppLocalizations.of(context)!.aiCoaching,
                      value: AppLocalizations.of(context)!.reps,
                      description: AppLocalizations.of(context)!.general_89a02b48,
                    ),
                    SizedBox(height: 8),
                    _buildBonusItem(
                      icon: Icons.workspace_premium,
                      title: AppLocalizations.of(context)!.general_7db414f2,
                      value: AppLocalizations.of(context)!.generatedKey_1397c615,
                      description: AppLocalizations.of(context)!.general_9b63b1e6,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.general_8b3d7068,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.general_26e67e1a),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 紹介画面に遷移
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.general_d3c89caa,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// ボーナスアイテムWidget
  static Widget _buildBonusItem({
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange.shade700, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

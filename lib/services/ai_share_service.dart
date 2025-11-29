// lib/services/ai_share_service.dart
// AI分析結果SNSシェアサービス（簡易版）

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// AI分析結果をSNSシェアするサービス
class AIShareService {
  /// AI成長予測結果をシェア
  /// 
  /// [context] BuildContext
  /// [predictionData] 成長予測データ
  Future<void> shareGrowthPrediction(
    BuildContext context,
    Map<String, dynamic> predictionData,
  ) async {
    try {
      final currentWeight = predictionData['currentWeight'] as double? ?? 0;
      final predictedWeight = predictionData['predictedWeight'] as double? ?? 0;
      final growthPercentage = predictionData['growthPercentage'] as int? ?? 0;
      
      final shareText = '''
🏋️ GYM MATCH - AI成長予測結果

💪 現在の1RM: ${currentWeight.round()}kg
📈 4ヶ月後の予測: ${predictedWeight.round()}kg
🔥 成長率: +$growthPercentage%

GYM MATCHのAI科学的コーチングで
40本以上の論文に基づく科学的なトレーニング予測を取得しました！

#GYM_MATCH #筋トレ #AI #トレーニング #成長予測
''';

      await Share.share(shareText);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('シェアしました！ 📤'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error sharing growth prediction: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('シェアに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// トレーニング効果分析結果をシェア
  /// 
  /// [context] BuildContext
  /// [analysisData] 分析データ
  Future<void> shareTrainingAnalysis(
    BuildContext context,
    Map<String, dynamic> analysisData,
  ) async {
    try {
      final volumeStatus = analysisData['volumeAnalysis']?['status'] as String? ?? '適切';
      final frequencyStatus = analysisData['frequencyAnalysis']?['status'] as String? ?? '適切';
      final bodyPart = analysisData['bodyPart'] as String? ?? '';
      
      final shareText = '''
📊 GYM MATCH - トレーニング効果分析

対象部位: $bodyPart
📈 ボリューム評価: $volumeStatus
📅 頻度評価: $frequencyStatus

GYM MATCHのAI科学的コーチングで
トレーニング効果を科学的に分析しました！

#GYM_MATCH #筋トレ #AI #トレーニング分析
''';

      await Share.share(shareText);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('シェアしました！ 📤'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error sharing training analysis: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('シェアに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

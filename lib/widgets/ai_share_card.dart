// lib/widgets/ai_share_card.dart
// AI分析結果SNSシェア用カード

import 'package:flutter/material.dart';

/// AI分析結果をSNSシェア用に美しく表示するカード
class AIShareCard extends StatelessWidget {
  final String title;
  final String analysisType;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const AIShareCard({
    super.key,
    required this.title,
    required this.analysisType,
    required this.data,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade700,
            Colors.purple.shade500,
            Colors.pink.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー: GYM MATCHロゴ
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GYM MATCH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.general_AI科学的トレーニングコーチ,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // タイトル
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            analysisType,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          
          // データ表示
          ..._buildDataWidgets(),
          
          const SizedBox(height: 20),
          
          // フッター: 日付とブランディング
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${timestamp.year}/${timestamp.month}/${timestamp.day}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const Text(
                  '📱 App Store で入手',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// データウィジェットを構築
  List<Widget> _buildDataWidgets() {
    if (analysisType == 'growth_prediction') {
      return _buildGrowthPredictionWidgets();
    } else if (analysisType == 'training_analysis') {
      return _buildTrainingAnalysisWidgets();
    }
    return [];
  }

  /// 成長予測用ウィジェット
  List<Widget> _buildGrowthPredictionWidgets() {
    final currentWeight = data['currentWeight'] as double? ?? 0;
    final predictedWeight = data['predictedWeight'] as double? ?? 0;
    final growthPercentage = data['growthPercentage'] as int? ?? 0;
    
    return [
      // 現在のRM
      _buildStatRow(
        icon: Icons.straighten,
        label: AppLocalizations.of(context)!.general_現在の1RM,
        value: '${currentWeight.round()}kg',
      ),
      const SizedBox(height: 12),
      
      // 予測RM
      _buildStatRow(
        icon: Icons.trending_up,
        label: AppLocalizations.of(context)!.fourMonthPrediction,
        value: '${predictedWeight.round()}kg',
        highlighted: true,
      ),
      const SizedBox(height: 12),
      
      // 成長率
      _buildStatRow(
        icon: Icons.show_chart,
        label: AppLocalizations.of(context)!.general_成長率,
        value: '+$growthPercentage%',
        highlighted: true,
      ),
    ];
  }

  /// トレーニング分析用ウィジェット
  List<Widget> _buildTrainingAnalysisWidgets() {
    final volumeStatus = data['volumeAnalysis']?['status'] as String? ?? AppLocalizations.of(context)!.general_適切;
    final frequencyStatus = data['frequencyAnalysis']?['status'] as String? ?? AppLocalizations.of(context)!.general_適切;
    
    return [
      // ボリューム評価
      _buildStatRow(
        icon: Icons.fitness_center,
        label: AppLocalizations.of(context)!.general_トレーニングボリューム,
        value: volumeStatus,
      ),
      const SizedBox(height: 12),
      
      // 頻度評価
      _buildStatRow(
        icon: Icons.calendar_today,
        label: AppLocalizations.of(context)!.general_トレーニング頻度,
        value: frequencyStatus,
      ),
    ];
  }

  /// 統計行を構築
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlighted = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: highlighted
                ? Colors.amber.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: highlighted ? Colors.amber : Colors.white70,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlighted ? Colors.amber : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

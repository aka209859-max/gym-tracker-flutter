/// 🔬 トレーニング効果分析画面
/// 
/// ユーザーのトレーニング履歴を分析し、
/// 最適なボリューム・頻度・回復時間を提案する画面
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/training_analysis_service.dart';
import '../../services/subscription_service.dart';
import '../../services/advanced_fatigue_service.dart';
import '../../services/scientific_database.dart';
import '../../widgets/scientific_citation_card.dart';
import '../../screens/subscription_screen.dart';
import '../../screens/personal_factors_screen.dart';
import '../../screens/body_measurement_screen.dart';

/// トレーニング効果分析画面
class TrainingEffectAnalysisScreen extends StatefulWidget {
  const TrainingEffectAnalysisScreen({super.key});

  @override
  State<TrainingEffectAnalysisScreen> createState() =>
      _TrainingEffectAnalysisScreenState();
}

class _TrainingEffectAnalysisScreenState
    extends State<TrainingEffectAnalysisScreen> {
  // フォーム入力値
  final _formKey = GlobalKey<FormState>();
  final _oneRMController = TextEditingController(text: '60');  // 🆕 v1.0.227
  String _selectedBodyPart = '大胸筋';
  String _selectedLevel = '初心者';
  int _currentSets = 12;
  int _currentFrequency = 2;
  String _selectedGender = '女性';
  int _selectedAge = 25;
  
  // 🆕 v1.0.227: 自動取得データ
  final AdvancedFatigueService _fatigueService = AdvancedFatigueService();
  bool _isDataLoaded = false;
  double? _latestBodyWeight; // 最新の体重

  // サンプル履歴データ（実際にはFirestoreから取得）
  final List<Map<String, dynamic>> _sampleHistory = [
    {'week': 4, 'weight': 62, 'sets': 12},
    {'week': 3, 'weight': 60, 'sets': 12},
    {'week': 2, 'weight': 60, 'sets': 12},
    {'week': 1, 'weight': 60, 'sets': 12},
  ];

  // 分析結果
  Map<String, dynamic>? _analysisResult;
  bool _isLoading = false;  // ✅ 修正: 初期状態はローディングなし

  @override
  void initState() {
    super.initState();
    // ✅ 修正: 自動実行を削除（ユーザーが実行ボタンを押したときのみAI機能を使用）
    // 問題：画面起動時に入力前のデータで1回消費していた
    // 🆕 v1.0.227: ユーザーデータを自動ロード
    _loadUserData();
  }
  
  @override
  void dispose() {
    _oneRMController.dispose();
    super.dispose();
  }
  
  /// 🆕 v1.0.227: ユーザーデータを自動ロード
  Future<void> _loadUserData() async {
    try {
      // 1. 個人要因設定から年齢を取得
      final profile = await _fatigueService.getUserProfile();
      
      // 2. 最新の体重を取得
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final weightSnapshot = await FirebaseFirestore.instance
            .collection('body_measurements')
            .where('user_id', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .limit(1)
            .get();
        
        if (weightSnapshot.docs.isNotEmpty) {
          _latestBodyWeight = weightSnapshot.docs.first.data()['weight'] as double?;
        }
      }
      
      if (mounted) {
        setState(() {
          _selectedAge = profile.age;
          _isDataLoaded = true;
        });
        
        // 体重が取得できた場合は通知
        if (_latestBodyWeight != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '体重 ${_latestBodyWeight!.toStringAsFixed(1)}kg、年齢 ${profile.age}歳 を自動入力しました',
                style: const TextStyle(fontSize: 13),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ ユーザーデータ読み込みエラー: $e');
      if (mounted) {
        setState(() {
          _isDataLoaded = true; // エラーでも続行
        });
      }
    }
  }

  // 選択肢
  final List<String> _bodyParts = [
    '大胸筋',
    '広背筋',
    '大腿四頭筋',
    '上腕二頭筋',
    '上腕三頭筋',
    '三角筋',
  ];
  final List<String> _levels = ['初心者', '中級者', '上級者'];

  /// 効果分析を実行
  Future<void> _executeAnalysis() async {
    if (!_formKey.currentState!.validate()) return;
    
    // 🆕 v1.0.227: 体重が取得できていない場合はエラー
    if (_latestBodyWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('体重データが見つかりません。先に体重を記録してください。'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '記録する',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BodyMeasurementScreen(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    // 🔒 課金チェック: AI機能はプレミアム以上
    final subscriptionService = SubscriptionService();
    final hasAIAccess = await subscriptionService.isAIFeatureAvailable();
    
    if (!hasAIAccess) {
      // 無料プランユーザーは課金画面へ誘導
      if (mounted) {
        _showUpgradeDialog();
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // 🔢 AI使用回数チェック
    final canUseAI = await subscriptionService.canUseAIFeature();
    if (!canUseAI) {
      if (mounted) {
        final usageStatus = await subscriptionService.getAIUsageStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(usageStatus), backgroundColor: Colors.orange),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      print('🚀 効果分析開始...');
      
      // 🆕 v1.0.227: Weight Ratioによる客観的レベル判定
      final declaredLevel = _selectedLevel; // ユーザーが選択したレベル
      final oneRM = double.parse(_oneRMController.text);
      final bodyWeight = _latestBodyWeight!;
      
      final objectiveLevel = ScientificDatabase.detectLevelFromWeightRatio(
        oneRM: oneRM,
        bodyWeight: bodyWeight,
        exerciseName: _selectedBodyPart,
        gender: _selectedGender,
      );
      
      // 🆕 客観レベルを優先
      final finalLevel = objectiveLevel;
      
      // 🆕 申告レベルと客観レベルに乖離がある場合、ユーザーに通知
      if (declaredLevel != objectiveLevel) {
        final weightRatio = (oneRM / bodyWeight).toStringAsFixed(2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Weight Ratio ${weightRatio}倍から判定: 実際のレベルは「$objectiveLevel」です。\nより正確な分析のため、このレベルで計算します。',
              style: const TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 6),
          ),
        );
        // 判定結果を反映するために少し待つ
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final result = await TrainingAnalysisService.analyzeTrainingEffect(
        bodyPart: _selectedBodyPart,
        level: finalLevel,  // 🆕 客観レベルを使用
        currentSetsPerWeek: _currentSets,
        currentFrequency: _currentFrequency,
        recentHistory: _sampleHistory,
        gender: _selectedGender,
        age: _selectedAge,  // 個人要因設定から自動取得
      );
      print('✅ 効果分析完了: ${result['success']}');

      // ✅ AI使用回数をインクリメント
      await subscriptionService.incrementAIUsage();
      print('✅ AI使用回数: ${await subscriptionService.getCurrentMonthAIUsage()}');

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 効果分析例外: $e');
      if (mounted) {
        setState(() {
          _analysisResult = {
            'success': false,
            'error': '分析に失敗しました: $e',
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニング効果分析'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ヘッダー
                _buildHeader(),
                const SizedBox(height: 24),

                // 入力フォーム
                _buildInputForm(),
                const SizedBox(height: 24),

                // 分析実行ボタン
                _buildAnalyzeButton(),
                const SizedBox(height: 32),

                // 分析結果
                if (_isLoading)
                  _buildLoadingIndicator()
                else if (_analysisResult != null)
                  _buildAnalysisResult(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ヘッダー
  Widget _buildHeader() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.analytics, size: 40, color: Colors.purple.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'トレーニング効果分析',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '最適なボリューム・頻度・回復時間を提案',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 入力フォーム
  Widget _buildInputForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '現在のトレーニング情報',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 対象部位
            _buildDropdownField(
              label: '対象部位',
              value: _selectedBodyPart,
              items: _bodyParts,
              onChanged: (value) {
                setState(() {
                  _selectedBodyPart = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 🆕 v1.0.227: 現在の1RM（Weight Ratio計算用）
            TextFormField(
              controller: _oneRMController,
              decoration: const InputDecoration(
                labelText: '現在の1RM（kg）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '1RMを入力してください';
                }
                final weight = double.tryParse(value);
                if (weight == null) {
                  return '数値を入力してください';
                }
                if (weight <= 0) {
                  return '1kg以上を入力してください';
                }
                if (weight > 500) {
                  return '500kg以下を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // トレーニングレベル
            _buildDropdownField(
              label: 'トレーニングレベル',
              value: _selectedLevel,
              items: _levels,
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 週あたりセット数
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderField(
                  label: 'この部位の週あたりセット数',
                  value: _currentSets.toDouble(),
                  min: 4,
                  max: 24,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() {
                      _currentSets = value.toInt();
                    });
                  },
                  displayValue: '${_currentSets}セット',
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '※ $_selectedBodyPart のトレーニングで週に実施する総セット数',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // トレーニング頻度
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderField(
                  label: 'この部位のトレーニング頻度',
                  value: _currentFrequency.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  onChanged: (value) {
                    setState(() {
                      _currentFrequency = value.toInt();
                    });
                  },
                  displayValue: '週${_currentFrequency}回',
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '※ $_selectedBodyPart を週に何回トレーニングするか',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 性別
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('男性'),
                    value: '男性',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('女性'),
                    value: '女性',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🆕 v1.0.227: 年齢表示（編集不可、個人要因設定へのリンク）
            _buildAgeDisplayWithLink(),
            const SizedBox(height: 16),
            
            // 🆕 v1.0.227: 体重表示（自動取得、Weight Ratio計算用）
            if (_latestBodyWeight != null)
              _buildBodyWeightDisplay(),
          ],
        ),
      ),
    );
  }

  /// 🆕 v1.0.227: 年齢表示 + 個人要因設定へのリンク
  Widget _buildAgeDisplayWithLink() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.cake, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '年齢',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${_selectedAge}歳',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // 個人要因設定画面へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalFactorsScreen(),
                ),
              ).then((_) {
                // 戻ってきたらデータをリロード
                _loadUserData();
              });
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text(
              '変更',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 🆕 v1.0.227: 体重表示（自動取得）
  Widget _buildBodyWeightDisplay() {
    final weightRatio = _oneRMController.text.isNotEmpty 
        ? (double.tryParse(_oneRMController.text) ?? 0) / _latestBodyWeight!
        : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.monitor_weight, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '体重（最新記録から自動取得）',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${_latestBodyWeight!.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (weightRatio > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Weight Ratio: ${weightRatio.toStringAsFixed(2)}倍',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // 体重記録画面へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BodyMeasurementScreen(),
                ),
              ).then((_) {
                // 戻ってきたらデータをリロード
                _loadUserData();
              });
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text(
              '更新',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// ドロップダウンフィールド
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  /// スライダーフィールド
  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// 分析実行ボタン
  Widget _buildAnalyzeButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _executeAnalysis,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics),
          SizedBox(width: 8),
          Text('効果分析を実行'),
        ],
      ),
    );
  }

  /// ローディングインジケーター
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('トレーニング効果を分析中...'),
        ],
      ),
    );
  }

  /// 分析結果表示
  Widget _buildAnalysisResult() {
    // nullチェック
    if (_analysisResult == null) {
      return Card(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('分析結果がありません'),
        ),
      );
    }

    // エラーチェック
    if (_analysisResult!['success'] != true) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    '分析エラー',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _analysisResult!['error']?.toString() ?? '不明なエラーが発生しました',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ),
        ),
      );
    }

    // 必須フィールドの存在チェック
    if (!_analysisResult!.containsKey('volumeAnalysis') ||
        !_analysisResult!.containsKey('frequencyAnalysis')) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '分析データが不完全です。もう一度お試しください。',
            style: TextStyle(color: Colors.orange.shade900),
          ),
        ),
      );
    }

    final volumeAnalysis = _analysisResult!['volumeAnalysis'] as Map<String, dynamic>;
    final frequencyAnalysis = _analysisResult!['frequencyAnalysis'] as Map<String, dynamic>;
    final plateauDetected = _analysisResult!['plateauDetected'] as bool;
    final growthTrend = _analysisResult!['growthTrend'] as Map<String, dynamic>;
    final recommendations = _analysisResult!['recommendations'] as List;
    final basis = _analysisResult!['scientificBasis'] as List;
    final aiAnalysis = _analysisResult!['aiAnalysis'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ステータスサマリー
        _buildStatusSummary(volumeAnalysis, frequencyAnalysis, plateauDetected, growthTrend),
        const SizedBox(height: 16),

        // ボリューム分析
        _buildVolumeAnalysis(volumeAnalysis),
        const SizedBox(height: 16),

        // 頻度分析
        _buildFrequencyAnalysis(frequencyAnalysis),
        const SizedBox(height: 16),

        // プラトー警告
        if (plateauDetected) ...[
          _buildPlateauWarning(),
          const SizedBox(height: 16),
        ],

        // 推奨アクション
        _buildRecommendations(recommendations),
        const SizedBox(height: 16),

        // AI分析
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.purple.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'AI詳細分析',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormattedText(aiAnalysis),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 科学的根拠
        ScientificBasisSection(
          basis: basis.cast<Map<String, String>>(),
        ),
        const SizedBox(height: 8),

        // 信頼度インジケーター
        Center(
          child: ConfidenceIndicator(paperCount: basis.length),
        ),
      ],
    );
  }

  /// ステータスサマリー
  Widget _buildStatusSummary(
    Map<String, dynamic> volume,
    Map<String, dynamic> frequency,
    bool plateau,
    Map<String, dynamic> trend,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    if (plateau) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusMessage = 'プラトー検出：改善が必要';
    } else if (volume['status'] == 'optimal' && frequency['status'] == 'optimal') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusMessage = '最適なトレーニング中';
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.info;
      statusMessage = '改善の余地あり';
    }

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            const SizedBox(height: 12),
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              trend['message'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ボリューム分析
  Widget _buildVolumeAnalysis(Map<String, dynamic> analysis) {
    Color statusColor;
    switch (analysis['status']) {
      case 'optimal':
        statusColor = Colors.green;
        break;
      case 'insufficient':
      case 'suboptimal':
        statusColor = Colors.orange;
        break;
      case 'excessive':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: statusColor),
                const SizedBox(width: 8),
                const Text(
                  'ボリューム分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVolumeBar(
              current: analysis['currentSets'],
              min: analysis['minSets'],
              optimal: analysis['optimalSets'],
              max: analysis['maxSets'],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                analysis['advice'],
                style: TextStyle(
                  fontSize: 13,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ボリュームバー
  Widget _buildVolumeBar({
    required int current,
    required int min,
    required int optimal,
    required int max,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('最小: ${min}'),
            Text('最適: $optimal', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('最大: ${max}'),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // 背景バー
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            // 最適範囲
            FractionallySizedBox(
              widthFactor: (max - min) / max,
              alignment: Alignment.centerLeft,
              child: Container(
                height: 32,
                margin: EdgeInsets.only(left: (min / max * 100).toDouble()),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // 現在値
            FractionallySizedBox(
              widthFactor: current / max,
              alignment: Alignment.centerLeft,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '現在: ${current}セット',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 頻度分析
  Widget _buildFrequencyAnalysis(Map<String, dynamic> analysis) {
    Color statusColor;
    switch (analysis['status']) {
      case 'optimal':
        statusColor = Colors.green;
        break;
      case 'low':
        statusColor = Colors.orange;
        break;
      case 'high':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: statusColor),
                const SizedBox(width: 8),
                const Text(
                  '頻度分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFrequencyItem(
                  '現在',
                  analysis['currentFrequency'],
                  Colors.blue,
                ),
                Icon(Icons.arrow_forward, color: Colors.grey.shade400),
                _buildFrequencyItem(
                  '推奨',
                  analysis['recommendedFrequency'],
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                analysis['advice'],
                style: TextStyle(
                  fontSize: 13,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 頻度アイテム
  Widget _buildFrequencyItem(String label, int frequency, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            '週${frequency}回',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// プラトー警告
  Widget _buildPlateauWarning() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning, size: 40, color: Colors.orange.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プラトー期を検出',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '4週間成長が停滞しています。プログラム変更を推奨します。',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 推奨アクション
  Widget _buildRecommendations(List recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Text(
                  '推奨アクション',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) {
              final recMap = rec as Map<String, dynamic>;
              Color priorityColor;
              switch (recMap['priority']) {
                case 'high':
                  priorityColor = Colors.red;
                  break;
                case 'medium':
                  priorityColor = Colors.orange;
                  break;
                default:
                  priorityColor = Colors.blue;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recMap['category'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          recMap['basis'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recMap['action'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Markdownテキストのフォーマット
  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.trim().startsWith('##')) {
        final heading = line.replaceFirst(RegExp(r'^##\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              heading,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        );
      } else {
        String processedLine = line;
        if (processedLine.trim().startsWith('*')) {
          processedLine = processedLine.replaceFirst(RegExp(r'^\*\s*'), '・');
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              processedLine,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  /// 🔒 アップグレードダイアログ表示
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8),
            Text('プレミアム機能'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI効果分析はプレミアムプラン以上でご利用いただけます。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '✨ プレミアムプランの特典:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• AI成長予測（3ヶ月先の重量予測）'),
            Text('• AI効果分析（科学的根拠付き）'),
            Text('• トレーニングパートナー検索'),
            SizedBox(height: 16),
            Text(
              '月額 ¥980',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // サブスクリプション画面へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            child: const Text('プランを見る'),
          ),
        ],
      ),
    );
  }
}

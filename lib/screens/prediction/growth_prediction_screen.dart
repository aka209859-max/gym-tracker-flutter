/// 📈 AI成長予測画面
/// 
/// ユーザーの筋力成長を科学的根拠に基づいて予測し、
/// グラフと信頼区間で視覚化する画面
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/ai_prediction_service.dart';
import '../../services/subscription_service.dart';
import '../../services/advanced_fatigue_service.dart';
import '../../services/scientific_database.dart';
import '../../widgets/scientific_citation_card.dart';
import '../../screens/subscription_screen.dart';
import '../../screens/personal_factors_screen.dart';
import '../../screens/body_measurement_screen.dart';

/// AI成長予測画面
class GrowthPredictionScreen extends StatefulWidget {
  const GrowthPredictionScreen({super.key});

  @override
  State<GrowthPredictionScreen> createState() => _GrowthPredictionScreenState();
}

class _GrowthPredictionScreenState extends State<GrowthPredictionScreen> {
  // フォーム入力値
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController(text: '60');
  String _selectedLevel = '初心者';
  int _selectedFrequency = 3;
  String _selectedGender = '女性';
  int _selectedAge = 25;
  String _selectedBodyPart = '大胸筋';
  int _selectedRPE = 8; // 🆕 v1.0.228: RPE（自覚的強度、デフォルト8）

  // 予測結果
  Map<String, dynamic>? _predictionResult;
  bool _isLoading = false;  // ✅ 修正: 初期状態はローディングなし
  
  // 🆕 v1.0.227: 自動取得データ
  final AdvancedFatigueService _fatigueService = AdvancedFatigueService();
  bool _isDataLoaded = false;
  double? _latestBodyWeight; // 最新の体重

  // レベル選択肢
  final List<String> _levels = ['初心者', '中級者', '上級者'];

  // 部位選択肢
  final List<String> _bodyParts = [
    '大胸筋',
    '広背筋',
    '大腿四頭筋',
    '上腕二頭筋',
    '上腕三頭筋',
    '三角筋',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ 修正: 自動実行を削除（ユーザーが実行ボタンを押したときのみAI機能を使用）
    // 問題：画面起動時に入力前のデータで1回消費していた
    // 🆕 v1.0.227: ユーザーデータを自動ロード
    _loadUserData();
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

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  /// 成長予測を実行
  Future<void> _executePrediction() async {
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
      _predictionResult = null;
    });

    try {
      print('🚀 成長予測開始...');
      
      // 🆕 v1.0.227: Weight Ratioによる客観的レベル判定
      final declaredLevel = _selectedLevel; // ユーザーが選択したレベル
      final oneRM = double.parse(_weightController.text);
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
              'Weight Ratio ${weightRatio}倍から判定: 実際のレベルは「$objectiveLevel」です。\nより正確な予測のため、このレベルで計算します。',
              style: const TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 6),
          ),
        );
        // 判定結果を反映するために少し待つ
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final result = await AIPredictionService.predictGrowth(
        currentWeight: oneRM,
        level: finalLevel, // 🆕 客観レベルを使用
        frequency: _selectedFrequency,
        gender: _selectedGender,
        age: _selectedAge, // 個人要因設定から自動取得
        bodyPart: _selectedBodyPart,
        monthsAhead: 4,
        rpe: _selectedRPE, // 🆕 v1.0.228: RPE（自覚的強度）
      );
      print('✅ 成長予測完了: ${result['success']}');

      // ✅ AI使用回数をインクリメント
      await subscriptionService.incrementAIUsage();
      print('✅ AI使用回数: ${await subscriptionService.getCurrentMonthAIUsage()}');

      if (mounted) {
        setState(() {
          _predictionResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 成長予測例外: $e');
      if (mounted) {
        setState(() {
          _predictionResult = {
            'success': false,
            'error': '予測の生成に失敗しました: $e',
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
        title: const Text('AI成長予測'),
        backgroundColor: Colors.blue.shade700,
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

                // 予測実行ボタン
                _buildPredictButton(),
                const SizedBox(height: 32),

                // 予測結果
                if (_isLoading)
                  _buildLoadingIndicator()
                else if (_predictionResult != null)
                  _buildPredictionResult(),
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
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.timeline, size: 40, color: Colors.blue.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI成長予測',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '40本以上の論文に基づく科学的予測',
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
              'あなたの情報を入力',
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

            // 現在の1RM
            TextFormField(
              controller: _weightController,
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

            // トレーニング頻度
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderField(
                  label: 'この部位のトレーニング頻度',
                  value: _selectedFrequency.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value.toInt();
                    });
                  },
                  displayValue: '週${_selectedFrequency}回',
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '※ 選択した部位（$_selectedBodyPart）を週に何回トレーニングするか',
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

            // 🆕 v1.0.228: RPE（自覚的強度）スライダー
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderField(
                  label: '前回のトレーニングの強度（RPE）',
                  value: _selectedRPE.toDouble(),
                  min: 6,
                  max: 10,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() {
                      _selectedRPE = value.toInt();
                    });
                  },
                  displayValue: _getRPELabel(_selectedRPE),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _getRPEDescription(_selectedRPE),
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
    final weightRatio = _weightController.text.isNotEmpty 
        ? (double.tryParse(_weightController.text) ?? 0) / _latestBodyWeight!
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

  /// 予測実行ボタン
  Widget _buildPredictButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _executePrediction,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
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
          Icon(Icons.auto_graph),
          SizedBox(width: 8),
          Text('AI予測を実行'),
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
          Text('AI予測を生成中...'),
        ],
      ),
    );
  }

  /// 予測結果表示
  Widget _buildPredictionResult() {
    // nullチェック
    if (_predictionResult == null) {
      return Card(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('予測結果がありません'),
        ),
      );
    }

    // エラーチェック
    if (_predictionResult!['success'] != true) {
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
                    '予測エラー',
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
                _predictionResult!['error']?.toString() ?? '不明なエラーが発生しました',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ),
        ),
      );
    }

    // 必須フィールドの存在チェック
    if (!_predictionResult!.containsKey('currentWeight') ||
        !_predictionResult!.containsKey('predictedWeight')) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '予測データが不完全です。もう一度お試しください。',
            style: TextStyle(color: Colors.orange.shade900),
          ),
        ),
      );
    }

    final current = _predictionResult!['currentWeight'];
    final predicted = _predictionResult!['predictedWeight'];
    final growth = _predictionResult!['growthPercentage'];
    final ci = _predictionResult!['confidenceInterval'];
    final basis = _predictionResult!['scientificBasis'] as List;
    final aiAnalysis = _predictionResult!['aiAnalysis'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 予測結果サマリー
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 48,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 16),
                const Text(
                  '4ヶ月後の予測',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${predicted.round()}kg',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '現在: ${current.round()}kg → +${growth}%の成長',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        '信頼区間: ${ci['lower'].round()}-${ci['upper'].round()}kg',
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
        ),
        const SizedBox(height: 16),

        // 簡易グラフ表示
        _buildSimpleChart(current, predicted, ci),
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

  /// 簡易グラフ表示
  Widget _buildSimpleChart(double current, double predicted, Map ci) {
    final maxValue = ci['upper'] * 1.1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '成長予測グラフ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 現在値
            _buildChartBar('現在', current, maxValue, Colors.blue),
            const SizedBox(height: 12),
            // 予測値
            _buildChartBar('4ヶ月後', predicted, maxValue, Colors.green),
            const SizedBox(height: 12),
            // 信頼区間上限
            _buildChartBar('最大予測', ci['upper'], maxValue, Colors.green.shade200),
          ],
        ),
      ),
    );
  }

  /// グラフバー
  Widget _buildChartBar(String label, double value, double maxValue, Color color) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${value.round()}kg',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 24,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Markdownテキストのフォーマット
  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.trim().startsWith('##')) {
        // 見出し
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
        // 通常テキスト
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
              'AI成長予測はプレミアムプラン以上でご利用いただけます。',
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

  /// 🆕 v1.0.228: RPEラベルを取得
  String _getRPELabel(int rpe) {
    switch (rpe) {
      case 6:
      case 7:
        return 'RPE $rpe（余裕あり）';
      case 8:
      case 9:
        return 'RPE $rpe（適正）';
      case 10:
        return 'RPE $rpe（限界）';
      default:
        return 'RPE $rpe';
    }
  }

  /// 🆕 v1.0.228: RPE説明文を取得
  String _getRPEDescription(int rpe) {
    if (rpe <= 7) {
      return '※ まだ余裕があった場合、予測成長率を10%アップします';
    } else if (rpe >= 10) {
      return '※ 限界まで追い込んだ場合、過労を考慮して予測成長率を20%ダウンします';
    } else {
      return '※ 適正な強度でトレーニングできた場合、標準の成長率で予測します';
    }
  }
}

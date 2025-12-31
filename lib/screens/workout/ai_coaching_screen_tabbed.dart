import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 🎯 Phase 1追加
import 'package:gym_match/gen/app_localizations.dart'; // 🆕 v1.0.274: Multilingual support
import '../../services/ai_prediction_service.dart';
import '../../services/training_analysis_service.dart';
import '../../services/subscription_service.dart';
import '../../services/reward_ad_service.dart';
import '../../services/ai_credit_service.dart';
import '../../services/advanced_fatigue_service.dart'; // 🆕 Phase 7: 年齢取得用
import '../../services/scientific_database.dart'; // 🆕 Phase 7: レベル判定用
import '../../widgets/scientific_citation_card.dart';
import '../../widgets/paywall_dialog.dart';
import '../../main.dart'; // globalRewardAdService用
import '../../models/workout_log.dart'; // 🔧 v1.0.220: トレーニング履歴保存用
import '../personal_factors_screen.dart'; // 🔧 Phase 7 Fix: 個人要因設定画面
import '../body_measurement_screen.dart'; // 🔧 Phase 7 Fix: 体重記録画面

/// 🔧 v1.0.220: パース済み種目データ（AIコーチ提案メニュー用）
class ParsedExercise {
  final String name;
  final String bodyPart;
  final double? weight; // kg（筋トレ用）
  final int? reps; // 回数（筋トレ用）
  final int? sets; // セット数
  final String? description; // 初心者向け説明
  
  // 🔧 v1.0.237: 有酸素運動対応
  final bool isCardio; // 有酸素運動かどうか
  final double? distance; // 距離（km）（有酸素用）
  final int? duration; // 時間（分）（有酸素用）

  ParsedExercise({
    required this.name,
    required this.bodyPart,
    this.weight,
    this.reps,
    this.sets,
    this.description,
    this.isCardio = false, // デフォルトは筋トレ
    this.distance,
    this.duration,
  });
}

/// Layer 5: AIコーチング画面（統合版）
/// 
/// 機能:
/// - Tab 1: AIトレーニングメニュー提案（既存機能）
/// - Tab 2: AI成長予測（科学的根拠ベース）
/// - Tab 3: トレーニング効果分析
class AICoachingScreenTabbed extends StatefulWidget {
  final int initialTabIndex;

  const AICoachingScreenTabbed({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AICoachingScreenTabbed> createState() => _AICoachingScreenTabbedState();
}

class _AICoachingScreenTabbedState extends State<AICoachingScreenTabbed>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _autoLoginIfNeeded();
    
    // 🎯 Phase 1: AI初回利用時のガイド表示
    _showFirstTimeAIGuide();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 未ログイン時に自動的に匿名ログイン
  Future<void> _autoLoginIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint('✅ 匿名認証成功');
      } catch (e) {
        debugPrint('❌ 匿名認証エラー: $e');
      }
    }
  }
  
  /// 🎯 Phase 1: AI初回利用時のガイド
  Future<void> _showFirstTimeAIGuide() async {
    // UIが安定してから表示
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final hasSeenGuide = prefs.getBool('has_seen_ai_first_guide') ?? false;
    
    // 初回のみ表示
    if (hasSeenGuide) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アニメーションアイコン
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology,
                        size: 64,
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            
            // タイトル
            Text(AppLocalizations.of(context)!.aiFatigueAnalysisWelcome,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            
            // 説明
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideItem(
                  icon: Icons.analytics,
                  title: AppLocalizations.of(context)!.aiMenuScientificAnalysis,
                  description: AppLocalizations.of(context)!.workout_762fc148,
                ),
                SizedBox(height: 12),
                _buildGuideItem(
                  icon: Icons.auto_awesome,
                  title: AppLocalizations.of(context)!.workout_3f0bb9b4,
                  description: AppLocalizations.of(context)!.workout_369dbcbd,
                ),
                SizedBox(height: 12),
                _buildGuideItem(
                  icon: Icons.trending_up,
                  title: AppLocalizations.of(context)!.workout_e3e5061b,
                  description: AppLocalizations.of(context)!.workout_d373a48f,
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await prefs.setBool('has_seen_ai_first_guide', true);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.getStarted,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// ガイド項目Widget
  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.purple.shade600,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 設定メニューを表示
  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドル
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // タイトル
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.deepPurple.shade700),
                  SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.settingsMenu,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            // メニュー項目1: トレーニングメモ
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.note_alt,
                  color: Colors.blue.shade700,
                ),
              ),
              title: Text(AppLocalizations.of(context)!.trainingMemo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(AppLocalizations.of(context)!.pastTrainingRecords),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/workout-memo');
              },
            ),
            // メニュー項目2: 個人要因設定
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.purple.shade700,
                ),
              ),
              title: Text(AppLocalizations.of(context)!.personalFactorsSettings,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(AppLocalizations.of(context)!.editPersonalFactors),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/personal-factors');
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.aiCoaching)),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.aiCoaching)),
            body: Center(child: Text(AppLocalizations.of(context)!.loginError)),
          );
        }

        return _buildMainContent(user);
      },
    );
  }

  Widget _buildMainContent(User user) {
    return Scaffold(
        appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, size: 24),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.aiScientificCoaching),
          ],
        ),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsMenu,
            tooltip: AppLocalizations.of(context)!.settings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.fitness_center),
              text: AppLocalizations.of(context)!.workout_0185a259,
            ),
            Tab(
              icon: Icon(Icons.timeline),
              text: AppLocalizations.of(context)!.workout_fec3bf19,
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: AppLocalizations.of(context)!.aiEffectAnalysis,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: AIメニュー提案（既存機能）
          _AIMenuTab(user: user),
          // Tab 2: 成長予測
          _GrowthPredictionTab(),
          // Tab 3: 効果分析
          _EffectAnalysisTab(),
        ],
      ),
    );
  }
}

// ========================================
// Tab 1: AIメニュー提案タブ
// ========================================

class _AIMenuTab extends StatefulWidget {
  final User user;

  const _AIMenuTab({required this.user});

  @override
  State<_AIMenuTab> createState() => _AIMenuTabState();
}

class _AIMenuTabState extends State<_AIMenuTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 部位選択状態（有酸素追加）
  late final Map<String, bool> _selectedBodyParts;
  bool _selectedBodyPartsInitialized = false;
  
  // 🔧 v1.0.217: レベル選択（初心者・中級者・上級者）
  late String _selectedLevel; // デフォルトは初心者（didChangeDependenciesで初期化）

  // UI状態
  bool _isGenerating = false;
  String? _generatedMenu;
  String? _errorMessage;
  
  // 🔧 v1.0.217: トレーニング履歴データ
  Map<String, Map<String, dynamic>> _exerciseHistory = {}; // 種目名 → {maxWeight, max1RM, totalSets}
  bool _isLoadingWorkoutHistory = false;
  
  // 🔧 v1.0.220: パース済み種目データ（チェックボックス対応）
  List<ParsedExercise> _parsedExercises = [];
  Set<int> _selectedExerciseIndices = {}; // 選択された種目のインデックス

  // 履歴
  List<Map<String, dynamic>> _history = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    // 注: _selectedBodyParts の初期化は didChangeDependencies() で実行
    // （AppLocalizationsへのアクセスが必要なため）
    _loadHistory();
    _loadWorkoutHistory(); // 🔧 v1.0.217: トレーニング履歴を読み込む
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🔧 Phase 2 Fix: context依存の初期化はここで実行
    _selectedLevel = AppLocalizations.of(context)!.beginner;
    
    // 🔧 Build #24.1 Hotfix8: 部位選択状態を多言語で初期化（初期化フラグ使用）
    if (!_selectedBodyPartsInitialized) {
      _selectedBodyParts = {
        AppLocalizations.of(context)!.bodyPartChest: false,
        AppLocalizations.of(context)!.bodyPartBack: false,
        AppLocalizations.of(context)!.bodyPartLegs: false,
        AppLocalizations.of(context)!.bodyPartShoulders: false,
        AppLocalizations.of(context)!.bodyPartArms: false,
        AppLocalizations.of(context)!.bodyPart_ceb49fa1: false,
        AppLocalizations.of(context)!.exerciseCardio: false,
      };
      _selectedBodyPartsInitialized = true;
    }
  }

  /// 履歴読み込み
  Future<void> _loadHistory() async {
    if (mounted) {
    setState(() => _isLoadingHistory = true);
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('aiCoachingHistory')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      if (mounted) {
      setState(() {
        _history = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _isLoadingHistory = false;
      });
      }
    } catch (e) {
      debugPrint('❌ 履歴読み込みエラー: $e');
      if (mounted) {
      setState(() => _isLoadingHistory = false);
      }
    }
  }
  
  /// 🔧 v1.0.217: 直近1ヶ月のトレーニング履歴を読み込み、1RMを自動計算
  Future<void> _loadWorkoutHistory() async {
    if (mounted) {
    setState(() => _isLoadingWorkoutHistory = true);
    }
    
    try {
      // 1ヶ月前の日付
      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // workout_logsから直近1ヶ月のデータを取得
      final snapshot = await FirebaseFirestore.instance
          .collection('workout_logs')
          .where('user_id', isEqualTo: widget.user.uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(oneMonthAgo))
          .get();
      
      // 種目ごとに集計
      final Map<String, Map<String, dynamic>> exerciseData = {};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final sets = data['sets'] as List<dynamic>? ?? [];
        
        for (final set in sets) {
          if (set is! Map<String, dynamic>) continue;
          
          final exerciseName = set['exercise_name'] as String?;
          final weight = (set['weight'] as num?)?.toDouble();
          final reps = set['reps'] as int?;
          final isCompleted = set['is_completed'] as bool? ?? false;
          
          // 完了していないセットはスキップ
          if (!isCompleted || exerciseName == null || weight == null || reps == null) {
            continue;
          }
          
          // 1RM計算（Epley formula: 1RM = weight × (1 + reps / 30)）
          final calculated1RM = weight * (1 + reps / 30);
          
          // 種目データを更新
          if (!exerciseData.containsKey(exerciseName)) {
            exerciseData[exerciseName] = {
              'maxWeight': weight,
              'max1RM': calculated1RM,
              'totalSets': 1,
              'bestReps': reps,
            };
          } else {
            final current = exerciseData[exerciseName]!;
            exerciseData[exerciseName] = {
              'maxWeight': weight > (current['maxWeight'] as double) ? weight : current['maxWeight'],
              'max1RM': calculated1RM > (current['max1RM'] as double) ? calculated1RM : current['max1RM'],
              'totalSets': (current['totalSets'] as int) + 1,
              'bestReps': reps > (current['bestReps'] as int) ? reps : current['bestReps'],
            };
          }
        }
      }
      
      if (mounted) {
      setState(() {
        _exerciseHistory = exerciseData;
        _isLoadingWorkoutHistory = false;
      });
      }
      
      debugPrint('✅ トレーニング履歴読み込み完了: ${exerciseData.length}種目');
      for (final entry in exerciseData.entries) {
        debugPrint('   ${entry.key}: 最大重量=${entry.value['maxWeight']}kg, 1RM=${entry.value['max1RM']?.toStringAsFixed(1)}kg');
      }
    } catch (e) {
      debugPrint('❌ トレーニング履歴読み込みエラー: $e');
      if (mounted) {
      setState(() => _isLoadingWorkoutHistory = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 説明文
          _buildDescription(),
          SizedBox(height: 24),

          // 🔧 v1.0.217: レベル選択
          _buildLevelSelector(),
          SizedBox(height: 24),

          // 部位選択
          _buildBodyPartSelector(),
          SizedBox(height: 24),

          // メニュー生成ボタン
          _buildGenerateButton(),
          SizedBox(height: 24),

          // 生成結果表示
          if (_generatedMenu != null) ...[
            _buildGeneratedMenu(),
            SizedBox(height: 24),
          ],

          // エラー表示
          if (_errorMessage != null) ...[
            _buildErrorMessage(),
            SizedBox(height: 24),
          ],

          // 履歴表示
          _buildHistory(),
        ],
      ),
    );
  }

  /// 説明文
  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.aiPoweredTraining,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.workout_17f59b6a,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 🔧 v1.0.217: レベル選択セクション
  Widget _buildLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.workout_2dc1ee52,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLevelButton(AppLocalizations.of(context)!.levelBeginner, Icons.fitness_center, Colors.green),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildLevelButton(AppLocalizations.of(context)!.levelIntermediate, Icons.trending_up, Colors.orange),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildLevelButton(AppLocalizations.of(context)!.levelAdvanced, Icons.emoji_events, Colors.red),
            ),
          ],
        ),
      ],
    );
  }
  
  /// レベルボタン
  Widget _buildLevelButton(String level, IconData icon, Color color) {
    final isSelected = _selectedLevel == level;
    
    return Material(
      color: isSelected ? color : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (mounted) {
          setState(() {
            _selectedLevel = level;
          });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 28,
              ),
              SizedBox(height: 8),
              Text(
                level,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 部位選択セクション
  Widget _buildBodyPartSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.workout_478bc20c,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedBodyParts.keys.map((part) {
            final isSelected = _selectedBodyParts[part]!;
            final isBeginner = part == AppLocalizations.of(context)!.levelBeginner;

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBeginner) ...[
                    Icon(Icons.school, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                  ],
                  Text(part),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (mounted) {
                setState(() {
                  _selectedBodyParts[part] = selected;
                });
                }
              },
              selectedColor: isBeginner
                  ? Colors.green.shade100
                  : Colors.blue.shade100,
              checkmarkColor: isBeginner
                  ? Colors.green.shade700
                  : Colors.blue.shade700,
              backgroundColor: isBeginner ? Colors.green.shade50 : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// メニュー生成ボタン
  Widget _buildGenerateButton() {
    final selectedParts = _selectedBodyParts.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final isEnabled = selectedParts.isNotEmpty && !_isGenerating;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? () {
          FocusScope.of(context).unfocus();
          _generateMenu(selectedParts);
        } : null,
        icon: _isGenerating
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.auto_awesome),
        label: Text(_isGenerating ? AppLocalizations.of(context)!.aiThinking : AppLocalizations.of(context)!.generateMenu),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// 🔧 v1.0.220: 生成されたメニュー表示（チェックボックス付き）
  Widget _buildGeneratedMenu() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.workout_ba5c8bd5,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // 全選択/全解除ボタン
                    TextButton.icon(
                      onPressed: () {
                        if (mounted) {
                        setState(() {
                          if (_selectedExerciseIndices.length == _parsedExercises.length) {
                            _selectedExerciseIndices.clear();
                          } else {
                            _selectedExerciseIndices = Set.from(
                              List.generate(_parsedExercises.length, (i) => i)
                            );
                          }
                        });
                        }
                      },
                      icon: Icon(
                        _selectedExerciseIndices.length == _parsedExercises.length
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                      ),
                      label: Text(
                        _selectedExerciseIndices.length == _parsedExercises.length
                            ? AppLocalizations.of(context)!.workout_69593f57
                            : AppLocalizations.of(context)!.workout_219e609f,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.save),
                      onPressed: _saveMenu,
                      tooltip: AppLocalizations.of(context)!.saveWorkout,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 8),
            
            // 🔧 v1.0.220: パース済み種目リスト（チェックボックス付き）
            if (_parsedExercises.isNotEmpty) ...[
              ..._parsedExercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                final isSelected = _selectedExerciseIndices.contains(index);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected ? Colors.blue.shade50 : null,
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      if (mounted) {
                      setState(() {
                        if (value == true) {
                          _selectedExerciseIndices.add(index);
                        } else {
                          _selectedExerciseIndices.remove(index);
                        }
                      });
                      }
                    },
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getBodyPartColor(exercise.bodyPart),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            exercise.bodyPart,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        // 🔧 v1.0.237: 有酸素運動と筋トレで表示を分ける
                        if (exercise.isCardio) 
                          // 有酸素運動の表示: 距離/時間
                          Wrap(
                            spacing: 12,
                            children: [
                              if (exercise.distance != null && exercise.distance! > 0)
                                _buildInfoChip(Icons.straighten, '${exercise.distance}km'),
                              if (exercise.duration != null)
                                _buildInfoChip(Icons.timer, '${exercise.duration}${AppLocalizations.of(context)!.aiMenuMinutesSuffix}'),
                              if (exercise.sets != null)
                                _buildInfoChip(Icons.layers, '${exercise.sets}${AppLocalizations.of(context)!.aiMenuSetsSuffix}'),
                            ],
                          )
                        else
                          // 筋トレの表示: 重さ/回数
                          Wrap(
                            spacing: 12,
                            children: [
                              if (exercise.weight != null)
                                _buildInfoChip(Icons.fitness_center, '${exercise.weight}kg'),
                              if (exercise.reps != null)
                                _buildInfoChip(Icons.repeat, '${exercise.reps}${AppLocalizations.of(context)!.aiMenuRepsSuffix}'),
                              if (exercise.sets != null)
                                _buildInfoChip(Icons.layers, '${exercise.sets}${AppLocalizations.of(context)!.aiMenuSetsSuffix}'),
                            ],
                          ),
                        if (exercise.description != null) ...[
                          SizedBox(height: 6),
                          Text(
                            exercise.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              
              // 🔧 v1.0.222: トレーニングを開始ボタン（記録画面に遷移）
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedExerciseIndices.isEmpty
                      ? null
                      : _saveSelectedExercisesToWorkoutLog,
                  icon: Icon(Icons.fitness_center),
                  label: Text(
                    'トレーニングを開始 (${_selectedExerciseIndices.length}種目)',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
            ] else ...[
              // 🔧 v1.0.223-debug: パースに失敗した場合はエラーメッセージと生テキストを表示（デバッグ用）
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 48),
                      SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.aiMenuParseFailed,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.aiMenuParseFailedMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (mounted) {
                          setState(() {
                            _generatedMenu = null;
                            _parsedExercises.clear();
                            _errorMessage = null;
                          });
                          }
                        },
                        icon: Icon(Icons.refresh),
                        label: Text(AppLocalizations.of(context)!.aiMenuRetryButton),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      const Divider(),
                      SizedBox(height: 8),
                      // 🐛 デバッグ用: 生成されたテキストを表示
                      ExpansionTile(
                        title: Text(
                          AppLocalizations.of(context)!.aiMenuDebugTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.grey.shade100,
                            child: SelectableText(
                              _generatedMenu ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 🔧 v1.0.221: 部位別カラー取得（二頭・三頭対応）
  Color _getBodyPartColor(String bodyPart) {
    final l10n = AppLocalizations.of(context)!;
    
    if (bodyPart == AppLocalizations.of(context)!.bodyPartChest) {
      return Colors.red.shade400;
    } else if (bodyPart == AppLocalizations.of(context)!.bodyPartBack) {
      return Colors.blue.shade400;
    } else if (bodyPart == AppLocalizations.of(context)!.bodyPartLegs) {
      return Colors.green.shade400;
    } else if (bodyPart == AppLocalizations.of(context)!.bodyPartShoulders) {
      return Colors.orange.shade400;
    } else if (bodyPart == AppLocalizations.of(context)!.bodyPartBiceps) {
      return Colors.purple.shade400;
    } else if (bodyPart == AppLocalizations.of(context)!.bodyPartTriceps) {
      return Colors.deepPurple.shade400;
    } else if (bodyPart == '腕') { // 後方互換性
      return Colors.purple.shade300;
    } else if (bodyPart == AppLocalizations.of(context)!.bodyPart_ceb49fa1) {
      return Colors.teal.shade400;
    } else {
      return Colors.grey.shade400;
    }
  }
  
  /// 🔧 v1.0.220: 情報チップウィジェット
  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// エラーメッセージ表示
  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 履歴表示
  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.aiMenuHistoryTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        if (_isLoadingHistory)
          Center(child: CircularProgressIndicator())
        else if (_history.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(AppLocalizations.of(context)!.workout_355e6980),
              ),
            ),
          )
        else
          ..._history.map((item) => _buildHistoryItem(item)),
      ],
    );
  }

  /// 履歴アイテム
  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final bodyParts = (item['bodyParts'] as List<dynamic>?)?.join(', ') ?? '';
    final createdAt = (item['createdAt'] as Timestamp?)?.toDate();
    final menu = item['menu'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(bodyParts),
        subtitle: Text(
          createdAt != null
              ? '${createdAt.month}/${createdAt.day} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
              : '',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildFormattedText(menu),
          ),
        ],
      ),
    );
  }

  /// Markdown形式テキストをフォーマット済みウィジェットに変換
  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final List<InlineSpan> spans = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // 1. 見出し処理（## Text → 太字テキスト）
      if (line.trim().startsWith('##')) {
        final headingText = line.replaceFirst(RegExp(r'^##\s*'), '');
        spans.add(
          TextSpan(
            text: headingText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.8,
            ),
          ),
        );
        if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // 2. 箇条書き処理（* → ・）
      if (line.trim().startsWith('*')) {
        line = line.replaceFirst(RegExp(r'^\*\s*'), '・');
      }

      // 3. 太字処理（**text** → 太字）
      final boldPattern = RegExp(r'\*\*(.+?)\*\*');
      final matches = boldPattern.allMatches(line);

      if (matches.isEmpty) {
        // 太字なし → 通常テキスト
        spans.add(TextSpan(text: line));
      } else {
        // 太字あり → パースして分割
        int lastIndex = 0;
        for (final match in matches) {
          // 太字前のテキスト
          if (match.start > lastIndex) {
            spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
          }
          // 太字テキスト
          spans.add(
            TextSpan(
              text: match.group(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          lastIndex = match.end;
        }
        // 太字後のテキスト
        if (lastIndex < line.length) {
          spans.add(TextSpan(text: line.substring(lastIndex)));
        }
      }

      // 改行追加（最終行以外）
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
        children: spans,
      ),
    );
  }

  /// AIメニュー生成（サブスクリプションチェック統合）
  Future<void> _generateMenu(List<String> bodyParts) async {
    // ========================================
    // 🔐 Step 1: サブスクリプション状態チェック
    // ========================================
    final subscriptionService = SubscriptionService();
    final creditService = AICreditService();
    final rewardAdService = globalRewardAdService;
    
    final currentPlan = await subscriptionService.getCurrentPlan();
    debugPrint('🔍 [AI生成] 現在のプラン: $currentPlan');
    
    // ========================================
    // 🎯 Step 2: AI利用可能性チェック
    // ========================================
    final canUseAIResult = await creditService.canUseAI();
    debugPrint('🔍 [AI生成] AI使用可能: ${canUseAIResult.allowed}');
    
    if (!canUseAIResult.allowed) {
      // 無料プランでAIクレジットがない場合
      if (currentPlan == SubscriptionType.free) {
        // リワード広告で獲得可能かチェック
        final canEarnFromAd = await creditService.canEarnCreditFromAd();
        debugPrint('🔍 [AI生成] 広告視聴可能: $canEarnFromAd');
        
        if (canEarnFromAd) {
          // ========================================
          // 📺 Step 3: リワード広告ダイアログ表示
          // ========================================
          final shouldShowAd = await _showRewardAdDialog();
          
          if (shouldShowAd == true) {
            // 広告を表示してクレジット獲得
            final adSuccess = await _showRewardAdAndEarn();
            
            if (!adSuccess) {
              // 広告表示失敗
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.workout_9d662a8d),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
            // 広告視聴成功 → 下記のAI生成処理に進む
          } else {
            // ユーザーがキャンセル
            return;
          }
        } else {
          // 今月の広告視聴上限に達している
          if (mounted) {
            await _showUpgradeDialog(AppLocalizations.of(context)!.workout_2ee7735b);
          }
          return;
        }
      } else {
        // 有料プランで月次上限に達している
        if (mounted) {
          await _showUpgradeDialog(AppLocalizations.of(context)!.workout_1b17a3c8);
        }
        return;
      }
    }
    
    // ========================================
    // 🤖 Step 4: AI生成処理（クレジット消費含む）
    // ========================================
    if (mounted) {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedMenu = null;
    });
    }

    try {
      debugPrint('🤖 Gemini APIでメニュー生成開始: ${bodyParts.join(', ')}');

      // Gemini 2.0 Flash API呼び出し
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': _buildPrompt(bodyParts),
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3, // 🔧 v1.0.226: 一貫性のある出力のため低く設定
            'topK': 20,
            'topP': 0.85,
            'maxOutputTokens': 2048,
          }
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('AI menu generation request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // ========================================
        // ✅ Step 5: AI生成成功 → クレジット消費
        // ========================================
        final consumeSuccess = await creditService.consumeAICredit();
        debugPrint('✅ AIクレジット消費: $consumeSuccess');
        
        // 🔧 v1.0.223: メニューをパースして種目抽出
        debugPrint('📄 生成されたメニュー（最初の500文字）:\n${text.substring(0, text.length > 500 ? 500 : text.length)}');
        
        // ========================================
        // 🔄 Build #24.1 Hotfix10: 日本語生成→翻訳方式（種目DB互換性保持）
        // ========================================
        String finalMenu = text;
        final locale = AppLocalizations.of(context)!.localeName;
        
        if (locale != 'ja') {
          debugPrint('🌐 非日本語ユーザー検出（$locale）→ 翻訳開始');
          finalMenu = await _translateMenuToLanguage(text);
          debugPrint('✅ 翻訳完了: ${finalMenu.length}文字');
        } else {
          debugPrint('🇯🇵 日本語ユーザー → 翻訳スキップ');
        }
        
        final parsedExercises = _parseGeneratedMenu(finalMenu, bodyParts);
        
        debugPrint('✅ メニュー生成成功: ${parsedExercises.length}種目抽出');
        if (parsedExercises.isEmpty) {
          debugPrint('⚠️ 警告: パースされた種目が0件です。メニューの形式を確認してください。');
        }
        
        if (mounted) {
        setState(() {
          _generatedMenu = finalMenu;
          _parsedExercises = parsedExercises;
          _selectedExerciseIndices.clear(); // 選択をリセット
        });
        }
        
        // 残りクレジット表示
        if (mounted) {
          final statusMessage = await creditService.getAIUsageStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.ai_generationComplete(statusMessage)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ メニュー生成エラー: $e');
      if (mounted) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context)!.ai_menuGenerationError}: $e';
      });
      }
    } finally {
      // 🆕 Build #24.1 Hotfix9.6: 確実にローディング状態をクリア
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
  
  /// 🔧 v1.0.223: AI生成メニューをパースして種目データを抽出（完全内部処理）
  /// 🆕 Build #24.1 Hotfix9.3: 多言語対応パーサー
  List<ParsedExercise> _parseGeneratedMenu(String menu, List<String> bodyParts) {
    debugPrint('🔍 パース開始: 全${menu.length}文字, ${menu.split('\n').length}行');
    
    // Get localized parser keywords
    final l10n = AppLocalizations.of(context)!;
    final exercisePrefix = l10n.parserExercisePrefix;
    final weightLabel = l10n.parserWeightLabel;
    final repsLabel = l10n.parserRepsLabel;
    final setsLabel = l10n.parserSetsLabel;
    final durationLabel = l10n.parserDurationLabel;
    
    final exercises = <ParsedExercise>[];
    final lines = menu.split('\n');
    
    String currentBodyPart = '';
    String currentExerciseName = '';
    String currentDescription = '';
    double? currentWeight;
    int? currentReps;
    int? currentSets;
    
    // 🔧 v1.0.221: 部位マッピング（二頭・三頭を分離）
    // 🔧 v1.0.226: 有酸素を追加
    final bodyPartMap = {
      AppLocalizations.of(context)!.bodyPartChest: AppLocalizations.of(context)!.bodyPartChest,
      AppLocalizations.of(context)!.musclePecs: AppLocalizations.of(context)!.bodyPartChest,
      AppLocalizations.of(context)!.bodyPartBack: AppLocalizations.of(context)!.bodyPartBack,
      AppLocalizations.of(context)!.workout_0f45a131: AppLocalizations.of(context)!.bodyPartBack,
      AppLocalizations.of(context)!.workout_b06bf71b: AppLocalizations.of(context)!.bodyPartBack,
      AppLocalizations.of(context)!.bodyPartLegs: AppLocalizations.of(context)!.bodyPartLegs,
      AppLocalizations.of(context)!.workout_0c28e8be: AppLocalizations.of(context)!.bodyPartLegs,
      AppLocalizations.of(context)!.workout_10073d2e: AppLocalizations.of(context)!.bodyPartLegs,
      AppLocalizations.of(context)!.bodyPartShoulders: AppLocalizations.of(context)!.bodyPartShoulders,
      AppLocalizations.of(context)!.workout_da6d5d22: AppLocalizations.of(context)!.bodyPartShoulders,
      AppLocalizations.of(context)!.bodyPartBiceps: AppLocalizations.of(context)!.bodyPartBiceps,
      AppLocalizations.of(context)!.bodyPart_8efece65: AppLocalizations.of(context)!.bodyPartBiceps,
      AppLocalizations.of(context)!.bodyPartTriceps: AppLocalizations.of(context)!.bodyPartTriceps,
      AppLocalizations.of(context)!.bodyPart_c158cb15: AppLocalizations.of(context)!.bodyPartTriceps,
      '腕': '腕', // 後方互換性のため残す
      AppLocalizations.of(context)!.bodyPart_cc7dbde9: AppLocalizations.of(context)!.bodyPartArms,
      AppLocalizations.of(context)!.bodyPart_ceb49fa1: AppLocalizations.of(context)!.bodyPart_ceb49fa1,
      AppLocalizations.of(context)!.bodyPartAbs: AppLocalizations.of(context)!.bodyPart_ceb49fa1,
      AppLocalizations.of(context)!.workout_3347b366: AppLocalizations.of(context)!.bodyPart_ceb49fa1,
      AppLocalizations.of(context)!.bodyPartCardio: AppLocalizations.of(context)!.bodyPartCardio, // 🔧 v1.0.226: 有酸素運動対応
      AppLocalizations.of(context)!.workout_5cd69285: AppLocalizations.of(context)!.exerciseCardio,
      AppLocalizations.of(context)!.workout_ad5c696a: AppLocalizations.of(context)!.exerciseCardio,
    };
    
    debugPrint('🔍 パーサー開始: 全${lines.length}行を処理');
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      debugPrint('  📄 処理中: $line');
      
      // 🔧 v1.0.226: 部位の検出（■、【】、## または単一#で囲まれた部位名）
      // ### はサブセクションなので無視
      if (line.startsWith('■') || line.startsWith('【') || 
          (line.startsWith('##') && !line.startsWith('###')) ||
          (line.startsWith('#') && !line.startsWith('##'))) {
        for (final key in bodyPartMap.keys) {
          if (line.contains(key)) {
            currentBodyPart = bodyPartMap[key]!;
            debugPrint('  📍 部位検出: $currentBodyPart (行: $line)');
            break;
          }
        }
        continue;
      }
      
      // ### はサブセクション（スキップ）
      if (line.startsWith('###')) {
        debugPrint('  ⏭️  サブセクションをスキップ: $line');
        continue;
      }
      
      // 🔧 v1.0.226: 種目名の検出（複数パターンに対応）
      // パターン1: "1. 種目名" or "1) 種目名"
      final exercisePattern = RegExp(r'^(\d+[\.\)]\s*)(.+?)(?:[:：]|$)');
      final match = exercisePattern.firstMatch(line);
      
      // パターン2: "・ 種目名：" のような形式（ウォームアップなど）
      final altExercisePattern = RegExp(r'^[・\*]\s*(.+?)(?:[:：]\s*\*\*|$)');
      final altMatch = altExercisePattern.firstMatch(line);
      
      // パターン3: "**種目1：種目名**" のようなマークダウン形式
      // 🆕 Build #24.1 Hotfix9.3: 多言語対応（種目 → Exercise, 종목, 项目, etc.）
      final markdownPattern = RegExp(r'^\*\*' + exercisePrefix + r'\d+[:：](.+?)\*\*');
      final markdownMatch = markdownPattern.firstMatch(line);
      
      // パターン4: "**A1. EZバーカール**" のような英数字番号付き形式
      final alphaNumPattern = RegExp(r'^\*\*[A-Z]\d+[\.\)]\s*(.+?)\*\*');
      final alphaNumMatch = alphaNumPattern.firstMatch(line);
      
      // 詳細情報行の判定（先頭がスペースまたはタブ、または「•」「*」で始まる）
      final isDetailLine = line.startsWith('  ') || line.startsWith('\t') || 
                           line.startsWith('•') || 
                           (line.startsWith('*') && markdownMatch == null);
      
      if ((match != null || altMatch != null || markdownMatch != null || alphaNumMatch != null) && !isDetailLine) {
        // 前の種目を保存
        if (currentExerciseName.isNotEmpty && currentBodyPart.isNotEmpty) {
          // 🔧 v1.0.237: 有酸素運動かどうかを判定
          final isCardio = currentBodyPart == AppLocalizations.of(context)!.exerciseCardio;
          
          if (isCardio) {
            // 有酸素運動の場合: duration（時間）とdistance（距離）を使用
            final finalDuration = currentReps; // repsに時間が入っている
            final finalDistance = currentWeight; // weightに距離が入っている可能性
            final finalSets = currentSets ?? 1; // 有酸素は通常1セット
            
            debugPrint('  💾 有酸素種目保存: $currentExerciseName - duration=$finalDuration分, distance=$finalDistance, sets=$finalSets');
            
            exercises.add(ParsedExercise(
              name: currentExerciseName,
              bodyPart: currentBodyPart,
              isCardio: true,
              duration: finalDuration,
              distance: finalDistance,
              sets: finalSets,
              description: currentDescription.isNotEmpty ? currentDescription : null,
            ));
          } else {
            // 筋トレの場合: weight, reps, setsを使用
            final finalWeight = currentWeight ?? 0.0;
            final finalReps = currentReps ?? 10;
            final finalSets = currentSets ?? 3;
            
            debugPrint('  💾 筋トレ種目保存: $currentExerciseName - weight=$finalWeight, reps=$finalReps, sets=$finalSets');
            
            exercises.add(ParsedExercise(
              name: currentExerciseName,
              bodyPart: currentBodyPart,
              isCardio: false,
              weight: finalWeight,
              reps: finalReps,
              sets: finalSets,
              description: currentDescription.isNotEmpty ? currentDescription : null,
            ));
          }
        }
        
        // 🔧 v1.0.226: 種目名の抽出（4パターンに対応）
        // 🆕 Build #24.1 Hotfix9.6: 安全なグループ抽出（境界チェック）
        var name = '';
        if (match != null && match.groupCount >= 2) {
          name = match.group(2)?.trim() ?? '';
        } else if (altMatch != null && altMatch.groupCount >= 1) {
          name = altMatch.group(1)?.trim() ?? '';
        } else if (markdownMatch != null && markdownMatch.groupCount >= 1) {
          name = markdownMatch.group(1)?.trim() ?? '';
        } else if (alphaNumMatch != null && alphaNumMatch.groupCount >= 1) {
          name = alphaNumMatch.group(1)?.trim() ?? '';
        }
        
        // 名前が取得できなかった場合はスキップ
        if (name.isEmpty) {
          debugPrint('  ⚠️ 種目名を抽出できませんでした: $line');
          continue;
        }
        
        // **で囲まれた部分があれば除去
        name = name.replaceAll('**', '').trim();
        
        // 🔧 v1.0.226-fix: コロンがあれば後ろの部分（実際の種目名）を取得
        // 🆕 Build #24.1 Hotfix9.6: 安全な分割処理（境界チェック）
        if (name.contains('：')) {
          // 「種目1：ショルダープレス」→「ショルダープレス」
          final parts = name.split('：');
          if (parts.length > 1 && parts[1].trim().isNotEmpty) {
            name = parts[1].trim();
          } else if (parts.isNotEmpty) {
            name = parts[0].trim();
          }
        }
        if (name.contains(':')) {
          final parts = name.split(':');
          if (parts.length > 1 && parts[1].trim().isNotEmpty) {
            name = parts[1].trim();
          } else if (parts.isNotEmpty) {
            name = parts[0].trim();
          }
        }
        
        // 括弧内の補足情報を除去（例: ベンチプレス（バーベル）→ ベンチプレス）
        name = name.replaceAll(RegExp(r'[（\(][^）\)]*[）\)]'), '').trim();
        
        currentExerciseName = name;
        currentDescription = '';
        currentWeight = null;
        currentReps = null;
        currentSets = null;
        
        debugPrint('  ✅ 種目検出: $currentExerciseName (部位: $currentBodyPart)');
        
        // 同じ行に重量・回数・セット情報があるか確認
        // 🆕 Build #24.1 Hotfix9.3: 多言語対応パターン
        final weightPattern = RegExp(r'(\d+(?:\.\d+)?)\s*kg');
        final repsPattern = RegExp(r'(\d+)\s*(?:' + repsLabel + r'|回|reps?)');
        final setsPattern = RegExp(r'(\d+)\s*(?:' + setsLabel + r'|セット|sets?)');
        final timePattern = RegExp(r'(\d+)\s*(?:' + durationLabel + r'|分)(?:\s*（|\s*\()?');
        
        final weightMatch = weightPattern.firstMatch(line);
        final repsMatch = repsPattern.firstMatch(line);
        final setsMatch = setsPattern.firstMatch(line);
        final timeMatch = timePattern.firstMatch(line);
        
        // 🆕 Build #24.1 Hotfix9.6: 安全なグループ抽出（境界チェック）
        if (weightMatch != null && weightMatch.groupCount >= 1) {
          currentWeight = double.tryParse(weightMatch.group(1) ?? '');
        }
        if (repsMatch != null && repsMatch.groupCount >= 1) {
          currentReps = int.tryParse(repsMatch.group(1) ?? '');
        }
        // 🔧 v1.0.226: 有酸素運動の場合のみ、時間をrepsとして扱う
        if (timeMatch != null && timeMatch.groupCount >= 1 && currentReps == null && currentBodyPart == AppLocalizations.of(context)!.exerciseCardio) {
          currentReps = int.tryParse(timeMatch.group(1) ?? '');
        }
        if (setsMatch != null && setsMatch.groupCount >= 1) {
          currentSets = int.tryParse(setsMatch.group(1) ?? '');
        }
      } else if (currentExerciseName.isNotEmpty) {
        // 種目の説明や詳細情報
        if (line.startsWith(AppLocalizations.of(context)!.workout_f517d9ec) || line.startsWith(AppLocalizations.of(context)!.workout_5071705c)) {
          currentDescription = line.replaceFirst(RegExp(r'説明[:：]\s*'), '');
        } else if (!line.startsWith('■') && !line.startsWith('【') && !line.startsWith('##') && !line.startsWith('#')) {
          // 🔧 v1.0.224: *や・、•で始まる行、または通常の行から重量・回数・セット情報を抽出
          String cleanLine = line;
          // マークダウンの **説明:** のような形式に対応
          if (line.startsWith('* **') || line.startsWith('• **')) {
            cleanLine = line.substring(2).trim();
            // **を除去
            cleanLine = cleanLine.replaceAll('**', '').trim();
          } else if (line.startsWith('*') || line.startsWith('・') || line.startsWith('-') || line.startsWith('•')) {
            cleanLine = line.substring(1).trim();
          }
          // インデントされた行の処理
          cleanLine = cleanLine.trim();
          
          // 🔧 v1.0.224: 重量・回数・セット数の抽出（複数パターン対応）
          // 🆕 Build #24.1 Hotfix9.3: 多言語対応パターン
          // パターン1: "重量: XXkg" または "Weight: XXkg" または "무게: XXkg"
          final weightPattern = RegExp(
            '(?:' + weightLabel + r'|重量|Weight|Peso|Gewicht)[:：]?\s*(?:男性[:：]?\s*)?(\d+(?:\.\d+)?)(?:-\d+(?:\.\d+)?)?(?:kg)?',
            caseSensitive: false
          );
          final repsPattern = RegExp(
            '(?:' + repsLabel + r'|回数|Reps?|Repeticiones|횟수|次数|Wiederholungen)[:：]?\s*(\d+)\s*(?:' + repsLabel + r'|回|reps?)?',
            caseSensitive: false
          );
          final setsPattern = RegExp(
            '(?:' + setsLabel + r'|セット数|Sets?|Series|세트 수|组数|組數|Sätze)[:：]?\s*(\d+)\s*(?:' + setsLabel + r'|セット|sets?)?',
            caseSensitive: false
          );
          
          // パターン2: 単純な "XXkg", "XX회", "XX回", "XX reps"
          // 🆕 Build #24.1 Hotfix9.3: 多言語対応
          final weightPattern2 = RegExp(r'(\d+(?:\.\d+)?)\s*(?:-\d+(?:\.\d+)?)?\s*kg');
          final repsPattern2 = RegExp(r'(\d+)\s*(?:' + repsLabel + r'|회|回|reps?)');
          final setsPattern2 = RegExp(r'(\d+)\s*(?:' + setsLabel + r'|세트|セット|sets?)');
          
          // 🔧 v1.0.226: 有酸素運動用のパターン（時間）- 括弧付き説明にも対応
          // 🆕 Build #24.1 Hotfix9.3: 多言語対応
          final timePattern = RegExp(
            '(?:' + durationLabel + r'|時間|Duration|Duración|시간|分钟|分鐘|Dauer|HIIT形式)[:：]?\s*(\d+)\s*(?:' + durationLabel + r'|분|分|min)?',
            caseSensitive: false
          );
          final timePattern2 = RegExp(r'(\d+)\s*(?:' + durationLabel + r'|분|分|min)(?:\s*（|\s*\()?');
          
          var weightMatch = weightPattern.firstMatch(cleanLine);
          var repsMatch = repsPattern.firstMatch(cleanLine);
          var setsMatch = setsPattern.firstMatch(cleanLine);
          var timeMatch = timePattern.firstMatch(cleanLine);
          
          // 代替パターンでも試す
          if (weightMatch == null) weightMatch = weightPattern2.firstMatch(cleanLine);
          if (repsMatch == null) repsMatch = repsPattern2.firstMatch(cleanLine);
          if (setsMatch == null) setsMatch = setsPattern2.firstMatch(cleanLine);
          if (timeMatch == null) timeMatch = timePattern2.firstMatch(cleanLine);
          
          // 🆕 Build #24.1 Hotfix9.6: 安全なグループ抽出（境界チェック）
          if (weightMatch != null && weightMatch.groupCount >= 1 && currentWeight == null) {
            currentWeight = double.tryParse(weightMatch.group(1) ?? '');
          }
          if (repsMatch != null && repsMatch.groupCount >= 1 && currentReps == null) {
            currentReps = int.tryParse(repsMatch.group(1) ?? '');
          }
          // 🔧 v1.0.226: 有酸素運動の場合のみ、時間をrepsとして扱う
          if (timeMatch != null && timeMatch.groupCount >= 1 && currentReps == null && currentBodyPart == AppLocalizations.of(context)!.exerciseCardio) {
            final timeStr = timeMatch.group(1) ?? '';
            currentReps = int.tryParse(timeStr);
            debugPrint('  ⏱️ 有酸素時間検出: ${timeStr}分 → reps=$currentReps (line: $cleanLine)');
          }
          if (setsMatch != null && setsMatch.groupCount >= 1 && currentSets == null) {
            final setsStr = setsMatch.group(1) ?? '';
            currentSets = int.tryParse(setsStr);
            debugPrint('  📊 セット数検出: ${setsStr}セット');
          }
          
          // デバッグ: パース状態を確認
          if (currentExerciseName.isNotEmpty && (weightMatch != null || repsMatch != null || timeMatch != null || setsMatch != null)) {
            debugPrint('  📝 現在の状態 ($currentExerciseName): weight=$currentWeight, reps=$currentReps, sets=$currentSets');
          }
          
          // 🔧 v1.0.226: 休憩時間、ポイントなどの無関係な行をスキップ
          final isIgnoredLine = cleanLine.contains(AppLocalizations.of(context)!.restTime) || 
                               cleanLine.contains(AppLocalizations.of(context)!.points) ||
                               cleanLine.contains(AppLocalizations.of(context)!.workout_f87ab689) ||
                               cleanLine.contains(AppLocalizations.of(context)!.workout_1acc9df7) ||
                               cleanLine.contains(AppLocalizations.of(context)!.workout_695ead36) ||
                               cleanLine.contains(AppLocalizations.of(context)!.workout_ad1f2968);
          
          // 説明の続き（重量・回数・セット情報がない場合、かつ無視すべき行ではない場合）
          if (!isIgnoredLine && currentDescription.isNotEmpty && weightMatch == null && repsMatch == null && timeMatch == null && setsMatch == null) {
            currentDescription += ' ' + cleanLine;
          }
        }
      }
    }
    
    // 最後の種目を保存
    if (currentExerciseName.isNotEmpty && currentBodyPart.isNotEmpty) {
      // 🔧 v1.0.237: 有酸素運動かどうかを判定
      final isCardio = currentBodyPart == AppLocalizations.of(context)!.exerciseCardio;
      
      if (isCardio) {
        // 有酸素運動の場合: duration（時間）とdistance（距離）を使用
        final finalDuration = currentReps; // repsに時間が入っている
        final finalDistance = currentWeight; // weightに距離が入っている可能性
        final finalSets = currentSets ?? 1; // 有酸素は通常1セット
        
        debugPrint('  💾 有酸素種目保存: $currentExerciseName - duration=$finalDuration分, distance=$finalDistance, sets=$finalSets');
        
        exercises.add(ParsedExercise(
          name: currentExerciseName,
          bodyPart: currentBodyPart,
          isCardio: true,
          duration: finalDuration,
          distance: finalDistance,
          sets: finalSets,
          description: currentDescription.isNotEmpty ? currentDescription : null,
        ));
      } else {
        // 筋トレの場合: weight, reps, setsを使用
        final finalWeight = currentWeight ?? 0.0;
        final finalReps = currentReps ?? 10;
        final finalSets = currentSets ?? 3;
        
        debugPrint('  💾 筋トレ種目保存: $currentExerciseName - weight=$finalWeight, reps=$finalReps, sets=$finalSets');
        
        exercises.add(ParsedExercise(
          name: currentExerciseName,
          bodyPart: currentBodyPart,
          isCardio: false,
          weight: finalWeight,
          reps: finalReps,
          sets: finalSets,
          description: currentDescription.isNotEmpty ? currentDescription : null,
        ));
      }
    }
    
    debugPrint('📝 パース結果: ${exercises.length}種目抽出');
    if (exercises.isEmpty) {
      debugPrint('❌ エラー: 1つも種目が抽出できませんでした！');
      debugPrint('📋 最後の状態:');
      debugPrint('  - currentExerciseName: $currentExerciseName');
      debugPrint('  - currentBodyPart: $currentBodyPart');
      debugPrint('  - currentWeight: $currentWeight');
      debugPrint('  - currentReps: $currentReps');
      debugPrint('  - currentSets: $currentSets');
    } else {
      for (final ex in exercises) {
        if (ex.isCardio) {
          debugPrint('  ✅ ${ex.name} (${ex.bodyPart}): ${ex.duration}分, ${ex.distance ?? 0}km, ${ex.sets}セット [有酸素]');
        } else {
          debugPrint('  ✅ ${ex.name} (${ex.bodyPart}): ${ex.weight}kg, ${ex.reps}回, ${ex.sets}セット [筋トレ]');
        }
      }
    }
    
    return exercises;
  }

  /// 🔧 v1.0.219: 初心者向けトレーニング種目データベース（説明付き）
  static const String _beginnerExerciseDatabase = '''
【初心者向けトレーニング種目一覧】以下から選択し、必ず説明を含めてください。

■胸（大胸筋）:
1. チェストプレスマシン
   説明: 軌道が固定されており最も安全。座ったまま胸の前でバーを押し出す。大胸筋全体を鍛える基本種目。

2. ダンベルベンチプレス
   説明: ベンチに仰向けになりダンベルを胸の上で押し上げる。バーベルより可動域が広く、バランス感覚も養える。

3. ペックフライマシン
   説明: 座った状態で両腕を胸の前で閉じる動作。大胸筋のストレッチと収縮を意識しやすい。

■背中（広背筋・僧帽筋）:
1. ラットプルダウン
   説明: 座った状態でバーを上から引き下ろす。懸垂ができない初心者に最適な背中の基本種目。

2. シーテッドロー
   説明: 座った状態でケーブルやバーを胸に向かって引く。広背筋と僧帽筋を効率的に鍛える。

3. バックエクステンション
   説明: うつ伏せで上体を起こす。脊柱起立筋を鍛え、姿勢改善に効果的。

■脚（大腿四頭筋・ハムストリングス）:
1. レッグプレスマシン
   説明: 座った状態で足でプレートを押し出す。スクワットより安全で、大腿四頭筋・ハムストリングス・大臀筋を鍛える。

2. レッグエクステンション
   説明: 座った状態で膝を伸ばす動作。大腿四頭筋（太もも前側）を集中的に鍛える。

3. レッグカール
   説明: うつ伏せで膝を曲げる動作。ハムストリングス（太もも裏側）を集中的に鍛える。

■肩（三角筋）:
1. ショルダープレスマシン
   説明: 座った状態でバーを頭上に押し上げる。三角筋全体を安全に鍛えられる。

2. サイドレイズ（ダンベル）
   説明: 両手にダンベルを持ち、腕を横に上げる。三角筋中部を重点的に鍛える。

■二頭（上腕二頭筋）:
1. ダンベルカール
   説明: ダンベルを持ち肘を曲げて持ち上げる。上腕二頭筋（力こぶ）を鍛える基本種目。

2. ハンマーカール
   説明: 親指を上にしてダンベルを持ち上げる。二頭筋と前腕を同時に鍛えられる。

3. マシンアームカール
   説明: 軌道が固定されており初心者に安全。座った状態で肘を曲げる。

■三頭（上腕三頭筋）:
1. トライセプスプレスダウン
   説明: ケーブルマシンでバーを下に押し下げる。上腕三頭筋（二の腕）を鍛える基本種目。

2. トライセプスキックバック
   説明: ダンベルを持ち、後ろに押し出す動作。三頭筋の収縮を意識しやすい。

3. マシンディップス
   説明: 補助付きで安全に三頭筋を鍛える。体を上下させる動作。

■腹筋（腹直筋・腹斜筋）:
1. アブドミナルクランチマシン
   説明: マシンで上体を丸める動作。腹直筋を効率的に鍛えられる。

2. プランク
   説明: うつ伏せで肘と つま先で体を支える。体幹全体を鍛える基礎種目。

■有酸素運動:
1. ランニング（トレッドミル）
   説明: 有酸素運動の王道。心肺機能向上と脂肪燃焼に効果的。時速6-8km/hから開始推奨。

2. エアロバイク
   説明: 膝への負担が少なく、有酸素運動初心者に最適。心拍数を管理しやすい。

3. ウォーキング（トレッドミル）
   説明: 最も負担が少ない有酸素運動。運動習慣がない方の第一歩に最適。

4. クロストレーナー
   説明: 全身を使う有酸素運動。関節への負担が少なく、消費カロリーが高い。

5. ステッパー
   説明: 階段を登る動作を再現。下半身と心肺機能を同時に鍛えられる。

6. 水泳
   説明: 全身運動で関節への負担が最小。心肺機能と筋持久力を同時に向上。

**重要**: 必ず上記の説明を含めて提案すること。
''';

  /// 🔧 v1.0.219: 中・上級者向けトレーニング種目データベース（種目名のみ）
  static const String _advancedExerciseDatabase = '''
【中・上級者向けトレーニング種目一覧】以下から選択してください。

■胸（大胸筋）:
ベンチプレス（バーベル）、インクラインベンチプレス、デクラインベンチプレス、ダンベルベンチプレス、インクラインダンベルプレス、ダンベルフライ、インクラインフライ、ケーブルクロスオーバー、ディップス（胸重視）、チェストプレスマシン、ペックフライマシン

■背中（広背筋・僧帽筋・脊柱起立筋）:
デッドリフト（バーベル）、ラットプルダウン（ワイド）、ラットプルダウン（ナロー）、チンニング（懸垂）、ベントオーバーロー、ワンハンドダンベルロー、Tバーロー、シーテッドロー、ケーブルロー、バックエクステンション、シュラッグ

■脚（大腿四頭筋・ハムストリングス・大臀筋）:
バーベルスクワット、フロントスクワット、ブルガリアンスクワット、レッグプレスマシン、レッグエクステンション、レッグカール、ルーマニアンデッドリフト、ランジ（フロント）、ランジ（バック）、レッグアブダクション、レッグアダクション、カーフレイズ、ヒップスラスト

■肩（三角筋）:
ショルダープレス（バーベル）、ダンベルショルダープレス、マシンショルダープレス、サイドレイズ（ダンベル）、ケーブルサイドレイズ、フロントレイズ、リアレイズ（ダンベル）、ケーブルリアレイズ、アップライトロー、フェイスプル

■二頭（上腕二頭筋）:
バーベルカール（ストレート）、EZバーカール、ダンベルカール（オルタネイト）、ハンマーカール、プリチャーカール、インクラインダンベルカール、コンセントレーションカール、ケーブルカール、チンアップ（逆手懸垂）、21カール、ドラッグカール、ゾットマンカール、マシンアームカール

■三頭（上腕三頭筋）:
トライセプスプレスダウン、ケーブルプレスダウン、ライイングトライセプスエクステンション、スカルクラッシャー、オーバーヘッドトライセプスエクステンション、ディップス（三頭筋重視）、トライセプスキックバック、キックバック、クローズグリップベンチプレス、ケーブルオーバーヘッドエクステンション、リバースグリッププレスダウン、ダンベルトライセプスエクステンション、JMプレス、ダイヤモンドプッシュアップ、ベンチディップス、マシンディップス

■腹筋（腹直筋・腹斜筋・腹横筋）:
クランチ、レッグレイズ、ハンギングレッグレイズ、ケーブルクランチ、アブローラー、プランク、サイドプランク、ロシアンツイスト、マウンテンクライマー、バイシクルクランチ、ドラゴンフラッグ

■有酸素運動:
ランニング（トレッドミル）、ジョギング（屋外）、エアロバイク、ウォーキング（トレッドミル）、インターバルラン、クロストレーナー、ステッパー、水泳、ローイングマシン、バトルロープ、バーピージャンプ、マウンテンクライマー（高強度）

**重要**: 種目名・重量・回数のみ簡潔に記載。説明は不要。
''';

  /// 🆕 v1.0.301: 多言語対応のための言語指示取得
  String _getLanguageInstruction() {
    final locale = AppLocalizations.of(context)!.localeName;
    switch (locale) {
      case 'en':
        return 'Please provide detailed explanations in English';
      case 'es':
        return 'Proporcione explicaciones detalladas en español';
      case 'ko':
        return '한국어로 자세한 설명을 제공하세요';
      case 'zh':
        return AppLocalizations.of(context)!.workout_df5c2fc5;
      case 'zh_TW':
        return AppLocalizations.of(context)!.workout_837b9b2e;
      case 'de':
        return 'Bitte geben Sie detaillierte Erklärungen auf Deutsch';
      case 'ja':
      default:
        return AppLocalizations.of(context)!.workout_7f865f4b;
    }
  }

  /// 🆕 Build #24.1: AI生成メニューを他言語に翻訳（Gemini 2.0 Flash Exp使用）
  /// 日本語以外のユーザー向けに、生成されたメニューを翻訳する
  /// 🔄 Build #24.1 Hotfix10: 翻訳品質改善（リトライ、フォーマット保持強化）
  Future<String> _translateMenuToLanguage(String japaneseMenu) async {
    final locale = AppLocalizations.of(context)!.localeName;
    
    // 日本語ユーザーの場合は翻訳不要
    if (locale == 'ja') {
      return japaneseMenu;
    }
    
    // 翻訳先言語の決定
    String targetLanguage;
    switch (locale) {
      case 'en':
        targetLanguage = 'English';
        break;
      case 'es':
        targetLanguage = 'Spanish';
        break;
      case 'ko':
        targetLanguage = 'Korean';
        break;
      case 'zh':
        targetLanguage = 'Simplified Chinese';
        break;
      case 'zh_TW':
        targetLanguage = 'Traditional Chinese';
        break;
      case 'de':
        targetLanguage = 'German';
        break;
      default:
        targetLanguage = 'English'; // デフォルトは英語
    }
    
    debugPrint('🌐 メニュー翻訳開始: 日本語 → $targetLanguage');
    
    try {
      // 🔄 Build #24.1 Hotfix10: 翻訳品質改善（フォーマット保持強化）
      // Gemini 2.0 Flash Exp API呼び出し（翻訳用）
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''
You are a professional translator specializing in fitness and training content.

Translate the following Japanese workout menu to $targetLanguage.

**CRITICAL FORMAT RULES (MUST FOLLOW EXACTLY):**
1. **Preserve exact markdown structure:** Keep ALL ##, **, *, formatting
2. **Keep numbers intact:** All weights (Xkg), reps (X回 or X reps), sets (Xセット or X sets), rest times (X秒 or Xsec)
3. **Translate ONLY text, NOT structure:**
   - Translate: Exercise names, explanations, tips
   - Keep: Numbers, units (kg, 回, セット, 秒), bullet points (*, -), headers (##)
4. **Line breaks:** Preserve ALL line breaks exactly as they appear
5. **Special terms:**
   - 重量 → Weight
   - 回数 → Reps
   - セット数 → Sets
   - 休憩時間 → Rest Time
   - フォームのポイント → Form Tips

**Example Format to Preserve:**
\`\`\`
## Body Part Training Menu

**Exercise 1: Exercise Name**
* Weight: XXkg
* Reps: XX
* Sets: X
* Rest Time: XXsec
* Form Tips: explanation text
\`\`\`

**Japanese Menu to Translate:**

$japaneseMenu

**Your Task:** Translate to $targetLanguage while keeping EXACT same structure and numbers.

**Translated Menu in $targetLanguage:**
''',
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2, // 🔄 更に低く設定（フォーマット一貫性向上）
            'topK': 10,
            'topP': 0.8,
            'maxOutputTokens': 3000,
          }
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Translation request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        debugPrint('✅ 翻訳完了: ${translatedText.length}文字');
        return translatedText;
      } else {
        throw Exception('Translation API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ 翻訳エラー（日本語メニューを返します）: $e');
      // 翻訳失敗時は日本語メニューをそのまま返す（フォールバック）
      return japaneseMenu;
    }
  }

  /// 🔧 v1.0.217: プロンプト構築（レベル別 + トレーニング履歴考慮 + v1.0.219: レベル別種目DB）
  /// 🆕 v1.0.301: 多言語対応追加
  /// 🔄 Build #24.1 Hotfix10: 日本語で生成→翻訳方式（種目DBと互換性保持）
  /// 🆕 Build #24.1 Hotfix9.4: 言語別に完全に専用のプロンプトを生成
  String _buildPrompt(List<String> bodyParts) {
    final locale = AppLocalizations.of(context)!.localeName;
    
    switch (locale) {
      case 'ja':
        return _buildJapanesePrompt(bodyParts);
      case 'ko':
        return _buildKoreanPrompt(bodyParts);
      case 'es':
        return _buildSpanishPrompt(bodyParts);
      case 'zh':
      case 'zh_TW':
        return _buildChinesePrompt(bodyParts);
      case 'de':
        return _buildGermanPrompt(bodyParts);
      default:
        return _buildEnglishPrompt(bodyParts);
    }
  }
  
  /// 🆕 Build #24.1 Hotfix9: 日本語プロンプト構築
  String _buildJapanesePrompt(List<String> bodyParts) {
    final languageInstruction = _getLanguageInstruction();
    // トレーニング履歴情報を構築
    String historyInfo = '';
    if (_exerciseHistory.isNotEmpty) {
      historyInfo = '\n【直近1ヶ月のトレーニング履歴】\n';
      for (final entry in _exerciseHistory.entries) {
        final exerciseName = entry.key;
        final maxWeight = entry.value['maxWeight'];
        final max1RM = entry.value['max1RM'];
        final totalSets = entry.value['totalSets'];
        historyInfo += '- $exerciseName: 最大重量=${maxWeight}kg, 推定1RM=${max1RM?.toStringAsFixed(1)}kg, 総セット数=$totalSets\n';
      }
      historyInfo += '\n上記の履歴を参考に、適切な重量と回数を提案してください。\n';
    }
    
    final targetParts = bodyParts;

    // レベル別プロンプト構築
    if (_selectedLevel == AppLocalizations.of(context)!.levelBeginner) {
      // 初心者向け
      if (targetParts.isEmpty) {
        return '''
あなたはプロのパーソナルトレーナーです。筋トレ初心者向けの全身トレーニングメニューを提案してください。

$_beginnerExerciseDatabase
$historyInfo
【対象者】
- 筋トレ初心者（ジム通い始めて1〜3ヶ月程度）
- 基礎体力づくりを目指す方
- トレーニングフォームを学びたい方

【提案形式】
**必ずこの形式で出力してください：**

```
## 部位トレーニングメニュー

**種目1：種目名**
* 重量：XXkg
* 回数：XX回
* セット数：Xセット
* 休憩時間：XX秒
* フォームのポイント：説明文

**種目2：種目名**
* 重量：XXkg
* 回数：XX回
* セット数：Xセット
```

各種目について以下の情報を含めてください：
- 種目名（種目データベースから選択）
- **具体的な重量（kg）** ← 履歴があればそれを参考に、なければ初心者向けの推奨重量
  ※有酸素運動の場合は「重量：0kg」とし、回数の代わりに「時間：XX分」を記載
- **回数（10-15回）** ← 有酸素の場合は「時間：20-30分」
- セット数（2-3セット）← 有酸素の場合は「1セット」
- 休憩時間（90-120秒）
- 初心者向けフォームのポイント

【条件】
- 全身をバランスよく鍛える
- 基本種目中心
- 30-45分で完了
- $languageInstruction

**重要: 各種目に具体的な重量と回数を必ず記載してください。有酸素運動の場合は重量0kg、時間をXX分形式で記載してください。**
''';
      } else {
        return '''
あなたはプロのパーソナルトレーナーです。筋トレ初心者向けの「${targetParts.join('、')}」トレーニングメニューを提案してください。

$_beginnerExerciseDatabase
$historyInfo
【対象者】
- 筋トレ初心者（ジム通い始めて1〜3ヶ月程度）
- ${targetParts.join('、')}を重点的に鍛えたい方

【提案形式】
**必ずこの形式で出力してください：**

```
## 部位トレーニングメニュー

**種目1：種目名**
* 重量：XXkg
* 回数：XX回
* セット数：Xセット
* 休憩時間：XX秒
* フォームのポイント：説明文

**種目2：種目名**
* 重量：XXkg
* 回数：XX回
* セット数：Xセット
```

各種目について以下の情報を含めてください：
- 種目名（種目データベースから選択）
- **具体的な重量（kg）** ← 履歴があればそれを参考に、なければ初心者向けの推奨重量
  ※有酸素運動の場合は「重量：0kg」とし、回数の代わりに「時間：XX分」を記載
- **回数（10-15回）** ← 有酸素の場合は「時間：20-30分」
- セット数（2-3セット）← 有酸素の場合は「1セット」
- 休憩時間（90-120秒）
- フォームのポイント

【条件】
- ${targetParts.join('、')}を重点的にトレーニング
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **有酸素運動のみ**を提案（筋トレ種目は含めない）" : "- 基本種目中心"}
- 30-45分で完了
- $languageInstruction

**重要: 各種目に具体的な重量と回数を必ず記載してください。有酸素運動の場合は重量0kg、時間をXX分形式で記載してください。**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**絶対厳守: 有酸素運動データベースの種目のみ使用すること。ベンチプレス、スクワットなどの筋トレ種目は絶対に含めないこと。**" : ""}
''';
      }
    } else if (_selectedLevel == AppLocalizations.of(context)!.levelIntermediate) {
      // 中級者向け
      return '''
あなたはプロのパーソナルトレーナーです。筋トレ中級者向けの「${targetParts.isEmpty ? "全身" : targetParts.join('、')}」トレーニングメニューを提案してください。

$_advancedExerciseDatabase
$historyInfo
【対象者】
- 筋トレ経験6ヶ月〜2年程度
- 筋力・筋肥大を目指す方
- より高度なテクニックを習得したい方

【提案形式】
**必ずこの形式で出力してください：**

```
## 部位トレーニングメニュー

**種目1：種目名**
* 重量：XXkg
* 回数：XX回
* セット数：Xセット
* 休憩時間：XX秒
* ポイント：説明文

**種目2：種目名**
* 重量：XXkg
* 回数：XX回
* セット数：Xセット
```

各種目について以下の情報を含めてください：
- 種目名（種目データベースから選択）
- **具体的な重量（kg）** ← 履歴の1RMの70-85%を目安に提案
  ※有酸素運動の場合は「重量：0kg」とし、回数の代わりに「時間：XX分」を記載
- **回数（8-12回）** ← 有酸素の場合は「時間：30-45分」または「インターバル形式」
- セット数（3-4セット）← 有酸素の場合は「1セット」
- 休憩時間（60-90秒）
- テクニックのポイント（ドロップセット、スーパーセット等）

【条件】
- ${targetParts.isEmpty ? "全身バランスよく" : targetParts.join('、')+AppLocalizations.of(context)!.autoGen_a4e8ab60}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **有酸素運動のみ**を提案（筋トレ種目は含めない）\n- HIIT、持久走、インターバルなど多様な有酸素トレーニング" : "- フリーウェイト中心\n- 筋肥大を重視"}
- 45-60分で完了
- $languageInstruction

**重要: 各種目に具体的な重量と回数を必ず記載してください。有酸素運動の場合は重量0kg、時間をXX分形式で記載してください。**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**絶対厳守: 有酸素運動データベースの種目のみ使用すること。ベンチプレス、スクワット、デッドリフトなどの筋トレ種目は絶対に含めないこと。**" : ""}
''';
    } else {
      // 上級者向け
      return '''
あなたはプロのパーソナルトレーナーです。筋トレ上級者向けの「${targetParts.isEmpty ? "全身" : targetParts.join('、')}」トレーニングメニューを提案してください。

$_advancedExerciseDatabase
$historyInfo
【対象者】
- 筋トレ経験2年以上
- 最大限の筋力・筋肥大を目指す方
- 高強度トレーニングに慣れている方

【提案形式】
**必ずこの形式で出力してください：**

```
## 部位トレーニングメニュー

**種目1：種目名**
* 重量：XXkg
* 回数：XX回
* セット数：Xセット
* 休憩時間：XX秒
* 高度なテクニック：説明文

**種目2：種目名**
* 重量：XXkg
* 回数：XX回
* セット数：Xセット
```

各種目について以下の情報を含めてください：
- 種目名（種目データベースから選択）
- **具体的な重量（kg）** ← 履歴の1RMの85-95%を目安に提案
  ※有酸素運動の場合は「重量：0kg」とし、回数の代わりに「時間：XX分」を記載
- **回数（5-8回）** ← 有酸素の場合は「HIIT形式：XX分」または「持久走：XX分」
- セット数（4-5セット）← 有酸素の場合は「1セット」
- 休憩時間（120-180秒）
- 高度なテクニック（ピラミッド法、5x5法等）

【条件】
- ${targetParts.isEmpty ? "全身最大限に" : targetParts.join('、')+"を極限まで"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **有酸素運動のみ**を提案（筋トレ種目は含めない）\n- HIIT、タバタ式、持久走など高強度有酸素トレーニング" : "- 高重量フリーウェイト中心\n- 最大筋力向上を重視"}
- 60-90分で完了
- $languageInstruction

**重要: 各種目に具体的な重量と回数を必ず記載してください。有酸素運動の場合は重量0kg、時間をXX分形式で記載してください。**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**絶対厳守: 有酸素運動データベースの種目のみ使用すること。ベンチプレス、スクワット、デッドリフト、ショルダープレスなどの筋トレ種目は絶対に含めないこと。**" : ""}
''';
    }
  }
  
  /// 🆕 Build #24.1 Hotfix9.3: English prompt construction for multilingual support
  String _buildEnglishPrompt(List<String> bodyParts) {
    final locale = AppLocalizations.of(context)!.localeName;
    String languageInstruction = 'Please provide detailed explanations in English';
    
    // Customize language instruction based on locale
    switch (locale) {
      case 'es':
        languageInstruction = 'Por favor proporciona explicaciones detalladas en español';
        break;
      case 'ko':
        languageInstruction = '한국어로 자세한 설명을 제공하세요';
        break;
      case 'zh':
      case 'zh_TW':
        languageInstruction = '请用中文提供详细说明';
        break;
      case 'de':
        languageInstruction = 'Bitte geben Sie detaillierte Erklärungen auf Deutsch';
        break;
    }
    
    // Build training history info in English
    String historyInfo = '';
    if (_exerciseHistory.isNotEmpty) {
      historyInfo = '\n【Recent Training History (Last 30 days)】\n';
      for (final entry in _exerciseHistory.entries) {
        final exerciseName = entry.key;
        final maxWeight = entry.value['maxWeight'];
        final max1RM = entry.value['max1RM'];
        final totalSets = entry.value['totalSets'];
        historyInfo += '- $exerciseName: Max Weight=${maxWeight}kg, Est. 1RM=${max1RM?.toStringAsFixed(1)}kg, Total Sets=$totalSets\n';
      }
      historyInfo += '\nPlease use the above history to suggest appropriate weights and reps.\n';
    }
    
    final targetParts = bodyParts;
    final currentLevel = _selectedLevel;
    
    // Beginner level
    if (currentLevel == AppLocalizations.of(context)!.levelBeginner) {
      if (targetParts.isEmpty) {
        return '''
You are a professional personal trainer. Please suggest a full-body training menu for beginners.

$_beginnerExerciseDatabase
$historyInfo
【Target Audience】
- Gym beginners (1-3 months of experience)
- Those aiming to build basic fitness
- Those who want to learn proper form

【Output Format】
**Please strictly follow this format:**

\`\`\`
## Body Part Training Menu

**Exercise 1: Exercise Name**
* Weight: XXkg
* Reps: XX
* Sets: X
* Rest Time: XXsec
* Form Tips: Explanation

**Exercise 2: Exercise Name**
* Weight: XXkg
* Reps: XX
* Sets: X
\`\`\`

Please include the following information for each exercise:
- Exercise name (selected from exercise database)
- **Specific weight (kg)** ← Use history as reference, or suggest beginner-friendly weights
  ※For cardio exercises, use "Weight: 0kg" and specify "Duration: XX minutes" instead of reps
- **Reps (10-15)** ← For cardio, use "Duration: 20-30 minutes"
- Sets (2-3 sets) ← For cardio, use "1 set"
- Rest time (90-120 seconds)
- Form tips for beginners

【Conditions】
- Balance training across all body parts
- Focus on basic exercises
- Completable in 30-45 minutes
- $languageInstruction

**Important: Always specify concrete weight and reps for each exercise. For cardio exercises, use weight 0kg and specify duration in XX minutes format.**
''';
      } else {
        return '''
You are a professional personal trainer. Please suggest a "${targetParts.join(', ')}" training menu for beginners.

$_beginnerExerciseDatabase
$historyInfo
【Target Audience】
- Gym beginners (1-3 months of experience)
- Those who want to focus on training ${targetParts.join(', ')}

【Output Format】
**Please strictly follow this format:**

\`\`\`
## Body Part Training Menu

**Exercise 1: Exercise Name**
* Weight: XXkg
* Reps: XX
* Sets: X
* Rest Time: XXsec
* Form Tips: Explanation

**Exercise 2: Exercise Name**
* Weight: XXkg
* Reps: XX
* Sets: X
\`\`\`

Please include the following information for each exercise:
- Exercise name (selected from exercise database)
- **Specific weight (kg)** ← Use history as reference, or suggest beginner-friendly weights
  ※For cardio exercises, use "Weight: 0kg" and specify "Duration: XX minutes" instead of reps
- **Reps (10-15)** ← For cardio, use "Duration: 20-30 minutes"
- Sets (2-3 sets) ← For cardio, use "1 set"
- Rest time (90-120 seconds)
- Form tips

【Conditions】
- Focus on training ${targetParts.join(', ')}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Suggest **cardio exercises ONLY** (do not include weight training)" : "- Focus on basic exercises"}
- Completable in 30-45 minutes
- $languageInstruction

**Important: Always specify concrete weight and reps for each exercise. For cardio exercises, use weight 0kg and specify duration in XX minutes format.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**STRICTLY: Use ONLY exercises from cardio database. Never include bench press, squats, or other weight training exercises.**" : ""}
''';
      }
    } else if (currentLevel == AppLocalizations.of(context)!.levelIntermediate) {
      // Intermediate level
      return '''
You are a professional personal trainer. Please suggest a "${targetParts.isEmpty ? "full-body" : targetParts.join(', ')}" training menu for intermediate trainees.

$_advancedExerciseDatabase
$historyInfo
【Target Audience】
- Intermediate trainees (6 months to 2 years of experience)
- Those aiming for strength and muscle hypertrophy
- Those who want to master more advanced techniques

【Output Format】
**Please strictly follow this format:**

\`\`\`
## Body Part Training Menu

**Exercise 1: Exercise Name**
* Weight: XXkg
* Reps: XX
* Sets: X
* Rest Time: XXsec
* Tips: Explanation

**Exercise 2: Exercise Name**
* Weight: XXkg
* Reps: XX
* Sets: X
\`\`\`

Please include the following information for each exercise:
- Exercise name (selected from exercise database)
- **Specific weight (kg)** ← Suggest 70-85% of historical 1RM
  ※For cardio exercises, use "Weight: 0kg" and specify "Duration: XX minutes" instead of reps
- **Reps (8-12)** ← For cardio, use "Duration: 30-45 minutes" or "Interval format"
- Sets (3-4 sets) ← For cardio, use "1 set"
- Rest time (60-90 seconds)
- Technique tips (drop sets, supersets, etc.)

【Conditions】
- ${targetParts.isEmpty ? "Balance training across all body parts" : "Focus intensively on ${targetParts.join(', ')}"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Suggest **cardio exercises ONLY** (do not include weight training)\n- Variety of cardio: HIIT, endurance running, intervals, etc." : "- Focus on free weights\n- Emphasize muscle hypertrophy"}
- Completable in 45-60 minutes
- $languageInstruction

**Important: Always specify concrete weight and reps for each exercise. For cardio exercises, use weight 0kg and specify duration in XX minutes format.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**STRICTLY: Use ONLY exercises from cardio database. Never include bench press, squats, deadlifts, or other weight training exercises.**" : ""}
''';
    } else {
      // Advanced level
      return '''
You are a professional personal trainer. Please suggest a "${targetParts.isEmpty ? "full-body" : targetParts.join(', ')}" training menu for advanced trainees.

$_advancedExerciseDatabase
$historyInfo
【Target Audience】
- Advanced trainees (2+ years of experience)
- Those aiming for maximum strength and muscle growth
- Those experienced with high-intensity training

【Output Format】
**Please strictly follow this format:**

\`\`\`
## Body Part Training Menu

**Exercise 1: Exercise Name**
* Weight: XXkg (based on 1RM history: 85-95%)
* Reps: XX (5-8 reps, or for cardio: HIIT XX minutes or Endurance run XX minutes)
* Sets: X (4-5 sets, for cardio: 1 set)
* Rest Time: XXsec (120-180 seconds)
* Advanced Techniques: Pyramid method, 5x5 method, etc.

**Exercise 2: Exercise Name**
* Weight: XXkg
* Reps: XX
* Sets: X
\`\`\`

Please include the following information for each exercise:
- Exercise name (selected from database)
- **Specific weight (kg)** ← Suggest 85-95% of historical 1RM
  ※For cardio exercises, use "Weight: 0kg" and specify "Duration: XX minutes" instead of reps
- **Reps (5-8)** ← For cardio, use "HIIT format XX minutes" or "Endurance run XX minutes"
- Sets (4-5 sets) ← For cardio, use "1 set"
- Rest time (120-180 seconds)
- Advanced techniques (pyramid, 5x5, etc.)

【Conditions】
- ${targetParts.isEmpty ? "Full-body training with maximum load" : "Train ${targetParts.join(', ')} to the absolute limit"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Suggest **cardio exercises ONLY**\n- Mix of HIIT, endurance, intervals, etc." : "- Emphasize compound movements\n- Maximize strength"}
- Completable in 60-90 minutes
- $languageInstruction

**Important: Always specify concrete weight and reps for each exercise. For cardio exercises, use weight 0kg and duration in XX minutes format. Use only cardio exercises when cardio is selected.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**STRICTLY: Use ONLY exercises from cardio database. Never include bench press, squats, deadlifts, shoulder press, or other weight training exercises.**" : ""}
''';
    }
  }
  
  /// 🆕 Build #24.1 Hotfix9.4: 韓国語専用プロンプト（完全にローカライズ）
  String _buildKoreanPrompt(List<String> bodyParts) {
    // トレーニング履歴情報を構築
    String historyInfo = '';
    if (_exerciseHistory.isNotEmpty) {
      historyInfo = '\n【최근 1개월 트레이닝 기록】\n';
      for (final entry in _exerciseHistory.entries) {
        final exerciseName = entry.key;
        final maxWeight = entry.value['maxWeight'];
        final max1RM = entry.value['max1RM'];
        final totalSets = entry.value['totalSets'];
        historyInfo += '- $exerciseName: 최대 중량=${maxWeight}kg, 추정 1RM=${max1RM?.toStringAsFixed(1)}kg, 총 세트 수=$totalSets\n';
      }
      historyInfo += '\n위 기록을 참고하여 적절한 중량과 횟수를 제안해 주세요.\n';
    }
    
    final targetParts = bodyParts;
    final currentLevel = _selectedLevel;
    
    // 初心者レベル
    if (currentLevel == AppLocalizations.of(context)!.levelBeginner) {
      if (targetParts.isEmpty) {
        return '''
당신은 전문 퍼스널 트레이너입니다. 초보자를 위한 전신 트레이닝 메뉴를 제안해 주세요.

$_beginnerExerciseDatabase
$historyInfo
【대상】
- 헬스장 초보자 (1~3개월 경력)
- 기초 체력 향상을 목표로 하는 분
- 트레이닝 자세를 배우고 싶은 분

【제안 형식】
**반드시 다음 형식으로 출력하세요:**

\`\`\`
## 부위별 트레이닝 메뉴

**종목 1: 종목명**
* 무게: XXkg
* 횟수: XX회
* 세트 수: X세트
* 휴식 시간: XX초
* 자세 포인트: 설명

**종목 2: 종목명**
* 무게: XXkg
* 횟수: XX회
* 세트 수: X세트
\`\`\`

각 종목에 대해 다음 정보를 포함해 주세요:
- 종목명 (종목 데이터베이스에서 선택)
- **구체적인 중량 (kg)** ← 기록이 있으면 참고, 없으면 초보자 추천 중량
  ※유산소 운동의 경우 "무게: 0kg"으로 하고, 횟수 대신 "지속: XX분"을 기재
- **횟수 (10-15회)** ← 유산소의 경우 "지속: 20-30분"
- 세트 수 (2-3세트) ← 유산소의 경우 "1세트"
- 휴식 시간 (90-120초)
- 초보자를 위한 자세 포인트

【조건】
- 모든 부위를 균형 있게 트레이닝
- 기본 종목 중심
- 30-45분 내 완료 가능

**중요: 각 종목에 구체적인 중량과 횟수를 반드시 기재하세요. 유산소 운동의 경우 중량 0kg, 시간을 XX분 형식으로 기재하세요.**
''';
      } else {
        return '''
당신은 전문 퍼스널 트레이너입니다. 초보자를 위한 "${targetParts.join(', ')}" 트레이닝 메뉴를 제안해 주세요.

$_beginnerExerciseDatabase
$historyInfo
【대상】
- 헬스장 초보자 (1~3개월 경력)
- ${targetParts.join(', ')}를 집중적으로 단련하고 싶은 분

【제안 형식】
**반드시 다음 형식으로 출력하세요:**

\`\`\`
## 부위별 트레이닝 메뉴

**종목 1: 종목명**
* 무게: XXkg
* 횟수: XX회
* 세트 수: X세트
* 휴식 시간: XX초
* 자세 포인트: 설명

**종목 2: 종목명**
* 무게: XXkg
* 횟수: XX회
* 세트 수: X세트
\`\`\`

각 종목에 대해 다음 정보를 포함해 주세요:
- 종목명 (종목 데이터베이스에서 선택)
- **구체적인 중량 (kg)** ← 기록이 있으면 참고, 없으면 초보자 추천 중량
  ※유산소 운동의 경우 "무게: 0kg"으로 하고, 횟수 대신 "지속: XX분"을 기재
- **횟수 (10-15회)** ← 유산소의 경우 "지속: 20-30분"
- 세트 수 (2-3세트) ← 유산소의 경우 "1세트"
- 휴식 시간 (90-120초)
- 자세 포인트

【조건】
- ${targetParts.join(', ')}를 집중적으로 트레이닝
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **유산소 운동만** 제안 (근력 운동은 포함하지 마세요)" : "- 기본 종목 중심"}
- 30-45분 내 완료 가능

**중요: 각 종목에 구체적인 중량과 횟수를 반드시 기재하세요. 유산소 운동의 경우 중량 0kg, 시간을 XX분 형식으로 기재하세요.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**절대 엄수: 유산소 운동 데이터베이스의 종목만 사용하세요. 벤치 프레스, 스쿼트 등의 근력 운동 종목은 절대 포함하지 마세요.**" : ""}
''';
      }
    } else if (currentLevel == AppLocalizations.of(context)!.levelIntermediate) {
      // 中級者向け
      return '''
당신은 전문 퍼스널 트레이너입니다. 중급자를 위한 "${targetParts.isEmpty ? "전신" : targetParts.join(', ')}" 트레이닝 메뉴를 제안해 주세요.

$_advancedExerciseDatabase
$historyInfo
【대상】
- 중급 트레이너 (6개월~2년 경력)
- 근력과 근비대를 목표로 하는 분
- 더 고급 기술을 습득하고 싶은 분

【제안 형식】
**반드시 다음 형식으로 출력하세요:**

\`\`\`
## 부위별 트레이닝 메뉴

**종목 1: 종목명**
* 무게: XXkg
* 횟수: XX회
* 세트 수: X세트
* 휴식 시간: XX초
* 팁: 설명

**종목 2: 종목명**
* 무게: XXkg
* 횟수: XX회
* 세트 수: X세트
\`\`\`

각 종목에 대해 다음 정보를 포함해 주세요:
- 종목명 (종목 데이터베이스에서 선택)
- **구체적인 중량 (kg)** ← 기록 1RM의 70-85%를 목안으로 제안
  ※유산소 운동의 경우 "무게: 0kg"으로 하고, 횟수 대신 "지속: XX분"을 기재
- **횟수 (8-12회)** ← 유산소의 경우 "지속: 30-45분" 또는 "인터벌 형식"
- 세트 수 (3-4세트) ← 유산소의 경우 "1세트"
- 휴식 시간 (60-90초)
- 기술 팁 (드롭 세트, 슈퍼 세트 등)

【조건】
- ${targetParts.isEmpty ? "모든 부위를 균형 있게 트레이닝" : "${targetParts.join(', ')}를 집중적으로 트레이닝"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **유산소 운동만** 제안 (근력 운동은 포함하지 마세요)\n- 다양한 유산소: HIIT, 지구력 달리기, 인터벌 등" : "- 프리 웨이트 중심\n- 근비대 강조"}
- 45-60분 내 완료 가능

**중요: 각 종목에 구체적인 중량과 횟수를 반드시 기재하세요. 유산소 운동의 경우 중량 0kg, 시간을 XX분 형식으로 기재하세요.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**절대 엄수: 유산소 운동 데이터베이스의 종목만 사용하세요. 벤치 프레스, 스쿼트, 데드리프트 등의 근력 운동 종목은 절대 포함하지 마세요.**" : ""}
''';
    } else {
      // 上級者向け
      return '''
당신은 전문 퍼스널 트레이너입니다. 고급자를 위한 "${targetParts.isEmpty ? "전신" : targetParts.join(', ')}" 트레이닝 메뉴를 제안해 주세요.

$_advancedExerciseDatabase
$historyInfo
【대상】
- 고급 트레이너 (2년 이상 경력)
- 최대 근력과 근육 성장을 목표로 하는 분
- 고강도 트레이닝에 익숙한 분

【제안 형식】
**반드시 다음 형식으로 출력하세요:**

\`\`\`
## 부위별 트레이닝 메뉴

**종목 1: 종목명**
* 무게: XXkg (기록 1RM 기준: 85-95%)
* 횟수: XX회 (5-8회, 또는 유산소의 경우: HIIT XX분 또는 지구력 달리기 XX분)
* 세트 수: X세트 (4-5세트, 유산소의 경우: 1세트)
* 휴식 시간: XX초 (120-180초)
* 고급 기술: 피라미드법, 5x5법 등

**종목 2: 종목명**
* 무게: XXkg
* 횟수: XX회
* 세트 수: X세트
\`\`\`

각 종목에 대해 다음 정보를 포함해 주세요:
- 종목명 (데이터베이스에서 선택)
- **구체적인 중량 (kg)** ← 기록 1RM의 85-95%를 목표로 제안
  ※유산소 운동의 경우 "무게: 0kg"으로 하고, 횟수 대신 "지속: XX분"을 기재
- **횟수 (5-8회)** ← 유산소의 경우 "HIIT 형식 XX분" 또는 "지구력 달리기 XX분"
- 세트 수 (4-5세트) ← 유산소의 경우 "1세트"
- 휴식 시간 (120-180초)
- 고급 기술 (피라미드, 5x5 등)

【조건】
- ${targetParts.isEmpty ? "전신을 최대한 부하로 트레이닝" : "${targetParts.join(', ')}를 극한까지 트레이닝"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **유산소 운동만** 제안\n- 다양한 유산소: HIIT, 지구력, 인터벌 등" : "- 복합 운동 강조\n- 근력 최대화"}
- 60-90분 내 완료 가능

**중요: 각 종목에 구체적인 중량과 횟수를 반드시 기재하세요. 유산소 운동의 경우 중량 0kg, 시간을 XX분 형식으로 기재하세요. 유산소 선택 시 유산소 운동만 사용하세요.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**절대 엄수: 유산소 운동 데이터베이스의 종목만 사용하세요. 벤치 프레스, 스쿼트, 데드리프트, 숄더 프레스 등의 근력 운동 종목은 절대 포함하지 마세요.**" : ""}
''';
    }
  }
  
  /// 🆕 Build #24.1 Hotfix9.4: スペイン語専用プロンプト（完全にローカライズ）
  String _buildSpanishPrompt(List<String> bodyParts) {
    // トレーニング履歴情報を構築
    String historyInfo = '';
    if (_exerciseHistory.isNotEmpty) {
      historyInfo = '\n【Historial de entrenamiento (últimos 30 días)】\n';
      for (final entry in _exerciseHistory.entries) {
        final exerciseName = entry.key;
        final maxWeight = entry.value['maxWeight'];
        final max1RM = entry.value['max1RM'];
        final totalSets = entry.value['totalSets'];
        historyInfo += '- $exerciseName: Peso máximo=${maxWeight}kg, 1RM estimado=${max1RM?.toStringAsFixed(1)}kg, Total de series=$totalSets\n';
      }
      historyInfo += '\nPor favor, utiliza el historial anterior para sugerir pesos y repeticiones apropiados.\n';
    }
    
    final targetParts = bodyParts;
    final currentLevel = _selectedLevel;
    
    // 初心者レベル
    if (currentLevel == AppLocalizations.of(context)!.levelBeginner) {
      if (targetParts.isEmpty) {
        return '''
Eres un entrenador personal profesional. Por favor, sugiere un menú de entrenamiento de cuerpo completo para principiantes.

$_beginnerExerciseDatabase
$historyInfo
【Público objetivo】
- Principiantes del gimnasio (1-3 meses de experiencia)
- Aquellos que buscan desarrollar condición física básica
- Aquellos que quieren aprender la forma adecuada

【Formato de salida】
**Por favor, sigue estrictamente este formato:**

\`\`\`
## Menú de entrenamiento por parte del cuerpo

**Ejercicio 1: Nombre del ejercicio**
* Peso: XXkg
* Repeticiones: XX
* Series: X
* Tiempo de descanso: XXseg
* Consejos de forma: Explicación

**Ejercicio 2: Nombre del ejercicio**
* Peso: XXkg
* Repeticiones: XX
* Series: X
\`\`\`

Por favor, incluye la siguiente información para cada ejercicio:
- Nombre del ejercicio (seleccionado de la base de datos de ejercicios)
- **Peso específico (kg)** ← Usa el historial como referencia, o sugiere pesos amigables para principiantes
  ※Para ejercicios cardiovasculares, usa "Peso: 0kg" y especifica "Duración: XX minutos" en lugar de repeticiones
- **Repeticiones (10-15)** ← Para cardio, usa "Duración: 20-30 minutos"
- Series (2-3 series) ← Para cardio, usa "1 serie"
- Tiempo de descanso (90-120 segundos)
- Consejos de forma para principiantes

【Condiciones】
- Entrenamiento equilibrado en todas las partes del cuerpo
- Enfoque en ejercicios básicos
- Completable en 30-45 minutos

**Importante: Siempre especifica el peso y las repeticiones concretas para cada ejercicio. Para ejercicios cardiovasculares, usa peso 0kg y especifica la duración en formato XX minutos.**
''';
      } else {
        return '''
Eres un entrenador personal profesional. Por favor, sugiere un menú de entrenamiento de "${targetParts.join(', ')}" para principiantes.

$_beginnerExerciseDatabase
$historyInfo
【Público objetivo】
- Principiantes del gimnasio (1-3 meses de experiencia)
- Aquellos que quieren enfocarse en entrenar ${targetParts.join(', ')}

【Formato de salida】
**Por favor, sigue estrictamente este formato:**

\`\`\`
## Menú de entrenamiento por parte del cuerpo

**Ejercicio 1: Nombre del ejercicio**
* Peso: XXkg
* Repeticiones: XX
* Series: X
* Tiempo de descanso: XXseg
* Consejos de forma: Explicación

**Ejercicio 2: Nombre del ejercicio**
* Peso: XXkg
* Repeticiones: XX
* Series: X
\`\`\`

Por favor, incluye la siguiente información para cada ejercicio:
- Nombre del ejercicio (seleccionado de la base de datos de ejercicios)
- **Peso específico (kg)** ← Usa el historial como referencia, o sugiere pesos amigables para principiantes
  ※Para ejercicios cardiovasculares, usa "Peso: 0kg" y especifica "Duración: XX minutos" en lugar de repeticiones
- **Repeticiones (10-15)** ← Para cardio, usa "Duración: 20-30 minutos"
- Series (2-3 series) ← Para cardio, usa "1 serie"
- Tiempo de descanso (90-120 segundos)
- Consejos de forma

【Condiciones】
- Enfoque en entrenar ${targetParts.join(', ')}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Sugiere **solo ejercicios cardiovasculares** (no incluyas entrenamiento con pesas)" : "- Enfoque en ejercicios básicos"}
- Completable en 30-45 minutos

**Importante: Siempre especifica el peso y las repeticiones concretas para cada ejercicio. Para ejercicios cardiovasculares, usa peso 0kg y especifica la duración en formato XX minutos.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**ESTRICTAMENTE: Usa SOLO ejercicios de la base de datos cardiovascular. Nunca incluyas press de banca, sentadillas u otros ejercicios de entrenamiento con pesas.**" : ""}
''';
      }
    } else if (currentLevel == AppLocalizations.of(context)!.levelIntermediate) {
      return '''
Eres un entrenador personal profesional. Por favor, sugiere un menú de entrenamiento de "${targetParts.isEmpty ? "cuerpo completo" : targetParts.join(', ')}" para intermedios.

$_advancedExerciseDatabase
$historyInfo
【Público objetivo】
- Practicantes intermedios (6 meses a 2 años de experiencia)
- Aquellos que buscan fuerza e hipertrofia muscular
- Aquellos que quieren dominar técnicas más avanzadas

【Formato de salida】
**Por favor, sigue estrictamente este formato:**

\`\`\`
## Menú de entrenamiento por parte del cuerpo

**Ejercicio 1: Nombre del ejercicio**
* Peso: XXkg
* Repeticiones: XX
* Series: X
* Tiempo de descanso: XXseg
* Consejos: Explicación

**Ejercicio 2: Nombre del ejercicio**
* Peso: XXkg
* Repeticiones: XX
* Series: X
\`\`\`

Por favor, incluye la siguiente información para cada ejercicio:
- Nombre del ejercicio (seleccionado de la base de datos de ejercicios)
- **Peso específico (kg)** ← Sugiere 70-85% del 1RM histórico
  ※Para ejercicios cardiovasculares, usa "Peso: 0kg" y especifica "Duración: XX minutos" en lugar de repeticiones
- **Repeticiones (8-12)** ← Para cardio, usa "Duración: 30-45 minutos" o "Formato de intervalos"
- Series (3-4 series) ← Para cardio, usa "1 serie"
- Tiempo de descanso (60-90 segundos)
- Consejos de técnica (series descendentes, superseries, etc.)

【Condiciones】
- ${targetParts.isEmpty ? "Entrenamiento equilibrado en todas las partes del cuerpo" : "Enfoque intensivo en ${targetParts.join(', ')}"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Sugiere **solo ejercicios cardiovasculares** (no incluyas entrenamiento con pesas)\n- Variedad de cardio: HIIT, carrera de resistencia, intervalos, etc." : "- Enfoque en pesas libres\n- Énfasis en hipertrofia muscular"}
- Completable en 45-60 minutos

**Importante: Siempre especifica el peso y las repeticiones concretas para cada ejercicio. Para ejercicios cardiovasculares, usa peso 0kg y especifica la duración en formato XX minutos.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**ESTRICTAMENTE: Usa SOLO ejercicios de la base de datos cardiovascular. Nunca incluyas press de banca, sentadillas, peso muerto u otros ejercicios de entrenamiento con pesas.**" : ""}
''';
    } else {
      return '''
Eres un entrenador personal profesional. Por favor, sugiere un menú de entrenamiento de "${targetParts.isEmpty ? "cuerpo completo" : targetParts.join(', ')}" para avanzados.

$_advancedExerciseDatabase
$historyInfo
【Público objetivo】
- Practicantes avanzados (más de 2 años de experiencia)
- Aquellos que buscan fuerza máxima y crecimiento muscular
- Aquellos experimentados con entrenamiento de alta intensidad

【Formato de salida】
**Por favor, sigue estrictamente este formato:**

\`\`\`
## Menú de entrenamiento por parte del cuerpo

**Ejercicio 1: Nombre del ejercicio**
* Peso: XXkg (basado en 1RM histórico: 85-95%)
* Repeticiones: XX (5-8 repeticiones, o para cardio: HIIT XX minutos o Carrera de resistencia XX minutos)
* Series: X (4-5 series, para cardio: 1 serie)
* Tiempo de descanso: XXseg (120-180 segundos)
* Técnicas avanzadas: Método piramidal, método 5x5, etc.

**Ejercicio 2: Nombre del ejercicio**
* Peso: XXkg
* Repeticiones: XX
* Series: X
\`\`\`

Por favor, incluye la siguiente información para cada ejercicio:
- Nombre del ejercicio (seleccionado de la base de datos)
- **Peso específico (kg)** ← Sugiere 85-95% del 1RM histórico
  ※Para ejercicios cardiovasculares, usa "Peso: 0kg" y especifica "Duración: XX minutos" en lugar de repeticiones
- **Repeticiones (5-8)** ← Para cardio, usa "Formato HIIT XX minutos" o "Carrera de resistencia XX minutos"
- Series (4-5 series) ← Para cardio, usa "1 serie"
- Tiempo de descanso (120-180 segundos)
- Técnicas avanzadas (piramidal, 5x5, etc.)

【Condiciones】
- ${targetParts.isEmpty ? "Entrenamiento de cuerpo completo con carga máxima" : "Entrena ${targetParts.join(', ')} al límite absoluto"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Sugiere **solo ejercicios cardiovasculares**\n- Mezcla de cardio: HIIT, resistencia, intervalos, etc." : "- Énfasis en movimientos compuestos\n- Maximizar la fuerza"}
- Completable en 60-90 minutos

**Importante: Siempre especifica el peso y las repeticiones concretas para cada ejercicio. Para ejercicios cardiovasculares, usa peso 0kg y duración en formato XX minutos. Usa solo ejercicios cardiovasculares cuando se seleccione cardio.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**ESTRICTAMENTE: Usa SOLO ejercicios de la base de datos cardiovascular. Nunca incluyas press de banca, sentadillas, peso muerto, press de hombros u otros ejercicios de entrenamiento con pesas.**" : ""}
''';
    }
  }
  
  /// 🆕 Build #24.1 Hotfix9.4: 中国語専用プロンプト（完全にローカライズ）
  String _buildChinesePrompt(List<String> bodyParts) {
    // トレーニング履歴情報を構築
    String historyInfo = '';
    if (_exerciseHistory.isNotEmpty) {
      historyInfo = '\n【最近1个月的训练记录】\n';
      for (final entry in _exerciseHistory.entries) {
        final exerciseName = entry.key;
        final maxWeight = entry.value['maxWeight'];
        final max1RM = entry.value['max1RM'];
        final totalSets = entry.value['totalSets'];
        historyInfo += '- $exerciseName: 最大重量=${maxWeight}kg, 估计1RM=${max1RM?.toStringAsFixed(1)}kg, 总组数=$totalSets\n';
      }
      historyInfo += '\n请参考上述记录，建议适当的重量和次数。\n';
    }
    
    final targetParts = bodyParts;
    final currentLevel = _selectedLevel;
    
    // 初心者レベル
    if (currentLevel == AppLocalizations.of(context)!.levelBeginner) {
      if (targetParts.isEmpty) {
        return '''
你是一名专业的私人教练。请为初学者建议全身训练菜单。

$_beginnerExerciseDatabase
$historyInfo
【目标对象】
- 健身房初学者（1-3个月经验）
- 希望打造基础体能的人
- 想要学习训练姿势的人

【建议格式】
**请严格按照以下格式输出：**

\`\`\`
## 部位训练菜单

**项目 1: 项目名称**
* 重量: XXkg
* 次数: XX次
* 组数: X组
* 休息时间: XX秒
* 姿势要点: 说明

**项目 2: 项目名称**
* 重量: XXkg
* 次数: XX次
* 组数: X组
\`\`\`

请为每个项目包含以下信息：
- 项目名称（从项目数据库中选择）
- **具体重量（kg）** ← 如有记录请参考，否则建议初学者适用重量
  ※有氧运动的情况下使用"重量: 0kg"，并用"持续: XX分钟"代替次数
- **次数（10-15次）** ← 有氧运动的情况下使用"持续: 20-30分钟"
- 组数（2-3组）← 有氧运动的情况下使用"1组"
- 休息时间（90-120秒）
- 初学者姿势要点

【条件】
- 所有部位均衡训练
- 以基础项目为中心
- 30-45分钟内完成

**重要：每个项目必须记载具体的重量和次数。有氧运动的情况下重量0kg，时间用XX分钟格式记载。**
''';
      } else {
        return '''
你是一名专业的私人教练。请为初学者建议"${targetParts.join('、')}"训练菜单。

$_beginnerExerciseDatabase
$historyInfo
【目标对象】
- 健身房初学者（1-3个月经验）
- 希望重点锻炼${targetParts.join('、')}的人

【建议格式】
**请严格按照以下格式输出：**

\`\`\`
## 部位训练菜单

**项目 1: 项目名称**
* 重量: XXkg
* 次数: XX次
* 组数: X组
* 休息时间: XX秒
* 姿势要点: 说明

**项目 2: 项目名称**
* 重量: XXkg
* 次数: XX次
* 组数: X组
\`\`\`

请为每个项目包含以下信息：
- 项目名称（从项目数据库中选择）
- **具体重量（kg）** ← 如有记录请参考，否则建议初学者适用重量
  ※有氧运动的情况下使用"重量: 0kg"，并用"持续: XX分钟"代替次数
- **次数（10-15次）** ← 有氧运动的情况下使用"持续: 20-30分钟"
- 组数（2-3组）← 有氧运动的情况下使用"1组"
- 休息时间（90-120秒）
- 姿势要点

【条件】
- 重点训练${targetParts.join('、')}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **仅建议有氧运动**（不包括力量训练）" : "- 以基础项目为中心"}
- 30-45分钟内完成

**重要：每个项目必须记载具体的重量和次数。有氧运动的情况下重量0kg，时间用XX分钟格式记载。**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**绝对遵守：仅使用有氧运动数据库中的项目。绝对不要包括卧推、深蹲等力量训练项目。**" : ""}
''';
      }
    } else if (currentLevel == AppLocalizations.of(context)!.levelIntermediate) {
      return '''
你是一名专业的私人教练。请为中级者建议"${targetParts.isEmpty ? "全身" : targetParts.join('、')}"训练菜单。

$_advancedExerciseDatabase
$historyInfo
【目标对象】
- 中级训练者（6个月到2年经验）
- 以力量和肌肥大为目标的人
- 想要掌握更高级技术的人

【建议格式】
**请严格按照以下格式输出：**

\`\`\`
## 部位训练菜单

**项目 1: 项目名称**
* 重量: XXkg
* 次数: XX次
* 组数: X组
* 休息时间: XX秒
* 提示: 说明

**项目 2: 项目名称**
* 重量: XXkg
* 次数: XX次
* 组数: X组
\`\`\`

请为每个项目包含以下信息：
- 项目名称（从项目数据库中选择）
- **具体重量（kg）** ← 建议记录1RM的70-85%
  ※有氧运动的情况下使用"重量: 0kg"，并用"持续: XX分钟"代替次数
- **次数（8-12次）** ← 有氧运动的情况下使用"持续: 30-45分钟"或"间歇格式"
- 组数（3-4组）← 有氧运动的情况下使用"1组"
- 休息时间（60-90秒）
- 技术提示（递减组、超级组等）

【条件】
- ${targetParts.isEmpty ? "所有部位均衡训练" : "重点训练${targetParts.join('、')}"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **仅建议有氧运动**（不包括力量训练）\n- 多样化有氧：HIIT、耐力跑、间歇等" : "- 以自由重量为中心\n- 强调肌肥大"}
- 45-60分钟内完成

**重要：每个项目必须记载具体的重量和次数。有氧运动的情况下重量0kg，时间用XX分钟格式记载。**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**绝对遵守：仅使用有氧运动数据库中的项目。绝对不要包括卧推、深蹲、硬拉等力量训练项目。**" : ""}
''';
    } else {
      return '''
你是一名专业的私人教练。请为高级者建议"${targetParts.isEmpty ? "全身" : targetParts.join('、')}"训练菜单。

$_advancedExerciseDatabase
$historyInfo
【目标对象】
- 高级训练者（2年以上经验）
- 以最大力量和肌肉生长为目标的人
- 熟悉高强度训练的人

【建议格式】
**请严格按照以下格式输出：**

\`\`\`
## 部位训练菜单

**项目 1: 项目名称**
* 重量: XXkg（基于记录1RM：85-95%）
* 次数: XX次（5-8次，或有氧运动的情况下：HIIT XX分钟或耐力跑XX分钟）
* 组数: X组（4-5组，有氧运动的情况下：1组）
* 休息时间: XX秒（120-180秒）
* 高级技术: 金字塔法、5x5法等

**项目 2: 项目名称**
* 重量: XXkg
* 次数: XX次
* 组数: X组
\`\`\`

请为每个项目包含以下信息：
- 项目名称（从数据库中选择）
- **具体重量（kg）** ← 建议记录1RM的85-95%
  ※有氧运动的情况下使用"重量: 0kg"，并用"持续: XX分钟"代替次数
- **次数（5-8次）** ← 有氧运动的情况下使用"HIIT格式XX分钟"或"耐力跑XX分钟"
- 组数（4-5组）← 有氧运动的情况下使用"1组"
- 休息时间（120-180秒）
- 高级技术（金字塔、5x5等）

【条件】
- ${targetParts.isEmpty ? "全身以最大负荷训练" : "${targetParts.join('、')}训练到极限"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- **仅建议有氧运动**\n- 多样化有氧：HIIT、耐力、间歇等" : "- 强调复合运动\n- 最大化力量"}
- 60-90分钟内完成

**重要：每个项目必须记载具体的重量和次数。有氧运动的情况下重量0kg，时间用XX分钟格式记载。选择有氧运动时仅使用有氧运动。**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**绝对遵守：仅使用有氧运动数据库中的项目。绝对不要包括卧推、深蹲、硬拉、肩推等力量训练项目。**" : ""}
''';
    }
  }
  
  /// 🆕 Build #24.1 Hotfix9.4: ドイツ語専用プロンプト（完全にローカライズ）
  String _buildGermanPrompt(List<String> bodyParts) {
    // トレーニング履歴情報を構築
    String historyInfo = '';
    if (_exerciseHistory.isNotEmpty) {
      historyInfo = '\n【Trainingshistorie (letzte 30 Tage)】\n';
      for (final entry in _exerciseHistory.entries) {
        final exerciseName = entry.key;
        final maxWeight = entry.value['maxWeight'];
        final max1RM = entry.value['max1RM'];
        final totalSets = entry.value['totalSets'];
        historyInfo += '- $exerciseName: Maximalgewicht=${maxWeight}kg, Geschätztes 1RM=${max1RM?.toStringAsFixed(1)}kg, Gesamtsätze=$totalSets\n';
      }
      historyInfo += '\nBitte verwenden Sie die obige Historie, um geeignete Gewichte und Wiederholungen vorzuschlagen.\n';
    }
    
    final targetParts = bodyParts;
    final currentLevel = _selectedLevel;
    
    // 初心者レベル
    if (currentLevel == AppLocalizations.of(context)!.levelBeginner) {
      if (targetParts.isEmpty) {
        return '''
Sie sind ein professioneller Personal Trainer. Bitte schlagen Sie ein Ganzkörper-Trainingsmenü für Anfänger vor.

$_beginnerExerciseDatabase
$historyInfo
【Zielgruppe】
- Fitness-Anfänger (1-3 Monate Erfahrung)
- Diejenigen, die eine grundlegende Fitness aufbauen möchten
- Diejenigen, die die richtige Form lernen möchten

【Ausgabeformat】
**Bitte folgen Sie strikt diesem Format:**

\`\`\`
## Trainingsmenü nach Körperteilen

**Übung 1: Übungsname**
* Gewicht: XXkg
* Wiederholungen: XX
* Sätze: X
* Pausenzeit: XXSek
* Formtipps: Erklärung

**Übung 2: Übungsname**
* Gewicht: XXkg
* Wiederholungen: XX
* Sätze: X
\`\`\`

Bitte fügen Sie für jede Übung folgende Informationen hinzu:
- Übungsname (aus der Übungsdatenbank ausgewählt)
- **Spezifisches Gewicht (kg)** ← Verwenden Sie die Historie als Referenz oder schlagen Sie anfängerfreundliche Gewichte vor
  ※Für Cardio-Übungen verwenden Sie "Gewicht: 0kg" und geben Sie "Dauer: XX Minuten" anstelle von Wiederholungen an
- **Wiederholungen (10-15)** ← Für Cardio verwenden Sie "Dauer: 20-30 Minuten"
- Sätze (2-3 Sätze) ← Für Cardio verwenden Sie "1 Satz"
- Pausenzeit (90-120 Sekunden)
- Formtipps für Anfänger

【Bedingungen】
- Ausgewogenes Training aller Körperteile
- Fokus auf grundlegende Übungen
- In 30-45 Minuten abschließbar

**Wichtig: Geben Sie immer konkretes Gewicht und Wiederholungen für jede Übung an. Für Cardio-Übungen verwenden Sie Gewicht 0kg und geben Sie die Dauer im Format XX Minuten an.**
''';
      } else {
        return '''
Sie sind ein professioneller Personal Trainer. Bitte schlagen Sie ein "${targetParts.join(', ')}" Trainingsmenü für Anfänger vor.

$_beginnerExerciseDatabase
$historyInfo
【Zielgruppe】
- Fitness-Anfänger (1-3 Monate Erfahrung)
- Diejenigen, die sich auf das Training von ${targetParts.join(', ')} konzentrieren möchten

【Ausgabeformat】
**Bitte folgen Sie strikt diesem Format:**

\`\`\`
## Trainingsmenü nach Körperteilen

**Übung 1: Übungsname**
* Gewicht: XXkg
* Wiederholungen: XX
* Sätze: X
* Pausenzeit: XXSek
* Formtipps: Erklärung

**Übung 2: Übungsname**
* Gewicht: XXkg
* Wiederholungen: XX
* Sätze: X
\`\`\`

Bitte fügen Sie für jede Übung folgende Informationen hinzu:
- Übungsname (aus der Übungsdatenbank ausgewählt)
- **Spezifisches Gewicht (kg)** ← Verwenden Sie die Historie als Referenz oder schlagen Sie anfängerfreundliche Gewichte vor
  ※Für Cardio-Übungen verwenden Sie "Gewicht: 0kg" und geben Sie "Dauer: XX Minuten" anstelle von Wiederholungen an
- **Wiederholungen (10-15)** ← Für Cardio verwenden Sie "Dauer: 20-30 Minuten"
- Sätze (2-3 Sätze) ← Für Cardio verwenden Sie "1 Satz"
- Pausenzeit (90-120 Sekunden)
- Formtipps

【Bedingungen】
- Fokus auf Training von ${targetParts.join(', ')}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Schlagen Sie **nur Cardio-Übungen** vor (kein Krafttraining einschließen)" : "- Fokus auf grundlegende Übungen"}
- In 30-45 Minuten abschließbar

**Wichtig: Geben Sie immer konkretes Gewicht und Wiederholungen für jede Übung an. Für Cardio-Übungen verwenden Sie Gewicht 0kg und geben Sie die Dauer im Format XX Minuten an.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**STRIKT: Verwenden Sie NUR Übungen aus der Cardio-Datenbank. Fügen Sie niemals Bankdrücken, Kniebeugen oder andere Krafttrainingsübungen hinzu.**" : ""}
''';
      }
    } else if (currentLevel == AppLocalizations.of(context)!.levelIntermediate) {
      return '''
Sie sind ein professioneller Personal Trainer. Bitte schlagen Sie ein "${targetParts.isEmpty ? "Ganzkörper" : targetParts.join(', ')}" Trainingsmenü für Fortgeschrittene vor.

$_advancedExerciseDatabase
$historyInfo
【Zielgruppe】
- Fortgeschrittene Trainierende (6 Monate bis 2 Jahre Erfahrung)
- Diejenigen, die Kraft und Muskelhypertrophie anstreben
- Diejenigen, die fortgeschrittenere Techniken beherrschen möchten

【Ausgabeformat】
**Bitte folgen Sie strikt diesem Format:**

\`\`\`
## Trainingsmenü nach Körperteilen

**Übung 1: Übungsname**
* Gewicht: XXkg
* Wiederholungen: XX
* Sätze: X
* Pausenzeit: XXSek
* Tipps: Erklärung

**Übung 2: Übungsname**
* Gewicht: XXkg
* Wiederholungen: XX
* Sätze: X
\`\`\`

Bitte fügen Sie für jede Übung folgende Informationen hinzu:
- Übungsname (aus der Übungsdatenbank ausgewählt)
- **Spezifisches Gewicht (kg)** ← Schlagen Sie 70-85% des historischen 1RM vor
  ※Für Cardio-Übungen verwenden Sie "Gewicht: 0kg" und geben Sie "Dauer: XX Minuten" anstelle von Wiederholungen an
- **Wiederholungen (8-12)** ← Für Cardio verwenden Sie "Dauer: 30-45 Minuten" oder "Intervallformat"
- Sätze (3-4 Sätze) ← Für Cardio verwenden Sie "1 Satz"
- Pausenzeit (60-90 Sekunden)
- Technik-Tipps (Drop-Sets, Supersätze, etc.)

【Bedingungen】
- ${targetParts.isEmpty ? "Ausgewogenes Training aller Körperteile" : "Intensiver Fokus auf ${targetParts.join(', ')}"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Schlagen Sie **nur Cardio-Übungen** vor (kein Krafttraining einschließen)\n- Vielfalt von Cardio: HIIT, Ausdauerlauf, Intervalle, etc." : "- Fokus auf freie Gewichte\n- Betonung auf Muskelhypertrophie"}
- In 45-60 Minuten abschließbar

**Wichtig: Geben Sie immer konkretes Gewicht und Wiederholungen für jede Übung an. Für Cardio-Übungen verwenden Sie Gewicht 0kg und geben Sie die Dauer im Format XX Minuten an.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**STRIKT: Verwenden Sie NUR Übungen aus der Cardio-Datenbank. Fügen Sie niemals Bankdrücken, Kniebeugen, Kreuzheben oder andere Krafttrainingsübungen hinzu.**" : ""}
''';
    } else {
      return '''
Sie sind ein professioneller Personal Trainer. Bitte schlagen Sie ein "${targetParts.isEmpty ? "Ganzkörper" : targetParts.join(', ')}" Trainingsmenü für Experten vor.

$_advancedExerciseDatabase
$historyInfo
【Zielgruppe】
- Experten-Trainierende (mehr als 2 Jahre Erfahrung)
- Diejenigen, die maximale Kraft und Muskelwachstum anstreben
- Diejenigen, die mit hochintensivem Training vertraut sind

【Ausgabeformat】
**Bitte folgen Sie strikt diesem Format:**

\`\`\`
## Trainingsmenü nach Körperteilen

**Übung 1: Übungsname**
* Gewicht: XXkg (basierend auf historischem 1RM: 85-95%)
* Wiederholungen: XX (5-8 Wiederholungen, oder für Cardio: HIIT XX Minuten oder Ausdauerlauf XX Minuten)
* Sätze: X (4-5 Sätze, für Cardio: 1 Satz)
* Pausenzeit: XXSek (120-180 Sekunden)
* Fortgeschrittene Techniken: Pyramidenmethode, 5x5-Methode, etc.

**Übung 2: Übungsname**
* Gewicht: XXkg
* Wiederholungen: XX
* Sätze: X
\`\`\`

Bitte fügen Sie für jede Übung folgende Informationen hinzu:
- Übungsname (aus der Datenbank ausgewählt)
- **Spezifisches Gewicht (kg)** ← Schlagen Sie 85-95% des historischen 1RM vor
  ※Für Cardio-Übungen verwenden Sie "Gewicht: 0kg" und geben Sie "Dauer: XX Minuten" anstelle von Wiederholungen an
- **Wiederholungen (5-8)** ← Für Cardio verwenden Sie "HIIT-Format XX Minuten" oder "Ausdauerlauf XX Minuten"
- Sätze (4-5 Sätze) ← Für Cardio verwenden Sie "1 Satz"
- Pausenzeit (120-180 Sekunden)
- Fortgeschrittene Techniken (Pyramide, 5x5, etc.)

【Bedingungen】
- ${targetParts.isEmpty ? "Ganzkörper-Training mit maximaler Last" : "Trainieren Sie ${targetParts.join(', ')} bis zur absoluten Grenze"}
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "- Schlagen Sie **nur Cardio-Übungen** vor\n- Mix von Cardio: HIIT, Ausdauer, Intervalle, etc." : "- Betonung auf zusammengesetzte Bewegungen\n- Maximierung der Kraft"}
- In 60-90 Minuten abschließbar

**Wichtig: Geben Sie immer konkretes Gewicht und Wiederholungen für jede Übung an. Für Cardio-Übungen verwenden Sie Gewicht 0kg und Dauer im Format XX Minuten. Verwenden Sie nur Cardio-Übungen, wenn Cardio ausgewählt ist.**
${targetParts.contains(AppLocalizations.of(context)!.exerciseCardio) ? "**STRIKT: Verwenden Sie NUR Übungen aus der Cardio-Datenbank. Fügen Sie niemals Bankdrücken, Kniebeugen, Kreuzheben, Schulterdrücken oder andere Krafttrainingsübungen hinzu.**" : ""}
''';
    }
  }
  
  /// リワード広告ダイアログ表示
  Future<bool?> _showRewardAdDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_circle_outline, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.workout_80a340fe),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.workout_27e98563,
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.workout_21745d7a,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: Icon(Icons.play_arrow),
            label: Text(AppLocalizations.of(context)!.workout_d489aa48),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  /// リワード広告を表示してクレジット獲得
  Future<bool> _showRewardAdAndEarn() async {
    // グローバルインスタンスを使用（main.dartで初期化済み）
    final rewardAdService = globalRewardAdService;
    
    // 広告読み込み待機ダイアログ表示
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.workout_65c94ed8),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // 広告を読み込む
    await rewardAdService.loadRewardedAd();
    
    // 読み込み完了まで最大5秒待機
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (rewardAdService.isAdReady()) {
        break;
      }
    }
    
    // ローディングダイアログを閉じる
    if (mounted) {
      Navigator.of(context).pop();
    }
    
    // 広告表示
    if (rewardAdService.isAdReady()) {
      final success = await rewardAdService.showRewardedAd();
      
      if (success) {
        // 広告視聴成功メッセージ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.ai_rewardEarned),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return true;
      }
    }
    
    return false;
  }
  
  /// アップグレード促進ダイアログ表示
  Future<void> _showUpgradeDialog(String message) async {
    // 🎯 新しいペイウォールダイアログを使用（AI追加パック訴求含む）
    return PaywallDialog.show(context, PaywallType.aiLimitReached);
  }
  
  /// メニュー保存
  /// 🔧 v1.0.222: 選択された種目をトレーニング記録画面に渡して遷移
  Future<void> _saveSelectedExercisesToWorkoutLog() async {
    try {
      if (_selectedExerciseIndices.isEmpty) return;
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(AppLocalizations.of(context)!.userNotAuthenticated);
      }
      
      // 選択された種目を抽出
      final selectedExercises = _selectedExerciseIndices
          .map((index) => _parsedExercises[index])
          .toList();
      
      debugPrint('✅ AIコーチ: ${selectedExercises.length}種目をトレーニング記録画面に渡します');
      
      // トレーニング記録画面に遷移（データを引き継ぐ）
      if (mounted) {
        await Navigator.of(context).pushNamed(
          '/add-workout',
          arguments: {
            'fromAICoach': true,
            'selectedExercises': selectedExercises,
            'userLevel': _selectedLevel, // 初心者・中級者・上級者
            'exerciseHistory': _exerciseHistory, // 1RM計算用の履歴
          },
        );
        
        // 戻ってきたら選択をリセット
        if (mounted) {
        setState(() {
          _selectedExerciseIndices.clear();
        });
        }
      }
    } catch (e) {
      debugPrint('❌ トレーニング記録画面への遷移エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.general_navigationError + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _saveMenu() async {
    try {
      if (_generatedMenu == null) return;

      final selectedParts = _selectedBodyParts.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('aiCoachingHistory')
          .add({
        'bodyParts': selectedParts,
        'menu': _generatedMenu,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.workout_b7932eef),
            backgroundColor: Colors.green,
          ),
        );
      }

      // 履歴を再読み込み
      _loadHistory();

      debugPrint('✅ メニュー保存成功');
    } catch (e) {
      debugPrint('❌ メニュー保存エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveWorkoutError + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ========================================
// Tab 2: 成長予測タブ
// ========================================

class _GrowthPredictionTab extends StatefulWidget {
  @override
  State<_GrowthPredictionTab> createState() => _GrowthPredictionTabState();
}

class _GrowthPredictionTabState extends State<_GrowthPredictionTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // フォーム入力値
  final _formKey = GlobalKey<FormState>();
  final _oneRMController = TextEditingController(); // 🔧 Phase 7 Fix: 1RM入力用コントローラー
  late String _selectedLevel;
  int _selectedFrequency = 3;
  late String _selectedGender;
  late String _selectedBodyPart;
  int _selectedRPE = 8; // 🆕 v1.0.230: RPE（自覚的強度、デフォルト8）

  // 🆕 Phase 7: 自動取得データ
  int? _userAge; // 個人要因設定から取得
  double? _latestBodyWeight; // 体重記録から取得
  DateTime? _weightRecordedAt; // 体重記録日時
  double? _currentOneRM; // 予測の基準となる1RM
  String? _objectiveLevel; // Weight Ratioから判定された客観的レベル
  double? _weightRatio; // 1RM ÷ 体重

  // 予測結果
  Map<String, dynamic>? _predictionResult;
  bool _isLoading = false;  // ✅ 修正: 初期状態はローディングなし

  @override
  void initState() {
    super.initState();
    // 初期化
    final l10n = AppLocalizations.of(context)!;
    _selectedLevel = AppLocalizations.of(context)!.levelBeginner;
    _selectedGender = AppLocalizations.of(context)!.genderFemale;
    _selectedBodyPart = AppLocalizations.of(context)!.musclePecs;
    _levels = [AppLocalizations.of(context)!.levelBeginner, AppLocalizations.of(context)!.levelIntermediate, AppLocalizations.of(context)!.levelAdvanced];
    _genders = [AppLocalizations.of(context)!.genderMale, AppLocalizations.of(context)!.genderFemale];
    _bodyParts = [AppLocalizations.of(context)!.musclePecs, AppLocalizations.of(context)!.bodyPart_8efece65, AppLocalizations.of(context)!.workout_0c5ee6c6, AppLocalizations.of(context)!.workout_da6d5d22, AppLocalizations.of(context)!.workout_0f45a131];
    
    _loadUserData(); // 🆕 Phase 7: 年齢・体重を自動取得
  }

  // レベル選択肢
  late List<String> _levels;

  // 部位選択肢
  late List<String> _bodyParts;
  
  // 性別選択肢
  late List<String> _genders;

  @override
  void dispose() {
    _oneRMController.dispose(); // 🔧 Phase 7 Fix: コントローラーを破棄
    super.dispose();
  }

  // ========================================
  // 🆕 Phase 7: データ自動取得ロジック
  // ========================================

  /// ユーザーデータ（年齢・体重）を自動取得
  Future<void> _loadUserData() async {
    await _loadUserAge();
    await _loadLatestBodyWeight();
  }

  /// 個人要因設定から年齢を取得
  Future<void> _loadUserAge() async {
    try {
      final advancedFatigueService = AdvancedFatigueService();
      final userProfile = await advancedFatigueService.getUserProfile();
      
      if (mounted) {
        if (mounted) {
        setState(() {
          _userAge = userProfile.age;
        });
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Phase 7] 年齢取得エラー: $e');
      // エラー時は null のまま（未設定状態）
    }
  }

  /// 📝 体重記録から最新の体重を取得（インデックス不要・全データ対応版）
  /// 🔧 v1.0.236: Gemini提案を反映 - orderBy削除+クライアント側ソート+フィールド名ゆらぎ対応
  Future<void> _loadLatestBodyWeight() async {
    if (!mounted) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('⚠️ [Phase 7] ユーザーIDが取得できません（未ログイン）');
        if (mounted) {
          if (mounted) {
          setState(() {
            _latestBodyWeight = null;
            _weightRecordedAt = null;
          });
          }
        }
        return;
      }

      debugPrint('🔍 [Phase 7] 体重取得クエリ開始: userId=$userId');

      // 🎯 Gemini提案: orderByを削除し、単純なwhereのみで取得（インデックス不要で高速・確実）
      final snapshot = await FirebaseFirestore.instance
          .collection('body_measurements')
          .where('user_id', isEqualTo: userId)
          .get(); // ⚡ orderBy削除でFirestoreインデックス不要

      debugPrint('📊 [Phase 7] 取得ドキュメント数: ${snapshot.docs.length}件');

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ [Phase 7] データが0件です。体重記録画面で保存してください。');
        if (mounted) {
          if (mounted) {
          setState(() {
            _latestBodyWeight = null;
            _weightRecordedAt = null;
          });
          }
        }
        return;
      }

      // 🔍 デバッグ用: 最初の3件のデータ構造を出力
      for (int i = 0; i < snapshot.docs.length && i < 3; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        debugPrint('  [${i+1}] id: ${doc.id}');
        debugPrint('      weight: ${data['weight']} (${data['weight'].runtimeType})');
        debugPrint('      date: ${data['date']}');
        debugPrint('      timestamp: ${data['timestamp']}');
        debugPrint('      created_at: ${data['created_at']}');
      }

      // 🎯 Gemini提案: クライアント側でソート（日付フィールドのゆらぎを吸収）
      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final dataA = a.data();
        final dataB = b.data();
        
        // 📌 date, timestamp, created_at の順で優先して日付を探す
        final timeA = (dataA['date'] ?? dataA['timestamp'] ?? dataA['created_at']) as Timestamp?;
        final timeB = (dataB['date'] ?? dataB['timestamp'] ?? dataB['created_at']) as Timestamp?;
        
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1; // 日付なしは後ろへ
        if (timeB == null) return -1;
        
        return timeB.compareTo(timeA); // 降順（新しい順）
      });

      // ✅ 最新のデータを取得
      final latestDoc = docs.first;
      final latestData = latestDoc.data();
      final weight = latestData['weight'] as num?; // int/double両対応
      
      // 日付の確認（デバッグ用）
      final recordDate = (latestData['date'] ?? latestData['timestamp'] ?? latestData['created_at']) as Timestamp?;

      debugPrint('✅ [Phase 7] 最新データ特定: ID=${latestDoc.id}, 体重=${weight}kg, 日付=${recordDate?.toDate()}');

      if (weight != null && weight > 0) {
        if (mounted) {
          if (mounted) {
          setState(() {
            _latestBodyWeight = weight.toDouble();
            _weightRecordedAt = recordDate?.toDate();
          });
          }
          
          // 🎯 Weight Ratio計算準備完了の通知
          debugPrint('🎯 [Phase 7] Weight Ratio計算準備完了: 体重=${weight}kg');
        }
      } else {
        debugPrint('⚠️ [Phase 7] 体重データが無効またはゼロ: weight=$weight');
        if (mounted) {
          if (mounted) {
          setState(() {
            _latestBodyWeight = null;
            _weightRecordedAt = null;
          });
          }
        }
      }
    } catch (e, stack) {
      debugPrint('❌ [Phase 7] 体重取得で例外発生: $e');
      debugPrint('   StackTrace: $stack');
      if (mounted) {
        if (mounted) {
        setState(() {
          _latestBodyWeight = null;
          _weightRecordedAt = null;
        });
        }
      }
    }
  }

  /// Weight Ratioを計算し、客観的レベルを判定
  void _calculateWeightRatioAndLevel(double oneRM) {
    if (_latestBodyWeight == null || _latestBodyWeight! <= 0) {
      if (mounted) {
      setState(() {
        _weightRatio = null;
        _objectiveLevel = null;
      });
      }
      return;
    }

    final ratio = oneRM / _latestBodyWeight!;
    final detectedLevel = ScientificDatabase.detectLevelFromWeightRatio(
      oneRM: oneRM,
      bodyWeight: _latestBodyWeight!,
      exerciseName: _selectedBodyPart,
      gender: _selectedGender,
    );

    if (mounted) {
    setState(() {
      _currentOneRM = oneRM;
      _weightRatio = ratio;
      _objectiveLevel = detectedLevel;
    });
    }
  }

  /// 成長予測を実行(サブスクリプションチェック統合)
  Future<void> _executePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    // ========================================
    // 🔐 Step 1: サブスクリプション状態チェック
    // ========================================
    final subscriptionService = SubscriptionService();
    final creditService = AICreditService();
    final rewardAdService = globalRewardAdService;
    
    final currentPlan = await subscriptionService.getCurrentPlan();
    debugPrint('🔍 [成長予測] 現在のプラン: $currentPlan');
    
    // ========================================
    // 🎯 Step 2: AI利用可能性チェック
    // ========================================
    final canUseAIResult = await creditService.canUseAI();
    debugPrint('🔍 [成長予測] AI使用可能: ${canUseAIResult.allowed}');
    
    if (!canUseAIResult.allowed) {
      // 無料プランでAIクレジットがない場合
      if (currentPlan == SubscriptionType.free) {
        // リワード広告で獲得可能かチェック
        final canEarnFromAd = await creditService.canEarnCreditFromAd();
        debugPrint('🔍 [成長予測] 広告視聴可能: $canEarnFromAd');
        
        if (canEarnFromAd) {
          // ========================================
          // 📺 Step 3: リワード広告ダイアログ表示
          // ========================================
          final shouldShowAd = await _showRewardAdDialog();
          
          if (shouldShowAd == true) {
            // 広告を表示してクレジット獲得
            final adSuccess = await _showRewardAdAndEarn();
            
            if (!adSuccess) {
              // 広告表示失敗
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.workout_9d662a8d),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
            // 広告視聴成功 → 下記のAI生成処理に進む
          } else {
            // ユーザーがキャンセル
            return;
          }
        } else {
          // 今月の広告視聴上限に達している
          if (mounted) {
            await _showUpgradeDialog(AppLocalizations.of(context)!.workout_2ee7735b);
          }
          return;
        }
      } else {
        // 有料プランで月次上限に達している
        if (mounted) {
          await _showUpgradeDialog(AppLocalizations.of(context)!.workout_1b17a3c8);
        }
        return;
      }
    }

    // ========================================
    // 🤖 Step 4: AI予測処理(クレジット消費含む)
    // ========================================
    if (mounted) {
    setState(() {
      _isLoading = true;
      _predictionResult = null;
    });
    }

    // 🆕 Phase 7: 必須データのバリデーション
    // 🔧 Phase 7 Fix: _oneRMControllerから1RMを取得
    final oneRMText = _oneRMController.text.trim();
    if (oneRMText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterOneRM),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final oneRM = double.tryParse(oneRMText);
    if (oneRM == null || oneRM <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.workout_199dd9c4),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_userAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.workout_b257cb17),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_latestBodyWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.workout_2375b9ab),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      print('🚀 成長予測開始...');
      final result = await AIPredictionService.predictGrowth(
        currentWeight: oneRM, // 🔧 Phase 7 Fix: controllerから取得した1RM
        level: _objectiveLevel ?? _selectedLevel, // 🆕 Phase 7: 客観的レベル優先
        frequency: _selectedFrequency,
        gender: _selectedGender,
        age: _userAge!, // 🆕 Phase 7: 自動取得した年齢
        bodyPart: _selectedBodyPart,
        monthsAhead: 4,
        rpe: _selectedRPE, // 🆕 v1.0.230: RPE（自覚的強度）
        locale: AppLocalizations.of(context)!.localeName, // 🆕 v1.0.274: Pass user's locale
      );
      print('✅ 成長予測完了: ${result['success']}');

      if (result['success'] == true) {
        // ========================================
        // ✅ Step 5: AI生成成功 → クレジット消費
        // ========================================
        final consumeSuccess = await creditService.consumeAICredit();
        debugPrint('✅ AIクレジット消費: $consumeSuccess');
        
        // 残りクレジット表示
        if (mounted) {
          final statusMessage = await creditService.getAIUsageStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.ai_predictionComplete(statusMessage)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      if (mounted) {
        if (mounted) {
        setState(() {
          _predictionResult = result;
          _isLoading = false;
        });
        }
      }
    } catch (e) {
      print('❌ 成長予測例外: $e');
      if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダー
            _buildHeader(),
            SizedBox(height: 24),

            // 入力フォーム
            _buildInputForm(),
            SizedBox(height: 24),

            // 予測実行ボタン
            _buildPredictButton(),
            SizedBox(height: 32),

            // 予測結果
            if (_isLoading)
              _buildLoadingIndicator()
            else if (_predictionResult != null)
              _buildPredictionResult(),
          ],
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
            Icon(Icons.timeline, size: 40, color: Colors.purple.shade700),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.aiGrowthPrediction,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.scientificPrediction,
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
            Text(
              'あなたの情報を入力',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // 🆕 Phase 7: 年齢表示（自動取得）
            _buildAutoLoadedDataDisplay(),
            SizedBox(height: 16),

            // 対象部位
            _buildDropdownField(
              label: '対象部位',
              value: _selectedBodyPart,
              items: _bodyParts,
              onChanged: (value) {
                if (mounted) {
                setState(() {
                  _selectedBodyPart = value!;
                });
                }
              },
            ),
            SizedBox(height: 16),

            // 現在の1RM
            _build1RMInputField(),
            SizedBox(height: 16),

            // 🆕 Phase 7: Weight Ratio & 客観的レベル表示
            if (_weightRatio != null) ...[
              _buildWeightRatioDisplay(),
              SizedBox(height: 16),
            ],

            // 🆕 Phase 7: 客観的レベル判定結果
            if (_objectiveLevel != null && _objectiveLevel != _selectedLevel) ...[
              _buildLevelWarning(),
              SizedBox(height: 16),
            ],

            // トレーニングレベル
            _buildDropdownField(
              label: AppLocalizations.of(context)!.workout_2dc1ee52,
              value: _selectedLevel,
              items: _levels,
              onChanged: (value) {
                if (mounted) {
                setState(() {
                  _selectedLevel = value!;
                });
                }
              },
            ),
            SizedBox(height: 16),

            // トレーニング頻度
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderField(
                  label: AppLocalizations.of(context)!.autoGen_c157b7e9,
                  value: _selectedFrequency.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  onChanged: (value) {
                    if (mounted) {
                    setState(() {
                      _selectedFrequency = value.toInt();
                    });
                    }
                  },
                  displayValue: '週${_selectedFrequency}回',
                ),
                SizedBox(height: 4),
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
            SizedBox(height: 16),

            // 🆕 v1.0.230: RPE（自覚的強度）スライダー
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderField(
                  label: AppLocalizations.of(context)!.autoGen_ec1bb9da,
                  value: _selectedRPE.toDouble(),
                  min: 6,
                  max: 10,
                  divisions: 4,
                  onChanged: (value) {
                    if (mounted) {
                    setState(() {
                      _selectedRPE = value.toInt();
                    });
                    }
                  },
                  displayValue: _getRPELabel(_selectedRPE),
                ),
                SizedBox(height: 4),
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
            SizedBox(height: 16),

            // 性別
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  label: AppLocalizations.of(context)!.gender,
                  value: _selectedGender,
                  items: [AppLocalizations.of(context)!.genderMale, AppLocalizations.of(context)!.genderFemale],
                  onChanged: (value) {
                    if (mounted) {
                    setState(() {
                      _selectedGender = value!;
                    });
                    }
                  },
                ),
                SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '※ 女性は上半身の相対的筋力向上率が男性より高い（Roberts 2020）',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ドロップダウンフィールド
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
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
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
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
          activeColor: Colors.purple.shade700,
        ),
      ],
    );
  }

  /// 予測実行ボタン
  Widget _buildPredictButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : () {
        FocusScope.of(context).unfocus();
        _executePrediction();
      },
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.auto_graph),
      label: Text(_isLoading ? AppLocalizations.of(context)!.aiAnalyzing : AppLocalizations.of(context)!.executeGrowthPrediction),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// ローディングインジケーター
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.aiAnalyzingScientific),
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
          child: Text(AppLocalizations.of(context)!.autoGen_4b5dcedc),
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
                _predictionResult!['error']?.toString() ?? AppLocalizations.of(context)!.autoGen_03b65e41,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ),
        ),
      );
    }

    final result = _predictionResult!;
    
    // 必須フィールドチェック
    if (!result.containsKey('currentWeight') || 
        !result.containsKey('predictedWeight') ||
        !result.containsKey('aiAnalysis')) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            AppLocalizations.of(context)!.autoGen_a2bbd225,
            style: TextStyle(color: Colors.orange.shade900),
          ),
        ),
      );
    }
    
    final currentWeight = result['currentWeight'] as double;
    final predictedWeight = result['predictedWeight'] as double;
    final growthPercentage = result['growthPercentage'] as int;
    final confidenceInterval = result['confidenceInterval'] as Map<String, dynamic>;
    final monthlyRate = result['monthlyRate'] as int;
    final weeklyRate = result['weeklyRate'] as double;
    final aiAnalysis = result['aiAnalysis'] as String;
    final scientificBasis = result['scientificBasis'] as List;

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
                SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.fourMonthPrediction,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${predictedWeight.round()}kg',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '現在: ${currentWeight.round()}kg → +$growthPercentage%の成長',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16),
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
                      SizedBox(width: 8),
                      Text(
                        '信頼区間: ${confidenceInterval['lower'].round()}-${confidenceInterval['upper'].round()}kg',
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
        SizedBox(height: 16),

        // 成長率カード
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: Colors.blue.shade700),
                    SizedBox(width: 8),
                    Text(
                      '成長率',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('月次成長', '+$monthlyRate%', Colors.blue),
                    _buildStatItem('週次成長', '+${weeklyRate.toStringAsFixed(1)}%', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

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
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.aiDetailedAnalysis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildFormattedText(aiAnalysis),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // 科学的根拠
        ScientificBasisSection(
          basis: scientificBasis.cast<Map<String, String>>(),
        ),
        SizedBox(height: 8),

        // 信頼度インジケーター
        Center(
          child: ConfidenceIndicator(paperCount: scientificBasis.length),
        ),
      ],
    );
  }

  /// 統計アイテム
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// リワード広告ダイアログ表示
  Future<bool?> _showRewardAdDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_circle_outline, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.workout_80a340fe),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.workout_27e98563,
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.workout_21745d7a,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: Icon(Icons.play_arrow),
            label: Text(AppLocalizations.of(context)!.workout_d489aa48),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  /// リワード広告を表示してクレジット獲得
  Future<bool> _showRewardAdAndEarn() async {
    // グローバルインスタンスを使用（main.dartで初期化済み）
    final rewardAdService = globalRewardAdService;
    
    // 広告読み込み待機ダイアログ表示
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.workout_65c94ed8),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // 広告を読み込む
    await rewardAdService.loadRewardedAd();
    
    // 読み込み完了まで最大5秒待機
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (rewardAdService.isAdReady()) {
        break;
      }
    }
    
    // ローディングダイアログを閉じる
    if (mounted) {
      Navigator.of(context).pop();
    }
    
    // 広告表示
    if (rewardAdService.isAdReady()) {
      final success = await rewardAdService.showRewardedAd();
      
      if (success) {
        // 広告視聴成功メッセージ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.ai_rewardEarned),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return true;
      }
    }
    
    return false;
  }
  
  /// アップグレード促進ダイアログ表示
  Future<void> _showUpgradeDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.autoGen_7a1d4370),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.autoGen_9d99af7f,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• 月10回までAI機能が使い放題\n'
              '• 広告なしで快適に利用\n'
              '• お気に入りジム無制限\n'
              '• レビュー投稿可能',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '月額 ¥500',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.later),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.upgradeToPremium),
          ),
        ],
      ),
    );
  }

  /// Markdown形式テキストをフォーマット済みウィジェットに変換
  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final List<InlineSpan> spans = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // 1. 見出し処理（## Text → 太字テキスト）
      if (line.trim().startsWith('##')) {
        final headingText = line.replaceFirst(RegExp(r'^##\s*'), '');
        spans.add(
          TextSpan(
            text: headingText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.8,
            ),
          ),
        );
        if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // 2. 箇条書き処理（* → ・）
      if (line.trim().startsWith('*')) {
        line = line.replaceFirst(RegExp(r'^\*\s*'), '・');
      }

      // 3. 太字処理（**text** → 太字）
      final boldPattern = RegExp(r'\*\*(.+?)\*\*');
      final matches = boldPattern.allMatches(line);

      if (matches.isEmpty) {
        spans.add(TextSpan(text: line));
      } else {
        int lastIndex = 0;
        for (final match in matches) {
          if (match.start > lastIndex) {
            spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
          }
          spans.add(
            TextSpan(
              text: match.group(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          lastIndex = match.end;
        }
        if (lastIndex < line.length) {
          spans.add(TextSpan(text: line.substring(lastIndex)));
        }
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
        children: spans,
      ),
    );
  }

  /// 🆕 v1.0.230: RPEラベルを取得
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

  /// 🆕 v1.0.230: RPE説明文を取得
  String _getRPEDescription(int rpe) {
    if (rpe <= 7) {
      return '※ まだ余裕があった場合、予測成長率を10%アップします';
    } else if (rpe >= 10) {
      return '※ 限界まで追い込んだ場合、過労を考慮して予測成長率を20%ダウンします';
    } else {
      return '※ 適正な強度でトレーニングできた場合、標準の成長率で予測します';
    }
  }

  // ========================================
  // 🆕 Phase 7: 自動取得データ表示UI
  // ========================================

  /// 年齢・体重の自動取得データ表示
  Widget _buildAutoLoadedDataDisplay() {
    return Column(
      children: [
        // 年齢表示
        if (_userAge != null)
          _buildDataRow(
            icon: Icons.calendar_today,
            label: AppLocalizations.of(context)!.age,
            value: '$_userAge歳',
            actionLabel: AppLocalizations.of(context)!.workout_5c7bbafb,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PersonalFactorsScreen()),
            ).then((_) => _loadUserAge()),
          )
        else
          _buildWarningCard(
            message: AppLocalizations.of(context)!.autoGen_f2350bf3,
            actionLabel: '設定する',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PersonalFactorsScreen()),
            ).then((_) => _loadUserAge()),
          ),
        SizedBox(height: 12),

        // 体重表示
        if (_latestBodyWeight != null)
          _buildDataRow(
            icon: Icons.monitor_weight,
            label: AppLocalizations.of(context)!.bodyWeight,
            value: '${_latestBodyWeight!.toStringAsFixed(1)}kg'
                '${_weightRecordedAt != null ? " (${_formatDate(_weightRecordedAt!)})" : ""}',
            actionLabel: AppLocalizations.of(context)!.update,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BodyMeasurementScreen()),
            ).then((_) => _loadLatestBodyWeight()),
          )
        else
          _buildWarningCard(
            message: AppLocalizations.of(context)!.autoGen_5754da52,
            actionLabel: '記録する',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BodyMeasurementScreen()),
            ).then((_) => _loadLatestBodyWeight()),
          ),
      ],
    );
  }

  /// データ表示行（年齢・体重）
  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required String value,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  /// 警告カード（未設定時）
  Widget _buildWarningCard({
    required String message,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  /// 1RM入力フィールド（Weight Ratio計算付き）
  Widget _build1RMInputField() {
    return TextFormField(
      controller: _oneRMController, // 🔧 Phase 7 Fix: controllerを使用
      decoration: InputDecoration(
        labelText: '現在の1RM (kg)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fitness_center),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onEditingComplete: () => FocusScope.of(context).unfocus(),
      onChanged: (value) {
        final oneRM = double.tryParse(value);
        if (oneRM != null && oneRM > 0) {
          _calculateWeightRatioAndLevel(oneRM);
        } else {
          // 🔧 Phase 7 Fix: 無効な入力時はWeight Ratioをクリア
          if (mounted) {
          setState(() {
            _currentOneRM = null;
            _weightRatio = null;
            _objectiveLevel = null;
          });
          }
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.enterOneRM;
        }
        final weight = double.tryParse(value);
        if (weight == null) {
          return AppLocalizations.of(context)!.autoGen_2119ad31;
        }
        if (weight <= 0) {
          return AppLocalizations.of(context)!.enterAtLeast1kg;
        }
        if (weight > 500) {
          return AppLocalizations.of(context)!.max500kg;
        }
        return null;
      },
    );
  }

  /// Weight Ratio表示
  Widget _buildWeightRatioDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: Colors.indigo.shade700),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.weightRatio,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_weightRatio!.toStringAsFixed(2)} (1RM ${_currentOneRM!.toStringAsFixed(1)}kg ÷ 体重 ${_latestBodyWeight!.toStringAsFixed(1)}kg)',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 客観的レベル判定の警告表示
  Widget _buildLevelWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700),
              SizedBox(width: 8),
              Text(
                'レベル判定の通知',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'あなたのWeight Ratio (${_weightRatio!.toStringAsFixed(2)}) から、'
            '客観的なレベルは「$_objectiveLevel」と判定されました。',
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            '選択中のレベル：「$_selectedLevel」',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
              setState(() {
                _selectedLevel = _objectiveLevel!;
              });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
            ),
            child: Text(AppLocalizations.of(context)!.autoGen_306c1cc0),
          ),
        ],
      ),
    );
  }

  /// 日付フォーマット
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

// ========================================
// Tab 3: 効果分析タブ
// ========================================

class _EffectAnalysisTab extends StatefulWidget {
  @override
  State<_EffectAnalysisTab> createState() => _EffectAnalysisTabState();
}

class _EffectAnalysisTabState extends State<_EffectAnalysisTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // フォーム入力値
  final _formKey = GlobalKey<FormState>();
  late String _selectedBodyPart;
  late String _selectedExercise;  // 種目選択（didChangeDependenciesで初期化）
  int _currentSets = 12;
  int _currentFrequency = 2;
  late String _selectedLevel;
  late String _selectedGender;
  bool _enablePlateauDetection = true;  // プラトー検出ON/OFF

  // 🆕 Phase 7.5: 自動取得データ
  int? _userAge; // 個人要因設定から取得

  // 分析結果
  Map<String, dynamic>? _analysisResult;
  bool _isLoading = false;  // ✅ 修正: 初期状態はローディングなし

  late List<String> _bodyParts;
  late Map<String, List<String>> _exercisesByBodyPart;
  late List<String> _levels; // 🔧 v1.0.297: late変更（didChangeDependenciesで初期化）
  bool _isInitialized = false; // 🔧 初期化フラグ

  @override
  void initState() {
    super.initState();
    _loadUserAge(); // 🆕 Phase 7.5: 年齢を自動取得
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 🔧 v1.0.297: 1回だけ初期化（context利用可能）
    if (!_isInitialized) {
      final l10n = AppLocalizations.of(context)!;
      
      _selectedBodyPart = AppLocalizations.of(context)!.musclePecs;
      _selectedExercise = AppLocalizations.of(context)!.exerciseBenchPress; // 🔧 Phase 2 Fix
      _selectedLevel = AppLocalizations.of(context)!.levelIntermediate;
      _selectedGender = AppLocalizations.of(context)!.genderFemale;
      
      // レベル選択肢
      _levels = [AppLocalizations.of(context)!.levelBeginner, AppLocalizations.of(context)!.levelIntermediate, AppLocalizations.of(context)!.levelAdvanced];
      
      // 部位選択肢
      _bodyParts = [
        AppLocalizations.of(context)!.musclePecs,
        AppLocalizations.of(context)!.workout_0f45a131,
        AppLocalizations.of(context)!.workout_0c5ee6c6,
        AppLocalizations.of(context)!.bodyPart_8efece65,
        AppLocalizations.of(context)!.bodyPart_c158cb15,
        AppLocalizations.of(context)!.workout_da6d5d22,
      ];

      // 種目選択肢（部位ごと）
      _exercisesByBodyPart = {
        AppLocalizations.of(context)!.musclePecs: [AppLocalizations.of(context)!.exerciseBenchPress, AppLocalizations.of(context)!.exercise_fbfc037a, AppLocalizations.of(context)!.workout_e85fb0a4, AppLocalizations.of(context)!.exerciseDips],
        AppLocalizations.of(context)!.workout_0f45a131: [AppLocalizations.of(context)!.exerciseDeadlift, AppLocalizations.of(context)!.exerciseLatPulldown, AppLocalizations.of(context)!.exerciseBentOverRow, AppLocalizations.of(context)!.exerciseChinUp],
        AppLocalizations.of(context)!.workout_0c5ee6c6: [AppLocalizations.of(context)!.exerciseSquat, AppLocalizations.of(context)!.exerciseLegPress, AppLocalizations.of(context)!.exerciseLegExtension, AppLocalizations.of(context)!.workout_a19f4e60],
        AppLocalizations.of(context)!.bodyPart_8efece65: [AppLocalizations.of(context)!.exerciseBarbellCurl, AppLocalizations.of(context)!.exerciseDumbbellCurl, AppLocalizations.of(context)!.exerciseHammerCurl, AppLocalizations.of(context)!.workout_d7e8733c],
        AppLocalizations.of(context)!.bodyPart_c158cb15: [AppLocalizations.of(context)!.exercise_636fb74f, AppLocalizations.of(context)!.workout_41ae2e59, AppLocalizations.of(context)!.exerciseDips, AppLocalizations.of(context)!.exercise_a60f616c],
        AppLocalizations.of(context)!.workout_da6d5d22: [AppLocalizations.of(context)!.exerciseShoulderPress, AppLocalizations.of(context)!.exerciseSideRaise, AppLocalizations.of(context)!.exerciseFrontRaise, AppLocalizations.of(context)!.workout_61db805d],
      };
      
      _isInitialized = true;
    }
  }

  // 現在選択中の部位の種目リスト
  List<String> get _availableExercises => _exercisesByBodyPart[_selectedBodyPart] ?? [];

  // ========================================
  // 🆕 Phase 7.5: データ自動取得ロジック
  // ========================================

  /// 個人要因設定から年齢を取得
  Future<void> _loadUserAge() async {
    try {
      final advancedFatigueService = AdvancedFatigueService();
      final userProfile = await advancedFatigueService.getUserProfile();
      
      if (mounted) {
        if (mounted) {
        setState(() {
          _userAge = userProfile.age;
        });
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Phase 7.5] 年齢取得エラー: $e');
      // エラー時は null のまま（未設定状態）
    }
  }

  /// 効果分析を実行(サブスクリプションチェック統合)
  Future<void> _executeAnalysis() async {
    if (!_formKey.currentState!.validate()) return;

    // ========================================
    // 🔐 Step 1: サブスクリプション状態チェック
    // ========================================
    final subscriptionService = SubscriptionService();
    final creditService = AICreditService();
    final rewardAdService = globalRewardAdService;
    
    final currentPlan = await subscriptionService.getCurrentPlan();
    debugPrint('🔍 [効果分析] 現在のプラン: $currentPlan');
    
    // ========================================
    // 🎯 Step 2: AI利用可能性チェック
    // ========================================
    final canUseAIResult = await creditService.canUseAI();
    debugPrint('🔍 [効果分析] AI使用可能: ${canUseAIResult.allowed}');
    
    if (!canUseAIResult.allowed) {
      // 無料プランでAIクレジットがない場合
      if (currentPlan == SubscriptionType.free) {
        // リワード広告で獲得可能かチェック
        final canEarnFromAd = await creditService.canEarnCreditFromAd();
        debugPrint('🔍 [効果分析] 広告視聴可能: $canEarnFromAd');
        
        if (canEarnFromAd) {
          // ========================================
          // 📺 Step 3: リワード広告ダイアログ表示
          // ========================================
          final shouldShowAd = await _showRewardAdDialog();
          
          if (shouldShowAd == true) {
            // 広告を表示してクレジット獲得
            final adSuccess = await _showRewardAdAndEarn();
            
            if (!adSuccess) {
              // 広告表示失敗
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.workout_9d662a8d),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
            // 広告視聴成功 → 下記のAI生成処理に進む
          } else {
            // ユーザーがキャンセル
            return;
          }
        } else {
          // 今月の広告視聴上限に達している
          if (mounted) {
            await _showUpgradeDialog(AppLocalizations.of(context)!.workout_2ee7735b);
          }
          return;
        }
      } else {
        // 有料プランで月次上限に達している
        if (mounted) {
          await _showUpgradeDialog(AppLocalizations.of(context)!.workout_1b17a3c8);
        }
        return;
      }
    }

    // ========================================
    // 🤖 Step 4: AI分析処理(クレジット消費含む)
    // ========================================
    if (mounted) {
    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });
    }

    try {
      print('🚀 効果分析開始...');
      
      // プラトー検出が有効な場合、Firestoreから履歴を取得
      // 🆕 Phase 7.5: 必須データのバリデーション
      if (_userAge == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.workout_b257cb17),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      List<Map<String, dynamic>> recentHistory = [];
      if (_enablePlateauDetection) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          recentHistory = await _fetchRecentExerciseHistory(user.uid, _selectedExercise);
          print('📊 履歴取得: ${recentHistory.length}件');
        }
      }
      
      final result = await TrainingAnalysisService.analyzeTrainingEffect(
        bodyPart: _selectedBodyPart,
        currentSetsPerWeek: _currentSets,
        currentFrequency: _currentFrequency,
        level: _selectedLevel,
        gender: _selectedGender,
        age: _userAge!, // 🆕 Phase 7.5: 自動取得した年齢
        recentHistory: recentHistory,
        locale: AppLocalizations.of(context)!.localeName, // 🆕 Build #24.1 Hotfix9: Pass locale
      );
      print('✅ 効果分析完了: ${result['success']}');

      if (result['success'] == true) {
        // ========================================
        // ✅ Step 5: AI生成成功 → クレジット消費
        // ========================================
        final consumeSuccess = await creditService.consumeAICredit();
        debugPrint('✅ AIクレジット消費: $consumeSuccess');
        
        // 残りクレジット表示
        if (mounted) {
          final statusMessage = await creditService.getAIUsageStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.ai_analysisComplete(statusMessage)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      if (mounted) {
        if (mounted) {
        setState(() {
          _analysisResult = result;
          _isLoading = false;
        });
        }
      }
    } catch (e) {
      print('❌ 効果分析例外: $e');
      if (mounted) {
        if (mounted) {
        setState(() {
          _analysisResult = {
            'success': false,
            'error': '分析の生成に失敗しました: $e',
          };
          _isLoading = false;
        });
        }
      }
    }
  }

  /// Firestoreから特定種目の直近4回のトレーニング記録を取得
  Future<List<Map<String, dynamic>>> _fetchRecentExerciseHistory(
    String userId,
    String exerciseName,
  ) async {
    try {
      // 直近30日間のworkoutログを取得
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final snapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where('user_id', isEqualTo: userId)
          .where('date', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('date', descending: true)
          .limit(20)  // 最大20件のワークアウトログを取得
          .get();

      final List<Map<String, dynamic>> exerciseRecords = [];
      
      // 各ワークアウトログから指定種目のデータを抽出
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final exercises = data['exercises'] as List<dynamic>?;
        
        if (exercises != null) {
          // 指定種目を探す
          for (final exercise in exercises) {
            final exerciseMap = exercise as Map<String, dynamic>;
            if (exerciseMap['name'] == exerciseName) {
              // 最大重量を計算
              final sets = exerciseMap['sets'] as List<dynamic>?;
              double maxWeight = 0;
              
              if (sets != null) {
                for (final set in sets) {
                  final setMap = set as Map<String, dynamic>;
                  final weight = setMap['weight']?.toDouble() ?? 0;
                  if (weight > maxWeight) {
                    maxWeight = weight;
                  }
                }
              }
              
              // 記録を追加（4件に達したら終了）
              exerciseRecords.add({
                'date': (data['date'] as Timestamp).toDate(),
                'weight': maxWeight,
                'sets': sets?.length ?? 0,
              });
              
              if (exerciseRecords.length >= 4) break;
            }
          }
        }
        
        if (exerciseRecords.length >= 4) break;
      }
      
      // 日付順にソート（新しい順）
      exerciseRecords.sort((a, b) => 
        (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      // 週番号を付与（直近が week 1）
      final result = <Map<String, dynamic>>[];
      for (int i = 0; i < exerciseRecords.length; i++) {
        result.add({
          'week': exerciseRecords.length - i,
          'weight': exerciseRecords[i]['weight'],
          'sets': exerciseRecords[i]['sets'],
        });
      }
      
      return result;
    } catch (e) {
      print('❌ 履歴取得エラー: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダー
            _buildHeader(),
            SizedBox(height: 24),

            // 入力フォーム
            _buildInputForm(),
            SizedBox(height: 24),

            // 分析実行ボタン
            _buildAnalyzeButton(),
            SizedBox(height: 32),

            // 分析結果
            if (_isLoading)
              _buildLoadingIndicator()
            else if (_analysisResult != null)
              _buildAnalysisResult(),
          ],
        ),
      ),
    );
  }

  /// ヘッダー
  Widget _buildHeader() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.analytics, size: 40, color: Colors.orange.shade700),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.aiEffectAnalysis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.autoGen_4a776041,
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
            Text(
              AppLocalizations.of(context)!.autoGen_9d44cf62,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // 🆕 Phase 7.5: 年齢表示（自動取得）
            _buildAgeDisplay(),
            SizedBox(height: 16),

            // 対象部位
            _buildDropdownField(
              label: '対象部位',
              value: _selectedBodyPart,
              items: _bodyParts,
              onChanged: (value) {
                if (mounted) {
                setState(() {
                  _selectedBodyPart = value!;
                  // 部位変更時に種目を自動選択
                  _selectedExercise = _availableExercises.isNotEmpty 
                      ? _availableExercises.first 
                      : AppLocalizations.of(context)!.exerciseBenchPress;
                });
                }
              },
            ),
            SizedBox(height: 16),

            // 種目選択
            _buildDropdownField(
              label: AppLocalizations.of(context)!.autoGen_07ba3722,
              value: _selectedExercise,
              items: _availableExercises,
              onChanged: (value) {
                if (mounted) {
                setState(() {
                  _selectedExercise = value!;
                });
                }
              },
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '※ 同じ種目で4回連続同じ重量の場合、停滞を検出',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 16),

            // プラトー検出トグル
            SwitchListTile(
              title: Text(
                AppLocalizations.of(context)!.autoGen_6619d354,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _enablePlateauDetection 
                    ? AppLocalizations.of(context)!.autoGen_6be4fd6d 
                    : AppLocalizations.of(context)!.autoGen_2f465804,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              value: _enablePlateauDetection,
              onChanged: (value) {
                if (mounted) {
                setState(() {
                  _enablePlateauDetection = value;
                });
                }
              },
              activeColor: Colors.orange.shade700,
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 16),

            // 週あたりセット数
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderField(
                  label: AppLocalizations.of(context)!.autoGen_64a1612a,
                  value: _currentSets.toDouble(),
                  min: 4,
                  max: 24,
                  divisions: 20,
                  onChanged: (value) {
                    if (mounted) {
                    setState(() {
                      _currentSets = value.toInt();
                    });
                    }
                  },
                  displayValue: '${_currentSets}セット',
                ),
                SizedBox(height: 4),
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
            SizedBox(height: 16),

            // トレーニング頻度
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderField(
                  label: AppLocalizations.of(context)!.autoGen_c157b7e9,
                  value: _currentFrequency.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  onChanged: (value) {
                    if (mounted) {
                    setState(() {
                      _currentFrequency = value.toInt();
                    });
                    }
                  },
                  displayValue: '週${_currentFrequency}回',
                ),
                SizedBox(height: 4),
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
            SizedBox(height: 16),

            // トレーニングレベル
            _buildDropdownField(
              label: AppLocalizations.of(context)!.workout_2dc1ee52,
              value: _selectedLevel,
              items: _levels,
              onChanged: (value) {
                if (mounted) {
                setState(() {
                  _selectedLevel = value!;
                });
                }
              },
            ),
            SizedBox(height: 16),

            // 性別
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  label: AppLocalizations.of(context)!.gender,
                  value: _selectedGender,
                  items: [AppLocalizations.of(context)!.genderMale, AppLocalizations.of(context)!.genderFemale],
                  onChanged: (value) {
                    if (mounted) {
                    setState(() {
                      _selectedGender = value!;
                    });
                    }
                  },
                ),
                SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '※ 女性は上半身の相対的筋力向上率が男性より高い（Roberts 2020）',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // 🆕 Phase 7.5: 年齢表示UI
  // ========================================

  /// 年齢の自動取得データ表示
  Widget _buildAgeDisplay() {
    if (_userAge != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue.shade700),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.age,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '$_userAge歳',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalFactorsScreen()),
              ).then((_) => _loadUserAge()),
              child: Text(AppLocalizations.of(context)!.workout_5c7bbafb),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade700),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.autoGen_f2350bf3,
                style: TextStyle(fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalFactorsScreen()),
              ).then((_) => _loadUserAge()),
              child: Text(AppLocalizations.of(context)!.general_configure),
            ),
          ],
        ),
      );
    }
  }

  /// ドロップダウンフィールド
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
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
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
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
          activeColor: Colors.orange.shade700,
        ),
      ],
    );
  }

  /// 分析実行ボタン
  Widget _buildAnalyzeButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : () {
        FocusScope.of(context).unfocus();
        _executeAnalysis();
      },
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.auto_graph),
      label: Text(_isLoading ? AppLocalizations.of(context)!.aiAnalyzing : '効果を分析'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// ローディングインジケーター
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.aiGenerating),
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
          child: Text(AppLocalizations.of(context)!.workout_noAnalysisResults),
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
                _analysisResult!['error']?.toString() ?? AppLocalizations.of(context)!.autoGen_03b65e41,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ),
        ),
      );
    }

    final result = _analysisResult!;
    
    // 必須フィールドチェック
    if (!result.containsKey('volumeAnalysis') || 
        !result.containsKey('frequencyAnalysis') ||
        !result.containsKey('aiAnalysis')) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            AppLocalizations.of(context)!.autoGen_15ac6a5e,
            style: TextStyle(color: Colors.orange.shade900),
          ),
        ),
      );
    }
    
    final volumeAnalysis = result['volumeAnalysis'] as Map<String, dynamic>;
    final frequencyAnalysis = result['frequencyAnalysis'] as Map<String, dynamic>;
    final plateauDetected = result['plateauDetected'] as bool;
    final growthTrend = result['growthTrend'] as Map<String, dynamic>;
    final recommendations = result['recommendations'] as List;
    final scientificBasis = result['scientificBasis'] as List;
    final aiAnalysis = result['aiAnalysis'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ステータスサマリー（トグルOFFの場合はプラトー無視）
        _buildStatusSummary(volumeAnalysis, frequencyAnalysis, 
          _enablePlateauDetection && plateauDetected, growthTrend),
        SizedBox(height: 16),

        // ボリューム分析
        _buildVolumeAnalysis(volumeAnalysis),
        SizedBox(height: 16),

        // 頻度分析
        _buildFrequencyAnalysis(frequencyAnalysis),
        SizedBox(height: 16),

        // プラトー警告（トグルON かつ 検出された場合のみ表示）
        if (_enablePlateauDetection && plateauDetected) ...[
          _buildPlateauWarning(),
          SizedBox(height: 16),
        ],

        // 推奨アクション
        _buildRecommendations(recommendations),
        SizedBox(height: 16),

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
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.aiDetailedAnalysis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildFormattedText(aiAnalysis),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // 科学的根拠
        ScientificBasisSection(
          basis: scientificBasis.cast<Map<String, String>>(),
        ),
        SizedBox(height: 8),

        // 信頼度インジケーター
        Center(
          child: ConfidenceIndicator(paperCount: scientificBasis.length),
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
        child: Row(
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusMessage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '成長トレンド: ${trend['trend']}',
                    style: TextStyle(
                      fontSize: 14,
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

  /// ボリューム分析
  Widget _buildVolumeAnalysis(Map<String, dynamic> analysis) {
    final status = analysis['status'] as String;
    final advice = analysis['advice'] as String;
    
    Color statusColor;
    String statusLabel;
    
    switch (status) {
      case 'optimal':
        statusColor = Colors.green;
        statusLabel = '最適';
        break;
      case 'suboptimal':
        statusColor = Colors.blue;
        statusLabel = AppLocalizations.of(context)!.autoGen_b1be274b;
        break;
      case 'insufficient':
        statusColor = Colors.orange;
        statusLabel = '不足';
        break;
      case 'excessive':
        statusColor = Colors.red;
        statusLabel = AppLocalizations.of(context)!.autoGen_81ebe44b;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = AppLocalizations.of(context)!.unknown;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(
                  'ボリューム分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              advice,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  /// 頻度分析
  Widget _buildFrequencyAnalysis(Map<String, dynamic> analysis) {
    final status = analysis['status'] as String;
    final advice = analysis['advice'] as String;
    
    Color statusColor;
    String statusLabel;
    
    switch (status) {
      case 'optimal':
        statusColor = Colors.green;
        statusLabel = '最適';
        break;
      case 'suboptimal':
        statusColor = Colors.blue;
        statusLabel = AppLocalizations.of(context)!.autoGen_b1be274b;
        break;
      case 'insufficient':
        statusColor = Colors.orange;
        statusLabel = '不足';
        break;
      case 'excessive':
        statusColor = Colors.red;
        statusLabel = AppLocalizations.of(context)!.autoGen_81ebe44b;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = AppLocalizations.of(context)!.unknown;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.green.shade700),
                SizedBox(width: 8),
                Text(
                  '頻度分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              advice,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
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
            Icon(Icons.warning_amber, size: 40, color: Colors.orange.shade700),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プラトー検出',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.autoGen_773d1c04,
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
                Icon(Icons.recommend, color: Colors.purple.shade700),
                SizedBox(width: 8),
                Text(
                  '推奨アクション',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...recommendations.map((rec) {
              final action = rec['action'] as String;
              final category = rec['category'] as String;
              final priority = rec['priority'] as String;
              
              Color priorityColor;
              switch (priority) {
                case 'high':
                  priorityColor = Colors.red;
                  break;
                case 'medium':
                  priorityColor = Colors.orange;
                  break;
                default:
                  priorityColor = Colors.blue;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            action,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
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

  /// リワード広告ダイアログ表示
  Future<bool?> _showRewardAdDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_circle_outline, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.workout_80a340fe),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.workout_27e98563,
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.workout_21745d7a,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: Icon(Icons.play_arrow),
            label: Text(AppLocalizations.of(context)!.workout_d489aa48),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  /// リワード広告を表示してクレジット獲得
  Future<bool> _showRewardAdAndEarn() async {
    // グローバルインスタンスを使用（main.dartで初期化済み）
    final rewardAdService = globalRewardAdService;
    
    // 広告読み込み待機ダイアログ表示
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.workout_65c94ed8),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // 広告を読み込む
    await rewardAdService.loadRewardedAd();
    
    // 読み込み完了まで最大5秒待機
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (rewardAdService.isAdReady()) {
        break;
      }
    }
    
    // ローディングダイアログを閉じる
    if (mounted) {
      Navigator.of(context).pop();
    }
    
    // 広告表示
    if (rewardAdService.isAdReady()) {
      final success = await rewardAdService.showRewardedAd();
      
      if (success) {
        // 広告視聴成功メッセージ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.ai_rewardEarned),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return true;
      }
    }
    
    return false;
  }
  
  /// アップグレード促進ダイアログ表示
  Future<void> _showUpgradeDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.autoGen_7a1d4370),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.autoGen_9d99af7f,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• 月10回までAI機能が使い放題\n'
              '• 広告なしで快適に利用\n'
              '• お気に入りジム無制限\n'
              '• レビュー投稿可能',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '月額 ¥500',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.later),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.upgradeToPremium),
          ),
        ],
      ),
    );
  }

  /// Markdown形式テキストをフォーマット済みウィジェットに変換
  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final List<InlineSpan> spans = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // 1. 見出し処理（## Text → 太字テキスト）
      if (line.trim().startsWith('##')) {
        final headingText = line.replaceFirst(RegExp(r'^##\s*'), '');
        spans.add(
          TextSpan(
            text: headingText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.8,
            ),
          ),
        );
        if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // 2. 箇条書き処理（* → ・）
      if (line.trim().startsWith('*')) {
        line = line.replaceFirst(RegExp(r'^\*\s*'), '・');
      }

      // 3. 太字処理（**text** → 太字）
      final boldPattern = RegExp(r'\*\*(.+?)\*\*');
      final matches = boldPattern.allMatches(line);

      if (matches.isEmpty) {
        spans.add(TextSpan(text: line));
      } else {
        int lastIndex = 0;
        for (final match in matches) {
          if (match.start > lastIndex) {
            spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
          }
          spans.add(
            TextSpan(
              text: match.group(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          lastIndex = match.end;
        }
        if (lastIndex < line.length) {
          spans.add(TextSpan(text: line.substring(lastIndex)));
        }
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
        children: spans,
      ),
    );
  }
}

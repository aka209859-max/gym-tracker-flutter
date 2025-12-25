import 'package:gym_match/gen/app_localizations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/subscription_service.dart';
import '../../services/ai_credit_service.dart';
import '../../widgets/reward_ad_dialog.dart';
import '../ai_addon_purchase_screen.dart';
import '../../utils/console_logger.dart';
import '../../utils/app_logger.dart';

/// Layer 5: AIコーチング画面
/// 
/// 機能:
/// - Gemini 2.0 Flash APIでトレーニングメニュー提案
/// - 部位選択UI（チップ式）
/// - メニュー保存・履歴表示
class AICoachingScreen extends StatefulWidget {
  AICoachingScreen({super.key});

  @override
  State<AICoachingScreen> createState() => _AICoachingScreenState();
}

class _AICoachingScreenState extends State<AICoachingScreen> {
  // 部位選択状態（有酸素・初心者追加）
  final Map<String, bool> _selectedBodyParts = {
    AppLocalizations.of(context)!.bodyPartChest: false,
    AppLocalizations.of(context)!.bodyPartBack: false,
    AppLocalizations.of(context)!.bodyPartLegs: false,
    AppLocalizations.of(context)!.bodyPartShoulders: false,
    AppLocalizations.of(context)!.bodyPartArms: false,
    AppLocalizations.of(context)!.bodyPart_ceb49fa1: false,
    AppLocalizations.of(context)!.exerciseCardio: false,
    AppLocalizations.of(context)!.levelBeginner: false,
  };

  // UI状態
  bool _isGenerating = false;
  String? _generatedMenu;
  String? _errorMessage;
  
  // 履歴
  List<Map<String, dynamic>> _history = [];
  bool _isLoadingHistory = false;
  
  // サブスクリプションサービス
  final SubscriptionService _subscriptionService = SubscriptionService();
  final AICreditService _creditService = AICreditService();

  @override
  void initState() {
    super.initState();
    _autoLoginIfNeeded();
    _loadHistory();
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

  /// 履歴読み込み
  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('aiCoachingHistory')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      setState(() {
        _history = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      debugPrint('❌ 履歴読み込みエラー: $e');
      setState(() => _isLoadingHistory = false);
    }
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
        title: Text(AppLocalizations.of(context)!.aiCoaching),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: AppLocalizations.of(context)!.workout_9e8d8121,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 説明文
            _buildDescription(),
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
            Text(AppLocalizations.of(context)!.selectExercise,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                      SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.workout_f8ad9a0a,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.generatedKey_79ab5374
                    AppLocalizations.of(context)!.generatedKey_46daa8ca
                    AppLocalizations.of(context)!.workout_d35c3540,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 部位選択セクション
  Widget _buildBodyPartSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.selectExercise,
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
                    const Icon(Icons.school, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                  ],
                  Text(part),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedBodyParts[part] = selected;
                });
              },
              selectedColor: isBeginner 
                  ? Colors.green.shade100 
                  : Colors.blue.shade100,
              checkmarkColor: isBeginner 
                  ? Colors.green.shade700 
                  : Colors.blue.shade700,
              backgroundColor: isBeginner 
                  ? Colors.green.shade50 
                  : null,
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
          ConsoleLogger.userAction('AI_MENU_GENERATE_BUTTON_CLICKED', data: {'bodyParts': selectedParts});
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

  /// 生成されたメニュー表示
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
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _saveMenu,
                  tooltip: AppLocalizations.of(context)!.saveWorkout,
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            _buildFormattedText(_generatedMenu!),
          ],
        ),
      ),
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
          AppLocalizations.of(context)!.workout_5fcb26ba,
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
              padding: EdgeInsets.all(24),
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
  /// 
  /// 変換ルール:
  /// - `## 見出し` → 太字見出し（##は削除）
  /// - `**太字**` → 太字テキスト
  /// - `* 箇条書き` → `・箇条書き`
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.8,
            ),
          ),
        );
        if (i < lines.length - 1) spans.add(TextSpan(text: '\n'));
        continue;
      }

      // 2. 箇条書き処理（* → ・）
      if (line.trim().startsWith('*')) {
        line = line.replaceFirst(RegExp(r'^\*\s*'), AppLocalizations.of(context)!.aiPromptTargetBodyPart);
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
              style: TextStyle(fontWeight: FontWeight.bold),
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
        spans.add(TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
        children: spans,
      ),
    );
  }

  /// AIメニュー生成
  Future<void> _generateMenu(List<String> bodyParts) async {
    ConsoleLogger.info(AppLocalizations.of(context)!.workout_195d675c, tag: 'AI_COACHING');
    
    // ステップ1: AI使用可能チェック（サブスク or クレジット）
    final canUse = await _creditService.canUseAI();
    ConsoleLogger.debug(AppLocalizations.of(context)!.generatedKey_b657787b, tag: 'AI_COACHING');
    
    if (!canUse) {
      // ステップ2: 広告視聴可能かチェック（無料ユーザー & 月3回未満）
      final canEarnFromAd = await _creditService.canEarnCreditFromAd();
      ConsoleLogger.debug(AppLocalizations.of(context)!.generatedKey_c85769fb, tag: 'AI_COACHING');
      
      if (canEarnFromAd && mounted) {
        ConsoleLogger.info(AppLocalizations.of(context)!.workout_3cdc9d1b, tag: 'AI_COACHING');
        // ステップ3: リワード広告ダイアログ表示
        final watchedAd = await showDialog<bool>(
          context: context,
          builder: (context) => RewardAdDialog(),
        );
        
        ConsoleLogger.debug(AppLocalizations.of(context)!.generatedKey_5a65e7d3, tag: 'AI_COACHING');
        
        if (watchedAd != true) {
          ConsoleLogger.warn(AppLocalizations.of(context)!.cancel, tag: 'AI_COACHING');
          return; // キャンセルまたは失敗
        }
        ConsoleLogger.info(AppLocalizations.of(context)!.success, tag: 'AI_COACHING');
        // 広告視聴成功 → クレジット付与済み → 処理続行
      } else {
        // 月3回上限到達 → サブスク誘導
        ConsoleLogger.warn(AppLocalizations.of(context)!.workout_d689f5ec, tag: 'AI_COACHING');
        if (mounted) {
          _showUpgradeDialog();
        }
        return;
      }
    }
    
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedMenu = null;
    });

    try {
      final startTime = DateTime.now();
      ConsoleLogger.info('Gemini APIでメニュー生成開始: ${bodyParts.join(', ')}', tag: 'AI_COACHING');

      // Gemini 2.0 Flash Exp API呼び出し（10秒タイムアウト）
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY'),
        headers: {
          'Content-Type': 'application/json',
          // Note: Gemini API does NOT support X-Ios-Bundle-Identifier header
          // Use API Key restrictions in Google Cloud Console instead
        },
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
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,  // 初心者向け詳細メニューに対応（1024→2048）
          }
        }),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning(AppLocalizations.of(context)!.workout_18ebf2f6, tag: 'AI_COACHING');
          throw TimeoutException('API request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

        // AI使用回数/クレジット消費
        await _creditService.consumeAICredit();
        
        // デバッグ情報
        final currentPlan = await _subscriptionService.getCurrentPlan();
        if (currentPlan != SubscriptionType.free) {
          AppLogger.debug('AI使用回数: ${await _subscriptionService.getCurrentMonthAIUsage()}', tag: 'AI_COACHING');
        } else {
          AppLogger.debug('AIクレジット残高: ${await _creditService.getAICredits()}', tag: 'AI_COACHING');
        }

        setState(() {
          _generatedMenu = text;
          _isGenerating = false;
        });

        final duration = DateTime.now().difference(startTime);
        AppLogger.performance('AI Menu Generation', duration);
        AppLogger.info(AppLocalizations.of(context)!.success, tag: 'AI_COACHING');
      } else {
        AppLogger.warning('Gemini API エラー: ${response.statusCode} - フォールバックを使用', tag: 'AI_COACHING');
        throw Exception('API Error: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      AppLogger.warning(AppLocalizations.of(context)!.workout_17d45dd6, tag: 'AI_COACHING');
      _generateFallbackMenu(bodyParts);
    } catch (e) {
      AppLogger.error(AppLocalizations.of(context)!.error, tag: 'AI_COACHING', error: e);
      _generateFallbackMenu(bodyParts);
    }
  }

  /// フォールバックメニュー生成（AI失敗時）
  void _generateFallbackMenu(List<String> bodyParts) {
    final isBeginner = bodyParts.contains(AppLocalizations.of(context)!.levelBeginner);
    final targetParts = bodyParts.where((part) => part != AppLocalizations.of(context)!.levelBeginner).toList();
    
    final buffer = StringBuffer();
    buffer.writeln(AppLocalizations.of(context)!.generatedKey_a2170a7d);
    buffer.writeln(AppLocalizations.of(context)!.generatedKey_8627ad90);
    
    if (targetParts.isEmpty) {
      // 全身トレーニング
      buffer.writeln(AppLocalizations.of(context)!.generatedKey_3921a074);
      if (isBeginner) {
        buffer.writeln(AppLocalizations.of(context)!.exercise_6d49cfbd);
        buffer.writeln(AppLocalizations.of(context)!.workout_87cf37ce);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_63dfa8fd);
        buffer.writeln(AppLocalizations.of(context)!.workout_ff02a3f0);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_f48e246a);
        
        buffer.writeln(AppLocalizations.of(context)!.exercise_7f131aaa);
        buffer.writeln(AppLocalizations.of(context)!.workout_87cf37ce);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_63dfa8fd);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_9dbcd380);
        
        buffer.writeln(AppLocalizations.of(context)!.workout_fe875196);
        buffer.writeln(AppLocalizations.of(context)!.workout_87cf37ce);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_63dfa8fd);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_e3c1b530);
      } else {
        buffer.writeln(AppLocalizations.of(context)!.exercise_6d49cfbd);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_95eff134);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_7b69d2d1);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_7d332e7f);
        
        buffer.writeln(AppLocalizations.of(context)!.exercise_7f131aaa);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_95eff134);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_7b69d2d1);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_7d332e7f);
        
        buffer.writeln(AppLocalizations.of(context)!.exercise_bddaa38a);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_9c54dcf8);
        buffer.writeln(AppLocalizations.of(context)!.reps);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_64963de8);
      }
    } else {
      // 部位別トレーニング
      for (final part in targetParts) {
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_7fb65399);
        _addBodyPartExercises(buffer, part, isBeginner);
      }
    }
    
    buffer.writeln('\n---');
    buffer.writeln(AppLocalizations.of(context)!.workout_4c839041);
    buffer.writeln(AppLocalizations.of(context)!.workout_5055caaf);
    
    setState(() {
      _generatedMenu = buffer.toString();
      _isGenerating = false;
    });
  }
  
  /// 部位別エクササイズを追加
  void _addBodyPartExercises(StringBuffer buffer, String bodyPart, bool isBeginner) {
    final exercises = {
      AppLocalizations.of(context)!.bodyPartChest: [AppLocalizations.of(context)!.exerciseBenchPress, AppLocalizations.of(context)!.workout_e85fb0a4, AppLocalizations.of(context)!.workout_c196525e],
      AppLocalizations.of(context)!.bodyPartBack: [AppLocalizations.of(context)!.exerciseDeadlift, AppLocalizations.of(context)!.exerciseLatPulldown, AppLocalizations.of(context)!.exerciseBentOverRow],
      AppLocalizations.of(context)!.bodyPartLegs: [AppLocalizations.of(context)!.exerciseSquat, AppLocalizations.of(context)!.exerciseLegPress, AppLocalizations.of(context)!.exerciseLegCurl],
      AppLocalizations.of(context)!.bodyPartShoulders: [AppLocalizations.of(context)!.exerciseShoulderPress, AppLocalizations.of(context)!.exerciseSideRaise, AppLocalizations.of(context)!.exerciseRearDeltFly],
      AppLocalizations.of(context)!.bodyPartArms: [AppLocalizations.of(context)!.exerciseBarbellCurl, AppLocalizations.of(context)!.exerciseTricepsExtension, AppLocalizations.of(context)!.exerciseHammerCurl],
      AppLocalizations.of(context)!.bodyPart_ceb49fa1: [AppLocalizations.of(context)!.exerciseCrunch, AppLocalizations.of(context)!.exercisePlank, AppLocalizations.of(context)!.exerciseLegRaise],
    };
    
    final targetExercises = exercises[bodyPart] ?? [AppLocalizations.of(context)!.workout_065a723e];
    
    for (int i = 0; i < targetExercises.length && i < 3; i++) {
      buffer.writeln('### ${i + 1}. ${targetExercises[i]}');
      if (isBeginner) {
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_7f25816c);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_7ae0e831);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_9dbcd380);
      } else {
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_9c54dcf8);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_22068d85);
        buffer.writeln(AppLocalizations.of(context)!.generatedKey_e420dac1);
      }
    }
  }

  /// プロンプト構築
  String _buildPrompt(List<String> bodyParts) {
    // 初心者モード判定
    final isBeginner = bodyParts.contains(AppLocalizations.of(context)!.levelBeginner);
    
    // 初心者以外の部位を抽出
    final targetParts = bodyParts.where((part) => part != AppLocalizations.of(context)!.levelBeginner).toList();
    
    if (isBeginner) {
      // 初心者向け専用プロンプト
      if (targetParts.isEmpty) {
        // 初心者のみ選択 → 全身トレーニング
        return '''
あなたはプロのパーソナルトレーナーです。筋トレ初心者向けの全身トレーニングメニューを提案してください。

【対象者】
- 筋トレ初心者（ジム通い始めて1〜3ヶ月程度）
- 基礎体力づくりを目指す方
- トレーニングフォームを学びたい方

【提案形式】
各種目について以下の情報を含めてください：
- 種目名
- セット数（少なめ: 2-3セット）
- 回数（軽い重量で: 10-15回）
- 休憩時間（長め: 90-120秒）
- 初心者向けフォームのポイント
- よくある間違いと注意事項

【条件】
- 全身をバランスよく鍛える（胸・背中・脚・肩・腕・腹筋）
- 基本種目中心（マシンとフリーウェイト組み合わせ）
- 30-45分で完了
- 怪我のリスクが少ない種目
- フォーム習得を重視
- 日本語で丁寧に説明

初心者が安全に取り組める全身トレーニングメニューを提案してください。
''';
      } else {
        // 初心者 + 部位指定 → その部位に特化した初心者メニュー
        return '''
あなたはプロのパーソナルトレーナーです。筋トレ初心者向けの「${targetParts.join('、')}」トレーニングメニューを提案してください。

【対象者】
- 筋トレ初心者（ジム通い始めて1〜3ヶ月程度）
- ${targetParts.join('、')}を重点的に鍛えたい方
- トレーニングフォームを学びたい方

【提案形式】
各種目について以下の情報を含めてください：
- 種目名
- セット数（少なめ: 2-3セット）
- 回数（軽い重量で: 10-15回）
- 休憩時間（長め: 90-120秒）
- 初心者向けフォームのポイント
- よくある間違いと注意事項

【条件】
- ${targetParts.join('、')}を重点的にトレーニング
- 基本種目中心（マシンとフリーウェイト組み合わせ）
- 30-45分で完了
- 怪我のリスクが少ない種目
- フォーム習得を重視
- 日本語で丁寧に説明

初心者が安全に取り組める${targetParts.join('、')}トレーニングメニューを提案してください。
''';
      }
    } else {
      // 通常モード（初心者選択なし）
      return '''
あなたはプロのパーソナルトレーナーです。以下の部位をトレーニングするための最適なメニューを提案してください。

【トレーニング部位】
${bodyParts.join('、')}

【提案形式】
各種目について以下の情報を含めてください：
- 種目名
- セット数
- 回数
- 休憩時間
- ポイント・注意事項

【条件】
- 初心者〜中級者向け
- ジムで実施可能
- 45-60分で完了
- 効率的に鍛えられる
- 日本語で簡潔に

メニューを提案してください。
''';
    }
  }

  /// メニュー保存
  Future<void> _saveMenu() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _generatedMenu == null) return;

      final selectedParts = _selectedBodyParts.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('aiCoachingHistory')
          .add({
        'bodyParts': selectedParts,
        'menu': _generatedMenu,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.save),
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
            content: Text(AppLocalizations.of(context)!.save),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 使い方ダイアログ
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.workout_47f85b9f),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.workout_6298b94b,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.selectExercise,
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.workout_cb9ef699,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.save,
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.workout_e63fe8de,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.confirm,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.readLess),
          ),
        ],
      ),
    );
  }

  /// アップグレード誘導ダイアログ（無料プラン: 月3回上限到達時）
  void _showUpgradeDialog() async {
    final currentPlan = await _subscriptionService.getCurrentPlan();
    
    // 有料プランユーザーには追加購入オプションを表示
    if (currentPlan != SubscriptionType.free && mounted) {
      _showAddonPurchaseDialog();
      return;
    }
    
    // 無料プランユーザーにはサブスク誘導
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.workout_42a622a9),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.workout_f85e416b,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.workout_d00ce2c5,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.workout_302d148c, style: TextStyle(fontSize: 13)),
            Text(AppLocalizations.of(context)!.workout_18419fdb, style: TextStyle(fontSize: 13)),
            Text(AppLocalizations.of(context)!.workout_995040b8, style: TextStyle(fontSize: 13)),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.workout_98fdb72e,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.readLess),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // サブスク画面へ遷移
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.workout_aa5018ba),
          ),
        ],
      ),
    );
  }
  
  /// 追加購入ダイアログ（有料プラン会員用）
  void _showAddonPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.workout_42a622a9),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.workout_03c8c351,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.generatedKey_530c8f16,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.workout_940a74d8, style: TextStyle(fontSize: 13)),
            Text(AppLocalizations.of(context)!.workout_d9fd4ff4, style: TextStyle(fontSize: 13)),
            Text(AppLocalizations.of(context)!.workout_fdf1a277, style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.readLess),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // AI追加購入画面へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AIAddonPurchaseScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.addWorkout),
          ),
        ],
      ),
    );
  }
}

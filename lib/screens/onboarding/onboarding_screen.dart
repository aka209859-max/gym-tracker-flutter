import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';
import '../../services/referral_service.dart';

/// オンボーディング画面
/// 
/// 初回起動時にユーザータイプを診断し、最適なトレーニング体験を提供します
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  final ReferralService _referralService = ReferralService();
  
  int _currentPage = 0;
  
  // ユーザー選択
  String _selectedTrainingLevel = '';
  String _selectedTrainingGoal = '';
  String _selectedTrainingFrequency = '';
  
  // 🎁 紹介コード（Task 10: バイラルループ）
  final TextEditingController _referralCodeController = TextEditingController();
  bool _hasReferralCode = false;

  @override
  void dispose() {
    _pageController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  // 次のページへ
  void _nextPage() {
    if (_currentPage < 3) { // 🎯 4ページに変更
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  // オンボーディング完了
  Future<void> _completeOnboarding() async {
    // ユーザープロフィール保存
    await _onboardingService.saveUserProfile(
      trainingLevel: _selectedTrainingLevel,
      trainingGoal: _selectedTrainingGoal,
      trainingFrequency: _selectedTrainingFrequency,
    );
    
    // 🎁 紹介コード処理（Task 10: バイラルループ）
    if (_hasReferralCode && _referralCodeController.text.trim().isNotEmpty) {
      try {
        final result = await _referralService.applyReferralCode(_referralCodeController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 紹介コードを適用しました！AI無料利用×3回を獲得！'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.error),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
    
    // オンボーディング完了マーク
    await _onboardingService.markOnboardingCompleted();
    
    // ホーム画面へ遷移
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27), // 濃いネイビー背景
      body: SafeArea(
        child: Column(
          children: [
            // プログレスインジケーター
            _buildProgressIndicator(),
            
            // ページコンテンツ
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // スワイプ無効
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1TrainingLevel(),
                  _buildPage2TrainingGoal(),
                  _buildPage3TrainingFrequency(),
                  _buildPage4Tutorial(), // 🎯 チュートリアル画面追加
                ],
              ),
            ),
            
            // 次へボタン
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  // プログレスインジケーター
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: List.generate(4, (index) { // 🎯 4ページに変更
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? Colors.purple
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Page 1: トレーニングレベル選択
  Widget _buildPage1TrainingLevel() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            AppLocalizations.of(context)!.trainingExperience,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.createOptimalMenu,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 40),
          _buildOptionCard(
            title: AppLocalizations.of(context)!.levelBeginner,
            subtitle: AppLocalizations.of(context)!.beginnerDesc,
            icon: Icons.self_improvement,
            isSelected: _selectedTrainingLevel == AppLocalizations.of(context)!.beginner,
            onTap: () {
              setState(() {
                _selectedTrainingLevel = AppLocalizations.of(context)!.beginner;
              });
            },
          ),
          SizedBox(height: 16),
          _buildOptionCard(
            title: AppLocalizations.of(context)!.levelIntermediate,
            subtitle: AppLocalizations.of(context)!.intermediateDesc,
            icon: Icons.fitness_center,
            isSelected: _selectedTrainingLevel == AppLocalizations.of(context)!.intermediate,
            onTap: () {
              setState(() {
                _selectedTrainingLevel = AppLocalizations.of(context)!.intermediate;
              });
            },
          ),
          SizedBox(height: 16),
          _buildOptionCard(
            title: AppLocalizations.of(context)!.advanced,
            subtitle: AppLocalizations.of(context)!.advancedDesc,
            icon: Icons.emoji_events,
            isSelected: _selectedTrainingLevel == AppLocalizations.of(context)!.advanced,
            onTap: () {
              setState(() {
                _selectedTrainingLevel = AppLocalizations.of(context)!.advanced;
              });
            },
          ),
        ],
      ),
    );
  }

  // Page 2: トレーニング目的選択
  Widget _buildPage2TrainingGoal() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            AppLocalizations.of(context)!.trainingGoal,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.optimalProgram,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 40),
          _buildOptionCard(
            title: AppLocalizations.of(context)!.goalMuscleGain,
            subtitle: AppLocalizations.of(context)!.muscleGrowthDesc,
            icon: Icons.volunteer_activism,
            isSelected: _selectedTrainingGoal == AppLocalizations.of(context)!.muscleGrowth,
            onTap: () {
              setState(() {
                _selectedTrainingGoal = AppLocalizations.of(context)!.muscleGrowth;
              });
            },
          ),
          SizedBox(height: 16),
          _buildOptionCard(
            title: AppLocalizations.of(context)!.goalDiet,
            subtitle: AppLocalizations.of(context)!.dietGoalDesc,
            icon: Icons.trending_down,
            isSelected: _selectedTrainingGoal == AppLocalizations.of(context)!.dietGoal,
            onTap: () {
              setState(() {
                _selectedTrainingGoal = AppLocalizations.of(context)!.dietGoal;
              });
            },
          ),
          SizedBox(height: 16),
          _buildOptionCard(
            title: AppLocalizations.of(context)!.goalMaintenance,
            subtitle: AppLocalizations.of(context)!.healthMaintenanceDesc,
            icon: Icons.favorite,
            isSelected: _selectedTrainingGoal == AppLocalizations.of(context)!.healthMaintenance,
            onTap: () {
              setState(() {
                _selectedTrainingGoal = AppLocalizations.of(context)!.healthMaintenance;
              });
            },
          ),
        ],
      ),
    );
  }

  // Page 3: トレーニング頻度選択
  Widget _buildPage3TrainingFrequency() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            AppLocalizations.of(context)!.trainingFrequency,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.general_頻度に応じた最適なボリュームを提案します,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 40),
          _buildOptionCard(
            title: '週1-2回',
            subtitle: AppLocalizations.of(context)!.startHabitBuilding,
            icon: Icons.calendar_today,
            isSelected: _selectedTrainingFrequency == AppLocalizations.of(context)!.frequency1to2,
            onTap: () {
              setState(() {
                _selectedTrainingFrequency = AppLocalizations.of(context)!.frequency1to2;
              });
            },
          ),
          SizedBox(height: 16),
          _buildOptionCard(
            title: '週3-4回',
            subtitle: AppLocalizations.of(context)!.regularTraining,
            icon: Icons.calendar_month,
            isSelected: _selectedTrainingFrequency == AppLocalizations.of(context)!.frequency3to4,
            onTap: () {
              setState(() {
                _selectedTrainingFrequency = AppLocalizations.of(context)!.frequency3to4;
              });
            },
          ),
          SizedBox(height: 16),
          _buildOptionCard(
            title: AppLocalizations.of(context)!.frequency5plus,
            subtitle: AppLocalizations.of(context)!.dailyTraining,
            icon: Icons.event_repeat,
            isSelected: _selectedTrainingFrequency == AppLocalizations.of(context)!.frequency5plus,
            onTap: () {
              setState(() {
                _selectedTrainingFrequency = AppLocalizations.of(context)!.frequency5plus;
              });
            },
          ),
        ],
      ),
    );
  }

  // オプションカード
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.purple.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.purple : Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.purple,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  // Page 4: アニメーション付きチュートリアル
  Widget _buildPage4Tutorial() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
          const SizedBox(height: 40),
          // アニメーションアイコン
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      size: 60,
                      color: Colors.purple,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 40),
          Text(
            AppLocalizations.of(context)!.ready,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'GYM MATCHで最高のトレーニング体験を',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          // 機能紹介カード
          _buildFeatureCard(
            icon: Icons.fitness_center,
            title: AppLocalizations.of(context)!.workoutRecords,
            description: AppLocalizations.of(context)!.general_簡単にワークアウトを記録管理,
            delay: 0,
          ),
          SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.psychology,
            title: AppLocalizations.of(context)!.aiFatigueAnalysis,
            description: AppLocalizations.of(context)!.aiAnalysisDesc,
            delay: 200,
          ),
          SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.emoji_events,
            title: AppLocalizations.of(context)!.general_目標達成,
            description: AppLocalizations.of(context)!.achievementSupport,
            delay: 400,
          ),
          const SizedBox(height: 32),
          // 🎁 紹介コード入力（Task 10: バイラルループ）
          _buildReferralCodeSection(),
          const SizedBox(height: 100), // 下部に余白追加
        ],
      ),
    ),
    );
  }

  /// 🎁 紹介コードセクション（Task 10: バイラルループ）
  Widget _buildReferralCodeSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.general_紹介コードをお持ちですか,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _hasReferralCode,
                  onChanged: (value) {
                    setState(() {
                      _hasReferralCode = value ?? false;
                    });
                  },
                  title: Text(
                    AppLocalizations.of(context)!.general_紹介コードを入力する,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.orange,
                ),
                if (_hasReferralCode) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _referralCodeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'GYM12ABC',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.orange.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.orange.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.confirmation_number, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✨ AI無料利用×3回を獲得！',
                    style: TextStyle(
                      color: Colors.amber.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // 機能紹介カード
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 次へボタン
  Widget _buildNextButton() {
    bool canProceed = false;
    
    if (_currentPage == 0) {
      canProceed = _selectedTrainingLevel.isNotEmpty;
    } else if (_currentPage == 1) {
      canProceed = _selectedTrainingGoal.isNotEmpty;
    } else if (_currentPage == 2) {
      canProceed = _selectedTrainingFrequency.isNotEmpty;
    } else if (_currentPage == 3) {
      canProceed = true; // チュートリアル画面は常に進める
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canProceed ? _nextPage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            disabledBackgroundColor: Colors.grey.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _currentPage < 3 ? AppLocalizations.of(context)!.next : AppLocalizations.of(context)!.getStarted, // 🎯 4ページに変更
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

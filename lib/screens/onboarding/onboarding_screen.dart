import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

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
  
  int _currentPage = 0;
  
  // ユーザー選択
  String _selectedTrainingLevel = '';
  String _selectedTrainingGoal = '';
  String _selectedTrainingFrequency = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 次のページへ
  void _nextPage() {
    if (_currentPage < 2) {
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
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
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
          const SizedBox(height: 40),
          const Text(
            'あなたのトレーニング経験は？',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'あなたに最適なメニューを作成します',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          _buildOptionCard(
            title: '初心者',
            subtitle: 'トレーニングを始めたばかり',
            icon: Icons.self_improvement,
            isSelected: _selectedTrainingLevel == '初心者',
            onTap: () {
              setState(() {
                _selectedTrainingLevel = '初心者';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            title: '中級者',
            subtitle: '半年〜2年程度の経験あり',
            icon: Icons.fitness_center,
            isSelected: _selectedTrainingLevel == '中級者',
            onTap: () {
              setState(() {
                _selectedTrainingLevel = '中級者';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            title: '上級者',
            subtitle: '2年以上の継続的な経験あり',
            icon: Icons.emoji_events,
            isSelected: _selectedTrainingLevel == '上級者',
            onTap: () {
              setState(() {
                _selectedTrainingLevel = '上級者';
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
          const SizedBox(height: 40),
          const Text(
            '主なトレーニング目的は？',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '目的に合わせた最適なプログラムを提案します',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          _buildOptionCard(
            title: '筋肥大',
            subtitle: '筋肉を大きくしたい',
            icon: Icons.volunteer_activism,
            isSelected: _selectedTrainingGoal == '筋肥大',
            onTap: () {
              setState(() {
                _selectedTrainingGoal = '筋肥大';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            title: 'ダイエット',
            subtitle: '体脂肪を減らしたい',
            icon: Icons.trending_down,
            isSelected: _selectedTrainingGoal == 'ダイエット',
            onTap: () {
              setState(() {
                _selectedTrainingGoal = 'ダイエット';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            title: '健康維持',
            subtitle: '健康的な身体を維持したい',
            icon: Icons.favorite,
            isSelected: _selectedTrainingGoal == '健康維持',
            onTap: () {
              setState(() {
                _selectedTrainingGoal = '健康維持';
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
          const SizedBox(height: 40),
          const Text(
            'トレーニング頻度は？',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '頻度に応じた最適なボリュームを提案します',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          _buildOptionCard(
            title: '週1-2回',
            subtitle: 'まずは習慣化から',
            icon: Icons.calendar_today,
            isSelected: _selectedTrainingFrequency == '週1-2回',
            onTap: () {
              setState(() {
                _selectedTrainingFrequency = '週1-2回';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            title: '週3-4回',
            subtitle: '本格的にトレーニング',
            icon: Icons.calendar_month,
            isSelected: _selectedTrainingFrequency == '週3-4回',
            onTap: () {
              setState(() {
                _selectedTrainingFrequency = '週3-4回';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            title: '週5回以上',
            subtitle: '毎日トレーニング',
            icon: Icons.event_repeat,
            isSelected: _selectedTrainingFrequency == '週5回以上',
            onTap: () {
              setState(() {
                _selectedTrainingFrequency = '週5回以上';
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

  // 次へボタン
  Widget _buildNextButton() {
    bool canProceed = false;
    
    if (_currentPage == 0) {
      canProceed = _selectedTrainingLevel.isNotEmpty;
    } else if (_currentPage == 1) {
      canProceed = _selectedTrainingGoal.isNotEmpty;
    } else if (_currentPage == 2) {
      canProceed = _selectedTrainingFrequency.isNotEmpty;
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
            _currentPage < 2 ? '次へ' : 'はじめる',
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

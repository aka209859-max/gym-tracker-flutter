import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'workout/add_workout_screen.dart';
import 'workout/rm_calculator_screen.dart';
import 'workout/ai_coaching_screen_tabbed.dart';
import 'workout/template_screen.dart';
import 'workout/workout_log_screen.dart';
import 'workout/statistics_dashboard_screen.dart';
import 'achievements_screen.dart';
import 'goals_screen.dart';
import '../models/workout_log.dart' as workout_models;
import '../models/goal.dart';
import '../services/achievement_service.dart';
import '../services/goal_service.dart';
import '../services/share_service.dart';
import '../services/workout_share_service.dart';
import '../services/enhanced_share_service.dart';
import '../services/fatigue_management_service.dart';
import '../services/advanced_fatigue_service.dart';
import '../models/user_profile.dart';
import '../widgets/workout_share_card.dart';
import '../widgets/workout_share_image.dart';
import '../providers/navigation_provider.dart';
import '../services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/paywall_trigger_service.dart';
import '../widgets/paywall_dialog.dart';
import '../services/ai_credit_service.dart';
import '../services/subscription_service.dart';

import '../services/reminder_service.dart';
import '../services/habit_formation_service.dart';
import '../services/magic_number_service.dart';
import '../services/crowd_alert_service.dart';
import '../services/referral_service.dart';
import 'debug_log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Map<String, dynamic>> _selectedDayWorkouts = [];
  bool _isLoading = false;
  
  // トレーニング記録がある日付のセット
  Set<DateTime> _workoutDates = {};
  
  // 種目ごとの展開状態を管理
  Map<String, bool> _expandedExercises = {};
  
  // 統計データ
  double _last7DaysVolume = 0.0;
  double _currentMonthVolume = 0.0;
  double _totalVolume = 0.0;
  
  // 日数カウンター（MONTHLY ARCHIVE & TOTAL）
  int _monthlyActiveDays = 0;  // 今月のワークアウト日数
  int _totalDaysFromStart = 0;  // 初回記録からの経過日数
  
  // Task 14: 検索・フィルター機能
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMuscleGroupFilter;
  DateTimeRange? _dateRangeFilter;
  List<Map<String, dynamic>> _filteredWorkouts = [];
  
  // 📱 AdMob広告関連
  final AdMobService _adMobService = AdMobService();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  
  // Task 16: バッジシステム
  final AchievementService _achievementService = AchievementService();
  Map<String, int> _badgeStats = {'total': 0, 'unlocked': 0, 'locked': 0};
  
  // Task 17: 目標システム
  final GoalService _goalService = GoalService();
  List<Goal> _activeGoals = [];
  
  // Task 27: SNSシェア
  final ShareService _shareService = ShareService();
  
  // 疲労管理システム
  final FatigueManagementService _fatigueService = FatigueManagementService();
  final AdvancedFatigueService _advancedFatigueService = AdvancedFatigueService();
  
  // 🔔 リマインダーシステム
  final ReminderService _reminderService = ReminderService();
  bool _show48HourReminder = false;
  bool _show7DayInactiveReminder = false;
  
  // 🔥 習慣形成システム
  final HabitFormationService _habitService = HabitFormationService();
  int _currentStreak = 0;
  
  // ✨ マジックナンバーシステム（5記録/30日）
  final MagicNumberService _magicNumberService = MagicNumberService();
  int _magicNumberCount = 0;
  double _magicNumberProgress = 0.0;
  bool _magicNumberAchieved = false;
  
  // 🔔 混雑度アラートシステム（Premium/Pro限定）
  final CrowdAlertService _crowdAlertService = CrowdAlertService();
  Map<String, int> _weeklyProgress = {'current': 0, 'goal': 3};
  List<Map<String, dynamic>> _topTrainingDays = [];
  
  // 🎁 バイラルループシステム（Task 10）
  final ReferralService _referralService = ReferralService();
  String? _referralCode;
  int _totalReferrals = 0;
  int _discountCredits = 0;
  
  // 詳細セクションの表示/非表示状態
  bool _isAdvancedSectionsExpanded = false;
  
  // SetType説明一覧の表示/非表示状態
  bool _showSetTypeExplanation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedDay = _focusedDay;
    // 空セットをクリーンアップしてからデータ読み込み
    _cleanupEmptySets().then((_) {
      _loadWorkoutDates(); // トレーニング記録がある日付を読み込む
      _loadWorkoutsForSelectedDay();
      _loadBadgeStats();
      _loadActiveGoals();
      _loadStatistics(); // 統計データを読み込む
      
      // 🎯 Day 7ペイウォールトリガーチェック
      _checkDay7Paywall();
      
      // 🔔 リマインダーチェック
      _checkReminders();
      
      // 🔥 習慣形成データ読み込み
      _loadHabitData();
      
      // 🎁 紹介コードデータ読み込み（Task 10）
      _loadReferralData();
      
      // 🎁 紹介バナー表示チェック（週1回）
      _checkAndShowReferralBanner();
    });
    
    // 📱 バナー広告をロード
    _loadBannerAd();
    
    // 🔔 混雑度アラート監視開始（Premium/Pro限定）
    _startCrowdAlertMonitoring();
  }
  
  /// 混雑度アラート監視を開始
  Future<void> _startCrowdAlertMonitoring() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _crowdAlertService.startMonitoring(user.uid);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 混雑度アラート監視開始エラー: $e');
      }
    }
  }
  
  /// Day 7ペイウォールをチェックして表示
  Future<void> _checkDay7Paywall() async {
    // initState完了後に遅延実行（UIが安定してから表示）
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final paywallService = PaywallTriggerService();
    final shouldShow = await paywallService.shouldShowDay7Paywall();
    
    if (shouldShow && mounted) {
      await PaywallDialog.show(context, PaywallType.day7Achievement);
      await paywallService.markDay7PaywallShown();
    }
  }
  
  /// 🔔 リマインダーをチェック
  Future<void> _checkReminders() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;
    
    // 7日連続達成リマインダーをチェック（ダイアログ）
    final shouldShow7DayStreak = await _reminderService.shouldShow7DayStreakReminder();
    if (shouldShow7DayStreak && mounted) {
      await _show7DayStreakDialog();
      await _reminderService.markStreak7DayReminderShown();
      return; // ダイアログ表示したら他のリマインダーは表示しない
    }
    
    // 48時間経過リマインダーをチェック（カード表示）
    final shouldShow48Hour = await _reminderService.shouldShow48HourReminder();
    
    // 7日間未記録リマインダーをチェック（カード表示）
    final shouldShow7DayInactive = await _reminderService.shouldShow7DayInactiveReminder();
    
    if (mounted) {
      setState(() {
        _show48HourReminder = shouldShow48Hour;
        _show7DayInactiveReminder = shouldShow7DayInactive;
      });
      
      // 7日間未記録リマインダーを表示済みとしてマーク
      if (shouldShow7DayInactive) {
        await _reminderService.markInactive7DayReminderShown();
      }
    }
  }
  
  /// 7日連続達成ダイアログを表示
  Future<void> _show7DayStreakDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade50,
                Colors.deepOrange.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎉 アイコン
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 48,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              
              // タイトル
              const Text(
                '7日連続達成！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              
              // メッセージ
              const Text(
                'おめでとうございます！\n7日間連続でトレーニングを記録しました。\nこの調子で続けましょう！💪',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // 閉じるボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ありがとう！',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 🔥 習慣形成データを読み込む
  Future<void> _loadHabitData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;
    
    // 連続トレーニング日数を取得
    final streak = await _habitService.getCurrentStreak();
    
    // 今週の進捗を取得
    final weeklyProgress = await _habitService.getWeeklyProgress();
    
    // 最もトレーニングしている曜日TOP3を取得
    final topDays = await _habitService.getTopTrainingDays();
    
    // ✨ マジックナンバー進捗を取得（5記録/30日）
    final magicData = await _magicNumberService.getProgress();
    
    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _weeklyProgress = weeklyProgress;
        _topTrainingDays = topDays;
        _magicNumberCount = magicData['count'] as int;
        _magicNumberProgress = magicData['progress'] as double;
        _magicNumberAchieved = magicData['isAchieved'] as bool? ?? false;
      });
      
      // マイルストーン達成チェック
      await _checkMilestone();
      
      // ✨ マジックナンバー達成チェック
      await _checkMagicNumberAchievement();
    }
  }
  
  /// マイルストーン達成をチェックして表示
  Future<void> _checkMilestone() async {
    if (!mounted) return;
    
    final milestone = await _habitService.checkMilestone();
    if (milestone != null && mounted) {
      await _showMilestoneDialog(milestone);
      await _habitService.markMilestoneShown(milestone);
    }
  }
  
  /// ✨ マジックナンバー達成をチェックして表示
  Future<void> _checkMagicNumberAchievement() async {
    if (!mounted) return;
    
    final shouldShow = await _magicNumberService.checkAndMarkAchievement();
    if (shouldShow && mounted) {
      await _showMagicNumberDialog();
    }
  }
  
  /// マイルストーン達成ダイアログを表示
  Future<void> _showMilestoneDialog(HabitMilestone milestone) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade50,
                Colors.deepPurple.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🏆 トロフィーアイコン
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 16),
              
              // タイトル
              Text(
                milestone.message,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 12),
              
              // メッセージ
              const Text(
                'すごい！マイルストーン達成です！\nこの調子で続けていきましょう！💪',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // 閉じるボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ありがとう！',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// バナー広告を読み込む
  Future<void> _loadBannerAd() async {
    await _adMobService.loadBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _bannerAd = ad;
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('バナー広告読み込み失敗: $error');
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // NavigationProviderのtargetDateを監視
    final navigationProvider = Provider.of<NavigationProvider>(
      context, 
      listen: true,
    );
    
    // 対象日付が設定されている場合、その日を選択
    if (navigationProvider.targetDate != null) {
      final targetDate = navigationProvider.targetDate!;
      print('📅 [HomeScreen] 対象日付を受信: ${targetDate.year}/${targetDate.month}/${targetDate.day}');
      
      setState(() {
        _selectedDay = targetDate;
        _focusedDay = targetDate;
      });
      
      // データを再読み込み
      _loadWorkoutsForSelectedDay();
      
      // targetDateをクリア（次回の遷移のため）
      Future.delayed(const Duration(milliseconds: 500), () {
        navigationProvider.clearTargetDate();
      });
    }
  }
  
  // Task 16: バッジ統計を読み込む
  Future<void> _loadBadgeStats() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      // バッジを初期化（初回のみ）
      await _achievementService.initializeUserBadges(user.uid);
      
      // バッジをチェックして更新
      await _achievementService.checkAndUpdateBadges(user.uid);
      
      // 統計を取得
      final stats = await _achievementService.getBadgeStats(user.uid);
      if (mounted) {
        setState(() {
          _badgeStats = stats;
        });
      }
    } catch (e) {
      print('❌ バッジ統計の読み込みエラー: $e');
    }
  }
  
  // Task 17: アクティブな目標を読み込む
  Future<void> _loadActiveGoals() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      // 進捗を更新
      await _goalService.updateGoalProgress(user.uid);
      
      // アクティブな目標を取得
      final goals = await _goalService.getActiveGoals(user.uid);
      if (mounted) {
        setState(() {
          _activeGoals = goals.where((g) => !g.isExpired).toList();
        });
      }
    } catch (e) {
      print('❌ 目標の読み込みエラー: $e');
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _bannerAd?.dispose();  // 📱 バナー広告を破棄
    
    // 🔔 混雑度アラート監視を停止
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      _crowdAlertService.stopMonitoring(user.uid);
    }
    
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // アプリが foreground に戻った時に自動リフレッシュ
      print('🔄 アプリがアクティブになりました - データを再読み込み');
      _loadWorkoutDates(); // トレーニング記録日付も再読み込み
      _loadWorkoutsForSelectedDay();
      _loadStatistics(); // 統計データも再読み込み
    }
  }
  
  /// 統計データと日数カウンターを計算して読み込む
  Future<void> _loadStatistics() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      print('📊 統計データを計算中...');
      
      // 全トレーニング記録を取得（シンプルクエリ - インデックス不要）
      final querySnapshot = await FirebaseFirestore.instance
          .collection('workout_logs')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      print('📊 全記録件数: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _last7DaysVolume = 0.0;
          _currentMonthVolume = 0.0;
          _totalVolume = 0.0;
          _monthlyActiveDays = 0;
          _totalDaysFromStart = 0;
        });
        return;
      }
      
      // 基準日
      final now = DateTime.now();
      final last7DaysStart = now.subtract(const Duration(days: 7));
      final currentMonthStart = DateTime(now.year, now.month, 1);
      
      double last7DaysVolume = 0.0;
      double currentMonthVolume = 0.0;
      double totalVolume = 0.0;
      
      // 🆕 日数カウンター用の変数
      DateTime? firstWorkoutDate;
      Set<String> monthlyWorkoutDates = {};  // 今月のワークアウト日（重複除去）
      
      // 各トレーニング記録を処理
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp?)?.toDate();
        final sets = data['sets'] as List<dynamic>? ?? [];
        
        if (date == null) continue;
        
        // 🆕 最初のワークアウト日を記録
        if (firstWorkoutDate == null || date.isBefore(firstWorkoutDate)) {
          firstWorkoutDate = date;
        }
        
        // 🆕 今月のワークアウト日をカウント
        if (date.year == now.year && date.month == now.month) {
          final dateKey = '${date.year}-${date.month}-${date.day}';
          monthlyWorkoutDates.add(dateKey);
        }
        
        // この記録の総負荷量を計算
        double workoutVolume = 0.0;
        for (final set in sets) {
          if (set is Map<String, dynamic>) {
            final weight = (set['weight'] as num?)?.toDouble() ?? 0.0;
            final reps = (set['reps'] as num?)?.toInt() ?? 0;
            workoutVolume += (weight * reps);
          }
        }
        
        // トンに変換
        workoutVolume = workoutVolume / 1000.0;
        
        // 期間別に集計
        totalVolume += workoutVolume;
        
        if (date.isAfter(last7DaysStart)) {
          last7DaysVolume += workoutVolume;
        }
        
        if (date.isAfter(currentMonthStart)) {
          currentMonthVolume += workoutVolume;
        }
      }
      
      // 🆕 日数計算（バグ修正: 最低値を1に設定）
      int totalDaysFromStart = 0;
      if (firstWorkoutDate != null) {
        // 初回記録から今日までの日数（+1で最低値1を保証）
        totalDaysFromStart = now.difference(firstWorkoutDate).inDays + 1;
        print('📅 初回ワークアウト: ${firstWorkoutDate.year}/${firstWorkoutDate.month}/${firstWorkoutDate.day}');
        print('📅 経過日数: $totalDaysFromStart日');
      }
      
      final monthlyActiveDays = monthlyWorkoutDates.length;
      print('📅 今月のアクティブ日数: $monthlyActiveDays日');
      
      print('✅ 統計計算完了:');
      print('   7日間: ${last7DaysVolume.toStringAsFixed(2)}t');
      print('   今月: ${currentMonthVolume.toStringAsFixed(2)}t');
      print('   全期間: ${totalVolume.toStringAsFixed(2)}t');
      
      setState(() {
        _last7DaysVolume = last7DaysVolume;
        _currentMonthVolume = currentMonthVolume;
        _totalVolume = totalVolume;
        _monthlyActiveDays = monthlyActiveDays;
        _totalDaysFromStart = totalDaysFromStart;
      });
      
    } catch (e) {
      print('❌ 統計データの計算エラー: $e');
      setState(() {
        _last7DaysVolume = 0.0;
        _currentMonthVolume = 0.0;
        _totalVolume = 0.0;
        _monthlyActiveDays = 0;
        _totalDaysFromStart = 0;
      });
    }
  }

  /// トレーニング記録がある日付を読み込む（カレンダーマーカー用）
  Future<void> _loadWorkoutDates() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      print('📅 トレーニング記録日付を取得中...');
      
      // 全トレーニング記録の日付を取得
      final querySnapshot = await FirebaseFirestore.instance
          .collection('workout_logs')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      final workoutDates = <DateTime>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp?)?.toDate();
        
        if (date != null) {
          // 時刻を正規化（日付のみを使用）
          final normalizedDate = DateTime(date.year, date.month, date.day);
          workoutDates.add(normalizedDate);
        }
      }
      
      print('✅ トレーニング記録日付: ${workoutDates.length}日');
      
      setState(() {
        _workoutDates = workoutDates;
      });
      
    } catch (e) {
      print('❌ トレーニング記録日付の取得エラー: $e');
    }
  }

  // トレーニング記録をシェア
  Future<void> _handleShare() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      // ログイン不要でシェア機能を利用可能にする

      if (_selectedDay == null || _selectedDayWorkouts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('シェアできるトレーニング記録がありません'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 種目ごとにグループ化（home_screen表示ロジックと同じ構造）
      final exerciseMap = <String, List<Map<String, dynamic>>>{};
      
      for (final workout in _selectedDayWorkouts) {
        final sets = workout['sets'] as List<dynamic>?;
        
        if (sets != null) {
          for (final set in sets) {
            final setData = set as Map<String, dynamic>;
            final name = setData['exercise_name'] as String? ?? '不明な種目';
            
            if (!exerciseMap.containsKey(name)) {
              exerciseMap[name] = [];
            }
            
            exerciseMap[name]!.add({
              'weight': setData['weight'] ?? 0,
              'reps': setData['reps'] ?? 0,
            });
          }
        }
      }

      // WorkoutExerciseGroupリストに変換
      final exerciseGroups = exerciseMap.entries.map((entry) {
        return WorkoutExerciseGroup(
          name: entry.key,
          sets: entry.value,
        );
      }).toList();

      if (exerciseGroups.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('シェアできる種目がありません'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // シェア実行（Instagram Stories対応版）
      final shareService = EnhancedShareService();
      await shareService.shareWorkout(
        context: context,
        date: _selectedDay!,
        exercises: exerciseGroups,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('シェアに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 選択した日のトレーニング記録を読み込む
  Future<void> _loadWorkoutsForSelectedDay() async {
    if (_selectedDay == null) return;

    print('🔍 トレーニング記録を読み込み開始...');
    print('📅 選択日: ${_selectedDay!.year}/${_selectedDay!.month}/${_selectedDay!.day}');

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ ユーザーが未ログインです');
        // ユーザーが未ログインの場合もローディング終了
        if (mounted) {
          setState(() {
            _selectedDayWorkouts = [];
            _isLoading = false;
          });
        }
        return;
      }

      DebugLogger.instance.log('👤 User ID: ${user.uid}');
      DebugLogger.instance.log('📧 User Email: ${user.email}');

      // シンプルなクエリ（インデックス不要）
      DebugLogger.instance.log('🔍 ユーザーの全記録を取得中...');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('workout_logs')
          .where('user_id', isEqualTo: user.uid)
          .get(const GetOptions(source: Source.server));

      DebugLogger.instance.log('📊 全記録件数: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        DebugLogger.instance.log('⚠️ このユーザーの記録が見つかりません');
        DebugLogger.instance.log('   考えられる原因:');
        DebugLogger.instance.log('   1. まだトレーニングを記録していない');
        DebugLogger.instance.log('   2. Firestoreセキュリティルールで読み込みが拒否されている');
        DebugLogger.instance.log('   3. 異なるユーザーアカウントでログインしている');
      }

      // 選択した日（年・月・日のみ）
      final selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

      print('🕐 選択日: $selectedDate (${selectedDate.year}/${selectedDate.month}/${selectedDate.day})');

      // メモリ内でフィルタリング
      DebugLogger.instance.log('🔄 データマッピング開始...');
      final allWorkouts = <Map<String, dynamic>>[];
      
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        try {
          final doc = querySnapshot.docs[i];
          final data = doc.data();
          
          // データ構造をログ出力（最初の1件のみ）
          if (i == 0) {
            DebugLogger.instance.log('📋 データ構造サンプル:');
            DebugLogger.instance.log('   muscle_group: ${data['muscle_group']?.runtimeType}');
            DebugLogger.instance.log('   date: ${data['date']?.runtimeType}');
            DebugLogger.instance.log('   sets: ${data['sets']?.runtimeType}');
          }
          
          final workout = {
            'id': doc.id,
            'muscle_group': data['muscle_group'],
            'start_time': data['start_time'],
            'end_time': data['end_time'],
            'sets': data['sets'] as List<dynamic>,
            'date': (data['date'] as Timestamp).toDate(),
          };
          allWorkouts.add(workout);
        } catch (e) {
          DebugLogger.instance.log('❌ データマッピングエラー [$i]: $e');
          continue;
        }
      }

      DebugLogger.instance.log('✅ マッピング完了: ${allWorkouts.length}/${querySnapshot.docs.length}件');
      DebugLogger.instance.log('📊 全ワークアウト詳細: ${allWorkouts.length}件');
      for (var i = 0; i < allWorkouts.length && i < 3; i++) {
        final workout = allWorkouts[i];
        final workoutDate = workout['date'] as DateTime;
        final normalizedDate = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
        DebugLogger.instance.log('   [$i] date=${normalizedDate.year}/${normalizedDate.month}/${normalizedDate.day}, muscle=${workout['muscle_group']}');
      }
      if (allWorkouts.length > 3) {
        DebugLogger.instance.log('   ... 他 ${allWorkouts.length - 3}件');
      }

      // 選択した日のデータだけをフィルタ（時刻を無視して年月日のみで比較）
      DebugLogger.instance.log('🔍 フィルタリング開始: 選択日=${_selectedDay!.year}/${_selectedDay!.month}/${_selectedDay!.day}');
      
      int matchCount = 0;
      int excludeCount = 0;
      
      final filteredWorkouts = allWorkouts.where((workout) {
        final workoutDate = workout['date'] as DateTime;
        // 🔧 FIX: _isSameDay ヘルパーを使用して日付のみで正確に比較
        final isMatch = _isSameDay(workoutDate, _selectedDay!);
        
 
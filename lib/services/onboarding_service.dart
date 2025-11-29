import 'package:shared_preferences/shared_preferences.dart';

/// オンボーディング管理サービス
/// 
/// 初回起動判定やオンボーディング完了状態を管理します
class OnboardingService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyUserTrainingLevel = 'user_training_level';
  static const String _keyUserTrainingGoal = 'user_training_goal';
  static const String _keyUserTrainingFrequency = 'user_training_frequency';

  /// オンボーディングが完了しているか確認
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// オンボーディングを完了としてマーク
  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// ユーザープロフィールを保存
  Future<void> saveUserProfile({
    required String trainingLevel,
    required String trainingGoal,
    required String trainingFrequency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserTrainingLevel, trainingLevel);
    await prefs.setString(_keyUserTrainingGoal, trainingGoal);
    await prefs.setString(_keyUserTrainingFrequency, trainingFrequency);
  }

  /// ユーザープロフィールを取得
  Future<Map<String, String>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'trainingLevel': prefs.getString(_keyUserTrainingLevel) ?? '',
      'trainingGoal': prefs.getString(_keyUserTrainingGoal) ?? '',
      'trainingFrequency': prefs.getString(_keyUserTrainingFrequency) ?? '',
    };
  }

  /// オンボーディング状態をリセット（デバッグ用）
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingCompleted);
    await prefs.remove(_keyUserTrainingLevel);
    await prefs.remove(_keyUserTrainingGoal);
    await prefs.remove(_keyUserTrainingFrequency);
  }
}

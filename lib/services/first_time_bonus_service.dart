import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 初回ボーナスサービス（v1.02新機能）
/// 
/// 新規ユーザーに初回AI無料体験を提供
class FirstTimeBonusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 初回ボーナス
  static const int _firstTimeAiBonus = 3; // AI無料体験×3回

  /// 初回ボーナスを付与
  Future<void> grantFirstTimeBonus() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // 既に付与済みかチェック
      if (await hasReceivedFirstTimeBonus()) {
        print('ℹ️ 初回ボーナス: 既に付与済み');
        return;
      }

      // Firestoreに初回ボーナスを記録
      await _firestore.collection('users').doc(user.uid).update({
        'firstTimeBonusAiCredits': _firstTimeAiBonus,
        'firstTimeBonusGrantedAt': FieldValue.serverTimestamp(),
      });

      // SharedPreferencesにもキャッシュ
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_time_bonus_granted', true);

      print('✅ 初回ボーナス付与成功: AI×$_firstTimeAiBonus回');
    } catch (e) {
      print('❌ 初回ボーナス付与エラー: $e');
      throw Exception('Failed to grant first time bonus: $e');
    }
  }

  /// 初回ボーナスを受け取り済みかチェック
  Future<bool> hasReceivedFirstTimeBonus() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // まずSharedPreferencesをチェック（高速）
    final prefs = await SharedPreferences.getInstance();
    final cachedResult = prefs.getBool('first_time_bonus_granted');
    if (cachedResult != null) {
      return cachedResult;
    }

    // Firestoreをチェック
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();

    final hasReceived = data?.containsKey('firstTimeBonusGrantedAt') ?? false;

    // キャッシュに保存
    await prefs.setBool('first_time_bonus_granted', hasReceived);

    return hasReceived;
  }

  /// 初回ボーナスのAIクレジット数を取得
  Future<int> getFirstTimeBonusAiCredits() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();

    return data?['firstTimeBonusAiCredits'] as int? ?? 0;
  }

  /// 初回ボーナスのAIクレジットを消費
  Future<void> consumeFirstTimeBonusAiCredit() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update({
      'firstTimeBonusAiCredits': FieldValue.increment(-1),
    });

    print('✅ 初回ボーナスAI消費: 残り${await getFirstTimeBonusAiCredits()}回');
  }

  /// 初回体験ウェルカムダイアログを表示すべきかチェック
  Future<bool> shouldShowWelcomeDialog() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // 初回ボーナス未受け取り
    if (!(await hasReceivedFirstTimeBonus())) {
      return true;
    }

    // ウェルカムダイアログを表示済みかチェック
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('welcome_dialog_shown') ?? false;

    return !shown;
  }

  /// ウェルカムダイアログを表示済みにする
  Future<void> markWelcomeDialogAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcome_dialog_shown', true);
  }
}

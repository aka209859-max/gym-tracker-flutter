import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gym_match/gen/app_localizations.dart';
/// 現在ログイン中のユーザーのサブスクリプション情報を表示
Future<void> debugCurrentUserSubscription() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      print('❌ ユーザーがログインしていません');
      return;
    }
    
    print('=== サブスクリプション情報 ===');
    print('User ID: ${user.uid}');
    print('Email: ${user.email ?? AppLocalizations.of(context)!.workout_7f3b4423}');
    print('Anonymous: ${user.isAnonymous}');
    print('');
    
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    if (!userDoc.exists) {
      print('❌ Firestoreにユーザー情報が存在しません');
      return;
    }
    
    final data = userDoc.data()!;
    final isPremium = data['isPremium'] as bool? ?? false;
    final premiumType = data['premiumType'] as String? ?? 'free';
    final premiumEndDate = data['premiumEndDate'] as Timestamp?;
    final premiumStartDate = data['premiumStartDate'] as Timestamp?;
    
    print(AppLocalizations.of(context)!.subscription_a9e04143);
    print('  isPremium: $isPremium');
    print('  premiumType: $premiumType');
    print('');
    
    if (premiumStartDate != null) {
      print('開始日: ${premiumStartDate.toDate()}');
    }
    
    if (premiumEndDate != null) {
      final endDate = premiumEndDate.toDate();
      print(AppLocalizations.of(context)!.generatedKey_cbb37278);
      
      final now = DateTime.now();
      final remaining = endDate.difference(now);
      
      if (endDate.year >= 2099) {
        print(AppLocalizations.of(context)!.generatedKey_3a8ab63e);
      } else if (remaining.isNegative) {
        print('❌ 期限切れ（${remaining.inDays.abs()}日前に終了）');
      } else {
        print('✅ 残り: ${remaining.inDays}日');
      }
    } else {
      print(AppLocalizations.of(context)!.subscription_7db85d75);
    }
    
    print('======================');
  } catch (e) {
    print('❌ エラー: $e');
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:gym_match/gen/app_localizations.dart';
/// AdMob広告管理サービス
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  /// AdMob初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Web環境ではAdMobをスキップ
    if (kIsWeb) {
      print(AppLocalizations.of(context)!.general_36030a98);
      _isInitialized = true;
      return;
    }
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
    print('✅ AdMob initialized successfully');
  }

  /// バナー広告ID取得（iOS専用）
  static String get bannerAdUnitId {
    // ✅ 修正: kReleaseMode を使用してリリースビルドでは必ず本番広告を表示
    if (kReleaseMode) {
      // iOS本番広告ID（TestFlight、App Store）
      return 'ca-app-pub-2887531479031819/1682429555';
    }
    
    // デバッグビルドのみテスト広告を表示
    return 'ca-app-pub-3940256099942544/2934735716'; // Googleテスト用バナー広告ID
  }

  /// インタースティシャル広告ID取得（iOS専用）
  static String get interstitialAdUnitId {
    // ✅ 修正: kReleaseMode を使用
    if (kReleaseMode) {
      // iOS本番インタースティシャル広告ID
      // 現在は未使用のため、テストIDを使用
      return 'ca-app-pub-3940256099942544/4411468910'; // TODO: 本番IDに要変更
    }
    
    // デバッグビルドのみテスト広告を表示
    return 'ca-app-pub-3940256099942544/4411468910'; // Googleテスト用インタースティシャル広告ID
  }

  /// リワード広告ID取得（iOS専用）
  static String get rewardedAdUnitId {
    // iOS本番リワード広告ID（AI使用回数+1機能）
    return 'ca-app-pub-2887531479031819/6163055454';
  }
}

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ai_credit_service.dart';

/// リワード動画広告サービス（CEO戦略: 動画1回視聴 → AI機能1回追加）
class RewardAdService {
  static final RewardAdService _instance = RewardAdService._internal();
  factory RewardAdService() => _instance;
  RewardAdService._internal();
  
  final AICreditService _creditService = AICreditService();
  
  // AdMob Unit IDs (テスト用)
  // 本番環境では実際のUnit IDに置き換える
  static const String _rewardAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // テスト用
      : 'YOUR_PRODUCTION_REWARD_AD_UNIT_ID';
  
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  bool _isAdReady = false;
  
  /// AdMob SDKを初期化
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) {
        debugPrint('✅ AdMob SDK initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AdMob initialization error: $e');
      }
    }
  }
  
  /// リワード動画広告を読み込み
  Future<void> loadRewardedAd() async {
    if (_isAdLoading || _isAdReady) {
      return;
    }
    
    _isAdLoading = true;
    
    try {
      await RewardedAd.load(
        adUnitId: _rewardAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (kDebugMode) {
              debugPrint('✅ Rewarded ad loaded');
            }
            _rewardedAd = ad;
            _isAdReady = true;
            _isAdLoading = false;
            
            // 広告イベントリスナー設定
            _setupAdCallbacks(ad);
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              debugPrint('❌ Rewarded ad failed to load: $error');
            }
            _isAdLoading = false;
            _isAdReady = false;
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ loadRewardedAd error: $e');
      }
      _isAdLoading = false;
    }
  }
  
  /// 広告イベントリスナーを設定
  void _setupAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) {
          debugPrint('📺 Rewarded ad showed full screen');
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) {
          debugPrint('📺 Rewarded ad dismissed');
        }
        ad.dispose();
        _rewardedAd = null;
        _isAdReady = false;
        
        // 次の広告を事前ロード
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          debugPrint('❌ Rewarded ad failed to show: $error');
        }
        ad.dispose();
        _rewardedAd = null;
        _isAdReady = false;
        
        // エラー後も次の広告を試行
        loadRewardedAd();
      },
    );
  }
  
  /// リワード動画広告を表示（成功時にAIクレジット付与）
  Future<bool> showRewardedAd() async {
    if (!_isAdReady || _rewardedAd == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Rewarded ad not ready');
      }
      return false;
    }
    
    bool rewardGranted = false;
    
    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) async {
          if (kDebugMode) {
            debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
          }
          
          // AI機能1回分のクレジットを付与
          await _creditService.addAICredit(1);
          await _creditService.recordAdEarned();
          rewardGranted = true;
        },
      );
      
      return rewardGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ showRewardedAd error: $e');
      }
      return false;
    }
  }
  
  /// 広告が準備完了か
  bool isAdReady() {
    return _isAdReady && _rewardedAd != null;
  }
  
  /// サービスを破棄
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
  }
}

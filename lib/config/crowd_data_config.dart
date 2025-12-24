/// 混雑度データ戦略の設定管理
/// 
/// フェーズベースのデータソース切り替えを管理
class CrowdDataConfig {
  /// 現在のデータ戦略フェーズ
  /// 
  /// - Phase1: 統計ベース + ユーザー報告（コスト$0）
  /// - Phase2: ハイブリッド（人気ジムのみAPI、コスト$170/月）
  /// - Phase3: フルAPI（全ジムAPI、コスト$850/月）
  static const CrowdDataPhase currentPhase = CrowdDataPhase.phase1;
  
  /// Google Places API (Advanced) の有効/無効
  /// 
  /// Phase1: false（統計推定のみ）
  /// Phase2: true（人気ジムのみ）
  /// Phase3: true（全ジムで使用）
  static const bool enableGooglePlacesAPI = false;
  
  /// API使用対象ジムの条件（Phase2用）
  /// 
  /// Phase2では人気ジムのみAPI使用してコスト削減
  static const int minimumReviewsForAPI = 100;  // レビュー100件以上
  static const double minimumRatingForAPI = 4.0; // 評価4.0以上
  
  /// API呼び出し上限（月間）
  /// 
  /// Phase2: 10,000リクエスト/月（$170/月）
  /// Phase3: 50,000リクエスト/月（$850/月）
  static const int monthlyAPILimit = 10000;
  
  /// キャッシュ有効期限（秒）
  /// 
  /// データ鮮度とコストのバランス
  static const int peakTimeCacheSeconds = 3600;      // ピーク時: 1時間
  static const int normalTimeCacheSeconds = 14400;   // 通常時: 4時間
  static const int nightTimeCacheSeconds = 28800;    // 深夜: 8時間
  
  /// ユーザー報告の有効期限（秒）
  static const int userReportValiditySeconds = 86400; // 24時間
  
  /// 現在のフェーズに応じたAPI使用判定
  /// 
  /// [rating] ジムの評価
  /// [reviewCount] レビュー数
  /// 
  /// 戻り値: API使用可能かどうか
  static bool shouldUseAPIForGym({
    required double? rating,
    required int? reviewCount,
  }) {
    // Phase1: API無効（統計推定のみ）
    if (currentPhase == CrowdDataPhase.phase1) {
      return false;
    }
    
    // API機能が無効の場合
    if (!enableGooglePlacesAPI) {
      return false;
    }
    
    // Phase3: 全ジムでAPI使用
    if (currentPhase == CrowdDataPhase.phase3) {
      return true;
    }
    
    // Phase2: 人気ジムのみAPI使用
    if (currentPhase == CrowdDataPhase.phase2) {
      if (rating == null || reviewCount == null) {
        return false; // データ不足はAPI使用しない
      }
      
      return rating >= minimumRatingForAPI && 
             reviewCount >= minimumReviewsForAPI;
    }
    
    return false;
  }
  
  /// 現在時刻に応じた適切なキャッシュ期限を取得
  static int getCacheDuration() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // ピークタイム判定
    final isWeekend = now.weekday >= 6;
    final isPeakTime = isWeekend 
        ? (hour >= 10 && hour <= 15)  // 週末ピーク
        : (hour >= 18 && hour <= 21) || (hour >= 7 && hour <= 9); // 平日ピーク
    
    if (isPeakTime) {
      return peakTimeCacheSeconds;     // 1時間
    } else if (hour >= 0 && hour <= 6) {
      return nightTimeCacheSeconds;    // 8時間（深夜）
    } else {
      return normalTimeCacheSeconds;   // 4時間（通常）
    }
  }
  
  /// フェーズ情報の表示用テキスト
  static String get phaseDescription {
    switch (currentPhase) {
      case CrowdDataPhase.phase1:
        return AppLocalizations.of(context)!.generatedKey_d1f54967;
      case CrowdDataPhase.phase2:
        return AppLocalizations.of(context)!.generatedKey_cbcfc076;
      case CrowdDataPhase.phase3:
        return AppLocalizations.of(context)!.generatedKey_7d8a2d8a;
    }
  }
  
  /// 月額API費用の見積もり
  static String get estimatedMonthlyCost {
    switch (currentPhase) {
      case CrowdDataPhase.phase1:
        return '\$0';
      case CrowdDataPhase.phase2:
        return '\$170';
      case CrowdDataPhase.phase3:
        return '\$850';
    }
  }
}

/// データ戦略フェーズの列挙型
enum CrowdDataPhase {
  /// フェーズ1: 統計ベース + ユーザー報告
  /// 
  /// - 対象収益: 0 - 100万円/月
  /// - コスト: $0/月
  /// - データ精度: 70-90%
  phase1,
  
  /// フェーズ2: ハイブリッド戦略
  /// 
  /// - 対象収益: 100 - 300万円/月
  /// - コスト: $170/月
  /// - データ精度: 85-95%
  phase2,
  
  /// フェーズ3: フルAPI導入
  /// 
  /// - 対象収益: 300万円/月以上
  /// - コスト: $850/月
  /// - データ精度: 90-95%
  phase3,
}

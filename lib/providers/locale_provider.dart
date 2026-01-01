import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 言語設定を管理するProvider
/// 
/// サポート言語:
/// - ja: 日本語
/// - en: 英語（米国）
/// - ko: 韓国語
/// - zh: 中国語（簡体字）
/// - de: ドイツ語
/// - es: スペイン語
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ja'); // デフォルト: 日本語
  
  static const String _localeKey = 'app_locale';
  
  /// サポートされている言語リスト
  /// 🆕 Build #24.1 Hotfix9.9: 7言語完全対応（zh_TW追加）
  static const List<LocaleInfo> supportedLocales = [
    LocaleInfo(locale: Locale('ja'), name: '日本語', nativeName: '日本語', flag: '🇯🇵'),
    LocaleInfo(locale: Locale('en'), name: 'English', nativeName: 'English', flag: '🇺🇸'),
    LocaleInfo(locale: Locale('ko'), name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    LocaleInfo(locale: Locale('zh'), name: 'Chinese (Simplified)', nativeName: '中文（简体）', flag: '🇨🇳'),
    LocaleInfo(locale: Locale('zh', 'TW'), name: 'Chinese (Traditional)', nativeName: '中文（繁體）', flag: '🇹🇼'),
    LocaleInfo(locale: Locale('de'), name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    LocaleInfo(locale: Locale('es'), name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
  ];
  
  Locale get locale => _locale;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  LocaleProvider() {
    _loadLocale();
  }
  
  /// SharedPreferencesから保存された言語設定を読み込み
  /// 🆕 Build #24.1 Hotfix9.9: zh_TW対応（countryCode保存）
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      final countryCode = prefs.getString('${_localeKey}_country'); // 🆕 countryCode取得
      
      if (languageCode != null) {
        // 🆕 Build #24.1 Hotfix9.9: countryCodeも含めてマッチング
        final isSupported = supportedLocales.any((info) => 
          info.locale.languageCode == languageCode &&
          (countryCode == null || info.locale.countryCode == countryCode)
        );
        
        if (isSupported) {
          _locale = countryCode != null 
            ? Locale(languageCode, countryCode) // zh_TW などのケース
            : Locale(languageCode); // 通常のケース
          print('✅ 保存された言語設定を読み込み: $languageCode${countryCode != null ? "_$countryCode" : ""}');
        } else {
          print('⚠️ サポートされていない言語コード: $languageCode${countryCode != null ? "_$countryCode" : ""} (デフォルト: ja)');
        }
      }
    } catch (e) {
      print('⚠️ 言語設定の読み込みに失敗: $e (デフォルト: ja)');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// 言語を変更してSharedPreferencesに保存
  /// 🆕 Build #24.1 Hotfix9.9: zh_TW対応（countryCode保存）
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      
      // 🆕 Build #24.1 Hotfix9.9: countryCodeがある場合は保存（zh_TW用）
      if (locale.countryCode != null) {
        await prefs.setString('${_localeKey}_country', locale.countryCode!);
        print('✅ 言語設定を保存: ${locale.languageCode}_${locale.countryCode}');
      } else {
        await prefs.remove('${_localeKey}_country'); // countryCodeがない場合は削除
        print('✅ 言語設定を保存: ${locale.languageCode}');
      }
    } catch (e) {
      print('❌ 言語設定の保存に失敗: $e');
    }
  }
  
  /// 現在の言語情報を取得
  /// 🆕 Build #24.1 Hotfix9.9: zh_TW対応（countryCodeも比較）
  LocaleInfo get currentLocaleInfo {
    return supportedLocales.firstWhere(
      (info) => info.locale.languageCode == _locale.languageCode &&
                info.locale.countryCode == _locale.countryCode,
      orElse: () => supportedLocales[0], // デフォルト: 日本語
    );
  }
}

/// 言語情報クラス
class LocaleInfo {
  final Locale locale;
  final String name;        // 英語名
  final String nativeName;  // ネイティブ名（その言語での表記）
  final String flag;        // 国旗絵文字
  
  const LocaleInfo({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

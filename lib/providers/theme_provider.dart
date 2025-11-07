import 'package:flutter/material.dart';
import '../utils/app_themes.dart';

/// テーマ管理プロバイダー（Energeticテーマ固定）
/// iOS若年層ターゲット向けに、ダークブルー×エナジーオレンジに統一
class ThemeProvider with ChangeNotifier {
  // テーマはEnergetic系に固定
  final String _currentThemeKey = 'energetic';
  final ThemeData _currentTheme = AppThemes.energeticTheme;

  String get currentThemeKey => _currentThemeKey;
  ThemeData get currentTheme => _currentTheme;
}

import 'package:flutter/foundation.dart';

/// ナビゲーション状態管理プロバイダー
/// 
/// BottomNavigationBarのタブ切り替えを管理
class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  DateTime? _targetDate; // 記録画面で表示する対象日付

  int get selectedIndex => _selectedIndex;
  DateTime? get targetDate => _targetDate;

  /// タブを切り替え
  void selectTab(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  /// 記録画面に切り替え + 特定日付を指定
  void navigateToRecordWithDate(DateTime date) {
    _targetDate = date;
    _selectedIndex = 0; // HomeScreen（記録画面）のインデックス
    notifyListeners();
  }

  /// 対象日付をクリア
  void clearTargetDate() {
    _targetDate = null;
    notifyListeners();
  }
}

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Phase 6.9: 残り5箇所の完全修正スクリプト
"""

import re
from pathlib import Path

class FinalFixer:
    def __init__(self):
        # デバッグprint文は英語に統一（contextが使えないため）
        self.fixes = [
            {
                'file': 'lib/screens/home_screen.dart',
                'line': 4232,
                'old': "print('🎯 削除対象: \"$exerciseName\" (length=${exerciseName.length})');",
                'new': "print('🎯 Delete target: \"$exerciseName\" (length=${exerciseName.length})');",
            },
            {
                'file': 'lib/screens/home_screen.dart',
                'line': 4237,
                'old': "print('   セット比較: \"$setExerciseName\" vs \"$exerciseName\" → Match=$isMatch');",
                'new': "print('   Set comparison: \"$setExerciseName\" vs \"$exerciseName\" → Match=$isMatch');",
            },
            {
                'file': 'lib/screens/search_screen.dart',
                'line': 854,
                'old': "print('📝 テキスト検索: \"$_searchQuery\"');",
                'new': "print('📝 Text search: \"$_searchQuery\"');",
            },
            {
                'file': 'lib/screens/search_screen.dart',
                'line': 938,
                'old': "print('   検索クエリ: \"$query\"');",
                'new': "print('   Search query: \"$query\"');",
            },
            {
                'file': 'lib/screens/workout/workout_log_screen.dart',
                'line': 52,
                'old': "print('📱 [WorkoutLogScreen] 現在のユーザー: ${user?.uid ?? 'null'}');",
                'new': "print('📱 [WorkoutLogScreen] Current user: ${user?.uid ?? 'null'}');",
            },
        ]
    
    def apply_fixes(self):
        """修正を適用"""
        print("=" * 80)
        print("Phase 6.9: 残り5箇所の完全修正")
        print("=" * 80)
        
        total_fixed = 0
        
        for fix in self.fixes:
            file_path = Path(fix['file'])
            
            if not file_path.exists():
                print(f"⚠️ ファイルが存在しません: {file_path}")
                continue
            
            # ファイルを読み込む
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 修正を適用
            if fix['old'] in content:
                new_content = content.replace(fix['old'], fix['new'])
                
                # ファイルに書き込む
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                print(f"✅ {file_path}:{fix['line']} - 修正完了")
                total_fixed += 1
            else:
                print(f"⚠️ {file_path}:{fix['line']} - パターンが見つかりません")
        
        print(f"\n" + "=" * 80)
        print(f"修正完了: {total_fixed}/5箇所")
        print("=" * 80)
        
        return total_fixed

def main():
    fixer = FinalFixer()
    total = fixer.apply_fixes()
    
    if total == 5:
        print("\n🎉 100%達成！全ての日本語ハードコードを削除しました！")
    else:
        print(f"\n⚠️ {5-total}箇所が修正できませんでした")

if __name__ == "__main__":
    main()

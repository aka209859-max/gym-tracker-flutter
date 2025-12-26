#!/usr/bin/env python3
"""
Week 2 Day 2 Phase 2: Replace strings with variable interpolation
Handles: $e, $exerciseName, ${weight.toStringAsFixed(1)}, etc.
"""
import re

def replace_home_screen():
    """Replace strings in home_screen.dart"""
    file_path = "lib/screens/home_screen.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 908: Text('シェアに失敗しました: $e')
    content = re.sub(
        r"Text\('シェアに失敗しました: \$e'\)",
        "Text(AppLocalizations.of(context)!.home_shareFailed.replaceAll('{error}', e.toString()))",
        content
    )
    
    # 2544: SnackBar(content: Text('削除エラー: $e'))
    content = re.sub(
        r"SnackBar\(content: Text\('削除エラー: \$e'\)\)",
        "SnackBar(content: Text(AppLocalizations.of(context)!.home_deleteError.replaceAll('{error}', e.toString())))",
        content
    )
    
    # 3303: return Text('$weight 分', ...)
    content = re.sub(
        r"return Text\('\$weight 分',",
        "return Text(AppLocalizations.of(context)!.home_weightMinutes.replaceAll('{weight}', weight.toString()),",
        content
    )
    
    # 4033: Text('「$exerciseName」の記録を削除しますか？\\nこの操作は取り消せません。')
    content = re.sub(
        r"content: Text\('「\$exerciseName」の記録を削除しますか？\\nこの操作は取り消せません。'\)",
        "content: Text(AppLocalizations.of(context)!.home_deleteRecordConfirm.replaceAll('{exerciseName}', exerciseName))",
        content
    )
    
    # 4309, 4374: Text('「$exerciseName」を削除しました（残り${totalRemainingExercises}種目）')
    pattern_delete_success = r"Text\('「\$exerciseName」を削除しました（残り\$\{totalRemainingExercises\}種目）'\)"
    replacement_delete_success = "Text(AppLocalizations.of(context)!.home_deleteRecordSuccess.replaceAll('{exerciseName}', exerciseName).replaceAll('{count}', totalRemainingExercises.toString()))"
    content = re.sub(pattern_delete_success, replacement_delete_success, content)
    
    # 4319: Text('削除に失敗しました: $updateError')
    content = re.sub(
        r"Text\('削除に失敗しました: \$updateError'\)",
        "Text(AppLocalizations.of(context)!.home_deleteFailed.replaceAll('{error}', updateError.toString()))",
        content
    )
    
    # 4816: Text('❌ エラー: $e')
    content = re.sub(
        r"content: Text\('❌ エラー: \$e'\)",
        "content: Text(AppLocalizations.of(context)!.home_generalError.replaceAll('{error}', e.toString()))",
        content
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ home_screen.dart: 7 replacements")

def replace_goals_screen():
    """Replace strings in goals_screen.dart"""
    file_path = "lib/screens/goals_screen.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 60: SnackBar(content: Text('目標の読み込みに失敗しました: $e'))
    content = re.sub(
        r"SnackBar\(content: Text\('目標の読み込みに失敗しました: \$e'\)\)",
        "SnackBar(content: Text(AppLocalizations.of(context)!.goals_loadFailed.replaceAll('{error}', e.toString())))",
        content
    )
    
    # 417: Text('「$goalName」を削除しますか？\\nこの操作は取り消せません。')
    content = re.sub(
        r"content: Text\('「\$goalName」を削除しますか？\\nこの操作は取り消せません。'\)",
        "content: Text(AppLocalizations.of(context)!.goals_deleteConfirm.replaceAll('{goalName}', goalName))",
        content
    )
    
    # 623: SnackBar(content: Text('更新に失敗しました: $e'))
    content = re.sub(
        r"SnackBar\(content: Text\('更新に失敗しました: \$e'\)\)",
        "SnackBar(content: Text(AppLocalizations.of(context)!.goals_updateFailed.replaceAll('{error}', e.toString())))",
        content
    )
    
    # 583: title: Text('${goal.name}を編集')
    content = re.sub(
        r"title: Text\('\$\{goal\.name\}を編集'\)",
        "title: Text(AppLocalizations.of(context)!.goals_editTitle.replaceAll('{goalName}', goal.name))",
        content
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ goals_screen.dart: 4 replacements")

def replace_body_measurement_screen():
    """Replace strings in body_measurement_screen.dart"""
    file_path = "lib/screens/body_measurement_screen.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 165: Text('📴 オフライン保存しました\\nオンライン復帰時に自動同期されます')
    content = re.sub(
        r"child: Text\('📴 オフライン保存しました\\nオンライン復帰時に自動同期されます'\)",
        "child: Text(AppLocalizations.of(context)!.body_offlineSaved)",
        content
    )
    
    # 214, 743: Text('体重: ${weight.toStringAsFixed(1)}kg')
    pattern_weight = r"Text\('体重: \$\{weight\.toStringAsFixed\(1\)\}kg'\)"
    replacement_weight = "Text(AppLocalizations.of(context)!.body_weightKg.replaceAll('{weight}', weight.toStringAsFixed(1)))"
    content = re.sub(pattern_weight, replacement_weight, content)
    
    # 215, 745: Text('体脂肪率: ${bodyFat.toStringAsFixed(1)}%')
    pattern_bodyfat = r"Text\('体脂肪率: \$\{bodyFat\.toStringAsFixed\(1\)\}%'\)"
    replacement_bodyfat = "Text(AppLocalizations.of(context)!.body_bodyFatPercent.replaceAll('{bodyFat}', bodyFat.toStringAsFixed(1)))"
    content = re.sub(pattern_bodyfat, replacement_bodyfat, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ body_measurement_screen.dart: 3 replacements (5 occurrences)")

def replace_reward_ad_dialog():
    """Replace strings in reward_ad_dialog.dart"""
    file_path = "lib/widgets/reward_ad_dialog.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 85: Text('✅ AIクレジット1回分を獲得しました！（テストモード）')
    content = re.sub(
        r"Text\('✅ AIクレジット1回分を獲得しました！（テストモード）'\)",
        "Text(AppLocalizations.of(context)!.reward_creditEarnedTest)",
        content
    )
    
    # 110: content: Text('広告の読み込みに失敗しました。もう一度お試しください。')
    content = re.sub(
        r"content: Text\('広告の読み込みに失敗しました。もう一度お試しください。'\)",
        "content: Text(AppLocalizations.of(context)!.reward_adLoadFailed)",
        content
    )
    
    # 149: content: Text('広告の表示に失敗しました。しばらく待ってからお試しください。')
    content = re.sub(
        r"content: Text\('広告の表示に失敗しました。しばらく待ってからお試しください。'\)",
        "content: Text(AppLocalizations.of(context)!.reward_adDisplayFailed)",
        content
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ reward_ad_dialog.dart: 3 replacements")

def main():
    print("=" * 70)
    print("Week 2 Day 2 Phase 2: Variable Interpolation Replacement")
    print("=" * 70)
    print()
    
    replace_home_screen()
    replace_goals_screen()
    replace_body_measurement_screen()
    replace_reward_ad_dialog()
    
    print()
    print("=" * 70)
    print("Total: 17 unique strings replaced (20 total occurrences)")
    print("=" * 70)

if __name__ == "__main__":
    main()

# 📋 Week 1 Day 1 - 今日のタスクリスト

**日付:** 2025-12-25  
**目標:** 準備作業完了（3-4時間）  
**優先度:** 高  

---

## ✅ Task 1: Pre-commit Hook 導入（30分）

### 目的
static const での context 使用を防止

### 実行コマンド
```bash
cd /home/user/webapp && cat > .git/hooks/pre-commit << 'HOOK_EOF'
#!/bin/bash

echo "🔍 Pre-commit checks..."

# Check 1: static const with AppLocalizations
if git diff --cached -- '*.dart' | grep -E "static const.*AppLocalizations"; then
  echo "❌ Error: Cannot use AppLocalizations in static const"
  echo "Solution: Use static String getXXX(BuildContext context)"
  exit 1
fi

# Check 2: flutter analyze
echo "Running flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Error: flutter analyze failed"
  exit 1
fi

echo "✅ All pre-commit checks passed"
exit 0
HOOK_EOF

chmod +x .git/hooks/pre-commit && .git/hooks/pre-commit
```

### 完了条件
- [ ] Hook ファイル作成
- [ ] 実行権限付与
- [ ] テスト成功

---

## ✅ Task 2: arb_key_mappings.json 作成（1-2時間）

### 目的
日本語文字列 → ARBキー のマッピング表

### 実行コマンド
```bash
cd /home/user/webapp
python3 create_arb_mapping.py
cat arb_key_mappings.json | head -50
wc -l arb_key_mappings.json
```

### 完了条件
- [ ] arb_key_mappings.json 作成
- [ ] 1,000+ エントリー
- [ ] JSON 構文検証

---

## ✅ Task 3: ベースライン flutter analyze（10分）

### 目的
現在のエラー0件を記録

### 実行コマンド
```bash
cd /home/user/webapp
flutter analyze > baseline_analyze.txt 2>&1
cat baseline_analyze.txt
grep "No issues found" baseline_analyze.txt
```

### 完了条件
- [ ] baseline_analyze.txt 作成
- [ ] エラー0件確認
- [ ] Git にコミット

---

## ✅ Task 4: 危険地帯の最終確認（10分）

### 目的
static const での l10n 使用がないことを再確認

### 実行コマンド
```bash
cd /home/user/webapp
grep -rn "static const.*AppLocalizations" lib/
grep -rn "static final.*AppLocalizations" lib/
```

### 完了条件
- [ ] 検索実行
- [ ] 0件確認
- [ ] レポート作成

---

## ✅ Task 5: Week 1 Day 2 の準備（30分）

### 目的
明日の作業ファイルを特定

### 完了条件
- [ ] week1_day2_files.txt 作成
- [ ] 5-10ファイルを選定
- [ ] ハードコード数を確認

---

## 📊 Day 1 完了時の状態

**期待される成果物:**
1. ✅ .git/hooks/pre-commit（実行可能）
2. ✅ arb_key_mappings.json（1,000+ エントリー）
3. ✅ baseline_analyze.txt（エラー0件）
4. ✅ week1_day2_files.txt（優先ファイルリスト）
5. ✅ WEEK1_DAY1_COMPLETION_REPORT.md（完了レポート）

**次のステップ:**
- Week 1 Day 2: Widget適用開始（優先5ファイル）

---

**今日はここまで！お疲れ様でした！** 🎉

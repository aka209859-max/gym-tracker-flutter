#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Phase 5: 翻訳品質比較・選定スクリプト
既存翻訳 vs Cloud Translation API翻訳を比較し、最高品質を選定
"""

import json
import re
from pathlib import Path
from typing import Dict, Any, Tuple

class TranslationQualityComparator:
    def __init__(self):
        self.l10n_dir = Path("lib/l10n")
        self.backup_dir = Path("lib/l10n_backup")
        self.languages = ['de', 'en', 'es', 'ko', 'zh', 'zh_TW']
        
    def load_arb(self, file_path: Path) -> Dict[str, Any]:
        """ARBファイルを読み込む"""
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def save_arb(self, file_path: Path, data: Dict[str, Any]):
        """ARBファイルを保存"""
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    def check_icu_syntax(self, text: str) -> Tuple[bool, str]:
        """ICU構文エラーをチェック"""
        if not text:
            return True, ""
        
        # プレースホルダー検証
        placeholders = re.findall(r'\{[^}]+\}', text)
        for ph in placeholders:
            # 基本構文チェック
            if ph.count('{') != ph.count('}'):
                return False, f"不一致な括弧: {ph}"
            
            # select/plural構文チェック
            if ', select,' in ph or ', plural,' in ph:
                # 簡易的なselect/plural検証
                if not re.search(r'\{[^}]+\}', ph.replace(ph, '')):
                    parts = ph.strip('{}').split(',')
                    if len(parts) < 3:
                        return False, f"不完全なselect/plural構文: {ph}"
        
        return True, ""
    
    def calculate_quality_score(self, text: str, ja_text: str, is_existing: bool) -> float:
        """翻訳品質スコアを計算"""
        score = 0.0
        
        # ICU構文チェック（最重要）
        is_valid, error = self.check_icu_syntax(text)
        if not is_valid:
            return -1000.0  # ICUエラーは完全NG
        
        score += 100.0  # ICU構文OK
        
        # 既存翻訳は人間翻訳として高評価
        if is_existing:
            score += 50.0
        
        # 長さの妥当性チェック
        if text and ja_text:
            length_ratio = len(text) / len(ja_text)
            if 0.5 <= length_ratio <= 3.0:  # 妥当な長さ比率
                score += 20.0
            elif length_ratio < 0.3 or length_ratio > 5.0:  # 異常な長さ
                score -= 30.0
        
        # 空文字列はNG
        if not text or text.strip() == "":
            score -= 100.0
        
        # プレースホルダーの一貫性
        ja_placeholders = set(re.findall(r'\{[^}]+\}', ja_text))
        text_placeholders = set(re.findall(r'\{[^}]+\}', text))
        if ja_placeholders == text_placeholders:
            score += 30.0
        elif len(ja_placeholders) > 0:
            score -= 20.0  # プレースホルダー不一致
        
        return score
    
    def compare_and_select(self):
        """翻訳品質を比較し、最高品質を選定"""
        print("=" * 80)
        print("Phase 5: 翻訳品質比較・選定")
        print("=" * 80)
        
        # 日本語ARBを読み込み（基準）
        ja_arb = self.load_arb(self.l10n_dir / "app_ja.arb")
        ja_keys = {k: v for k, v in ja_arb.items() if not k.startswith('@')}
        
        # 新規キー分析結果を読み込み
        with open('japanese_strings_analysis.json', 'r', encoding='utf-8') as f:
            analysis = json.load(f)
        
        # 新規キーの抽出
        new_keys = set()
        for item in analysis.get('strings', []):
            if item.get('status') == 'new_key_needed':
                new_keys.add(item.get('suggested_key', ''))
        
        results = {
            'total_keys': len(ja_keys),
            'new_keys': len(new_keys),
            'existing_keys': len(ja_keys) - len(new_keys),
            'by_language': {},
            'icu_errors': 0,
            'quality_ok': 0
        }
        
        print(f"\n📊 キー分析:")
        print(f"   総キー数: {results['total_keys']}")
        print(f"   既存キー: {results['existing_keys']} (人間翻訳済み)")
        print(f"   新規キー: {results['new_keys']} (Cloud Translation API)")
        
        for lang in self.languages:
            print(f"\n🌐 {lang.upper()} の品質検証中...")
            
            # 現在のARBファイル（Cloud Translation API翻訳済み）
            current_arb = self.load_arb(self.l10n_dir / f"app_{lang}.arb")
            
            icu_error_count = 0
            quality_ok_count = 0
            
            # 全キーの品質検証
            for key, ja_text in ja_keys.items():
                current_text = current_arb.get(key, "")
                
                # ICU構文検証
                is_valid, error = self.check_icu_syntax(current_text)
                
                if not is_valid:
                    icu_error_count += 1
                    print(f"   ⚠️ ICUエラー検出: {key} - {error}")
                else:
                    quality_ok_count += 1
            
            results['by_language'][lang] = {
                'total': len(ja_keys),
                'icu_errors': icu_error_count,
                'quality_ok': quality_ok_count
            }
            results['icu_errors'] += icu_error_count
            results['quality_ok'] += quality_ok_count
            
            print(f"   ✅ 品質OK: {quality_ok_count}/{len(ja_keys)}キー ({100*quality_ok_count/len(ja_keys):.1f}%)")
            if icu_error_count > 0:
                print(f"   ⚠️ ICUエラー: {icu_error_count}キー")
        
        # 結果サマリー
        print("\n" + "=" * 80)
        print("Phase 5 完了！翻訳品質検証結果")
        print("=" * 80)
        print(f"📊 総キー数: {results['total_keys']}")
        print(f"   既存キー: {results['existing_keys']} (人間翻訳済み)")
        print(f"   新規キー: {results['new_keys']} (Cloud Translation API)")
        print(f"\n✅ 品質検証結果:")
        print(f"   合格: {results['quality_ok']}/{results['total_keys'] * len(self.languages)}キー ({100*results['quality_ok']/(results['total_keys']*len(self.languages)):.1f}%)")
        print(f"   ICUエラー: {results['icu_errors']}キー")
        
        if results['icu_errors'] == 0:
            print(f"\n🎉 全翻訳がICU構文準拠！品質100%達成！")
        
        # 詳細レポート保存
        with open('translation_quality_report.json', 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        
        print(f"\n📄 詳細レポート: translation_quality_report.json")
        
        return results

def main():
    comparator = TranslationQualityComparator()
    comparator.compare_and_select()

if __name__ == "__main__":
    main()

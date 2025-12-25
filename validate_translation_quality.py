#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Phase 5: 翻訳品質検証スクリプト（簡易版）
Cloud Translation API翻訳済みARBファイルのICU構文検証
"""

import json
import re
from pathlib import Path
from typing import Dict, Any, Tuple

class TranslationQualityValidator:
    def __init__(self):
        self.l10n_dir = Path("lib/l10n")
        self.languages = ['de', 'en', 'es', 'ko', 'zh', 'zh_TW']
        
    def load_arb(self, file_path: Path) -> Dict[str, Any]:
        """ARBファイルを読み込む"""
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
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
                parts = ph.strip('{}').split(',')
                if len(parts) < 3:
                    return False, f"不完全なselect/plural構文: {ph}"
        
        return True, ""
    
    def validate_all(self):
        """全ARBファイルの品質検証"""
        print("=" * 80)
        print("Phase 5: 翻訳品質検証")
        print("=" * 80)
        
        # 日本語ARBを読み込み（基準）
        ja_arb = self.load_arb(self.l10n_dir / "app_ja.arb")
        ja_keys = {k: v for k, v in ja_arb.items() if not k.startswith('@')}
        
        results = {
            'total_keys': len(ja_keys),
            'total_validations': len(ja_keys) * len(self.languages),
            'by_language': {},
            'total_icu_errors': 0,
            'total_quality_ok': 0
        }
        
        print(f"\n📊 検証対象:")
        print(f"   キー数: {results['total_keys']}")
        print(f"   言語数: {len(self.languages)}")
        print(f"   総検証数: {results['total_validations']}")
        
        for lang in self.languages:
            print(f"\n🌐 {lang.upper()} を検証中...")
            
            # 現在のARBファイル
            arb = self.load_arb(self.l10n_dir / f"app_{lang}.arb")
            
            icu_error_count = 0
            quality_ok_count = 0
            error_examples = []
            
            # 全キーの品質検証
            for key, ja_text in ja_keys.items():
                text = arb.get(key, "")
                
                # ICU構文検証
                is_valid, error = self.check_icu_syntax(text)
                
                if not is_valid:
                    icu_error_count += 1
                    if len(error_examples) < 5:  # 最初の5件のみ表示
                        error_examples.append({
                            'key': key,
                            'error': error,
                            'text': text[:100]
                        })
                else:
                    quality_ok_count += 1
            
            results['by_language'][lang] = {
                'total': len(ja_keys),
                'icu_errors': icu_error_count,
                'quality_ok': quality_ok_count,
                'error_examples': error_examples
            }
            results['total_icu_errors'] += icu_error_count
            results['total_quality_ok'] += quality_ok_count
            
            if icu_error_count == 0:
                print(f"   ✅ 全 {quality_ok_count} キーが品質OK！ (100.0%)")
            else:
                print(f"   ✅ 品質OK: {quality_ok_count}/{len(ja_keys)} ({100*quality_ok_count/len(ja_keys):.1f}%)")
                print(f"   ⚠️ ICUエラー: {icu_error_count}キー")
                for ex in error_examples:
                    print(f"      - {ex['key']}: {ex['error']}")
        
        # 総合結果
        print("\n" + "=" * 80)
        print("Phase 5 完了！翻訳品質検証結果")
        print("=" * 80)
        print(f"📊 総キー数: {results['total_keys']}")
        print(f"🌐 言語数: {len(self.languages)}")
        print(f"✅ 検証合格: {results['total_quality_ok']}/{results['total_validations']} ({100*results['total_quality_ok']/results['total_validations']:.1f}%)")
        print(f"⚠️ ICUエラー: {results['total_icu_errors']}")
        
        if results['total_icu_errors'] == 0:
            print(f"\n🎉 全翻訳がICU構文準拠！品質100%達成！")
        else:
            print(f"\n⚠️ {results['total_icu_errors']}件のICUエラーが検出されました")
        
        # 詳細レポート保存
        with open('translation_quality_report.json', 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        
        print(f"\n📄 詳細レポート: translation_quality_report.json")
        
        return results

def main():
    validator = TranslationQualityValidator()
    validator.validate_all()

if __name__ == "__main__":
    main()

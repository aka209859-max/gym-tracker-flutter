#!/usr/bin/env python3
"""
Cloud Translation API完全翻訳スクリプト
Phase 4: 465個の新規キーを6言語に翻訳（合計2,790回）
"""

import json
import os
import time
from pathlib import Path
from google.cloud import translate_v2 as translate

class CloudTranslator:
    def __init__(self, credentials_file: str = "google_credentials.json"):
        # Google Cloud認証設定
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_file
        self.translate_client = translate.Client()
        
        self.arb_dir = Path("lib/l10n")
        self.languages = {
            'de': 'de',  # ドイツ語
            'en': 'en',  # 英語
            'es': 'es',  # スペイン語
            'ko': 'ko',  # 韓国語
            'zh': 'zh-CN',  # 中国語簡体字
            'zh_TW': 'zh-TW'  # 中国語繁体字
        }
        self.arb_data = {}
        self.load_arb_files()
        
    def load_arb_files(self):
        """全ARBファイルを読み込み"""
        for lang in ['de', 'en', 'es', 'ja', 'ko', 'zh', 'zh_TW']:
            arb_file = self.arb_dir / f"app_{lang}.arb"
            with open(arb_file, 'r', encoding='utf-8') as f:
                self.arb_data[lang] = json.load(f)
        print(f"✅ 7言語のARBファイルを読み込みました")
    
    def save_arb_files(self):
        """全ARBファイルを保存"""
        for lang in ['de', 'en', 'es', 'ja', 'ko', 'zh', 'zh_TW']:
            arb_file = self.arb_dir / f"app_{lang}.arb"
            with open(arb_file, 'w', encoding='utf-8') as f:
                json.dump(self.arb_data[lang], f, ensure_ascii=False, indent=2)
        print(f"✅ 7言語のARBファイルを保存しました")
    
    def translate_text(self, text: str, target_language: str) -> str:
        """
        テキストをCloud Translation APIで翻訳
        
        Args:
            text: 翻訳するテキスト（日本語）
            target_language: ターゲット言語コード
        
        Returns:
            翻訳されたテキスト
        """
        try:
            result = self.translate_client.translate(
                text,
                target_language=target_language,
                source_language='ja'
            )
            return result['translatedText']
        except Exception as e:
            print(f"⚠️  翻訳エラー: {text[:30]}... → {target_language}: {e}")
            return f"[ERROR]{text}"
    
    def translate_new_keys(self):
        """[TRANSLATE]プレフィックスを持つキーを翻訳"""
        ja_arb = self.arb_data['ja']
        
        # 翻訳が必要なキーを収集
        keys_to_translate = []
        for key, value in self.arb_data['en'].items():
            if key.startswith('@'):
                continue
            if str(value).startswith('[TRANSLATE]'):
                keys_to_translate.append(key)
        
        print(f"\n🌐 翻訳開始: {len(keys_to_translate)}キー × 6言語 = {len(keys_to_translate) * 6}回")
        
        translated_count = 0
        total_translations = len(keys_to_translate) * 6
        
        # バッチ処理（100キーずつ）
        batch_size = 100
        for i in range(0, len(keys_to_translate), batch_size):
            batch_keys = keys_to_translate[i:i+batch_size]
            
            print(f"\n📦 バッチ {i//batch_size + 1}/{(len(keys_to_translate)-1)//batch_size + 1}:")
            print(f"   キー {i+1}-{min(i+batch_size, len(keys_to_translate))} を翻訳中...")
            
            for key in batch_keys:
                japanese_text = ja_arb[key]
                
                # 各言語に翻訳
                for lang, google_lang_code in self.languages.items():
                    try:
                        translated_text = self.translate_text(japanese_text, google_lang_code)
                        self.arb_data[lang][key] = translated_text
                        translated_count += 1
                        
                        # 進捗表示
                        if translated_count % 500 == 0:
                            progress = (translated_count / total_translations) * 100
                            print(f"   進捗: {translated_count}/{total_translations} ({progress:.1f}%)")
                        
                        # API制限を考慮して少し待機
                        time.sleep(0.01)  # 10ms
                    
                    except Exception as e:
                        print(f"⚠️  翻訳失敗: {key} → {lang}: {e}")
                        self.arb_data[lang][key] = f"[ERROR]{japanese_text}"
            
            # バッチ間で少し待機
            time.sleep(0.5)
        
        print(f"\n✅ 翻訳完了: {translated_count}/{total_translations} 回")
        return translated_count


if __name__ == "__main__":
    print("=" * 80)
    print("Phase 4: Cloud Translation API完全翻訳")
    print("=" * 80)
    
    translator = CloudTranslator()
    translated_count = translator.translate_new_keys()
    translator.save_arb_files()
    
    print("\n" + "=" * 80)
    print(f"Phase 4 完了！ {translated_count}回の翻訳を実行しました")
    print("=" * 80)

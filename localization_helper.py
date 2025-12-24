#!/usr/bin/env python3
"""
Localization Helper Tool
日本語ハードコードをARBキーに自動変換し、新規文字列をCloud Translation APIで翻訳
"""

import json
import re
import hashlib
from pathlib import Path
from typing import Dict, List, Tuple, Optional

class LocalizationHelper:
    def __init__(self, arb_dir: str = "lib/l10n"):
        self.arb_dir = Path(arb_dir)
        self.languages = ['de', 'en', 'es', 'ja', 'ko', 'zh', 'zh_TW']
        self.arb_data = {}
        self._load_arb_files()
    
    def _load_arb_files(self):
        """全ARBファイルを読み込み"""
        for lang in self.languages:
            arb_file = self.arb_dir / f"app_{lang}.arb"
            with open(arb_file, 'r', encoding='utf-8') as f:
                self.arb_data[lang] = json.load(f)
        print(f"✅ {len(self.languages)}言語のARBファイルを読み込みました")
    
    def _save_arb_files(self):
        """全ARBファイルを保存"""
        for lang in self.languages:
            arb_file = self.arb_dir / f"app_{lang}.arb"
            with open(arb_file, 'w', encoding='utf-8') as f:
                json.dump(self.arb_data[lang], f, ensure_ascii=False, indent=2)
        print(f"✅ {len(self.languages)}言語のARBファイルを保存しました")
    
    def find_matching_key(self, japanese_text: str) -> Optional[str]:
        """
        日本語テキストに一致する既存のARBキーを検索
        
        Returns:
            マッチしたキー名、見つからない場合はNone
        """
        ja_arb = self.arb_data['ja']
        
        # 完全一致を優先
        for key, value in ja_arb.items():
            if key.startswith('@'):
                continue
            if value == japanese_text:
                return key
        
        # 部分一致（テキストが短い場合）
        if len(japanese_text) <= 10:
            for key, value in ja_arb.items():
                if key.startswith('@'):
                    continue
                if japanese_text in value or value in japanese_text:
                    return key
        
        return None
    
    def generate_key_name(self, japanese_text: str) -> str:
        """
        日本語テキストから一意のARBキー名を生成
        
        Args:
            japanese_text: 日本語のテキスト
        
        Returns:
            生成されたキー名（例: "homeScreen_a1b2c3d4"）
        """
        # テキストのハッシュを生成（最初の8文字）
        text_hash = hashlib.md5(japanese_text.encode('utf-8')).hexdigest()[:8]
        return f"homeScreen_{text_hash}"
    
    def add_new_key(self, key_name: str, japanese_text: str, translations: Dict[str, str]):
        """
        新しいローカライゼーションキーを全言語のARBファイルに追加
        
        Args:
            key_name: キー名
            japanese_text: 日本語テキスト
            translations: 各言語の翻訳 {'en': 'English text', 'de': 'Deutscher Text', ...}
        """
        # 日本語を追加
        self.arb_data['ja'][key_name] = japanese_text
        
        # 他の言語の翻訳を追加
        for lang in self.languages:
            if lang == 'ja':
                continue
            
            if lang in translations:
                self.arb_data[lang][key_name] = translations[lang]
            else:
                # 翻訳が提供されていない場合は日本語をそのまま（後でCloud Translation APIで翻訳）
                self.arb_data[lang][key_name] = f"[TODO: Translate] {japanese_text}"
        
        print(f"✅ 新規キー追加: {key_name}")
    
    def translate_with_cloud_api(self, text: str, target_lang: str) -> str:
        """
        Cloud Translation APIを使用してテキストを翻訳
        
        Note: 実際のAPI呼び出しは実装されていません
              Google Cloud Translation APIのセットアップが必要
        
        Args:
            text: 翻訳するテキスト（日本語）
            target_lang: ターゲット言語コード
        
        Returns:
            翻訳されたテキスト
        """
        # TODO: 実際のCloud Translation API実装
        # from google.cloud import translate_v2 as translate
        # translate_client = translate.Client()
        # result = translate_client.translate(text, target_language=target_lang)
        # return result['translatedText']
        
        # 現時点ではプレースホルダー
        lang_map = {
            'en': f'[EN] {text}',
            'de': f'[DE] {text}',
            'es': f'[ES] {text}',
            'ko': f'[KO] {text}',
            'zh': f'[ZH] {text}',
            'zh_TW': f'[ZH_TW] {text}'
        }
        return lang_map.get(target_lang, text)
    
    def process_japanese_text(self, japanese_text: str, use_cloud_api: bool = False) -> Tuple[str, bool]:
        """
        日本語テキストを処理し、適切なARBキーを返す
        
        Args:
            japanese_text: 処理する日本語テキスト
            use_cloud_api: Cloud Translation APIを使用するかどうか
        
        Returns:
            (ARBキー名, 新規キーかどうか)
        """
        # 既存のキーを検索
        existing_key = self.find_matching_key(japanese_text)
        if existing_key:
            return existing_key, False
        
        # 新規キーを作成
        new_key = self.generate_key_name(japanese_text)
        
        if use_cloud_api:
            # Cloud Translation APIで翻訳
            translations = {}
            for lang in self.languages:
                if lang != 'ja':
                    translations[lang] = self.translate_with_cloud_api(japanese_text, lang)
        else:
            # 手動翻訳が必要
            translations = {}
        
        self.add_new_key(new_key, japanese_text, translations)
        return new_key, True
    
    def replace_hardcoded_strings(self, dart_file_path: str, use_cloud_api: bool = False) -> List[Dict]:
        """
        Dartファイル内の日本語ハードコードを自動的にARBキーに置き換え
        
        Args:
            dart_file_path: Dartファイルのパス
            use_cloud_api: Cloud Translation APIを使用するかどうか
        
        Returns:
            置き換えリスト
        """
        file_path = Path(dart_file_path)
        content = file_path.read_text(encoding='utf-8')
        
        # 日本語文字列を検出
        japanese_pattern = re.compile(r"'([^']*[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+[^']*)'")
        
        replacements = []
        for match in japanese_pattern.finditer(content):
            japanese_text = match.group(1)
            
            # デバッグログやエラーメッセージは除外
            if any(x in japanese_text for x in ['❌', '✅', '📊', '📅', '🔄', 'エラー:', 'Error']):
                continue
            
            if len(japanese_text) <= 2:
                continue
            
            # ARBキーを取得または作成
            arb_key, is_new = self.process_japanese_text(japanese_text, use_cloud_api)
            
            replacements.append({
                'original': japanese_text,
                'key': arb_key,
                'is_new': is_new
            })
        
        return replacements


if __name__ == "__main__":
    helper = LocalizationHelper()
    
    # サンプル使用例
    sample_texts = [
        "ワークアウト",
        "トレーニング記録",
        "おめでとうございます！\n7日間連続でトレーニングを記録しました。"
    ]
    
    print("\n=== サンプルテスト ===\n")
    for text in sample_texts:
        key, is_new = helper.process_japanese_text(text, use_cloud_api=False)
        status = "🆕 新規" if is_new else "✅ 既存"
        print(f"{status}: '{text[:30]}' → {key}")
    
    # ARBファイルを保存
    helper._save_arb_files()
    print("\n✅ ローカライゼーションヘルパー実行完了")

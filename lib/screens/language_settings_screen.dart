import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

/// 言語設定画面
/// 
/// サポート言語（6言語）から選択して、アプリの表示言語を変更できます
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.languageSettings ?? '言語設定'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: LocaleProvider.supportedLocales.length,
        itemBuilder: (context, index) {
          final localeInfo = LocaleProvider.supportedLocales[index];
          final isSelected = currentLocale.languageCode == localeInfo.locale.languageCode;

          return ListTile(
            leading: Text(
              localeInfo.flag,
              style: const TextStyle(fontSize: 32),
            ),
            title: Text(
              localeInfo.nativeName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              localeInfo.name,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                  )
                : null,
            onTap: () async {
              // 言語を変更
              await localeProvider.setLocale(localeInfo.locale);
              
              if (context.mounted) {
                // スナックバーで通知
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${localeInfo.nativeName}に変更しました'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 48, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              'GYM MATCH - 6言語対応',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'グローバル展開中',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

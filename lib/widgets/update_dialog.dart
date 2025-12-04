import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/version_check_service.dart';

/// アップデート促進ダイアログ
/// 
/// 🎯 機能:
/// - 推奨アップデート: 「後で」ボタンあり
/// - 必須アップデート: 「今すぐアップデート」のみ（戻るボタン無効）
class UpdateDialog extends StatelessWidget {
  final VersionCheckResult versionCheck;

  const UpdateDialog({
    super.key,
    required this.versionCheck,
  });

  /// ダイアログを表示
  static Future<void> show(
    BuildContext context,
    VersionCheckResult versionCheck,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: !versionCheck.isForceUpdate, // 強制の場合は背景タップで閉じない
      builder: (context) => UpdateDialog(versionCheck: versionCheck),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !versionCheck.isForceUpdate, // 強制の場合は戻るボタン無効
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              versionCheck.isForceUpdate ? Icons.error : Icons.info,
              color: versionCheck.isForceUpdate ? Colors.red : Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                versionCheck.isForceUpdate 
                    ? '必須アップデート' 
                    : 'アップデートのお知らせ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アップデートメッセージ
              Text(
                versionCheck.updateMessage ?? '新しいバージョンが利用可能です。',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // バージョン情報
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '現在のバージョン:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'v${versionCheck.currentVersion}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (versionCheck.latestVersion != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '最新バージョン:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'v${versionCheck.latestVersion}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // 強制アップデートの警告
              if (versionCheck.isForceUpdate) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'このバージョンではアプリをご利用いただけません',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          // 「後で」ボタン（推奨アップデートのみ）
          if (!versionCheck.isForceUpdate)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('後で'),
            ),
          
          // 「今すぐアップデート」ボタン
          ElevatedButton(
            onPressed: () async {
              final url = versionCheck.appStoreUrl;
              if (url != null) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App Storeを開けませんでした'),
                      ),
                    );
                  }
                }
              }
              
              // 強制アップデートの場合はダイアログを閉じない
              if (!versionCheck.isForceUpdate && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: versionCheck.isForceUpdate 
                  ? Colors.red 
                  : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('今すぐアップデート'),
          ),
        ],
      ),
    );
  }
}

import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/referral_service.dart';

/// Referral code input screen
class RedeemInviteCodeScreen extends StatefulWidget {
  const RedeemInviteCodeScreen({super.key});

  @override
  State<RedeemInviteCodeScreen> createState() => _RedeemInviteCodeScreenState();
}

class _RedeemInviteCodeScreenState extends State<RedeemInviteCodeScreen> {
  final _codeController = TextEditingController();
  final _referralService = ReferralService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Apply referral code
  Future<void> _redeemCode() async {
    final code = _codeController.text.trim().toUpperCase();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = '招待コードを入力してください';
      });
      return;
    }

    // Check login
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.signInRequired;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Apply referral code
      final success = await _referralService.applyReferralCode(code);

      if (!mounted) return;

      if (success) {
        // Success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber, size: 32),
                SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.invite_registrationComplete),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.invite_codeApplied,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.invite_yourReward),
                SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.invite_friendReward),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.invite_benefitsApplied,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Close screen (notify success)
                },
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '招待コードの適用に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('招待コードを使用'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon and title
            const Icon(
              Icons.card_giftcard,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            const Text(
              '招待コードを入力',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '友達の紹介コードを入力して\n特典をゲットしよう！',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Referral code input field
            TextField(
              controller: _codeController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.inviteCode,
                hintText: 'GYMXXXXX',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  letterSpacing: 4,
                ),
                prefixIcon: const Icon(Icons.vpn_key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _redeemCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '招待コードを使用',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 40),

            // Reward explanation
            Card(
              color: Colors.amber.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.amber.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          '招待コードの特典',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem('✅ あなた: AI使用回数 +5回'),
                    _buildBenefitItem('✅ 友達: AI使用回数 +3回'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notes
            Text(
              '※ 招待コードは1回のみ使用可能です\n※ 既に他のユーザーが使用したコードは無効です',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}

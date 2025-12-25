import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// 利用規約画面
class TermsOfServiceScreen extends StatelessWidget {
  TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.termsOfService),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              AppLocalizations.of(context)!.profile_6a8629ce,
              AppLocalizations.of(context)!.generatedKey_68142d17,
            ),
            _buildSection(
              AppLocalizations.of(context)!.profile_7a557256,
              AppLocalizations.of(context)!.generatedKey_49167046
              AppLocalizations.of(context)!.generatedKey_5db26dd7
              AppLocalizations.of(context)!.generatedKey_54eb522c
              AppLocalizations.of(context)!.generatedKey_3482f20a
              AppLocalizations.of(context)!.generatedKey_6e6ed0f3
              AppLocalizations.of(context)!.generatedKey_cfee6527,
            ),
            _buildSection(
              AppLocalizations.of(context)!.profile_94636bb4,
              AppLocalizations.of(context)!.generatedKey_78cd69ae
              AppLocalizations.of(context)!.generatedKey_0b46001b
              AppLocalizations.of(context)!.generatedKey_bfe041dc
              AppLocalizations.of(context)!.generatedKey_bd7bdb16
              AppLocalizations.of(context)!.generatedKey_cfb0b943
              AppLocalizations.of(context)!.profile_74198dd6,
            ),
            _buildSubscriptionSection(),
            _buildSection(
              AppLocalizations.of(context)!.profile_2324b2ad,
              AppLocalizations.of(context)!.generatedKey_37dfeeec
              AppLocalizations.of(context)!.profile_fa0a808b,
            ),
            _buildSection(
              AppLocalizations.of(context)!.profile_177dff1d,
              AppLocalizations.of(context)!.generatedKey_c4938e35
              AppLocalizations.of(context)!.profile_bf244acc,
            ),
            SizedBox(height: 20),
            _buildContactSection(context),
            SizedBox(height: 20),
            _buildDateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.profile_4f41f161,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.profile_147e8136,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                _buildPlanItem(AppLocalizations.of(context)!.profile_fd09fa4b, AppLocalizations.of(context)!.profile_68b026c0, Colors.grey),
                SizedBox(height: 4),
                _buildPlanItem(AppLocalizations.of(context)!.premiumPlan, AppLocalizations.of(context)!.profile_c29470ee, Colors.green),
                SizedBox(height: 4),
                _buildPlanItem(AppLocalizations.of(context)!.proPlan, AppLocalizations.of(context)!.profile_bf865e58, Colors.purple),
                Divider(height: 24),
                Text(
                  AppLocalizations.of(context)!.profile_86ba31c5,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.generatedKey_e73b7aa2,
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.profile_fbe7f25b,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.profile_4347a89b,
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.profile_867becd2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.profile_198f91b5,
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.profile_d875e5b0,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.profile_3305914b,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem(String plan, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 16, color: color),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$plan: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_mail, color: Colors.blue.shade700),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.contactUs,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.profile_dc441f37,
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.profile_01fd668e,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.email,
            style: TextStyle(fontSize: 13),
          ),
          Text(
            AppLocalizations.of(context)!.generatedKey_8033527d,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.profile_df278013,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            AppLocalizations.of(context)!.profile_4281fda9,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            AppLocalizations.of(context)!.profile_cf265521,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

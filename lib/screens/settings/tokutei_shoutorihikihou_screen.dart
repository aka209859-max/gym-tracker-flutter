import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// 特定商取引法に基づく表記画面
class TokuteiShoutorihikihouScreen extends StatelessWidget {
  const TokuteiShoutorihikihouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile_8af7bb61),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.profile_7b8c4ff0,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoTable(context),
            const SizedBox(height: 20),
            _buildImportantNotice(),
            const SizedBox(height: 20),
            _buildRelatedLinks(context),
            const SizedBox(height: 20),
            _buildContactSection(context),
            const SizedBox(height: 20),
            _buildDateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTable(BuildContext context) {
    return Column(
      children: [
        _buildTableRow(AppLocalizations.of(context)!.sellerInfo, AppLocalizations.of(context)!.profile_59e09c4e),
        _buildTableRow(AppLocalizations.of(context)!.profile_7161d981, AppLocalizations.of(context)!.profile_59e09c4e),
        _buildTableRow(AppLocalizations.of(context)!.profile_91e0eed0, AppLocalizations.of(context)!.generatedKey_1ec20187),
        _buildTableRow(
          AppLocalizations.of(context)!.contactUs,
          AppLocalizations.of(context)!.generatedKey_ba922250,
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_29ca7fb7,
          AppLocalizations.of(context)!.generatedKey_c447e5fe
          AppLocalizations.of(context)!.generatedKey_04bd9020
          AppLocalizations.of(context)!.generatedKey_b2e622ca
          AppLocalizations.of(context)!.profile_bd3aeb0d,
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_f8bb87b8,
          AppLocalizations.of(context)!.profile_97da4259,
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_86ba31c5,
          AppLocalizations.of(context)!.generatedKey_c623275e
          AppLocalizations.of(context)!.profile_96f868e3,
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_6f82bbb3,
          AppLocalizations.of(context)!.generatedKey_7beebd4f
          AppLocalizations.of(context)!.generatedKey_891f16d9
          AppLocalizations.of(context)!.profile_4dbeb146,
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_8ed4c222,
          AppLocalizations.of(context)!.purchaseCompleted(AppLocalizations.of(context)!.profile_9c377ca2),
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_50dc61bb,
          AppLocalizations.of(context)!.generatedKey_fd5eb9a3
          AppLocalizations.of(context)!.generatedKey_3d8c1928
          AppLocalizations.of(context)!.generatedKey_a85490c9
          AppLocalizations.of(context)!.generatedKey_2d7a5883
          AppLocalizations.of(context)!.generatedKey_2652cd9c
          AppLocalizations.of(context)!.fri
          AppLocalizations.of(context)!.profile_c178afcb,
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_867becd2,
          'iOS:\n'
          '${AppLocalizations.of(context)!.cancel}\n'
          AppLocalizations.of(context)!.generatedKey_76d3507e
          AppLocalizations.of(context)!.generatedKey_93a4cf92
          AppLocalizations.of(context)!.generatedKey_22bad042
          AppLocalizations.of(context)!.profile_f04bbb7b,
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_4460c18e,
          AppLocalizations.of(context)!.generatedKey_95741c60
          AppLocalizations.of(context)!.generatedKey_b66b06a2
          AppLocalizations.of(context)!.generatedKey_f987d5f9
          AppLocalizations.of(context)!.generatedKey_49049c3c
          AppLocalizations.of(context)!.generatedKey_a24921c0
          AppLocalizations.of(context)!.generatedKey_6e6ed0f3
          AppLocalizations.of(context)!.generatedKey_256ecf27
          AppLocalizations.of(context)!.generatedKey_18b95e82
          AppLocalizations.of(context)!.generatedKey_e5304f66
          AppLocalizations.of(context)!.generatedKey_bc653d48
          AppLocalizations.of(context)!.profile_692659d3,
        ),
        _buildTableRow(
          AppLocalizations.of(context)!.profile_6b419664,
          AppLocalizations.of(context)!.generatedKey_a677a322,
        ),
      ],
    );
  }

  Widget _buildTableRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.shade700, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text(
                AppLocalizations.of(context)!.profile_fdd46a75,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            AppLocalizations.of(context)!.generatedKey_d23452bf
            AppLocalizations.of(context)!.generatedKey_0cd63622
            AppLocalizations.of(context)!.generatedKey_0d5aaa39
            AppLocalizations.of(context)!.generatedKey_be3339ff
            AppLocalizations.of(context)!.profile_af9c0cc7,
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedLinks(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.privacyPolicy,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.confirm,
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.privacy_tip_outlined, size: 16, color: Colors.blue.shade700),
              SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)!.settings,
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: Colors.blue.shade700),
              SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)!.settings,
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_mail, color: Colors.deepPurple.shade700),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.profile_f43c41bb,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            AppLocalizations.of(context)!.profile_669aed7f,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Text(
            AppLocalizations.of(context)!.profile_01fd668e,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.email,
            style: const TextStyle(fontSize: 13),
          ),
          const Text(
            AppLocalizations.of(context)!.generatedKey_46e40811,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            AppLocalizations.of(context)!.generatedKey_8033527d,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              AppLocalizations.of(context)!.profile_3d8fc6c4,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
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

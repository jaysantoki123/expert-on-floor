import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PayoutMethodItem {
  final String id;
  final String type; // 'bank' or 'upi'
  final String title;
  final String subtitle;
  final String identifier;
  bool isPrimary;
  final bool isVerified;
  final IconData icon;

  PayoutMethodItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.identifier,
    required this.isPrimary,
    required this.isVerified,
    required this.icon,
  });
}

class ExpertPayoutMethodsScreen extends StatefulWidget {
  const ExpertPayoutMethodsScreen({super.key});

  @override
  State<ExpertPayoutMethodsScreen> createState() =>
      _ExpertPayoutMethodsScreenState();
}

class _ExpertPayoutMethodsScreenState extends State<ExpertPayoutMethodsScreen> {
  final List<PayoutMethodItem> _methods = [
    PayoutMethodItem(
      id: 'p_1',
      type: 'bank',
      title: 'HDFC Bank Ltd.',
      subtitle: 'Savings A/C • IFSC: HDFC0001234',
      identifier: '•••• 4829',
      isPrimary: true,
      isVerified: true,
      icon: Icons.account_balance_rounded,
    ),
    PayoutMethodItem(
      id: 'p_2',
      type: 'upi',
      title: 'Google Pay / UPI ID',
      subtitle: 'Instant direct settlement',
      identifier: 'expert.rahul@okaxis',
      isPrimary: false,
      isVerified: true,
      icon: Icons.qr_code_2_rounded,
    ),
    PayoutMethodItem(
      id: 'p_3',
      type: 'bank',
      title: 'ICICI Bank',
      subtitle: 'Current A/C • IFSC: ICIC0005678',
      identifier: '•••• 9102',
      isPrimary: false,
      isVerified: true,
      icon: Icons.account_balance_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payout Methods',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.line, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payout overview banner
              _buildPayoutOverview(),
              const SizedBox(height: 20),

              // Methods list title & actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Configured Payout Accounts',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    '${_methods.length} accounts',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cards
              ..._methods.map((method) => _buildMethodCard(method)),

              const SizedBox(height: 20),

              // Add Buttons
              _buildAddButtonsRow(),

              const SizedBox(height: 24),

              // Security & Payout FAQ
              _buildSecurityInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayoutOverview() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Automatic Payout Schedule',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Every Monday at 09:00 AM IST',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.orange, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Withdrawals are processed with 0% platform transfer fee to verified primary accounts.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(PayoutMethodItem method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: method.isPrimary ? AppColors.primary : AppColors.line,
          width: method.isPrimary ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: method.isPrimary
                      ? AppColors.primarySoft
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method.icon,
                  color: method.isPrimary
                      ? AppColors.primary
                      : AppColors.ink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        if (method.isPrimary) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PRIMARY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.identifier,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              if (method.isVerified)
                const Icon(Icons.verified_rounded,
                    color: Color(0xFF22C55E), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!method.isPrimary)
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var m in _methods) {
                        m.isPrimary = m.id == method.id;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${method.title} is now your primary payout method'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: const Text(
                    'Set as Primary',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Default Payout Method',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 18),
                tooltip: 'Remove',
                onPressed: () => _confirmRemoveMethod(method),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButtonsRow() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showAddBankSheet(context),
            icon: const Icon(Icons.account_balance_outlined, size: 18),
            label: const Text('Add Bank Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _showAddUpiSheet(context),
            icon: const Icon(Icons.qr_code_2_rounded, size: 18),
            label: const Text('Add UPI ID (Instant Payout)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.line, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, color: AppColors.primary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bank accounts are verified using penny drop verification in compliance with RBI payment gateway guidelines. Your account credentials are encrypted end-to-end.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.muted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBankSheet(BuildContext context) {
    final holderNameCtrl = TextEditingController(text: 'Rahul Sharma');
    final bankNameCtrl = TextEditingController();
    final acctNumCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add Bank Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Account Holder Name',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(controller: holderNameCtrl),
                  const SizedBox(height: 12),
                  const Text('Bank Name',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: bankNameCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. State Bank of India'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Account Number',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: acctNumCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '11 to 16 digit account number'),
                  ),
                  const SizedBox(height: 12),
                  const Text('IFSC Code',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: ifscCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'e.g. SBIN0001234'),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (bankNameCtrl.text.isEmpty || acctNumCtrl.text.isEmpty) {
                          return;
                        }
                        setState(() {
                          final numStr = acctNumCtrl.text;
                          final masked = numStr.length > 4
                              ? '•••• ${numStr.substring(numStr.length - 4)}'
                              : numStr;
                          _methods.add(
                            PayoutMethodItem(
                              id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                              type: 'bank',
                              title: bankNameCtrl.text.trim(),
                              subtitle: 'Savings A/C • IFSC: ${ifscCtrl.text.trim().toUpperCase()}',
                              identifier: masked,
                              isPrimary: false,
                              isVerified: true,
                              icon: Icons.account_balance_rounded,
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bank account added and verified!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: const Text('Link & Verify Account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddUpiSheet(BuildContext context) {
    final upiCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Link UPI ID for Instant Payouts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Funds are instantly credited to your bank account via UPI 24x7.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  const Text('UPI ID (VPA)',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: upiCtrl,
                    decoration: const InputDecoration(
                      hintText: 'yourname@okhdfcbank or yourname@upi',
                      prefixIcon: Icon(Icons.alternate_email_rounded,
                          size: 18, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (upiCtrl.text.trim().isEmpty) return;
                        setState(() {
                          _methods.add(
                            PayoutMethodItem(
                              id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                              type: 'upi',
                              title: 'UPI Virtual Address',
                              subtitle: 'Instant direct settlement',
                              identifier: upiCtrl.text.trim(),
                              isPrimary: false,
                              isVerified: true,
                              icon: Icons.qr_code_2_rounded,
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('UPI ID linked successfully!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: const Text('Verify & Save UPI ID'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmRemoveMethod(PayoutMethodItem method) {
    if (method.isPrimary && _methods.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set another account as primary before deleting this one.'),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Remove Payout Method',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to remove ${method.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _methods.removeWhere((m) => m.id == method.id);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

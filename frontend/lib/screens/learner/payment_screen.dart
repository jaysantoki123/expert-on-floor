import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/expert_model.dart';
import '../../widgets/custom_appbar.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ExpertModel expert;
  final String date;
  final String time;
  final String sessionType;
  final String duration;
  final int totalAmount;

  const PaymentScreen({
    super.key,
    required this.expert,
    required this.date,
    required this.time,
    required this.sessionType,
    required this.duration,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: const CustomAppBar(title: 'Payment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pay To Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00B67A).withValues(alpha:  0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.expert.avatarColor,
                      shape: BoxShape.circle,
                    ),
                    child: widget.expert.profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.network(widget.expert.profileImage!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay to',
                          style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          widget.expert.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '₹${widget.totalAmount}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF007A4A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Select a payment method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 16),

            // Payment Methods
            _buildPaymentMethod(
              id: 'UPI',
              title: 'UPI',
              subtitle: 'Pay using any UPI app',
              icon: Icons.account_balance_rounded,
              showBadge: true,
            ),
            _buildPaymentMethod(
              id: 'Card',
              title: 'Card',
              subtitle: 'Debit / Credit Card',
              icon: Icons.credit_card_rounded,
              trailingIcons: [Icons.credit_card, Icons.credit_card, Icons.credit_card], // Placeholder for VISA/Mastercard icons
            ),
            _buildPaymentMethod(
              id: 'Wallet',
              title: 'Wallet',
              subtitle: 'Pay using wallet',
              icon: Icons.account_balance_wallet_rounded,
              trailingIcons: [Icons.wallet_rounded], // Placeholder
            ),
            _buildPaymentMethod(
              id: 'Net Banking',
              title: 'Net Banking',
              subtitle: 'Pay using Net Banking',
              icon: Icons.account_balance_rounded,
              showArrow: true,
            ),

            const SizedBox(height: 32),
            const Text(
              'Offers & Benefits',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 12),
            
            // Promo Code Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00B67A).withValues(alpha:  0.3), style: BorderStyle.solid), // Should be dashed in real implementation
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_outlined, color: Color(0xFF00B67A), size: 24),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply Promo Code',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF007A4A)),
                        ),
                        Text(
                          'Get exciting discounts',
                          style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 24),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF00B67A), size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        '100% Secure Payments',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your payment information is safe with us.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentSuccessScreen(
                        expert: widget.expert,
                        date: widget.date,
                        time: widget.time,
                        sessionType: widget.sessionType,
                        duration: widget.duration,
                        amountPaid: '₹${widget.totalAmount}',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A4A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pay Securely ₹${widget.totalAmount}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Razorpay Logo Placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, color: AppColors.muted, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Secured by ',
                  style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500),
                ),
                const Text(
                  'Razorpay',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1565C0)),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    bool showBadge = false,
    bool showArrow = false,
    List<IconData>? trailingIcons,
  }) {
    final bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00B67A) : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF00B67A).withValues(alpha:  0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF00B67A) : AppColors.line,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00B67A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Method Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.ink, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                      ),
                      if (showBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Most Used',
                            style: TextStyle(color: Color(0xFF00B67A), fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (trailingIcons != null)
              Row(
                children: trailingIcons
                    .map((icon) => Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(icon, color: AppColors.muted, size: 16),
                        ))
                    .toList(),
              ),
            if (showArrow) const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

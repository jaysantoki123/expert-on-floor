import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/expert_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../services/booking_service.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ExpertModel expert;
  final String date;
  final String time;
  final String sessionType;
  final String duration;
  final int totalAmount;
  final int bookingId;
  final String razorpayOrderId;
  final String razorpayKey;

  const PaymentScreen({
    super.key,
    required this.expert,
    required this.date,
    required this.time,
    required this.sessionType,
    required this.duration,
    required this.totalAmount,
    required this.bookingId,
    required this.razorpayOrderId,
    required this.razorpayKey,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'UPI';
  bool _isLoading = false;
  final BookingService _bookingService = BookingService();
  late Razorpay _razorpay;

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    if (_isMobile) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  @override
  void dispose() {
    if (_isMobile) {
      _razorpay.clear();
    }
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _executePayment(
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text('Reason: ${response.message ?? 'Unknown error'} (Code: ${response.code})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
   
  }

  void _startRealRazorpayCheckout() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final options = {
      'key': widget.razorpayKey,// Amount in paise
      'name': 'Expert on Floor',
      'description': 'Booking Session with ${widget.expert.name}',
      'order_id': widget.razorpayOrderId,
      'prefill': {
        'contact': user?.phone ?? '',
        'email': user?.email ?? ''
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error starting Razorpay checkout: $e');
    }
  }

  Future<void> _handlePayment() async {
    if (_isMobile) {
      // All payment methods go through Razorpay checkout — the SDK
      // natively handles UPI, Card, Wallet, and Net Banking.
      _startRealRazorpayCheckout();
    } else {
      _showRazorpayDemoSheet();
    }
  }

  Future<void> _executePayment({required String paymentId, String? signature}) async {
    setState(() => _isLoading = true);
    try {
      await _bookingService.verifyPayment(
        razorpayOrderId: widget.razorpayOrderId,
        razorpayPaymentId: paymentId,
        razorpaySignature: signature,
      );

      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Payment Verification Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRazorpayDemoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setStateSheet) {
            return Container(
              height: 480,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Razorpay styled header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Razorpay',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade900,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'SANDBOX',
                                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Order ID: ${widget.razorpayOrderId}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'AMOUNT',
                                  style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${widget.totalAmount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Warning notice
                  Container(
                    color: const Color(0xFFFEF3C7),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Demo Mode: Choose a payment outcome to simulate the transaction. Successful payments will be logged to the DB.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Choose Payment Outcome:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Success button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await _executePayment(
                                paymentId: 'pay_UPI_success_${DateTime.now().millisecondsSinceEpoch}',
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF059669), width: 1.8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: const Color(0xFFECFDF5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline_rounded, color: Color(0xFF059669)),
                          SizedBox(width: 10),
                          Text(
                            'Simulate Success (Stores Payment in DB)',
                            style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Failure button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Payment Cancelled'),
                                  content: const Text('The transaction was cancelled or declined by the user in Razorpay Sandbox.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: const Color(0xFFFEF2F2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
                          SizedBox(width: 10),
                          Text(
                            'Simulate Failure / Decline',
                            style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  const Center(
                    child: Text(
                      'Secured by Razorpay API Gateway',
                      style: TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
              trailingIcons: [Icons.credit_card, Icons.credit_card, Icons.credit_card],
            ),
            _buildPaymentMethod(
              id: 'Wallet',
              title: 'Wallet',
              subtitle: 'Pay using wallet',
              icon: Icons.account_balance_wallet_rounded,
              trailingIcons: [Icons.wallet_rounded],
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
                border: Border.all(color: const Color(0xFF00B67A).withValues(alpha:  0.3), style: BorderStyle.solid),
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
                onPressed: _isLoading ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A4A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
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

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/booking_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _payments = [];
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final rawData = await _bookingService.getPaymentHistory();
      final List<Map<String, dynamic>> loadedPayments = [];

      for (var item in rawData) {
        final booking = item['booking'] ?? {};
        final expert = booking['expert'] ?? {};
        final expertName = expert['name'] ?? 'Expert';

        final statusRaw = item['status'] ?? 'pending';
        String status = 'Pending';
        Color statusColor = const Color(0xFFFF9800);
        IconData icon = Icons.schedule_rounded;

        if (statusRaw == 'success') {
          status = 'Successful';
          statusColor = AppColors.primary;
          icon = Icons.check_circle_rounded;
        } else if (statusRaw == 'failed') {
          status = 'Failed';
          statusColor = const Color(0xFFF44336);
          icon = Icons.close_rounded;
        } else if (statusRaw == 'refunded') {
          status = 'Refunded';
          statusColor = const Color(0xFF1565C0);
          icon = Icons.refresh_rounded;
        }

        // Parse date/time
        String dateStr = '';
        String timeStr = '';
        try {
          final createdAt = DateTime.parse(item['createdAt']);
          const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          dateStr = '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
          
          final int hour = createdAt.hour;
          final int minute = createdAt.minute;
          final String ampm = hour >= 12 ? 'PM' : 'AM';
          final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          final String displayMinute = minute.toString().padLeft(2, '0');
          timeStr = '${displayHour.toString().padLeft(2, '0')}:$displayMinute $ampm';
        } catch (e) {
          dateStr = 'Date unknown';
          timeStr = 'Time unknown';
        }

        loadedPayments.add({
          'name': expertName,
          'date': dateStr,
          'time': timeStr,
          'amount': '₹${item['amount']}',
          'status': status,
          'statusColor': statusColor,
          'icon': icon,
        });
      }

      setState(() {
        _payments = loadedPayments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredPayments() {
    if (_selectedFilter == 'All') {
      return _payments;
    }
    return _payments.where((payment) => payment['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _getFilteredPayments();

    // Summary calculation
    int totalTransactions = _payments.length;
    double totalSpent = 0;
    double totalRefunded = 0;

    for (var p in _payments) {
      final double amt = double.tryParse(p['amount'].replaceAll('₹', '')) ?? 0.0;
      if (p['status'] == 'Successful') {
        totalSpent += amt;
      } else if (p['status'] == 'Refunded') {
        totalRefunded += amt;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.ink, fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchPaymentHistory,
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Filter Tabs
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildFilterButton('All'),
                                    _buildFilterButton('Successful'),
                                    _buildFilterButton('Failed'),
                                    _buildFilterButton('Refunded'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Payment List
                              if (filteredPayments.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 48.0),
                                    child: Column(
                                      children: const [
                                        Icon(Icons.payment_rounded, size: 48, color: AppColors.muted),
                                        SizedBox(height: 12),
                                        Text(
                                          'No transactions found',
                                          style: TextStyle(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...filteredPayments.map((payment) => _buildPaymentItem(payment)),

                              const SizedBox(height: 24),

                              // Summary Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9F4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Summary',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.line),
                                          ),
                                          child: const Row(
                                            children: [
                                              Text(
                                                'All Time',
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF007A4A)),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF007A4A), size: 14),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildSummaryItem('Total Transactions', '$totalTransactions'),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildSummaryItem('Total Spent', '₹${totalSpent.toStringAsFixed(0)}', true),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildSummaryItem('Refunded', '₹${totalRefunded.toStringAsFixed(0)}', true, const Color(0xFF1565C0)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Help Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.field,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.headset_mic_outlined, color: AppColors.ink, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Need help?',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Contact our support team for any payment related queries or issues.',
                                            style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.ink,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'History of all your payments',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _fetchPaymentHistory,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.ink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primaryDark : AppColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: payment['statusColor'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              payment['icon'],
              color: payment['statusColor'],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking with ${payment['name']}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  '${payment['date']}, ${payment['time']}',
                  style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment['amount'],
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Text(
                payment['status'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: payment['statusColor'],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, [bool highlight = false, Color? highlightColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: highlight ? (highlightColor ?? AppColors.primaryDark) : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _selectedFilter = 'All';

  // Sample payment data
  final List<Map<String, dynamic>> _payments = [
    {
      'name': 'John Doe',
      'date': '18 May 2024',
      'time': '04:00 PM',
      'amount': '₹519',
      'status': 'Successful',
      'statusColor': AppColors.primary,
      'icon': Icons.check_circle_rounded,
    },
    {
      'name': 'Jane Smith',
      'date': '10 May 2024',
      'time': '03:30 PM',
      'amount': '₹699',
      'status': 'Successful',
      'statusColor': AppColors.primary,
      'icon': Icons.check_circle_rounded,
    },
    {
      'name': 'Mike Ross',
      'date': '05 May 2024',
      'time': '11:00 AM',
      'amount': '₹399',
      'status': 'Pending',
      'statusColor': const Color(0xFFFF9800),
      'icon': Icons.schedule_rounded,
    },
    {
      'name': 'Alex Morgan',
      'date': '28 Apr 2024',
      'time': '06:00 PM',
      'amount': '₹499',
      'status': 'Failed',
      'statusColor': const Color(0xFFF44336),
      'icon': Icons.close_rounded,
    },
    {
      'name': 'Sarah Lee',
      'date': '20 Apr 2024',
      'time': '02:00 PM',
      'amount': '₹519',
      'status': 'Successful',
      'statusColor': AppColors.primary,
      'icon': Icons.check_circle_rounded,
    },
    {
      'name': 'John Doe',
      'date': '15 Apr 2024',
      'time': '05:30 PM',
      'amount': '₹519',
      'status': 'Refunded',
      'statusColor': const Color(0xFF1565C0),
      'icon': Icons.refresh_rounded,
    },
  ];

  List<Map<String, dynamic>> _getFilteredPayments() {
    if (_selectedFilter == 'All') {
      return _payments;
    }
    return _payments.where((payment) => payment['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _getFilteredPayments();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
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
                                      'This Month',
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
                                child: _buildSummaryItem('Total Transactions', '12'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryItem('Total Spent', '₹5,254', true),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryItem('Refunded', '₹519', true, const Color(0xFF1565C0)),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.ink,
              size: 20,
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
              color: payment['statusColor'].withValues(alpha: 0.1),
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

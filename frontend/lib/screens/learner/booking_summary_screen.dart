import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/expert_model.dart';
import '../../widgets/custom_appbar.dart';
import 'payment_screen.dart';

class BookingSummaryScreen extends StatelessWidget {
  final ExpertModel expert;
  final String date;
  final String time;
  final String sessionType;
  final String duration;
  final int sessionFee;
  final int platformFee = 20;

  const BookingSummaryScreen({
    super.key,
    required this.expert,
    required this.date,
    required this.time,
    required this.sessionType,
    required this.duration,
    required this.sessionFee,
  });

  int get _totalAmount => sessionFee + platformFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: const CustomAppBar(title: 'Booking Summary'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00B67A).withValues(alpha:  0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_user_outlined, color: Color(0xFF00B67A), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You\'re almost there!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF007A4A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Review your booking details before proceeding to payment.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expert Details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  const SizedBox(height: 16),
                  
                  // Expert Profile
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: expert.avatarColor,
                          shape: BoxShape.circle,
                        ),
                        child: expert.profileImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: Image.network(expert.profileImage!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  expert.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, color: Color(0xFF00B67A), size: 16),
                              ],
                            ),
                            Text(
                              expert.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${expert.rating} (${expert.reviews} sessions)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Top Rated',
                                    style: TextStyle(
                                      color: Color(0xFF00B67A),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: AppColors.line),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Booking Details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailItem(Icons.calendar_today_rounded, 'Date', date),
                  const SizedBox(height: 12),
                  _buildDetailItem(Icons.access_time_rounded, 'Time', time),
                  const SizedBox(height: 12),
                  _buildDetailItem(Icons.videocam_outlined, 'Session Type', sessionType),
                  const SizedBox(height: 12),
                  _buildDetailItem(Icons.timer_outlined, 'Duration', duration),
                  
                  const SizedBox(height: 24),
                  
                  // Session Goals Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What you\'ll get in this session',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF007A4A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildGoalItem('Personalized guidance'),
                        _buildGoalItem('Actionable advice & solutions'),
                        _buildGoalItem('Career & growth insights'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Price Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  const SizedBox(height: 16),
                  _buildPriceRow('Session Fee', '₹$sessionFee'),
                  const SizedBox(height: 12),
                  _buildPriceRow('Platform Fee', '₹$platformFee', showInfo: true),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.line),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        '₹$_totalAmount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00B67A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Security Notice
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security_rounded, color: Color(0xFF00B67A), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Your payment is secure and encrypted',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        expert: expert,
                        date: date,
                        time: time,
                        sessionType: sessionType,
                        duration: duration,
                        totalAmount: _totalAmount,
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Payment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00B67A), size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalItem(String goal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF00B67A), size: 16),
          const SizedBox(width: 10),
          Text(
            goal,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {bool showInfo = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showInfo) ...[
          const SizedBox(width: 6),
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.muted.withValues(alpha:  0.5)),
        ],
        const Spacer(),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

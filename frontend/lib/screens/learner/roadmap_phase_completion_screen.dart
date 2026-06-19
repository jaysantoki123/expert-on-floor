import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class RoadmapPhaseCompletionScreen extends StatelessWidget {
  final int phaseNumber;
  final String phaseTitle;
  final String timeSpent;
  final int topicsCompleted;
  final int totalTopics;
  final List<String> achievements;
  final String nextPhaseTitle;

  const RoadmapPhaseCompletionScreen({
    super.key,
    this.phaseNumber = 1,
    this.phaseTitle = 'Foundation',
    this.timeSpent = '10h 25m',
    this.topicsCompleted = 8,
    this.totalTopics = 8,
    this.achievements = const [
      'Strong understanding of Dart basics',
      'Built your foundation in Flutter',
      'Ready to move to the next level',
    ],
    this.nextPhaseTitle = 'Core Flutter',
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: ConfettiPainter(),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 6),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha:  0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 90,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Congratulations! 🎉',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You have successfully completed',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phase $phaseNumber – $phaseTitle',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'You\'re one step closer to your goal!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha:  0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.schedule_rounded, timeSpent, 'Time Spent'),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.line,
                  ),
                  _buildStatItem(Icons.checklist_rounded, '$topicsCompleted / $totalTopics', 'Topics Completed'),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.line,
                  ),
                  _buildStatItem(Icons.radio_button_checked_rounded, '100%', 'Progress'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha:  0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What You\'ve Achieved',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: achievements.map((achievement) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events_outlined,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      achievement,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.amber[600],
                              size: 65,
                            ),
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildSmallConfetti(),
                                  _buildSmallConfetti(),
                                  _buildSmallConfetti(),
                                  _buildSmallConfetti(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha:  0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rewards Earned',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildRewardItem(Icons.star_rounded, '+250 XP', 'Experience Points', const Color(0xFFFFF8E0), const Color(0xFFFFB800)),
                      const SizedBox(width: 10),
                      _buildRewardItem(Icons.verified_rounded, 'Foundation Master', 'Badge Unlocked', AppColors.primarySoft, AppColors.primary),
                      const SizedBox(width: 10),
                      _buildRewardItem(Icons.diamond_outlined, '+5 Gems', 'Keep Going!', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1565C0).withValues(alpha:  0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What\'s Next?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Continue your journey with Phase ${phaseNumber + 1} – $nextPhaseTitle',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Next Phase',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 15),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.flag_rounded, color: Color(0xFF1565C0), size: 55),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Back to Roadmap',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue Learning',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Header
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
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
                  'Phase Complete',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Great work on finishing this phase',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem(IconData icon, String title, String subtitle, Color bg, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallConfetti() {
    final colors = [Colors.orange, Colors.blue, Colors.amber, AppColors.primary];
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: colors[DateTime.now().millisecond % colors.length],
        shape: BoxShape.circle,
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

final confettiPositions = [
      Offset(40, 40),
      Offset(size.width - 40, 30),
      Offset(60, 80),
      Offset(size.width - 60, 70),
      Offset(80, 120),
      Offset(size.width - 80, 110),
      Offset(20, 150),
      Offset(size.width - 20, 140),
    ];

    final confettiColors = [
      Colors.orange,
      Colors.blue,
      Colors.amber,
      AppColors.primary,
      Colors.purple,
    ];

    for (int i = 0; i < confettiPositions.length; i++) {
      paint.color = confettiColors[i % confettiColors.length];
      canvas.drawCircle(confettiPositions[i], i % 2 == 0 ? 5 : 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
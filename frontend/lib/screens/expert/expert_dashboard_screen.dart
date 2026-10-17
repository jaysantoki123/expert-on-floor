import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'expert_chat_list_screen.dart';
import 'expert_profile_screen.dart';
import '../learner/notifications_screen.dart';
import 'expert_bookings_screen.dart';
import 'edit_skills_screen.dart';
import 'expert_reviews_screen.dart';
import 'expert_earnings_screen.dart';
import 'expert_availability_screen.dart';
import 'expert_booking_analytics_screen.dart';
import 'expert_withdraw_screen.dart';
import 'expert_manage_services_screen.dart';
import 'expert_learners_screen.dart';
import 'expert_community_answers_screen.dart';
import 'expert_resources_screen.dart';
import 'expert_verification_screen.dart';
import 'expert_settings_screen.dart';
import 'expert_help_support_screen.dart';
import 'expert_video_session_screen.dart';
import 'expert_today_sessions_screen.dart';
import 'expert_payout_methods_screen.dart';
import '../login_screen.dart';

class ExpertDashboardScreen extends StatefulWidget {
  const ExpertDashboardScreen({super.key});

  @override
  State<ExpertDashboardScreen> createState() => _ExpertDashboardScreenState();
}

class _ExpertDashboardScreenState extends State<ExpertDashboardScreen> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const _ExpertDashboardTab(),
      const ExpertBookingsScreen(),
      const ExpertChatListScreen(),
      const ExpertEarningsScreen(),
      const ExpertProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomAppBar(
            padding: EdgeInsets.zero,
            height: 76,
            elevation: 0,
            color: Colors.white.withValues(alpha: 0.85),
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view_rounded,
                      label: 'Dashboard',
                      index: 0,
                      currentIndex: _currentIndex,
                      onTap: (idx) => setState(() => _currentIndex = idx),
                    ),
                    _NavItem(
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today_rounded,
                      label: 'Sessions',
                      index: 1,
                      currentIndex: _currentIndex,
                      onTap: (idx) => setState(() => _currentIndex = idx),
                    ),
                    _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: 'Messages',
                      index: 2,
                      currentIndex: _currentIndex,
                      onTap: (idx) => setState(() => _currentIndex = idx),
                    ),
                    _NavItem(
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet_rounded,
                      label: 'Earnings',
                      index: 3,
                      currentIndex: _currentIndex,
                      onTap: (idx) => setState(() => _currentIndex = idx),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      index: 4,
                      currentIndex: _currentIndex,
                      onTap: (idx) => setState(() => _currentIndex = idx),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primary : AppColors.muted,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Tab ──
class _ExpertDashboardTab extends StatefulWidget {
  const _ExpertDashboardTab();

  @override
  State<_ExpertDashboardTab> createState() => _ExpertDashboardTabState();
}

class _ExpertDashboardTabState extends State<_ExpertDashboardTab> {
  
  final String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final expertName = user?.name ?? 'Rahul Sharma';
    final expertRole = user?.isExpert == true ? 'Flutter Developer' : 'Technical Expert';

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, user?.profileImage),
            const SizedBox(height: 20),

            // Greeting & Status Card
            _buildGreetingCard(expertName, expertRole),
            const SizedBox(height: 24),

            // Overview Section
            _buildOverviewHeader(),
            const SizedBox(height: 14),
            _buildOverviewGrid(),
            const SizedBox(height: 24),

            // Earnings Chart Card
            _buildEarningsChartCard(),
            const SizedBox(height: 24),

            // Upcoming Sessions Section
            _buildUpcomingSessionsHeader(context),
            const SizedBox(height: 14),
            _buildUpcomingSessionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? profileImage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _showMenuBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line, width: 1),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: AppColors.ink,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Expert Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Notifications Icon
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.ink,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Profile image with green indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primarySoft,
                  backgroundImage: profileImage != null && profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage == null || profileImage.isEmpty
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingCard(String name, String role) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009D45), Color(0xFF007A35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background abstract circle designs
          Positioned(
            right: -30,
            top: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Good Morning, ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '👋',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFC107),
                                      size: 13,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '4.9',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
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
                  ],
                ),
                const SizedBox(height: 24),
                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 16),
                // Next Session Card
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExpertVideoSessionScreen(
                          menteeName: 'Priya Mehta',
                          sessionTitle: 'Career Guidance & Roadmap Review',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Session • Tap to Enter Room',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Today, 11:00 AM (Priya Mehta)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Join Call',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            children: [
              Text(
                _selectedPeriod,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.muted,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.35,
      children: [
        _buildOverviewCard(
          icon: Icons.calendar_month_rounded,
          iconBg: const Color(0xFFEAF7EF),
          iconColor: const Color(0xFF22C55E),
          title: 'Total Sessions',
          value: '24',
          growth: '+ 20%',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpertTodaySessionsScreen()),
            );
          },
        ),
        _buildOverviewCard(
          icon: Icons.payments_outlined,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF3B82F6),
          title: 'Total Earnings',
          value: '₹24,500',
          growth: '+ 18%',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpertEarningsScreen()),
            );
          },
        ),
        _buildOverviewCard(
          icon: Icons.star_border_rounded,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFFA855F7),
          title: 'Rating',
          value: '4.9',
          growth: '+ 5%',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpertReviewsScreen()),
            );
          },
        ),
        _buildOverviewCard(
          icon: Icons.chat_bubble_outline_rounded,
          iconBg: const Color(0xFFFFF7ED),
          iconColor: const Color(0xFFF97316),
          title: 'Reviews',
          value: '128',
          growth: '+ 15%',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpertReviewsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String growth,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'vs last month',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEarningsChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Earnings Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ExpertEarningsScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Chart view using CustomPainter
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: EarningsChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Upcoming Sessions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpertBookingsScreen()),
            );
          },
          child: const Text(
            'View All',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSessionsList() {
    final sessions = [
      _SessionData(
        title: 'Career Guidance Session',
        learner: 'Priya Mehta',
        time: 'Today, 11:00 AM',
        joinable: true,
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
      ),
      _SessionData(
        title: 'Flutter Project Discussion',
        learner: 'Amit Verma',
        time: 'Today, 02:00 PM',
        joinable: false,
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150',
      ),
      _SessionData(
        title: 'Resume Review',
        learner: 'Sneha Iyer',
        time: 'Tomorrow, 10:00 AM',
        joinable: false,
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=150',
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: NetworkImage(session.avatarUrl),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Session Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.learner,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.muted,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          session.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // CTA Button
              session.joinable
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpertVideoSessionScreen(
                              menteeName: session.learner,
                              sessionTitle: session.title,
                              menteeAvatar: session.avatarUrl,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.videocam_rounded, size: 14, color: Colors.white),
                      label: const Text(
                        'Join Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExpertBookingsScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF22C55E), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Expert Center & Navigation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mentorship & Catalog
                  _menuItem(
                    icon: Icons.workspace_premium_rounded,
                    iconColor: AppColors.primary,
                    title: 'Services & Pricing',
                    subtitle: 'Manage your consultation packages',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertManageServicesScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.calendar_month_rounded,
                    iconColor: const Color(0xFF22C55E),
                    title: "Today's Schedule & Slots",
                    subtitle: 'View your live appointments',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertTodaySessionsScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.people_outline_rounded,
                    iconColor: Colors.teal,
                    title: 'My Learners & Mentees',
                    subtitle: 'Track student progress & roadmap notes',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertLearnersScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.forum_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'Community Q&A Answers',
                    subtitle: 'Answer questions to earn mentorship leads',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ExpertCommunityAnswersScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.event_available_outlined,
                    iconColor: const Color(0xFF22C55E),
                    title: 'Manage Availability',
                    subtitle: 'Set weekly hours and holiday mode',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertAvailabilityScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.psychology_outlined,
                    iconColor: const Color(0xFF0284C7),
                    title: 'Edit Skills & Expertise',
                    subtitle: 'Update your tech stack tags',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditSkillsScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.folder_shared_outlined,
                    iconColor: Colors.indigo,
                    title: 'Shared Learning Resources',
                    subtitle: 'Cheat sheets, repos, & interview guides',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertResourcesScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.analytics_outlined,
                    iconColor: Colors.deepPurple,
                    title: 'Booking Analytics',
                    subtitle: 'Conversion rate & session volume',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ExpertBookingAnalyticsScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.account_balance_outlined,
                    iconColor: Colors.orange,
                    title: 'Withdraw Funds',
                    subtitle: 'Request payouts to your bank account',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertWithdrawScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.credit_card_rounded,
                    iconColor: const Color(0xFF0F766E),
                    title: 'Payout Methods (Bank & UPI)',
                    subtitle: 'Manage linked accounts and IFSC',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertPayoutMethodsScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.verified_user_outlined,
                    iconColor: const Color(0xFF0284C7),
                    title: 'Verification & Trust Badges',
                    subtitle: 'Identity and credentials checklist',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertVerificationScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.settings_outlined,
                    iconColor: AppColors.muted,
                    title: 'Expert Settings',
                    subtitle: 'Booking rules, reminders & preferences',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertSettingsScreen()),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.support_agent_rounded,
                    iconColor: Colors.teal,
                    title: 'Help & Partner Support',
                    subtitle: 'FAQ and concierge contact desk',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExpertHelpSupportScreen()),
                      );
                    },
                  ),
                  const Divider(height: 18, color: AppColors.line),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Colors.redAccent, size: 20),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.muted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.muted, size: 18),
      onTap: onTap,
    );
  }
}

class _SessionData {
  final String title;
  final String learner;
  final String time;
  final bool joinable;
  final String avatarUrl;

  _SessionData({
    required this.title,
    required this.learner,
    required this.time,
    required this.joinable,
    required this.avatarUrl,
  });
}

// ── CustomPainter for Earnings Chart ──
class EarningsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF009D45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final paintGrid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Earnings mock values & coordinates
    // Dates: 1 May, 8 May, 15 May, 22 May, 29 May
    // Earnings: [5K, 15K, 10K, 24.5K, 12K, 11K, 14K, 11K] -- plotted points
    final List<double> values = [5000, 14000, 9500, 11500, 22000, 12000, 11500, 13000, 10500];
    final int pointsCount = values.length;

    const double yMax = 30000;
    const double paddingLeft = 38.0;
    const double paddingRight = 12.0;
    const double paddingTop = 24.0;
    const double paddingBottom = 22.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    // Draw horizontal grid lines & Y-axis labels
    final double gridInterval = yMax / 3;
    for (int i = 0; i <= 3; i++) {
      final double value = gridInterval * i;
      final double y = paddingTop + chartHeight - (value / yMax) * chartHeight;

      // Grid line
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), paintGrid);

      // Y-axis Label
      String label = '₹${(value / 1000).toInt()}K';
      if (value == 0) label = '₹0';
      
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // X-axis Labels (Dates)
    final List<String> dates = ['1 May', '8 May', '15 May', '22 May', '29 May'];
    for (int i = 0; i < dates.length; i++) {
      final double fraction = i / (dates.length - 1);
      final double x = paddingLeft + fraction * chartWidth;

      textPainter.text = TextSpan(
        text: dates[i],
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - paddingBottom + 6),
      );
    }

    // Coordinates mapping
    final List<Offset> points = [];
    for (int i = 0; i < pointsCount; i++) {
      final double fraction = i / (pointsCount - 1);
      final double x = paddingLeft + fraction * chartWidth;
      final double y = paddingTop + chartHeight - (values[i] / yMax) * chartHeight;
      points.add(Offset(x, y));
    }

    // Drawing gradient area below spline
    final Path areaPath = Path();
    areaPath.moveTo(points[0].dx, paddingTop + chartHeight);
    areaPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      areaPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }
    areaPath.lineTo(points[pointsCount - 1].dx, paddingTop + chartHeight);
    areaPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF009D45).withValues(alpha: 0.22),
          const Color(0xFF009D45).withValues(alpha: 0.00),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(paddingLeft, paddingTop, size.width, size.height - paddingBottom))
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, fillPaint);

    // Drawing spline line
    final Path linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }
    canvas.drawPath(linePath, paintLine);

    // Draw active tooltip at 15 May peak (roughly index 4 in our values, which is 22000 => mapped to ₹24,500 in display)
    const int peakIndex = 4;
    final targetOffset = points[peakIndex];

    // Dot at peak
    final dotPaintOuter = Paint()
      ..color = const Color(0xFF009D45)
      ..style = PaintingStyle.fill;
    final dotPaintInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(targetOffset, 5.5, dotPaintOuter);
    canvas.drawCircle(targetOffset, 2.5, dotPaintInner);

    // Draw tooltip capsule above the dot
    final tooltipRect = Rect.fromCenter(
      center: Offset(targetOffset.dx, targetOffset.dy - 22),
      width: 58,
      height: 20,
    );
    final RRect tooltipRRect = RRect.fromRectAndRadius(tooltipRect, const Radius.circular(6));
    
    final paintTooltipBg = Paint()
      ..color = const Color(0xFF007A35)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(tooltipRRect, paintTooltipBg);

    // Drawing the small triangular pointer for tooltip
    final Path trianglePath = Path()
      ..moveTo(targetOffset.dx - 4, targetOffset.dy - 12)
      ..lineTo(targetOffset.dx + 4, targetOffset.dy - 12)
      ..lineTo(targetOffset.dx, targetOffset.dy - 8)
      ..close();
    canvas.drawPath(trianglePath, paintTooltipBg);

    // Tooltip Text
    textPainter.text = const TextSpan(
      text: '₹24,500',
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(targetOffset.dx - textPainter.width / 2, targetOffset.dy - 22 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'my_bookings_screen.dart';
import 'my_roadmap_screen.dart';
import 'conversations_screen.dart';
import 'learner_dashboard_screen.dart';
import 'session_history_screen.dart';
import 'my_reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFFF4F6F4),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ────────────────────────────
                SliverToBoxAdapter(child: _buildHeader()),

                // ── Stats Row ─────────────────────────
                SliverToBoxAdapter(child: _buildStatsRow()),

                // ── Quick Actions ──────────────────────
                SliverToBoxAdapter(child: _buildQuickActions(context)),

                // ── Menu Sections ──────────────────────
                SliverToBoxAdapter(child: _buildMenuSections(context)),

                // ── Logout ─────────────────────────────
                SliverToBoxAdapter(child: _buildLogout(context)),

                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F9D58), Color(0xFF00B67A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B67A).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.white, size: 30),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // Extract bottom nav to separate widget
  Widget _buildBottomNav() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomAppBar(
            padding: EdgeInsets.zero,
            height: 76,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 0,
            color: AppColors.white.withValues(alpha: 0.55),
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                      currentIndex: 3,
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LearnerDashboardScreen()),
                      ),
                    ),
                    _NavItem(
                      icon: Icons.school_outlined,
                      activeIcon: Icons.school_rounded,
                      label: 'Experts',
                      index: 1,
                      currentIndex: 3,
                      onTap: () {},
                    ),
                    const SizedBox(width: 56),
                    _NavItem(
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Community',
                      index: 2,
                      currentIndex: 3,
                      onTap: () {},
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      index: 3,
                      currentIndex: 3,
                      onTap: () {},
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

  // ══════════════════════════════════════════════════════════════
  // Header
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:  0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:  0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:  0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha:  0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha:  0.5),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                        // Edit badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: AppColors.primary,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Name + info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          const Text(
                            'Rohan Kumar',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Learner',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha:  0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Join date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Colors.white.withValues(alpha:  0.7),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Joined January 2024',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha:  0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Settings icon
                    GestureDetector(
                      onTap: () => _showSettingsSheet(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:  0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha:  0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Email + phone strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:  0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha:  0.2)),
                  ),
                  child: Row(
                    children: [
                      _contactInfo(Icons.email_outlined, 'rohan@gmail.com'),
                      Container(
                        width: 1,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.white.withValues(alpha:  0.3),
                      ),
                      _contactInfo(Icons.phone_outlined, '+91 9876543210'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactInfo(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha:  0.7), size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha:  0.85),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Stats Row
  // ══════════════════════════════════════════════════════════════
  Widget _buildStatsRow() {
    final stats = [
      _StatItem(
        value: '12',
        label: 'Sessions',
        icon: Icons.videocam_rounded,
        color: AppColors.primary,
      ),
      _StatItem(
        value: '4',
        label: 'Experts',
        icon: Icons.people_rounded,
        color: Colors.deepPurple,
      ),
      _StatItem(
        value: '61%',
        label: 'Roadmap',
        icon: Icons.route_rounded,
        color: Colors.teal,
      ),
      _StatItem(
        value: '4.8',
        label: 'Rating',
        icon: Icons.star_rounded,
        color: Colors.amber,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final isLast = e.key == stats.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(child: _StatCard(item: e.value)),
                if (!isLast)
                  Container(width: 1, height: 36, color: AppColors.line),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Quick Actions
  // ══════════════════════════════════════════════════════════════
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.calendar_month_rounded,
        label: 'My\nBookings',
        color: AppColors.primary,
        bgColor: AppColors.primarySoft,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
      ),
      _QuickAction(
        icon: Icons.chat_bubble_rounded,
        label: 'My\nChat',
        color: Colors.deepPurple,
        bgColor: const Color(0xFFF3E5F5),
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.route_rounded,
        label: 'My\nRoadmap',
        color: Colors.teal,
        bgColor: const Color(0xFFE0F2F1),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MyRoadmapScreen())),
      ),
      _QuickAction(
        icon: Icons.favorite_rounded,
        label: 'Saved\nExperts',
        color: Colors.redAccent,
        bgColor: const Color(0xFFFFEBEE),
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Quick Actions'),
          const SizedBox(height: 12),
          Row(
            children: actions
                .map(
                  (a) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: actions.indexOf(a) < actions.length - 1 ? 10 : 0,
                      ),
                      child: _QuickActionCard(action: a),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Menu Sections
  // ══════════════════════════════════════════════════════════════
  Widget _buildMenuSections(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Learning ──────────────────────────────
          const _SectionTitle('Learning'),
          const SizedBox(height: 10),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primarySoft,
                title: 'My Bookings',
                subtitle: '3 upcoming sessions',
                badge: '3',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.route_rounded,
                iconColor: Colors.teal,
                iconBg: const Color(0xFFE0F2F1),
                title: 'AI Roadmap',
                subtitle: '61% completed',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyRoadmapScreen()),
                ),
                trailing: _ProgressBadge(progress: 0.61),
              ),
              _MenuItem(
                icon: Icons.history_rounded,
                iconColor: Colors.orange,
                iconBg: const Color(0xFFFFF3E0),
                title: 'Session History',
                subtitle: '12 completed sessions',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.star_rounded,
                iconColor: Colors.amber,
                iconBg: const Color(0xFFFFF8E1),
                title: 'My Reviews',
                subtitle: 'Reviews you have given',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
                ),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Communication ─────────────────────────
          const _SectionTitle('Communication'),
          const SizedBox(height: 10),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.chat_bubble_rounded,
                iconColor: Colors.deepPurple,
                iconBg: const Color(0xFFF3E5F5),
                title: 'Messages',
                subtitle: '2 unread messages',
                badge: '2',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ConversationsScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.public_rounded,
                iconColor: Colors.indigo,
                iconBg: const Color(0xFFE8EAF6),
                title: 'Community',
                subtitle: 'Questions & discussions',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.notifications_rounded,
                iconColor: Colors.redAccent,
                iconBg: const Color(0xFFFFEBEE),
                title: 'Notifications',
                subtitle: '5 new notifications',
                badge: '5',
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Account ───────────────────────────────
          const _SectionTitle('Account'),
          const SizedBox(height: 10),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primarySoft,
                title: 'Edit Profile',
                subtitle: 'Update your information',
                onTap: () => _showEditProfile(context),
              ),
              _MenuItem(
                icon: Icons.payment_rounded,
                iconColor: Colors.green,
                iconBg: const Color(0xFFE8F5E9),
                title: 'Payment History',
                subtitle: 'View your transactions',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.lock_outline_rounded,
                iconColor: Colors.blueGrey,
                iconBg: const Color(0xFFECEFF1),
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.teal,
                iconBg: const Color(0xFFE0F2F1),
                title: 'Privacy Settings',
                subtitle: 'Manage your data',
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Preferences ───────────────────────────
          const _SectionTitle('Preferences'),
          const SizedBox(height: 10),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.language_rounded,
                iconColor: Colors.blue,
                iconBg: const Color(0xFFE3F2FD),
                title: 'Language',
                subtitle: 'English',
                onTap: () {},
                trailingText: 'English',
              ),
              _MenuItem(
                icon: Icons.dark_mode_outlined,
                iconColor: Colors.indigo,
                iconBg: const Color(0xFFE8EAF6),
                title: 'Theme',
                subtitle: 'Light mode',
                onTap: () {},
                trailingText: 'Light',
              ),
              _MenuItem(
                icon: Icons.help_outline_rounded,
                iconColor: Colors.orange,
                iconBg: const Color(0xFFFFF3E0),
                title: 'Help & Support',
                subtitle: 'FAQs, contact us',
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Logout
  // ══════════════════════════════════════════════════════════════
  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withValues(alpha:  0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Dialogs / Sheets
  // ══════════════════════════════════════════════════════════════
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            _settingsTile(
              Icons.notifications_outlined,
              'Notification Settings',
            ),
            _settingsTile(Icons.security_outlined, 'Security'),
            _settingsTile(Icons.info_outline_rounded, 'About App'),
            _settingsTile(Icons.star_outline_rounded, 'Rate App'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.muted,
        size: 20,
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _EditProfileSheet(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Edit Profile Sheet
// ══════════════════════════════════════════════════════════════════
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _nameCtrl = TextEditingController(text: 'Rohan Kumar');
  final _emailCtrl = TextEditingController(text: 'rohan@gmail.com');
  final _phoneCtrl = TextEditingController(text: '+91 9876543210');
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 24),

            // Avatar
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primarySoft, width: 3),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Change Photo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),

            _editField('Full Name', _nameCtrl, Icons.person_outline_rounded),
            const SizedBox(height: 14),
            _editField(
              'Email',
              _emailCtrl,
              Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _editField(
              'Phone',
              _phoneCtrl,
              Icons.phone_outlined,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await Future.delayed(
                          const Duration(milliseconds: 1200),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Profile updated successfully!',
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 14, color: AppColors.ink),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.muted, size: 18),
            filled: true,
            fillColor: AppColors.field,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Reusable Widgets
// ══════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ── Stat Models ────────────────────────────────────────────────────
class _StatItem {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

// Make _NavItem const constructor for performance
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.muted,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha:  0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: item.color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          item.value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }
}

// ── Quick Action ───────────────────────────────────────────────────
class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: action.bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color.withValues(alpha:  0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha:  0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: action.color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Card ──────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) => _MenuItemTile(item: item)).toList(),
      ),
    );
  }
}

// ── Menu Item ──────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.trailingText,
    this.trailing,
    this.isLast = false,
  });
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // Icon box
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),

                // Trailing
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (item.trailingText != null)
                  Text(
                    item.trailingText!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (item.trailing != null)
                  item.trailing!
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (!item.isLast)
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Divider(height: 1, color: AppColors.line),
          ),
      ],
    );
  }
}

// ── Progress Badge ─────────────────────────────────────────────────
class _ProgressBadge extends StatelessWidget {
  final double progress;
  const _ProgressBadge({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: AppColors.line,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'expert_listing_screen.dart';

class LearnerDashboardScreen extends StatefulWidget {
  const LearnerDashboardScreen({super.key});

  @override
  State<LearnerDashboardScreen> createState() => _LearnerDashboardScreenState();
}

class _LearnerDashboardScreenState extends State<LearnerDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardTab(),
    _ExpertsTab(),
    _CommunityTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.white,
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
          );
        },
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
                      currentIndex: _currentIndex,
                      onTap: (i) => setState(() => _currentIndex = i),
                    ),
                    _NavItem(
                      icon: Icons.school_outlined,
                      activeIcon: Icons.school_rounded,
                      label: 'Experts',
                      index: 1,
                      currentIndex: _currentIndex,
                      onTap: (i) => setState(() => _currentIndex = i),
                    ),
                    const SizedBox(width: 56), // gap for center FAB
                    _NavItem(
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Community',
                      index: 2,
                      currentIndex: _currentIndex,
                      onTap: (i) => setState(() => _currentIndex = i),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      index: 3,
                      currentIndex: _currentIndex,
                      onTap: (i) => setState(() => _currentIndex = i),
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

// ══════════════════════════════════════════════════════════════════
// Nav Item
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
    return GestureDetector(
      onTap: () => onTap(index),
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

// ══════════════════════════════════════════════════════════════════
// Dashboard Tab
// ══════════════════════════════════════════════════════════════════
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  final double _roadmapProgress = 0.61;
  String _aiQuery = '';
  bool _isFetchingAi = false;
  String? _aiResponse;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(begin: 0, end: _roadmapProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Header ────────────────────────────────────
            _buildHeader(),
            const SizedBox(height: 24),
            _buildHeroSummary(),
            const SizedBox(height: 22),
            _buildSearchBar(),
            const SizedBox(height: 22),
            _buildAiFetcher(),
            const SizedBox(height: 24),

            // ── Upcoming Sessions ─────────────────────────
            _buildSectionTitle('Upcoming Session', onMore: () {}),
            const SizedBox(height: 12),
            _buildUpcomingSession(),
            const SizedBox(height: 24),

            // ── AI Roadmap Progress ───────────────────────
            _buildSectionTitle('AI Roadmap Progress', onMore: () {}),
            const SizedBox(height: 12),
            _buildRoadmapProgress(),
            const SizedBox(height: 24),

            // ── Notifications ─────────────────────────────
            _buildSectionTitle('Notifications', onMore: () {}),
            const SizedBox(height: 12),
            _buildNotifications(),
            const SizedBox(height: 24),

            // ── Recent Mentors ────────────────────────────
            _buildSectionTitle('Recent Mentors', onMore: () {}),
            const SizedBox(height: 12),
            _buildRecentMentors(),
            const SizedBox(height: 24),

            // ── Quick Actions ─────────────────────────────
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    'Hello, Rohan ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text('👋', style: TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Build a stronger skillset with guided mentor support.',
                style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.white,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F9D58), Color(0xFF00B67A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Learner Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Focus on your next milestone and unlock expert guidance.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.white,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Learner',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '61% completed',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'On Track',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: _roadmapProgress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric('Sessions', '3 today', Icons.event_available),
              _buildMiniMetric('Mentors', '12 saved', Icons.favorite),
              _buildMiniMetric('Milestones', '4 done', Icons.flag),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String title, String subtitle, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.white, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.muted),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Search experts, sessions or topics',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAiFetcher() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Learning Assistant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask the AI for topic suggestions, study tips, or mentor recommendations.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _aiQuery = value),
                  decoration: InputDecoration(
                    hintText: 'What do you want help with?',
                        hintStyle: TextStyle(color: AppColors.muted.withValues(alpha: 0.75)),
                    filled: true,
                    fillColor: AppColors.field,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.line),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _aiQuery.trim().isEmpty || _isFetchingAi ? null : _fetchAiSuggestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isFetchingAi
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text(
                          'Fetch',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _AiHintChip(label: 'Best study plan'),
              _AiHintChip(label: 'Mentor for Flutter'),
              _AiHintChip(label: 'Interview prep tips'),
            ],
          ),
          if (_aiResponse != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _aiResponse!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.ink,
                  height: 1.55,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _fetchAiSuggestion() {
    setState(() {
      _isFetchingAi = true;
      _aiResponse = null;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _isFetchingAi = false;
        _aiResponse =
            'AI suggests: Focus on ${_aiQuery.trim().isEmpty ? 'goal alignment' : _aiQuery.trim()}, review top mentor profiles, and schedule a 30-minute session this week.';
      });
    });
  }

  // ── Section Title ──────────────────────────────────────────────
  Widget _buildSectionTitle(String title, {VoidCallback? onMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: const Text(
              'See all',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  // ── Upcoming Session Card ──────────────────────────────────────
  Widget _buildUpcomingSession() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _sessionRow(
            name: 'Rahul Sharma',
            topic: 'Flutter State Management',
            time: '6 Hrs, 6:00 PM',
            type: 'Video Call',
            avatarColor: const Color(0xFF5C6BC0),
          ),
          Divider(height: 20, color: AppColors.line),
          _sessionRow(
            name: 'Amit Verma',
            topic: 'React Native Basics',
            time: '5 Hrs, 3:00 PM',
            type: 'Audio Call',
            avatarColor: const Color(0xFF26A69A),
            showJoin: false,
          ),
        ],
      ),
    );
  }

  Widget _sessionRow({
    required String name,
    required String topic,
    required String time,
    required String type,
    required Color avatarColor,
    bool showJoin = true,
  }) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                topic,
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$time • $type',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Join Button
        if (showJoin)
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              elevation: 0,
            ),
            child: const Text(
              'Join',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: const Text(
              'Soon',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  // ── AI Roadmap Progress ────────────────────────────────────────
  Widget _buildRoadmapProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) => SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: _progressAnim.value,
                      strokeWidth: 8,
                      backgroundColor: AppColors.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_progressAnim.value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Done',
                        style: TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flutter Developer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '16 Weeks Plan',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 12),

                // Steps
                _progressStep('Dart Basics', true),
                const SizedBox(height: 6),
                _progressStep('Flutter Basics', true),
                const SizedBox(height: 6),
                _progressStep('State Management', false),
                const SizedBox(height: 12),

                // CTA
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Continue Learning →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
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

  Widget _progressStep(String label, bool done) {
    return Row(
      children: [
        Icon(
          done
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 14,
          color: done ? AppColors.primary : AppColors.muted,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: done ? AppColors.ink : AppColors.muted,
            fontWeight: done ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Notifications ──────────────────────────────────────────────
  Widget _buildNotifications() {
    final notifications = [
      _NotifData(
        icon: Icons.calendar_today_rounded,
        color: AppColors.primary,
        bgColor: AppColors.primarySoft,
        title: 'Session Reminder',
        subtitle: 'Rahul Sharma session in 30 mins',
        time: '10 min ago',
      ),
      _NotifData(
        icon: Icons.star_rounded,
        color: Colors.amber,
        bgColor: const Color(0xFFFFF8E1),
        title: 'New Review',
        subtitle: 'You received a 5-star review!',
        time: '1 hr ago',
      ),
      _NotifData(
        icon: Icons.route_rounded,
        color: Colors.deepPurple,
        bgColor: const Color(0xFFF3E5F5),
        title: 'Roadmap Updated',
        subtitle: 'Your AI roadmap has new steps',
        time: '2 hrs ago',
      ),
    ];

    return Column(
      children: notifications
          .map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NotificationCard(data: n),
            ),
          )
          .toList(),
    );
  }

  // ── Recent Mentors ─────────────────────────────────────────────
  Widget _buildRecentMentors() {
    final mentors = [
      _MentorData(
        name: 'Rahul Sharma',
        skill: 'Flutter',
        rating: '4.9',
        color: const Color(0xFF5C6BC0),
      ),
      _MentorData(
        name: 'Sneha Iyer',
        skill: 'UI/UX',
        rating: '4.7',
        color: const Color(0xFFEC407A),
      ),
      _MentorData(
        name: 'Amit Verma',
        skill: 'React',
        rating: '4.8',
        color: const Color(0xFF26A69A),
      ),
      _MentorData(
        name: 'Vikram Patel',
        skill: 'AI/ML',
        rating: '4.6',
        color: const Color(0xFFFF7043),
      ),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: mentors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _MentorCard(data: mentors[i]),
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        _QuickActionCard(
          icon: Icons.search_rounded,
          label: 'Find Expert',
          color: AppColors.primary,
          bgColor: AppColors.primarySoft,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _QuickActionCard(
          icon: Icons.public_rounded,
          label: 'Community',
          color: Colors.deepPurple,
          bgColor: const Color(0xFFF3E5F5),
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _QuickActionCard(
          icon: Icons.route_rounded,
          label: 'Roadmap',
          color: Colors.teal,
          bgColor: const Color(0xFFE0F2F1),
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _QuickActionCard(
          icon: Icons.chat_bubble_rounded,
          label: 'Chat',
          color: Colors.orange,
          bgColor: const Color(0xFFFFF3E0),
          onTap: () {},
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Notification Card
// ══════════════════════════════════════════════════════════════════
class _NotifData {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotifData({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotifData data;

  const _NotificationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            data.time,
            style: TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Mentor Card
// ══════════════════════════════════════════════════════════════════
class _MentorData {
  final String name;
  final String skill;
  final String rating;
  final Color color;

  const _MentorData({
    required this.name,
    required this.skill,
    required this.rating,
    required this.color,
  });
}

class _MentorCard extends StatelessWidget {
  final _MentorData data;

  const _MentorCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.name.split(' ')[0],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 10),
              const SizedBox(width: 2),
              Text(
                data.rating,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Quick Action Card
// ══════════════════════════════════════════════════════════════════
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiHintChip extends StatelessWidget {
  final String label;

  const _AiHintChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Placeholder Tabs
// ══════════════════════════════════════════════════════════════════
class _ExpertsTab extends StatelessWidget {
  const _ExpertsTab();

  @override
  Widget build(BuildContext context) {
    return const ExpertListingScreen();
  }
}

// Chat tab removed — UI no longer includes chat as a separate bottom nav item.

class _CommunityTab extends StatelessWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Community Screen',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

// ── AI Assistant Screen ─────────────────────────────────────────
class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: AppColors.primary,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'AI Assistant: Ask study tips, mentor suggestions, or topic plans.',
            style: TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

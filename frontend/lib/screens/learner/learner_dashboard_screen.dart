import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/learner/my_bookings_screen.dart';
import 'package:flutter_application_1/screens/learner/my_roadmap_screen.dart';
import 'package:flutter_application_1/screens/learner/notifications_screen.dart';
import 'package:flutter_application_1/screens/learner/expert_listing_screen.dart';
import 'package:flutter_application_1/screens/learner/profile_screen.dart';
import 'package:flutter_application_1/screens/learner/community_screen.dart';
import 'package:flutter_application_1/screens/learner/genrate_roadmap_screen.dart';
import 'package:flutter_application_1/screens/learner/conversations_screen.dart';
import 'package:flutter_application_1/screens/learner/roadmap_phase_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/roadmap_provider.dart';
import '../../providers/expert_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/auth_service.dart';
import '../../models/booking_model.dart';
import '../../models/roadmap_model.dart';
import '../../models/expert_model.dart';

class LearnerDashboardScreen extends StatefulWidget {
  const LearnerDashboardScreen({super.key});

  @override
  State<LearnerDashboardScreen> createState() => _LearnerDashboardScreenState();
}

class _LearnerDashboardScreenState extends State<LearnerDashboardScreen> {
  late final List<Widget> _tabs;
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabs = const [
      _DashboardTab(),
      _ExpertsTab(),
      CommunityScreen(),
      ProfileScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChatSocket();
    });
  }

  void _initChatSocket() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    final token = await AuthService().getToken();
    if (token != null && authProvider.user != null) {
      chatProvider.setUserId(authProvider.user!.id!);
      chatProvider.connectSocket(token);
      chatProvider.fetchConversations();
      
      notifProvider.setSocket(chatProvider.socket);
      notifProvider.fetchNotifications();
      
      chatProvider.removeListener(_handleIncomingCallChange);
      chatProvider.addListener(_handleIncomingCallChange);
    }
  }

  void _handleIncomingCallChange() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.incomingCallData != null) {
      final callData = chatProvider.incomingCallData!;
      chatProvider.clearIncomingCall();

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => IncomingCallDialog(callData: callData),
      );
    }
  }

  @override
  void dispose() {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.removeListener(_handleIncomingCallChange);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GenerateRoadmapScreen()),
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
                      onTap: onTabTapped,
                    ),
                    _NavItem(
                      icon: Icons.school_outlined,
                      activeIcon: Icons.school_rounded,
                      label: 'Experts',
                      index: 1, 
                      currentIndex: _currentIndex,
                      onTap: onTabTapped,
                    ),
                    const SizedBox(width: 56),
                    _NavItem(
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Community',
                      index: 2,
                      currentIndex: _currentIndex,
                      onTap: onTabTapped,
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      index: 3,
                      currentIndex: _currentIndex,
                      onTap: onTabTapped,
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

  void onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }
}

// Make _NavItem const constructor for performance
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

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  final _aiQueryController = TextEditingController();
  bool _isFetchingAi = false;
  String? _aiResponse;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final roadmapProvider = Provider.of<RoadmapProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final expertProvider = Provider.of<ExpertProvider>(context, listen: false);

    await Future.wait([
      roadmapProvider.fetchMyRoadmap(),
      bookingProvider.fetchMyBookings(),
      notificationProvider.fetchNotifications(),
      expertProvider.fetchExperts(),
    ]);

    // Update progress animation after roadmap loads
    final roadmap = roadmapProvider.myRoadmap;
    if (roadmap != null && roadmap.totalSteps > 0) {
      final progress = roadmap.completedSteps / roadmap.totalSteps;
      _progressAnim = Tween<double>(begin: 0, end: progress).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _aiQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<RoadmapProvider, BookingProvider, NotificationProvider, ExpertProvider>(
      builder: (context, roadmapProvider, bookingProvider, notificationProvider, expertProvider, _) {
        final authProvider = Provider.of<AuthProvider>(context);
        final userName = authProvider.user?.name.split(' ').first ?? 'User';
        final roadmap = roadmapProvider.myRoadmap;
        final upcomingBookings = bookingProvider.upcomingBookings;
        final recentMentors = expertProvider.experts.take(4).toList();
        final notifications = notificationProvider.notifications.take(3).toList();

        final roadmapProgress = roadmap?.totalSteps != null && roadmap!.totalSteps > 0
            ? roadmap.completedSteps / roadmap.totalSteps
            : 0.0;

        if (_progressAnim.value != roadmapProgress && roadmapProgress > 0) {
          _progressAnim = Tween<double>(begin: _progressAnim.value, end: roadmapProgress).animate(
            CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
          );
          _progressController.forward(from: 0);
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(userName),
                const SizedBox(height: 24),
                _buildHeroSummary(roadmapProgress),
                const SizedBox(height: 22),
                _buildSearchBar(),
                const SizedBox(height: 22),
                _buildAiFetcher(),
                const SizedBox(height: 24),
                _buildSectionTitle('Upcoming Session', onMore: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                )),
                const SizedBox(height: 12),
                _buildUpcomingSession(upcomingBookings),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  'AI Roadmap Progress',
                  onMore: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyRoadmapScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _buildRoadmapProgress(roadmap, roadmapProgress),
                const SizedBox(height: 24),
                _buildSectionTitle('Notifications', onMore: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                )),
                const SizedBox(height: 12),
                _buildNotifications(notifications),
                const SizedBox(height: 24),
                _buildSectionTitle('Recent Mentors', onMore: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExpertListingScreen()),
                )),
                const SizedBox(height: 12),
                _buildRecentMentors(recentMentors),
                const SizedBox(height: 24),
                _buildSectionTitle('Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Build a stronger skillset with guided mentor support.',
                style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          child: Stack(
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
              Consumer<NotificationProvider>(
                builder: (_, provider, _) {
                  if (provider.unreadCount == 0) return const SizedBox.shrink();
                  return Positioned(
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
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Consumer<AuthProvider>(
            builder: (_, authProvider, _) {
              final avatarUrl = authProvider.user?.profileImage;
              return Container(
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
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? ClipOval(child: Image.network(avatarUrl, fit: BoxFit.cover))
                    : const Icon(Icons.person_rounded, color: AppColors.white, size: 26),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSummary(double roadmapProgress) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role.apiValue.capitalize() ?? 'Learner';
    
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
                child: Text(
                  userRole,
                  style: const TextStyle(
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
                '${(roadmapProgress * 100).toInt()}% completed',
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
              value: roadmapProgress,
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
                  controller: _aiQueryController,
                  onChanged: (value) => setState(() {}),
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
                  onPressed: _aiQueryController.text.trim().isEmpty || _isFetchingAi
                      ? null
                      : _fetchAiSuggestion,
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
      if (mounted) {
        setState(() {
          _isFetchingAi = false;
          _aiResponse =
              'AI suggests: Focus on ${_aiQueryController.text.trim().isEmpty ? 'goal alignment' : _aiQueryController.text.trim()}, review top mentor profiles, and schedule a 30-minute session this week.';
        });
      }
    });
  }

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

  Widget _buildUpcomingSession(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
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
        child: const Center(
          child: Text(
            'No upcoming sessions',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ),
      );
    }

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
        children: bookings.take(2).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final booking = entry.value;
          return <Widget>[
            _sessionRow(
              name: booking.expertName ?? 'Expert',
              topic: booking.topic,
              time: _formatBookingTime(booking),
              type: booking.sessionType,
              avatarColor: _getAvatarColor(booking.expertId),
              showJoin: booking.status == 'confirmed' && index == 0,
            ),
            if (index < bookings.length - 1)
              Divider(height: 20, color: AppColors.line),
          ];
        }).expand((i) => i).toList(),
      ),
    );
  }

  String _formatBookingTime(BookingModel booking) {
    // Format date and time
    return '${booking.date?.substring(0, 10) ?? ''} • ${booking.timeSlot}';
  }

  Color _getAvatarColor(int expertId) {
    final colors = [
      const Color(0xFF5C6BC0),
      const Color(0xFFEC407A),
      const Color(0xFF26A69A),
      const Color(0xFFFF7043),
    ];
    return colors[expertId % colors.length];
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

  Widget _buildRoadmapProgress(RoadmapModel? roadmap, double progress) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roadmap?.title ?? 'Flutter Developer',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${roadmap?.totalWeeks ?? 16} Weeks Plan',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                if (roadmap?.phases != null) ...[
                  ...roadmap!.phases.take(3).map((phase) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _progressStep(phase.title, phase.isCompleted),
                  )),
                  const SizedBox(height: 12),
                ],
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RoadmapPhaseDetailScreen(phaseId: 3),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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

  Widget _buildNotifications(List<dynamic> notifications) {
    if (notifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: const Text(
          'No notifications yet',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      );
    }

    return Column(
      children: notifications.map((n) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(n);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _NotificationCard(
            icon: _getNotificationIcon(data['type']),
            color: _getNotificationColor(data['type']),
            bgColor: _getNotificationBgColor(data['type']),
            title: data['title'] ?? 'Notification',
            subtitle: data['message'] ?? '',
            time: data['createdAt'] ?? 'Just now',
          ),
        );
      }).toList(),
    );
  }

  IconData _getNotificationIcon(dynamic type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'roadmap':
        return Icons.route_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(dynamic type) {
    switch (type) {
      case 'booking':
        return AppColors.primary;
      case 'review':
        return Colors.amber;
      case 'roadmap':
        return Colors.deepPurple;
      default:
        return AppColors.primary;
    }
  }

  Color _getNotificationBgColor(dynamic type) {
    switch (type) {
      case 'booking':
        return AppColors.primarySoft;
      case 'review':
        return const Color(0xFFFFF8E1);
      case 'roadmap':
        return const Color(0xFFF3E5F5);
      default:
        return AppColors.primarySoft;
    }
  }

  Widget _buildRecentMentors(List<ExpertModel> mentors) {
    if (mentors.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: mentors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _MentorCard(
          expert: mentors[i],
          avatarColor: _getAvatarColor(mentors[i].expertId),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _QuickActionCard(
          icon: Icons.search_rounded,
          label: 'Find Expert',
          color: AppColors.primary,
          bgColor: AppColors.primarySoft,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExpertListingScreen()),
          ),
        ),
        const SizedBox(width: 12),
        _QuickActionCard(
          icon: Icons.public_rounded,
          label: 'Community',
          color: Colors.deepPurple,
          bgColor: const Color(0xFFF3E5F5),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CommunityScreen()),
          ),
        ),
        const SizedBox(width: 12),
        _QuickActionCard(
          icon: Icons.route_rounded,
          label: 'Roadmap',
          color: Colors.teal,
          bgColor: const Color(0xFFE0F2F1),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyRoadmapScreen()),
          ),
        ),
        const SizedBox(width: 12),
        _QuickActionCard(
          icon: Icons.chat_bubble_rounded,
          label: 'Chat',
          color: Colors.orange,
          bgColor: const Color(0xFFFFF3E0),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ConversationsScreen()),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationCard({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

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
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  final ExpertModel expert;
  final Color avatarColor;
  final VoidCallback onTap;

  const _MentorCard({
    required this.expert,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tags = expert.skills.take(2).toList();
    final rating = expert.rating.toStringAsFixed(1);
    final hasImage = expert.profileImage != null && expert.profileImage!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo area ──────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: hasImage
                      ? Image.network(
                          expert.profileImage!,
                          width: 165,
                          height: 118,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _avatarPlaceholder(),
                        )
                      : _avatarPlaceholder(),
                ),
                // Rating badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7B6000),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // ── Info area ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expert.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    expert.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 165,
      height: 118,
      color: avatarColor.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          expert.name.isNotEmpty ? expert.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: avatarColor,
          ),
        ),
      ),
    );
  }
}

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

class _ExpertsTab extends StatelessWidget {
  const _ExpertsTab();

  @override
  Widget build(BuildContext context) {
    return const ExpertListingScreen();
  }
}

class IncomingCallDialog extends StatelessWidget {
  final Map<String, dynamic> callData;

  const IncomingCallDialog({super.key, required this.callData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Incoming Call'),
      content: Text('Incoming call from ${callData['callerName'] ?? 'Unknown'}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Reject'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Handle call accept
          },
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
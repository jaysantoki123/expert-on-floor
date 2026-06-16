import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════
// Data Model
// ══════════════════════════════════════════════════════════════════
class SessionModel {
  final String id;
  final String expertName;
  final String expertRole;
  final String topic;
  final String date;
  final String time;
  final String duration;
  final String type;
  final String status;
  final int price;
  final Color avatarColor;
  final double? rating;
  final String? review;
  final bool hasRecording;
  final List<String> tags;

  const SessionModel({
    required this.id,
    required this.expertName,
    required this.expertRole,
    required this.topic,
    required this.date,
    required this.time,
    required this.duration,
    required this.type,
    required this.status,
    required this.price,
    required this.avatarColor,
    this.rating,
    this.review,
    this.hasRecording = false,
    this.tags = const [],
  });
}

final List<SessionModel> _allSessions = [
  SessionModel(
    id: '1',
    expertName: 'Rahul Sharma',
    expertRole: 'Senior Flutter Developer',
    topic: 'Flutter State Management',
    date: '10 May, 2026',
    time: '6:00 PM',
    duration: '60 min',
    type: 'Video Call',
    status: 'completed',
    price: 999,
    avatarColor: const Color(0xFF5C6BC0),
    rating: 5.0,
    review: 'Amazing session! Rahul explained Provider very clearly.',
    hasRecording: true,
    tags: ['Flutter', 'State Management', 'Provider'],
  ),
  SessionModel(
    id: '2',
    expertName: 'Sneha Iyer',
    expertRole: 'UI/UX Designer',
    topic: 'Figma Fundamentals & Design Systems',
    date: '5 May, 2026',
    time: '3:00 PM',
    duration: '45 min',
    type: 'Video Call',
    status: 'completed',
    price: 599,
    avatarColor: const Color(0xFFEC407A),
    rating: 4.5,
    review: 'Great insights on design systems.',
    hasRecording: false,
    tags: ['UI/UX', 'Figma', 'Design'],
  ),
  SessionModel(
    id: '3',
    expertName: 'Amit Verma',
    expertRole: 'Full Stack Developer',
    topic: 'React Native Navigation',
    date: '1 May, 2026',
    time: '11:00 AM',
    duration: '60 min',
    type: 'Audio Call',
    status: 'completed',
    price: 799,
    avatarColor: const Color(0xFF26A69A),
    rating: 4.0,
    hasRecording: false,
    tags: ['React Native', 'Navigation'],
  ),
  SessionModel(
    id: '4',
    expertName: 'Vikram Patel',
    expertRole: 'AI/ML Engineer',
    topic: 'Introduction to Machine Learning',
    date: '28 Apr, 2026',
    time: '2:00 PM',
    duration: '90 min',
    type: 'Video Call',
    status: 'completed',
    price: 1799,
    avatarColor: const Color(0xFFFF7043),
    rating: 5.0,
    review: 'Mind-blowing session! Best investment ever.',
    hasRecording: true,
    tags: ['AI', 'ML', 'Python'],
  ),
  SessionModel(
    id: '5',
    expertName: 'Priya Nair',
    expertRole: 'Data Scientist',
    topic: 'Data Visualization with Tableau',
    date: '22 Apr, 2026',
    time: '10:00 AM',
    duration: '60 min',
    type: 'Video Call',
    status: 'cancelled',
    price: 899,
    avatarColor: const Color(0xFF7E57C2),
    tags: ['Data Science', 'Tableau'],
  ),
  SessionModel(
    id: '6',
    expertName: 'Arjun Mehta',
    expertRole: 'DevOps Engineer',
    topic: 'Docker & Kubernetes Basics',
    date: '18 Apr, 2026',
    time: '4:00 PM',
    duration: '60 min',
    type: 'Video Call',
    status: 'completed',
    price: 699,
    avatarColor: const Color(0xFF29B6F6),
    rating: 4.5,
    hasRecording: true,
    tags: ['DevOps', 'Docker', 'Kubernetes'],
  ),
  SessionModel(
    id: '7',
    expertName: 'Kavya Reddy',
    expertRole: 'iOS Developer',
    topic: 'SwiftUI Animations',
    date: '12 Apr, 2026',
    time: '1:00 PM',
    duration: '30 min',
    type: 'Audio Call',
    status: 'completed',
    price: 549,
    avatarColor: const Color(0xFF66BB6A),
    rating: 5.0,
    review: 'Very detailed and practical explanation!',
    hasRecording: false,
    tags: ['iOS', 'Swift', 'Animation'],
  ),
  SessionModel(
    id: '8',
    expertName: 'Rahul Sharma',
    expertRole: 'Senior Flutter Developer',
    topic: 'Flutter Animations Deep Dive',
    date: '5 Apr, 2026',
    time: '5:00 PM',
    duration: '90 min',
    type: 'Video Call',
    status: 'completed',
    price: 1499,
    avatarColor: const Color(0xFF5C6BC0),
    rating: 5.0,
    review: 'Exceptional! Learned so much about animations.',
    hasRecording: true,
    tags: ['Flutter', 'Animations'],
  ),
  SessionModel(
    id: '9',
    expertName: 'Rohan Gupta',
    expertRole: 'Blockchain Developer',
    topic: 'Smart Contracts with Solidity',
    date: '28 Mar, 2026',
    time: '6:00 PM',
    duration: '60 min',
    type: 'Video Call',
    status: 'cancelled',
    price: 1299,
    avatarColor: const Color(0xFFFFA726),
    tags: ['Blockchain', 'Solidity'],
  ),
];

// ══════════════════════════════════════════════════════════════════
// Session History Screen
// ══════════════════════════════════════════════════════════════════
class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animCtrl;

  String _sortBy = 'Newest First';
  String _filterType = 'All';
  bool _showSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final _sortOptions = [
    'Newest First',
    'Oldest First',
    'Price: High to Low',
    'Price: Low to High',
    'Highest Rated',
  ];

  final _typeFilters = ['All', 'Video Call', 'Audio Call', 'Chat'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtered lists ─────────────────────────────────────────────
  List<SessionModel> _applyFilters(List<SessionModel> sessions) {
    List<SessionModel> result = List.from(sessions);

    // Search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (s) =>
                s.expertName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                s.topic.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.tags.any(
                  (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
                ),
          )
          .toList();
    }

    // Type filter
    if (_filterType != 'All') {
      result = result.where((s) => s.type == _filterType).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Newest First':
        result = result.reversed.toList();
        break;
      case 'Oldest First':
        break;
      case 'Price: High to Low':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Price: Low to High':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Highest Rated':
        result.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }

    return result;
  }

  List<SessionModel> get _completed => _applyFilters(
    _allSessions.where((s) => s.status == 'completed').toList(),
  );
  List<SessionModel> get _cancelled => _applyFilters(
    _allSessions.where((s) => s.status == 'cancelled').toList(),
  );

  // ── Summary Stats ──────────────────────────────────────────────
  int get _totalSessions =>
      _allSessions.where((s) => s.status == 'completed').length;
  int get _totalMinutes =>
      _allSessions.where((s) => s.status == 'completed').fold(0, (sum, s) {
        final min = int.tryParse(s.duration.replaceAll(' min', '')) ?? 0;
        return sum + min;
      });
  int get _totalSpent => _allSessions
      .where((s) => s.status == 'completed')
      .fold(0, (sum, s) => sum + s.price);
  double get _avgRating {
    final rated = _allSessions.where((s) => s.rating != null).toList();
    if (rated.isEmpty) return 0;
    return rated.fold(0.0, (sum, s) => sum + s.rating!) / rated.length;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────
              _buildHeader(),

              // ── Stats Banner ─────────────────────
              _buildStatsBanner(),

              // ── Search bar ───────────────────────
              if (_showSearch) _buildSearchBar(),

              // ── Filter row ───────────────────────
              _buildFilterRow(),

              // ── Tab bar ──────────────────────────
              _buildTabBar(),

              // ── Tab content ──────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _SessionList(
                      sessions: _applyFilters(_allSessions),
                      emptyLabel: 'No sessions found',
                      onRate: _showRatingSheet,
                      onRebook: _showRebookConfirm,
                    ),
                    _SessionList(
                      sessions: _completed,
                      emptyLabel: 'No completed sessions',
                      onRate: _showRatingSheet,
                      onRebook: _showRebookConfirm,
                    ),
                    _SessionList(
                      sessions: _cancelled,
                      emptyLabel: 'No cancelled sessions',
                      onRate: _showRatingSheet,
                      onRebook: _showRebookConfirm,
                    ),
                  ],
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
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                  'Session History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'All your past sessions',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          // Search toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchCtrl.clear();
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showSearch ? AppColors.primarySoft : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showSearch ? AppColors.primary : AppColors.line,
                ),
              ),
              child: Icon(
                _showSearch ? Icons.close_rounded : Icons.search_rounded,
                color: _showSearch ? AppColors.primary : AppColors.ink,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sort
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.sort_rounded,
                color: AppColors.ink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Stats Banner
  // ══════════════════════════════════════════════════════════════
  Widget _buildStatsBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:  0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:  0.06),
              ),
            ),
          ),
          Row(
            children: [
              _BannerStat(
                value: '$_totalSessions',
                label: 'Sessions',
                icon: Icons.videocam_rounded,
              ),
              _bannerDivider(),
              _BannerStat(
                value: '${(_totalMinutes / 60).toStringAsFixed(1)}h',
                label: 'Hours',
                icon: Icons.access_time_rounded,
              ),
              _bannerDivider(),
              _BannerStat(
                value: '₹$_totalSpent',
                label: 'Invested',
                icon: Icons.currency_rupee_rounded,
              ),
              _bannerDivider(),
              _BannerStat(
                value: _avgRating.toStringAsFixed(1),
                label: 'Avg Rating',
                icon: Icons.star_rounded,
                iconColor: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha:  0.2),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Search Bar
  // ══════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:  0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Search sessions, experts, topics...',
                  hintStyle: TextStyle(
                    color: AppColors.muted.withValues(alpha:  0.7),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () => _searchCtrl.clear(),
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.muted,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Filter Row
  // ══════════════════════════════════════════════════════════════
  Widget _buildFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: _typeFilters.map((f) {
          final selected = _filterType == f;
          return GestureDetector(
            onTap: () => setState(() => _filterType = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.line,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha:  0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    f == 'Video Call'
                        ? Icons.videocam_rounded
                        : f == 'Audio Call'
                        ? Icons.call_rounded
                        : f == 'Chat'
                        ? Icons.chat_rounded
                        : Icons.all_inclusive_rounded,
                    size: 13,
                    color: selected ? AppColors.white : AppColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    f,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.white : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Tab Bar
  // ══════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Container(
        height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.muted,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: Colors.transparent,
          tabs: [
            _tabItem('All', _allSessions.length),
            _tabItem('Completed', _completed.length),
            _tabItem('Cancelled', _cancelled.length),
          ],
        ),
      ),
    );
  }

  Tab _tabItem(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:  0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Actions
  // ══════════════════════════════════════════════════════════════
  void _showSortSheet() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sort Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map((opt) {
              final sel = _sortBy == opt;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.line,
                      width: 2,
                    ),
                  ),
                  child: sel
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 13,
                        )
                      : null,
                ),
                title: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                    color: sel ? AppColors.primary : AppColors.ink,
                  ),
                ),
                onTap: () {
                  setState(() => _sortBy = opt);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRatingSheet(SessionModel session) {
    if (session.rating != null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RatingSheet(session: session),
    );
  }

  void _showRebookConfirm(SessionModel session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RebookSheet(session: session),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Banner Stat Widget
// ══════════════════════════════════════════════════════════════════
class _BannerStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _BannerStat({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha:  0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Session List
// ══════════════════════════════════════════════════════════════════
class _SessionList extends StatelessWidget {
  final List<SessionModel> sessions;
  final String emptyLabel;
  final Function(SessionModel) onRate;
  final Function(SessionModel) onRebook;

  const _SessionList({
    required this.sessions,
    required this.emptyLabel,
    required this.onRate,
    required this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing filters or search',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      physics: const BouncingScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + i * 60),
          curve: Curves.easeOutCubic,
          builder: (_, val, child) => Opacity(
            opacity: val,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - val)),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _SessionCard(
              session: sessions[i],
              onRate: () => onRate(sessions[i]),
              onRebook: () => onRebook(sessions[i]),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Session Card
// ══════════════════════════════════════════════════════════════════
class _SessionCard extends StatefulWidget {
  final SessionModel session;
  final VoidCallback onRate;
  final VoidCallback onRebook;

  const _SessionCard({
    required this.session,
    required this.onRate,
    required this.onRebook,
  });

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _expanded = false;

  Color get _statusColor {
    switch (widget.session.status) {
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return AppColors.muted;
    }
  }

  IconData get _statusIcon {
    switch (widget.session.status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  IconData get _typeIcon {
    switch (widget.session.type) {
      case 'Video Call':
        return Icons.videocam_rounded;
      case 'Audio Call':
        return Icons.call_rounded;
      default:
        return Icons.chat_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _expanded
              ? AppColors.primary.withValues(alpha:  0.4)
              : AppColors.line,
          width: _expanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  _expanded ? 0.08 : 0.04),
            blurRadius: _expanded ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Main Row ─────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: session.avatarColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: session.avatarColor.withValues(alpha:  0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                session.expertName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor.withValues(alpha:  0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon,
                                    color: _statusColor,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    session.status[0].toUpperCase() +
                                        session.status.substring(1),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Role
                        Text(
                          session.expertRole,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Topic
                        Text(
                          session.topic,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Meta chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _MetaChip(
                              icon: Icons.calendar_today_rounded,
                              label: session.date,
                              color: AppColors.primary,
                            ),
                            _MetaChip(
                              icon: Icons.access_time_rounded,
                              label: '${session.time} • ${session.duration}',
                              color: Colors.deepPurple,
                            ),
                            _MetaChip(
                              icon: _typeIcon,
                              label: session.type,
                              color: Colors.teal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Bottom row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Price
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${session.price}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                            // Rating stars
                            if (session.rating != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < session.rating!.floor()
                                        ? Icons.star_rounded
                                        : i < session.rating!.ceil()
                                        ? Icons.star_half_rounded
                                        : Icons.star_border_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                ),
                              )
                            else if (session.status == 'completed')
                              GestureDetector(
                                onTap: widget.onRate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha:  0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.amber.withValues(alpha:  0.4),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_outline_rounded,
                                        color: Colors.amber,
                                        size: 12,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        'Rate',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Recording badge
                            if (session.hasRecording)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha:  0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(alpha:  0.3),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fiber_manual_record,
                                      color: Colors.redAccent,
                                      size: 8,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'REC',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Expand icon
                            Icon(
                              _expanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppColors.muted,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Section ──────────────────────
          if (_expanded) ...[
            Divider(height: 1, color: AppColors.line),
            _buildExpandedSection(session),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedSection(SessionModel session) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          if (session.tags.isNotEmpty) ...[
            const Text(
              'Topics Covered',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: session.tags.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha:  0.3),
                    ),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Review
          if (session.review != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha:  0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💬', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"${session.review}"',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.ink,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action buttons
          Row(
            children: [
              if (session.hasRecording)
                Expanded(
                  child: _actionBtn(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Watch Recording',
                    color: Colors.deepPurple,
                    onTap: () {},
                  ),
                ),
              if (session.hasRecording) const SizedBox(width: 8),
              Expanded(
                child: _actionBtn(
                  icon: Icons.refresh_rounded,
                  label: 'Book Again',
                  color: AppColors.primary,
                  onTap: widget.onRebook,
                  filled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha:  0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: filled ? color : color.withValues(alpha:  0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? Colors.white : color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Meta Chip
// ══════════════════════════════════════════════════════════════════
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Rating Sheet
// ══════════════════════════════════════════════════════════════════
class _RatingSheet extends StatefulWidget {
  final SessionModel session;
  const _RatingSheet({required this.session});

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _hoveredStar = 0;
  int _selectedStar = 0;
  final _reviewCtrl = TextEditingController();
  bool _loading = false;

  final _quickReviews = [
    'Very helpful! 🙌',
    'Great explanation! 📚',
    'Highly recommend! ⭐',
    'Learned a lot! 🚀',
  ];

  @override
  void dispose() {
    _reviewCtrl.dispose();
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Expert info
            CircleAvatar(
              radius: 30,
              backgroundColor: widget.session.avatarColor,
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Rate your session with',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            Text(
              widget.session.expertName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 20),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedStar = i + 1),
                  onTapDown: (_) => setState(() => _hoveredStar = i + 1),
                  onTapCancel: () => setState(() => _hoveredStar = 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedScale(
                      scale: (_hoveredStar == i + 1 || _selectedStar >= i + 1)
                          ? 1.2
                          : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        _selectedStar > i
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStar == 0
                  ? 'Tap to rate'
                  : _selectedStar == 1
                  ? 'Poor'
                  : _selectedStar == 2
                  ? 'Fair'
                  : _selectedStar == 3
                  ? 'Good'
                  : _selectedStar == 4
                  ? 'Great'
                  : 'Excellent! 🎉',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _selectedStar > 0 ? Colors.amber : AppColors.muted,
              ),
            ),
            const SizedBox(height: 20),

            // Quick reviews
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickReviews.map((r) {
                return GestureDetector(
                  onTap: () => _reviewCtrl.text = r,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      r,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Review text
            TextField(
              controller: _reviewCtrl,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Share your experience... (optional)',
                hintStyle: TextStyle(
                  color: AppColors.muted.withValues(alpha:  0.7),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.field,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedStar == 0 || _loading
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
                                'Review submitted! Thank you 🙏',
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
                  disabledBackgroundColor: AppColors.line,
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
                        'Submit Review',
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
}

// ══════════════════════════════════════════════════════════════════
// Rebook Sheet
// ══════════════════════════════════════════════════════════════════
class _RebookSheet extends StatelessWidget {
  final SessionModel session;
  const _RebookSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
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

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Book Again?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rebook a session with ${session.expertName}\nfor "${session.topic}"?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Booking request sent to ${session.expertName}!',
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Book Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'expert_booking_detail_screen.dart';

class ExpertBookingsScreen extends StatefulWidget {
  const ExpertBookingsScreen({super.key});

  @override
  State<ExpertBookingsScreen> createState() => _ExpertBookingsScreenState();
}

class _ExpertBookingsScreenState extends State<ExpertBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // Static mockup data
  final List<ExpertBookingData> _allBookings = [
    ExpertBookingData(
      id: '1',
      learnerName: 'Priya Mehta',
      topic: 'Career Guidance & Interview Prep',
      date: '15 Oct, 2026',
      time: '11:00 AM',
      durationMinutes: 45,
      amount: 1500,
      status: 'CONFIRMED',
      sessionType: 'Video Call',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
    ),
    ExpertBookingData(
      id: '2',
      learnerName: 'Amit Verma',
      topic: 'Flutter State Management',
      date: '15 Oct, 2026',
      time: '02:00 PM',
      durationMinutes: 60,
      amount: 2000,
      status: 'PENDING',
      sessionType: 'Video Call',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150',
    ),
    ExpertBookingData(
      id: '3',
      learnerName: 'Sneha Iyer',
      topic: 'Resume Review',
      date: '16 Oct, 2026',
      time: '10:00 AM',
      durationMinutes: 30,
      amount: 800,
      status: 'CONFIRMED',
      sessionType: 'Audio Call',
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=150',
    ),
    ExpertBookingData(
      id: '4',
      learnerName: 'Rahul Sharma',
      topic: 'System Architecture',
      date: '10 Oct, 2026',
      time: '04:00 PM',
      durationMinutes: 60,
      amount: 2500,
      status: 'COMPLETED',
      sessionType: 'Video Call',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150',
    ),
    ExpertBookingData(
      id: '5',
      learnerName: 'Anjali Desai',
      topic: 'Code Review for MVP',
      date: '12 Oct, 2026',
      time: '06:00 PM',
      durationMinutes: 45,
      amount: 1500,
      status: 'CANCELLED',
      sessionType: 'Video Call',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter by search query
    final filtered = _allBookings.where((b) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return b.learnerName.toLowerCase().contains(query) ||
          b.topic.toLowerCase().contains(query) ||
          b.sessionType.toLowerCase().contains(query);
    }).toList();

    // Group by status logic for tabs
    final upcoming = filtered.where((b) {
      return b.status == 'CONFIRMED' || b.status == 'PENDING';
    }).toList();

    final past = filtered.where((b) {
      return b.status == 'COMPLETED';
    }).toList();

    final cancelled = filtered.where((b) {
      return b.status == 'CANCELLED' || b.status == 'REJECTED';
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (_showSearch) _buildSearchBar(),
              _buildTabBar(upcoming.length),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(upcoming, isUpcomingTab: true),
                    _buildList(past),
                    _buildList(cancelled),
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
    final canPop = Navigator.canPop(context);
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          if (canPop) ...[
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
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learner Sessions',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Manage your scheduled bookings',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Search
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
                color: _showSearch ? AppColors.primarySoft : AppColors.field,
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
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Tab Bar
  // ══════════════════════════════════════════════════════════════
  Widget _buildTabBar(int upcomingCount) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
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
            Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Upcoming'),
                    const SizedBox(width: 4),
                    _tabBadge('$upcomingCount'),
                  ],
                ),
              ),
            ),
            const Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Past'),
              ),
            ),
            const Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Cancelled'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Search Bar
  // ══════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        style: const TextStyle(fontSize: 14, color: AppColors.ink),
        decoration: InputDecoration(
          hintText: 'Search learners, topics...',
          hintStyle: TextStyle(
            color: AppColors.muted.withValues(alpha: 0.7),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // List Builder
  // ══════════════════════════════════════════════════════════════
  Widget _buildList(List<ExpertBookingData> bookings,
      {bool isUpcomingTab = false}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No sessions found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ExpertBookingCard(
        data: bookings[i],
        isUpcomingTab: isUpcomingTab,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Card Widget
// ══════════════════════════════════════════════════════════════════
class _ExpertBookingCard extends StatelessWidget {
  final ExpertBookingData data;
  final bool isUpcomingTab;

  const _ExpertBookingCard({
    required this.data,
    this.isUpcomingTab = false,
  });

  Color get _statusColor {
    switch (data.status) {
      case 'CONFIRMED':
        return AppColors.primary;
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELLED':
      case 'REJECTED':
        return Colors.redAccent;
      default:
        return AppColors.muted;
    }
  }

  String _formatStatusLabel(String statusVal) {
    switch (statusVal) {
      case 'PENDING':
        return 'Pending Approval';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'REJECTED':
        return 'Rejected';
      default:
        return statusVal;
    }
  }

  Color _getDeterministicColor(String name) {
    final colors = [
      const Color(0xFF5C6BC0),
      const Color(0xFFEC407A),
      const Color(0xFFFF7043),
      const Color(0xFF26A69A),
      const Color(0xFF7E57C2),
    ];
    int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getDeterministicColor(data.learnerName);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExpertBookingDetailScreen(data: data),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
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
          // ── Header ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cardColor,
                  backgroundImage: data.avatarUrl.isNotEmpty
                      ? NetworkImage(data.avatarUrl)
                      : null,
                  child: data.avatarUrl.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.learnerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.topic.isNotEmpty ? data.topic : 'General Session',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatStatusLabel(data.status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Details ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _detailChip(
                      Icons.calendar_today_rounded,
                      data.date,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _detailChip(
                      Icons.access_time_rounded,
                      data.time,
                      Colors.deepPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _detailChip(
                      Icons.videocam_rounded,
                      data.sessionType,
                      Colors.teal,
                    ),
                  ],
                ),
                if (isUpcomingTab) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.line),
                  ),
                  // Actions based on status
                  if (data.status == 'PENDING')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Reject',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Accept',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (data.status == 'CONFIRMED')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Cancel'),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.muted,
                              side: const BorderSide(color: AppColors.line),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.videocam_rounded,
                                size: 16, color: Colors.white),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Join Session',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _detailChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Data Model
// ══════════════════════════════════════════════════════════════════
class ExpertBookingData {
  final String id;
  final String learnerName;
  final String topic;
  final String date;
  final String time;
  final int durationMinutes;
  final double amount;
  final String status;
  final String sessionType;
  final String avatarUrl;

  ExpertBookingData({
    required this.id,
    required this.learnerName,
    required this.topic,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.amount,
    required this.status,
    required this.sessionType,
    required this.avatarUrl,
  });
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _upcoming = [
    _BookingData(
      expertName: 'Rahul Sharma',
      topic: 'Flutter State Management',
      date: '17 May, 2026',
      time: '6:00 PM',
      duration: '60 min',
      type: 'Video Call',
      status: 'confirmed',
      price: 999,
      color: const Color(0xFF5C6BC0),
    ),
    _BookingData(
      expertName: 'Sneha Iyer',
      topic: 'UI/UX Fundamentals',
      date: '19 May, 2026',
      time: '3:00 PM',
      duration: '30 min',
      type: 'Audio Call',
      status: 'pending',
      price: 399,
      color: const Color(0xFFEC407A),
    ),
    _BookingData(
      expertName: 'Vikram Patel',
      topic: 'AI/ML Basics',
      date: '22 May, 2026',
      time: '11:00 AM',
      duration: '90 min',
      type: 'Video Call',
      status: 'confirmed',
      price: 1799,
      color: const Color(0xFFFF7043),
    ),
  ];

  final _past = [
    _BookingData(
      expertName: 'Amit Verma',
      topic: 'React Native Basics',
      date: '10 May, 2026',
      time: '4:00 PM',
      duration: '60 min',
      type: 'Video Call',
      status: 'completed',
      price: 799,
      color: const Color(0xFF26A69A),
    ),
    _BookingData(
      expertName: 'Rahul Sharma',
      topic: 'Dart Programming',
      date: '5 May, 2026',
      time: '2:00 PM',
      duration: '60 min',
      type: 'Video Call',
      status: 'completed',
      price: 999,
      color: const Color(0xFF5C6BC0),
    ),
  ];

  final _cancelled = [
    _BookingData(
      expertName: 'Priya Nair',
      topic: 'Data Science Intro',
      date: '3 May, 2026',
      time: '10:00 AM',
      duration: '60 min',
      type: 'Video Call',
      status: 'cancelled',
      price: 899,
      color: const Color(0xFF7E57C2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.ink,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Upcoming'),
                        const SizedBox(width: 4),
                        _tabBadge('${_upcoming.length}'),
                      ],
                    ),
                  ),
                  const Tab(text: 'Past'),
                  const Tab(text: 'Cancelled'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_upcoming),
          _buildList(_past),
          _buildList(_cancelled),
        ],
      ),
    );
  }

  Widget _tabBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:  0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildList(List<_BookingData> bookings) {
    if (bookings.isEmpty) {
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
                Icons.calendar_today_rounded,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No bookings found',
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
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _BookingCard(data: bookings[i]),
    );
  }
}

class _BookingData {
  final String expertName;
  final String topic;
  final String date;
  final String time;
  final String duration;
  final String type;
  final String status;
  final int price;
  final Color color;

  const _BookingData({
    required this.expertName,
    required this.topic,
    required this.date,
    required this.time,
    required this.duration,
    required this.type,
    required this.status,
    required this.price,
    required this.color,
  });
}

class _BookingCard extends StatelessWidget {
  final _BookingData data;
  const _BookingCard({required this.data});

  Color get _statusColor {
    switch (data.status) {
      case 'confirmed':
        return AppColors.primary;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return AppColors.muted;
    }
  }

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
        children: [
          // ── Header ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha:  0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: data.color,
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.expertName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.topic,
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha:  0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.status[0].toUpperCase() + data.status.substring(1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    _detailChip(
                      Icons.timer_outlined,
                      data.duration,
                      Colors.teal,
                    ),
                    const SizedBox(width: 8),
                    _detailChip(
                      Icons.videocam_outlined,
                      data.type,
                      Colors.orange,
                    ),
                    const Spacer(),
                    Text(
                      '₹${data.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (data.status == 'confirmed') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'Join Session',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
    );
  }

  Widget _detailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

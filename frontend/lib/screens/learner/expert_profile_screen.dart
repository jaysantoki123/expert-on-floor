import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../models/expert_model.dart';
import 'booking_summary_screen.dart';

class ExpertProfileScreen extends StatefulWidget {
  final ExpertModel expert;

  const ExpertProfileScreen({super.key, required this.expert});

  @override
  State<ExpertProfileScreen> createState() => _ExpertProfileScreenState();
}

class _ExpertProfileScreenState extends State<ExpertProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isBookmarked = false;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedDateStr;

  // Sample available dates
  final List<DateTime> _availableDates = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 1)),
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 5)),
    DateTime.now().add(const Duration(days: 7)),
  ];

  // Sample time slots by date
  final Map<String, List<String>> _timeSlots = {
    DateTime.now().toString().substring(0, 10): [
      '10:00 AM',
      '12:00 PM',
      '3:00 PM',
      '5:00 PM',
    ],
    DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10): [
      '11:00 AM',
      '2:00 PM',
      '4:00 PM',
    ],
    DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10): [
      '10:30 AM',
      '1:30 PM',
      '6:00 PM',
    ],
  };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkSoft,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeroHeader(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildTabBar(),
                    const SizedBox(height: 16),
                    _buildTabContent(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha:  0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: () => setState(() => _isBookmarked = !_isBookmarked),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha:  0.15),
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  key: ValueKey(_isBookmarked),
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha:  0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.primary.withValues(alpha:  0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha:  0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha:  0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withValues(alpha:  0.3),
                                width: 4,
                              ),
                            ),
                          ),
                          Container(
                            width: 95,
                            height: 95,
                            decoration: BoxDecoration(
                              color: widget.expert.avatarColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.expert.avatarColor.withValues(alpha:  0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: widget.expert.profileImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      widget.expert.profileImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 55,
                                  ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: widget.expert.isOnline
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.expert.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.expert.title,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.white.withValues(alpha:  0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _infoChip(
                          Icons.star_rounded,
                          '${widget.expert.rating}',
                          Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.workspace_premium_rounded,
                          widget.expert.experience,
                          AppColors.white,
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.location_on_rounded,
                          widget.expert.location.split(',').first,
                          AppColors.white,
                        ),
                      ],
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

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha:  0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withValues(alpha:  0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _actionButton(Icons.chat_bubble_outline_rounded, 'Message', AppColors.primary),
          const SizedBox(width: 12),
          _actionButton(Icons.call_outlined, 'Call', Colors.deepPurple),
          const SizedBox(width: 12),
          _actionButton(Icons.video_call_outlined, 'Video', Colors.teal),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          indicator: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.ink,
          unselectedLabelColor: AppColors.muted,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'About'),
            Tab(text: 'Reviews'),
            Tab(text: 'Sessions'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          switch (_tabController.index) {
            case 0:
              return _buildAboutTab();
            case 1:
              return _buildReviewsTab();
            case 2:
              return _buildSessionsTab();
            default:
              return _buildAboutTab();
          }
        },
      ),
    );
  }

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('About Me'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  0.04),
                blurRadius: 12,
              ),
            ],
          ),
          child: Text(
            widget.expert.bio,
            style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.7),
          ),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Skills'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.expert.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.02),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                skill,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Services'),
        const SizedBox(height: 10),
        ...widget.expert.services.map((service) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:  0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.design_services_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        _sectionLabel('Current Company'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.expert.company,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.expert.title,
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    final reviews = [
      _ReviewData(
        name: 'Arjun K.',
        rating: 5,
        comment: 'Excellent mentor! Explained Flutter concepts very clearly. Highly recommend.',
        date: '12 May 2026',
        avatarColor: const Color(0xFF5C6BC0),
      ),
      _ReviewData(
        name: 'Priya M.',
        rating: 5,
        comment: 'Very knowledgeable and patient. Helped me debug a complex state management issue.',
        date: '8 May 2026',
        avatarColor: const Color(0xFFEC407A),
      ),
      _ReviewData(
        name: 'Rohan S.',
        rating: 4,
        comment: 'Great session! Very practical approach. Would book again.',
        date: '2 May 2026',
        avatarColor: const Color(0xFF26A69A),
      ),
      _ReviewData(
        name: 'Kavya R.',
        rating: 5,
        comment: 'Amazing experience. Learned more in 1 hour than in weeks of self-study.',
        date: '28 Apr 2026',
        avatarColor: const Color(0xFFFF7043),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingSummary(),
        const SizedBox(height: 20),
        _sectionLabel('All Reviews'),
        const SizedBox(height: 12),
        ...reviews.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewCard(review: r),
            )),
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '${widget.expert.rating}',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < widget.expert.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.expert.reviews} reviews',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final pct = star == 5
                    ? 0.75
                    : star == 4
                        ? 0.18
                        : star == 3
                            ? 0.05
                            : 0.02;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: AppColors.line,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(pct * 100).toInt()}%',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    final dateStr = _selectedDate.toString().substring(0, 10);
    final times = _timeSlots[dateStr] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Select Date'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            enabledDayPredicate: (day) {
              return _availableDates.any((d) => isSameDay(d, day));
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _selectedTime = null;
                _selectedDateStr = '${selectedDay.day} ${_getMonthName(selectedDay.month)}, ${selectedDay.year}';
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              disabledDecoration: const BoxDecoration(),
              disabledTextStyle: TextStyle(color: AppColors.muted.withValues(alpha: 0.3)),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
              leftChevronIcon: Icon(Icons.chevron_left_rounded, color: AppColors.ink),
              rightChevronIcon: Icon(Icons.chevron_right_rounded, color: AppColors.ink),
            ),
            calendarBuilders: CalendarBuilders(
              disabledBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(color: AppColors.muted.withValues(alpha: 0.3)),
                  ),
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                final isAvailable = _availableDates.any((d) => isSameDay(d, day));
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isAvailable ? AppColors.primarySoft.withValues(alpha: 0.3) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: isAvailable ? AppColors.primary : AppColors.muted, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        _sectionLabel('Available Slots'),
        const SizedBox(height: 12),
        if (times.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy_rounded, color: AppColors.muted, size: 48),
                const SizedBox(height: 12),
                Text(
                  'No slots available for this date',
                  style: TextStyle(fontSize: 14, color: AppColors.muted),
                ),
              ],
            ),
          )
        else
          ...times.map((time) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SlotCard(
                  slot: _SlotData(
                    date: '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}',
                    time: time,
                    duration: '60 min',
                    type: 'Video Call',
                  ),
                  isSelected: _selectedTime == time,
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                      _selectedDateStr = '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}';
                    });
                    // Automatically open the booking sheet with the selected slot
                    _showBookingSheet(context);
                  },
                ),
              )),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.ink,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showBookingSheet(context),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha:  0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Book Session',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _BookingSheet(
        expert: widget.expert,
        initialDate: _selectedDateStr,
        initialTime: _selectedTime,
        availableTimes: _timeSlots[_selectedDate.toString().substring(0, 10)] ?? [],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
    );
  }
}

class _ReviewData {
  final String name;
  final int rating;
  final String comment;
  final String date;
  final Color avatarColor;

  const _ReviewData({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    required this.avatarColor,
  });
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:  0.04), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: review.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                              i < review.rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 14,
                            )),
                        const SizedBox(width: 8),
                        Text(
                          review.date,
                          style: TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _SlotData {
  final String date;
  final String time;
  final String duration;
  final String type;

  const _SlotData({
    required this.date,
    required this.time,
    required this.duration,
    required this.type,
  });
}

class _SlotCard extends StatelessWidget {
  final _SlotData slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _SlotCard({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot.date.split(',')[0].split(' ')[0],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.white : AppColors.primary,
                    ),
                  ),
                  Text(
                    slot.date.split(' ')[1].replaceAll(',', ''),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.8)
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.time,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _slotTag(slot.duration, Icons.timer_outlined),
                      const SizedBox(width: 10),
                      _slotTag(slot.type, Icons.videocam_outlined),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.line,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotTag(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.muted)),
      ],
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final ExpertModel expert;
  final String? initialDate;
  final String? initialTime;
  final List<String> availableTimes;

  const _BookingSheet({
    required this.expert,
    this.initialDate,
    this.initialTime,
    required this.availableTimes,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String _selectedType = 'Video Call';
  String _selectedDuration = '60 min';
  String? _selectedTime;
  String? _selectedDate;

  final _types = ['Video Call', 'Audio Call', 'Chat'];
  final _durations = ['30 min', '60 min', '90 min'];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectedDate = widget.initialDate;
  }

  int get _totalPrice {
    final base = widget.expert.pricePerHour;
    if (_selectedDuration == '30 min') return (base * 0.5).toInt();
    if (_selectedDuration == '90 min') return (base * 1.5).toInt();
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Book a Session',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'with ${widget.expert.name}',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              _sheetLabel('Session Type'),
              const SizedBox(height: 12),
              Row(
                children: _types.map((t) {
                  final sel = _selectedType == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: t != _types.last ? 10 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : AppColors.field,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel ? AppColors.primary : AppColors.line,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              t == 'Video Call'
                                  ? Icons.videocam_rounded
                                  : t == 'Audio Call'
                                      ? Icons.call_rounded
                                      : Icons.chat_rounded,
                              color: sel ? AppColors.white : AppColors.muted,
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: sel ? AppColors.white : AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _sheetLabel('Duration'),
              const SizedBox(height: 12),
              Row(
                children: _durations.map((d) {
                  final sel = _selectedDuration == d;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDuration = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: d != _durations.last ? 10 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : AppColors.field,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel ? AppColors.primary : AppColors.line,
                          ),
                        ),
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: sel ? AppColors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedDate != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _sheetLabel('Select Time'),
              const SizedBox(height: 12),
              if (widget.availableTimes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_rounded, color: AppColors.muted, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'No time slots available',
                        style: TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.availableTimes.map((time) {
                    final sel = _selectedTime == time;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTime = time),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : AppColors.field,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel ? AppColors.primary : AppColors.line,
                          ),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: sel ? AppColors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹$_totalPrice',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingSummaryScreen(
                              expert: widget.expert,
                              date: _selectedDate ?? 'Not selected',
                              time: _selectedTime ?? 'Not selected',
                              sessionType: _selectedType,
                              duration: _selectedDuration,
                              sessionFee: _totalPrice,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha:  0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 15,
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
        ),
      ),
    );
  }

  Widget _sheetLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }
}

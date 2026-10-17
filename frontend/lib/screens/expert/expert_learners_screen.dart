import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'expert_chat_list_screen.dart';
import 'expert_today_sessions_screen.dart';

class MenteeStudent {
  final String id;
  final String name;
  final String goal;
  final String avatarUrl;
  final int completedSessions;
  final String nextSession;
  final double roadmapProgress;
  final String lastActive;
  final String status; // 'Active', 'Completed', 'Upcoming'
  final List<String> completedMilestones;
  final List<String> currentTasks;
  final String mentorNote;

  MenteeStudent({
    required this.id,
    required this.name,
    required this.goal,
    required this.avatarUrl,
    required this.completedSessions,
    required this.nextSession,
    required this.roadmapProgress,
    required this.lastActive,
    required this.status,
    required this.completedMilestones,
    required this.currentTasks,
    required this.mentorNote,
  });
}

class ExpertLearnersScreen extends StatefulWidget {
  const ExpertLearnersScreen({super.key});

  @override
  State<ExpertLearnersScreen> createState() => _ExpertLearnersScreenState();
}

class _ExpertLearnersScreenState extends State<ExpertLearnersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Roadmap In-Progress', 'Completed'];

  final List<MenteeStudent> _students = [
    MenteeStudent(
      id: 'm_1',
      name: 'Priya Mehta',
      goal: 'Flutter Mobile & Cloud Architecture',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
      completedSessions: 6,
      nextSession: 'Today, 11:00 AM',
      roadmapProgress: 0.75,
      lastActive: '2 hours ago',
      status: 'Active',
      completedMilestones: [
        'Dart OOP & Generics Fundamentals',
        'State Management (Provider & Riverpod)',
        'REST API Integration with Dio',
      ],
      currentTasks: [
        'Implement offline caching with Hive',
        'Refactor repository pattern in clean architecture',
      ],
      mentorNote:
          'Very quick learner. Grasps state management quickly. Needs more practice with async error handling.',
    ),
    MenteeStudent(
      id: 'm_2',
      name: 'Amit Verma',
      goal: 'Transition from React Native to Flutter',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150',
      completedSessions: 4,
      nextSession: 'Today, 02:00 PM',
      roadmapProgress: 0.50,
      lastActive: '1 day ago',
      status: 'Active',
      completedMilestones: [
        'Flutter Widget Tree & Layouts',
        'Navigation 2.0 & GoRouter',
      ],
      currentTasks: [
        'Connect Firebase Auth & Firestore rules',
        'Build custom animations with AnimatedBuilder',
      ],
      mentorNote:
          'Has strong JS background. Still comparing widgets to JSX. Progressing well with animations.',
    ),
    MenteeStudent(
      id: 'm_3',
      name: 'Sneha Iyer',
      goal: 'System Design & Senior Dev Preparation',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150',
      completedSessions: 8,
      nextSession: 'Tomorrow, 10:00 AM',
      roadmapProgress: 0.90,
      lastActive: '3 hours ago',
      status: 'Active',
      completedMilestones: [
        'Microservices Design Principles',
        'Distributed Caching & Redis',
        'High Throughput Message Queues (Kafka)',
        'Database Sharding & Replication',
      ],
      currentTasks: [
        'Final system design mock interview prep',
        'Review rate limiting & CAP theorem tradeoffs',
      ],
      mentorNote:
          'Ready for top-tier tech interviews. Resume reviewed and polished.',
    ),
    MenteeStudent(
      id: 'm_4',
      name: 'Rohan Gupta',
      goal: 'Full-Stack Firebase & Web App',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150',
      completedSessions: 3,
      nextSession: '18 Oct, 04:00 PM',
      roadmapProgress: 0.35,
      lastActive: '5 days ago',
      status: 'Active',
      completedMilestones: [
        'Project Setup & Git workflow',
        'UI Mockup implementation',
      ],
      currentTasks: [
        'Cloud Functions deployment',
        'Stripe payment gateway integration',
      ],
      mentorNote: 'Missed one session last week due to college exams. Catching up.',
    ),
    MenteeStudent(
      id: 'm_5',
      name: 'Kavita Nair',
      goal: 'Frontend Performance & Core Web Vitals',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=150',
      completedSessions: 5,
      nextSession: 'None Scheduled',
      roadmapProgress: 1.0,
      lastActive: '2 weeks ago',
      status: 'Completed',
      completedMilestones: [
        'Bundle Optimization & Code Splitting',
        'Image Lazy Loading & WebP pipeline',
        'Lighthouse audit score 95+',
      ],
      currentTasks: [],
      mentorNote: 'Successfully placed at FinTech startup as Senior Frontend Dev!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.toLowerCase().trim();
    final filtered = _students.where((s) {
      final matchesSearch =
          s.name.toLowerCase().contains(query) || s.goal.toLowerCase().contains(query);
      if (!matchesSearch) return false;

      if (_selectedFilter == 'Active') return s.status == 'Active';
      if (_selectedFilter == 'Completed') return s.status == 'Completed';
      if (_selectedFilter == 'Roadmap In-Progress') {
        return s.roadmapProgress > 0 && s.roadmapProgress < 1.0;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Learners & Mentees',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.ink, size: 22),
            tooltip: 'Messages',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpertChatListScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.line, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats Row
            _buildStatsHeader(),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search mentee name, goal or tech...',
                    hintStyle: TextStyle(color: AppColors.muted, fontSize: 13.5),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),

            // Filter Tabs
            _buildFilterTabs(),

            // Learners List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = filtered[index];
                        return _buildStudentCard(student);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCol('42', 'Total Mentees', Icons.people_outline_rounded,
              AppColors.primary),
          Container(width: 1, height: 36, color: AppColors.line),
          _buildStatCol('18', 'Active Now', Icons.bolt_rounded, Colors.orange),
          Container(width: 1, height: 36, color: AppColors.line),
          _buildStatCol('89', 'Milestones', Icons.emoji_events_outlined,
              Colors.indigo),
          Container(width: 1, height: 36, color: AppColors.line),
          _buildStatCol('4.9★', 'Satisfaction', Icons.star_rounded,
              const Color(0xFFFFB300)),
        ],
      ),
    );
  }

  Widget _buildStatCol(
      String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              val,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = _filters[index];
          final isSelected = f == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.line,
                ),
              ),
              child: Center(
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(MenteeStudent student) {
    final progressPercent = (student.roadmapProgress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showStudentDetailSheet(student),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar, Name, Goal, Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(student.avatarUrl),
                        ),
                        if (student.status == 'Active')
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: student.status == 'Active'
                                      ? AppColors.primarySoft
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  student.status,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: student.status == 'Active'
                                        ? AppColors.primary
                                        : const Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            student.goal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${student.completedSessions} sessions completed • Active ${student.lastActive}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Roadmap Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Roadmap Milestone Progress',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '$progressPercent%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: student.roadmapProgress,
                        backgroundColor: const Color(0xFFF1F5F2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Next session pill + CTA buttons
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note_rounded,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Next Session: ${student.nextSession}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExpertChatListScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 13, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Chat',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
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
          ),
        ),
      ),
    );
  }

  void _showStudentDetailSheet(MenteeStudent student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: 12),
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

                  // Header with mentee info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(student.avatarUrl),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              student.goal,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${student.completedSessions} sessions with you',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ExpertChatListScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_rounded, size: 16),
                          label: const Text('Open Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ExpertTodaySessionsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today_rounded,
                              size: 16),
                          label: const Text('Schedule'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(color: AppColors.line),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Private Mentor Notes
                  const Text(
                    'Private Mentor Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sticky_note_2_outlined,
                            color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            student.mentorNote,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF92400E),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Completed Milestones
                  const Text(
                    'Completed Milestones',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...student.completedMilestones.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF22C55E), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current Homework / Next Session Tasks
                  const Text(
                    'Assigned Tasks for Next Session',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (student.currentTasks.isEmpty)
                    const Text(
                      'No pending tasks assigned.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                    )
                  else
                    ...student.currentTasks.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.assignment_outlined,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Learners Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching for another name or changing your filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

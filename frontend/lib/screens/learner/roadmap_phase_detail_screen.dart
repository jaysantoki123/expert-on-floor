import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'roadmap_phase_completion_screen.dart';

class RoadmapPhaseDetailScreen extends StatefulWidget {
  final int phaseNumber;
  final String title;
  final String description;
  final String duration;
  final String level;
  final double progress;

  const RoadmapPhaseDetailScreen({
    super.key,
    required this.phaseNumber,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    this.progress = 0.25,
  });

  @override
  State<RoadmapPhaseDetailScreen> createState() => _RoadmapPhaseDetailScreenState();
}

class _RoadmapPhaseDetailScreenState extends State<RoadmapPhaseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildPhaseHeaderCard(),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  // const SizedBox(height: 24),
                  // _buildTabBar(),
                  const SizedBox(height: 20),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 16),
          ),
        ),
      ),
      title: const Text(
        'Roadmap Detail',
        style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(Icons.bookmark_border_rounded, color: AppColors.ink, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'PHASE ${widget.phaseNumber}',
              style: const TextStyle(
                color: Color(0xFF00B67A),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF00B67A), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '${(widget.progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00B67A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: widget.progress,
                        minHeight: 12,
                        backgroundColor: AppColors.line,
                        color: const Color(0xFF00B67A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem(Icons.calendar_today_rounded, widget.duration, 'Duration'),
        const SizedBox(width: 12),
        _buildStatItem(Icons.signal_cellular_alt_rounded, widget.level, 'Level'),
        const SizedBox(width: 12),
        _buildStatItem(Icons.track_changes_rounded, '${(widget.progress * 100).toInt()}%', 'Completed'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00B67A), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildTabBar() {
  //   return TabBar(
  //     controller: _tabController,
  //     isScrollable: true,
  //     indicatorColor: const Color(0xFF00B67A),
  //     indicatorWeight: 3,
  //     labelColor: const Color(0xFF00B67A),
  //     unselectedLabelColor: AppColors.muted,
  //     labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
  //     unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  //     tabs: const [
  //       Tab(text: 'Overview', icon: Icon(Icons.grid_view_rounded, size: 18)),
  //       Tab(text: 'Topics', icon: Icon(Icons.list_alt_rounded, size: 18)),
  //       Tab(text: 'Resources', icon: Icon(Icons.bookmark_outline_rounded, size: 18)),
  //       Tab(text: 'Projects', icon: Icon(Icons.work_outline_rounded, size: 18)),
  //       Tab(text: 'Tips', icon: Icon(Icons.lightbulb_outline_rounded, size: 18)),
  //       Tab(text: 'Mentors', icon: Icon(Icons.people_outline_rounded, size: 18)),
  //     ],
  //   );
  // }

  Widget _buildTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLearnSection(),
        const SizedBox(height: 24),
        _buildTopicsCovered(),
        const SizedBox(height: 24),
        _buildResourcesSection(),
        const SizedBox(height: 24),
        _buildProjectsSection(),
        const SizedBox(height: 24),
        _buildSkillsGainSection(),
        const SizedBox(height: 24),
        _buildAiTipsSection(),
        const SizedBox(height: 24),
        _buildExpertRecommendations(),
        const SizedBox(height: 24),
        _buildMilestoneCard(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLearnSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Color(0xFF00B67A), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'What you\'ll learn',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'In this phase, you will learn the fundamentals of Dart programming language and Flutter basics. This will help you build a solid base for your Flutter development journey.',
            style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsCovered() {
    final topics = [
      'Dart Basics & Syntax',
      'Flutter Setup & Installation',
      'Variables & Data Types',
      'Understanding Widgets',
      'Functions in Dart',
      'Widget Tree',
      'OOP Concepts in Dart',
      'Hot Reload & Debugging',
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Topics Covered',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '8 Topics',
                style: TextStyle(color: Color(0xFF00B67A), fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 32,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF00B67A), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    topics[index],
                    style: const TextStyle(fontSize: 12, color: AppColors.ink, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildResourcesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Learning Resources',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            // TextButton(
            //   onPressed: () {},
            //   child: const Row(
            //     children: [
            //       Text('View All', style: TextStyle(color: Color(0xFF00B67A), fontSize: 12, fontWeight: FontWeight.w700)),
            //       Icon(Icons.chevron_right_rounded, color: Color(0xFF00B67A), size: 18),
            //     ],
            //   ),
            // ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildResourceCard(Icons.play_circle_fill_rounded, 'Video Course', '2h 30m', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _buildResourceCard(Icons.article_rounded, 'Official Docs', 'Read', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              _buildResourceCard(Icons.menu_book_rounded, 'Article', '5 Articles', const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
              const SizedBox(width: 12),
              _buildResourceCard(Icons.code_rounded, 'Practice', '12 Exercises', const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard(IconData icon, String title, String subtitle, Color bg, Color iconColor) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mini Projects',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            // TextButton(
            //   onPressed: () {},
            //   child: const Row(
            //     children: [
            //       Text('View All', style: TextStyle(color: Color(0xFF00B67A), fontSize: 12, fontWeight: FontWeight.w700)),
            //       Icon(Icons.chevron_right_rounded, color: Color(0xFF00B67A), size: 18),
            //     ],
            //   ),
            // ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildProjectCard(Icons.calculate_rounded, 'Calculator App', 'Easy', 'Build a basic calculator app using Flutter.', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _buildProjectCard(Icons.timer_rounded, 'Counter App', 'Easy', 'Create a counter app with state management.', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              _buildProjectCard(Icons.favorite_rounded, 'BMI Calculator', 'Medium', 'Build a BMI calculator with beautiful UI.', const Color(0xFFFCE4EC), const Color(0xFFC2185B)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(IconData icon, String title, String difficulty, String desc, Color bg, Color iconColor) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
                      child: Text(difficulty, style: TextStyle(color: iconColor, fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildSkillsGainSection() {
    final skills = ['Dart', 'OOP', 'Widgets', 'Layouts', 'State Management', 'Debugging'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills You\'ll Gain',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code_rounded, size: 14, color: Color(0xFF00B67A)),
                  const SizedBox(width: 6),
                  Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAiTipsSection() {
    final tips = [
      'Practice writing small programs daily.',
      'Understand Widget tree deeply.',
      'Use Hot Reload to speed up learning.',
      'Don\'t skip the basics!',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF00B67A), size: 18),
              SizedBox(width: 8),
              Text('AI Tips', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF00B67A), fontWeight: FontWeight.w900)),
                    Expanded(child: Text(tip, style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Image.network(
              'https://cdn-icons-png.flaticon.com/512/2044/2044943.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.smart_toy_rounded, color: Color(0xFF00B67A), size: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.people_outline_rounded, color: Color(0xFF00B67A), size: 18),
                  SizedBox(width: 8),
                  Text('Expert Recs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All', style: TextStyle(color: Color(0xFF00B67A), fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpertItem('John Doe', '4.9 (320 sessions)'),
          const SizedBox(height: 12),
          _buildExpertItem('Jane Smith', '4.8 (180 sessions)'),
        ],
      ),
    );
  }

  Widget _buildExpertItem(String name, String stats) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ink)),
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF00B67A), size: 10),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 10),
                        const SizedBox(width: 2),
                        Text(stats, style: TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoadmapPhaseCompletionScreen(
                    phaseNumber: widget.phaseNumber,
                    phaseTitle: widget.title,
                    nextPhaseTitle: 'Core Flutter',
                  ),
                ),
              );
            },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0F9F4),
                foregroundColor: const Color(0xFF00B67A),
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Book Session', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00B67A).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Milestone', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
                const SizedBox(height: 4),
                const Text('Complete this phase to unlock Phase 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                const Text('Core Flutter', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF00B67A))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lock_outline_rounded, color: AppColors.muted, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RoadmapPhaseCompletionScreen(
                  phaseNumber: widget.phaseNumber,
                  phaseTitle: widget.title,
                  nextPhaseTitle: 'Core Flutter',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B67A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Continue Learning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'roadmap_phase_detail_screen.dart';

class RoadmapResultScreen extends StatelessWidget {
  final String goal;
  final String level;
  final String timePerWeek;

  const RoadmapResultScreen({
    super.key,
    required this.goal,
    required this.level,
    required this.timePerWeek,
  });

  List<RoadmapPhase> get _phases => [
        RoadmapPhase(
          phase: 1,
          title: 'Foundation',
          duration: '2 Weeks',
          accentColor: const Color(0xFF1565C0),
          softColor: const Color(0xFFE3F0FB),
          icon: Icons.code_rounded,
          topics: [
            'Dart Basics & Syntax',
            'OOP Concepts in Dart',
            'Flutter Setup & IDE',
            'Understanding Widgets Tree',
          ],
        ),
        RoadmapPhase(
          phase: 2,
          title: 'Core Flutter',
          duration: '4 Weeks',
          accentColor: AppColors.primary,
          softColor: AppColors.primarySoft,
          icon: Icons.layers_rounded,
          topics: [
            'Stateless & Stateful Widgets',
            'Navigation & Routing',
            'Forms & Validation',
            'State Management (Provider)',
          ],
        ),
        RoadmapPhase(
          phase: 3,
          title: 'Intermediate',
          duration: '4 Weeks',
          accentColor: const Color(0xFFF57F17),
          softColor: const Color(0xFFFFF8E1),
          icon: Icons.api_rounded,
          topics: [
            'REST APIs & HTTP Client',
            'Local Storage (Hive)',
            'BLoC / Riverpod Pattern',
            'Animations & Custom UI',
          ],
        ),
        RoadmapPhase(
          phase: 4,
          title: 'Advanced',
          duration: '4 Weeks',
          accentColor: const Color(0xFF6A1B9A),
          softColor: const Color(0xFFF3E5F5),
          icon: Icons.rocket_launch_rounded,
          topics: [
            'Firebase Integration',
            'Push Notifications',
            'Testing & Debugging',
            'App Store Publishing',
          ],
        ),
      ];

  int get _totalWeeks =>
      _phases.fold(0, (sum, p) => sum + int.parse(p.duration.split(' ')[0]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      bottomSheet: _buildBottomAction(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummarySection(),
                  const SizedBox(height: 32),
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Learning Journey'),
                  const SizedBox(height: 20),
                  ..._phases.asMap().entries.map(
                        (e) => _buildPhaseItem(
                          context,
                          e.value,
                          e.key == _phases.length - 1,
                        ),
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      leading: Center(
        child: GestureDetector(
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
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.ink, size: 18),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Roadmap Result',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        background: Container(color: AppColors.white),
      ),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(Icons.share_outlined,
                color: AppColors.ink, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00B67A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:  0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha:  0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  'AI-Tailored for $level',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            goal,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We have crafted a $_totalWeeks-week intensive plan to help you achieve your goal.',
            style: TextStyle(
              color: AppColors.white.withValues(alpha:  0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('Weeks', '$_totalWeeks', Icons.calendar_today_rounded),
        const SizedBox(width: 12),
        _buildStatItem('Phases', '${_phases.length}', Icons.account_tree_rounded),
        const SizedBox(width: 12),
        _buildStatItem('Hrs/Wk', timePerWeek.split(' ')[0], Icons.timer_rounded),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: AppColors.line)),
      ],
    );
  }

  Widget _buildPhaseItem(BuildContext context, RoadmapPhase phase, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: phase.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: phase.accentColor.withValues(alpha:  0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(phase.icon, color: AppColors.white, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoadmapPhaseDetailScreen(
                    phaseNumber: phase.phase,
                    title: phase.title,
                    description:
                        'Build a strong foundation in ${phase.title} basics before moving to advanced topics.',
                    duration: phase.duration,
                    level: level,
                    progress: 0.0,
                  ),
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:  0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: phase.softColor.withValues(alpha:  0.5),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'PHASE ${phase.phase}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: phase.accentColor,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              phase.duration,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: phase.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phase.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...phase.topics.map(
                              (t) => _buildTopicItem(t, phase.accentColor)),
                        ],
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

  Widget _buildTopicItem(String topic, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
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
            // Logic to save roadmap and start
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start This Journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class RoadmapPhase {
  final int phase;
  final String title;
  final String duration;
  final Color accentColor;
  final Color softColor;
  final IconData icon;
  final List<String> topics;

  RoadmapPhase({
    required this.phase,
    required this.title,
    required this.duration,
    required this.accentColor,
    required this.softColor,
    required this.icon,
    required this.topics,
  });
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'roadmap_phase_detail_screen.dart';

class MyRoadmapScreen extends StatefulWidget {
  const MyRoadmapScreen({super.key});

  @override
  State<MyRoadmapScreen> createState() => _MyRoadmapScreenState();
}

class _MyRoadmapScreenState extends State<MyRoadmapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;
  int _expandedIndex = 0;

  final _steps = [
    _RoadmapStep(
      title: 'Dart Fundamentals',
      description:
          'Learn Dart basics, OOP, async programming and core concepts.',
      resources: ['Dart Official Docs', 'DartPad', 'Udemy Course'],
      duration: '2 weeks',
      status: 'completed',
      xp: 100,
    ),
    _RoadmapStep(
      title: 'Flutter Basics',
      description: 'Understand widgets, layouts, navigation and state basics.',
      resources: ['Flutter Docs', 'Flutter YouTube', 'Widget Catalog'],
      duration: '3 weeks',
      status: 'completed',
      xp: 150,
    ),
    _RoadmapStep(
      title: 'State Management',
      description: 'Master Provider, Riverpod, Bloc and other state solutions.',
      resources: ['Riverpod Docs', 'Bloc Library', 'Flutter Cookbook'],
      duration: '3 weeks',
      status: 'in_progress',
      xp: 200,
    ),
    _RoadmapStep(
      title: 'UI/UX & Widgets',
      description:
          'Build beautiful responsive UIs with custom widgets and animations.',
      resources: ['Flutter Gallery', 'Material Design', 'Dribbble'],
      duration: '2 weeks',
      status: 'locked',
      xp: 150,
    ),
    _RoadmapStep(
      title: 'Build Projects',
      description: 'Apply everything by building 3 real-world Flutter apps.',
      resources: ['GitHub', 'Pub.dev', 'Firebase Console'],
      duration: '4 weeks',
      status: 'locked',
      xp: 300,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0.61).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic),
    );
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

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
          'My Roadmap',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.line),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Progress Card ─────────────────────
            _buildProgressCard(),
            const SizedBox(height: 16),

            // ── Steps ─────────────────────────────
            _buildRoadmapSteps(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:  0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular progress
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, _) => SizedBox(
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
                          backgroundColor: Colors.white.withValues(alpha:  0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
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
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha:  0.75),
                            ),
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
                    const Text(
                      'Flutter Developer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '16 Weeks Plan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha:  0.75),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _statChip('2/5', 'Completed'),
                        const SizedBox(width: 8),
                        _statChip('900', 'XP Earned'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:  0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha:  0.25)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next milestone: State Management',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha:  0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:  0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha:  0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSteps() {
    return Column(
      children: _steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isExpanded = _expandedIndex == i;
        final isLast = i == _steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline
              Column(
                children: [
                  _StepIndicator(status: step.status, index: i),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: step.status == 'completed'
                            ? AppColors.primary
                            : AppColors.line,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _expandedIndex = isExpanded ? -1 : i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isExpanded
                              ? AppColors.primary
                              : AppColors.line,
                          width: isExpanded ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:  0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _StatusBadge(status: step.status),
                                          const Spacer(),
                                          Text(
                                            step.duration,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        step.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: step.status == 'locked'
                                              ? AppColors.muted
                                              : AppColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.muted,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),

                          // Expanded content
                          if (isExpanded) ...[
                            Divider(height: 1, color: AppColors.line),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Resources',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: step.resources
                                        .map(
                                          (r) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primarySoft,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppColors.line,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.link_rounded,
                                                  size: 11,
                                                  color: AppColors.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  r,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.emoji_events_rounded,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '+${step.xp} XP on completion',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 38,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => RoadmapPhaseDetailScreen(
                                              phaseNumber: i + 1,
                                              title: step.title,
                                              description: step.description,
                                              duration: step.duration,
                                              level: 'Intermediate', // Default or derived
                                              progress: step.status == 'completed' ? 1.0 : (step.status == 'in_progress' ? 0.25 : 0.0),
                                            ),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.primary),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'View Phase Details',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (step.status == 'in_progress') ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'Mark as Complete ✓',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RoadmapStep {
  final String title;
  final String description;
  final List<String> resources;
  final String duration;
  final String status;
  final int xp;

  const _RoadmapStep({
    required this.title,
    required this.description,
    required this.resources,
    required this.duration,
    required this.status,
    required this.xp,
  });
}

class _StepIndicator extends StatelessWidget {
  final String status;
  final int index;
  const _StepIndicator({required this.status, required this.index});

  @override
  Widget build(BuildContext context) {
    if (status == 'completed') {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    } else if (status == 'in_progress') {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2.5),
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: AppColors.primary,
          size: 16,
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.field,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line, width: 2),
        ),
        child: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.muted,
          size: 14,
        ),
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'completed':
        color = AppColors.primary;
        label = '✓ Completed';
        break;
      case 'in_progress':
        color = Colors.orange;
        label = '▶ In Progress';
        break;
      default:
        color = AppColors.muted;
        label = '🔒 Locked';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

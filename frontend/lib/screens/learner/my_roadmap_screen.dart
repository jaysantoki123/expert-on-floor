import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/roadmap_model.dart';
import '../../providers/roadmap_provider.dart';
import 'genrate_roadmap_screen.dart';
import 'roadmap_phase_detail_screen.dart';

class _RoadmapStep {
  final int id;
  final String title;
  final String description;
  final List<String> resources;
  final String duration;
  final String status; // 'completed', 'in_progress', 'locked'
  final int xp;

  _RoadmapStep({
    required this.id,
    required this.title,
    required this.description,
    required this.resources,
    required this.duration,
    required this.status,
    required this.xp,
  });
}

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

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0.0).animate(_progressCtrl);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRoadmap();
    });
  }

  Future<void> _fetchRoadmap() async {
    try {
      final provider = Provider.of<RoadmapProvider>(context, listen: false);
      await provider.fetchMyRoadmap();
      if (mounted && provider.roadmap != null) {
        final double targetProgress = provider.roadmap!.progressPercent / 100.0;
        setState(() {
          _progressAnim = Tween<double>(
            begin: 0,
            end: targetProgress,
          ).animate(
            CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic),
          );
        });
        _progressCtrl.reset();
        _progressCtrl.forward();
      }
    } catch (e) {
      debugPrint('Error fetching roadmap: $e');
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: SafeArea(
          child: Consumer<RoadmapProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.roadmap == null) {
                return Column(
                  children: [
                    _buildHeader(),
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                  ],
                );
              }

              final roadmap = provider.roadmap;
              if (roadmap == null) {
                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
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
                                  Icons.map_outlined,
                                  color: AppColors.primary,
                                  size: 38,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No roadmap generated yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Create a personalized learning path tailored to your goals with our AI generator.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const GenerateRoadmapScreen()),
                                    ).then((_) => _fetchRoadmap());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Generate AI Roadmap',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Compute steps list from phases
              final phases = roadmap.phases;
              int completedCount = 0;
              int firstIncompleteIndex = -1;
              for (int i = 0; i < phases.length; i++) {
                if (phases[i].isCompleted) {
                  completedCount++;
                } else if (firstIncompleteIndex == -1) {
                  firstIncompleteIndex = i;
                }
              }

              final List<_RoadmapStep> steps = phases.asMap().entries.map((e) {
                final idx = e.key;
                final phase = e.value;
                
                String status = 'locked';
                if (phase.isCompleted) {
                  status = 'completed';
                } else if (idx == firstIncompleteIndex) {
                  status = 'in_progress';
                }

                return _RoadmapStep(
                  id: phase.id,
                  title: phase.title,
                  description: phase.description,
                  resources: phase.resources.map((r) => r.title).toList(),
                  duration: '${phase.durationWeeks} weeks',
                  status: status,
                  xp: phase.durationWeeks * 50,
                );
              }).toList();

              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchRoadmap,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // ── Progress Card ─────────────────────
                            _buildProgressCard(roadmap, completedCount, phases.length),
                            const SizedBox(height: 16),

                            // ── Steps ─────────────────────────────
                            _buildRoadmapSteps(steps, provider),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Header
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Roadmap',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Track your learning journey',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _fetchRoadmap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(RoadmapModel roadmap, int completedCount, int totalCount) {
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
                    Text(
                      roadmap.title.isNotEmpty ? roadmap.title : (roadmap.goal ?? 'Personalized Roadmap'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${roadmap.totalWeeks} Weeks Plan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha:  0.75),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _statChip('$completedCount/$totalCount', 'Completed'),
                        const SizedBox(width: 8),
                        _statChip('${roadmap.progressPercent * 10}', 'XP Earned'),
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
                Expanded(
                  child: Text(
                    roadmap.progressPercent >= 100
                        ? 'Congratulations! Roadmap Fully Completed! 🎉'
                        : 'Keep learning! Reach your goals step by step.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha:  0.9),
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

  Widget _buildRoadmapSteps(List<_RoadmapStep> steps, RoadmapProvider roadmapProvider) {
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isExpanded = _expandedIndex == i;
        final isLast = i == steps.length - 1;

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
                                  if (step.resources.isNotEmpty) ...[
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
                                  ],
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
                                              phaseId: step.id,
                                            ),
                                          ),
                                        ).then((_) => _fetchRoadmap());
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
                                        onPressed: () async {
                                          try {
                                            await roadmapProvider.completePhase(step.id);
                                            _fetchRoadmap();
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(e.toString())),
                                            );
                                          }
                                        },
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

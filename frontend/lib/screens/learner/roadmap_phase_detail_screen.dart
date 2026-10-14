import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/roadmap_model.dart';
import '../../providers/roadmap_provider.dart';
import 'expert_listing_screen.dart';
import 'roadmap_phase_completion_screen.dart';


class RoadmapPhaseDetailScreen extends StatefulWidget {
  final int phaseId;

  const RoadmapPhaseDetailScreen({
    super.key,
    required this.phaseId,
  });

  @override
  State<RoadmapPhaseDetailScreen> createState() => _RoadmapPhaseDetailScreenState();
}

class _RoadmapPhaseDetailScreenState extends State<RoadmapPhaseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoadmapProvider>().fetchPhaseDetail(widget.phaseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        body: SafeArea(
          child: Consumer<RoadmapProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(provider.error.toString().replaceAll('Exception: ', ''), style: const TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.fetchPhaseDetail(widget.phaseId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final phase = provider.currentPhase;
              if (phase == null) {
                return const Center(child: Text('Phase not found'));
              }
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _buildPhaseHeaderCard(phase),
                          const SizedBox(height: 16),
                          _buildStatsRow(phase),
                          const SizedBox(height: 20),
                          _buildTabContent(phase),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButton(context, phase),
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
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
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
                  'Roadmap Detail',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Phase learning path',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: AppColors.ink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseHeaderCard(PhaseModel phase) {
    final roadmapProvider = context.read<RoadmapProvider>();
    final progress = roadmapProvider.roadmap?.progressPercent ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.02),
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
              phase.difficulty,
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
                  phase.title,
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
            phase.description,
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
                          '$progress%',
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
                        value: progress / 100,
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

  Widget _buildStatsRow(PhaseModel phase) {
    final roadmapProvider = context.read<RoadmapProvider>();
    final progress = roadmapProvider.roadmap?.progressPercent ?? 0;
    return Row(
      children: [
        _buildStatItem(Icons.calendar_today_rounded, '${phase.durationWeeks} Weeks', 'Duration'),
        const SizedBox(width: 12),
        _buildStatItem(Icons.signal_cellular_alt_rounded, phase.difficulty, 'Level'),
        const SizedBox(width: 12),
        _buildStatItem(Icons.track_changes_rounded, '$progress%', 'Completed'),
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

  Widget _buildTabContent(PhaseModel phase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLearnSection(phase),
        const SizedBox(height: 24),
        _buildTopicsCovered(phase),
        const SizedBox(height: 24),
        _buildResourcesSection(phase),
        const SizedBox(height: 24),
        _buildProjectsSection(phase),
        const SizedBox(height: 24),
        _buildSkillsGainSection(phase),
        const SizedBox(height: 24),
        _buildAiTipsSection(phase),
        const SizedBox(height: 24),
        _buildExpertRecommendations(),
        const SizedBox(height: 24),
        _buildMilestoneCard(phase),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLearnSection(PhaseModel phase) {
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
            phase.description,
            style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsCovered(PhaseModel phase) {
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
              child: Text(
                '${phase.topics.length} Topics',
                style: const TextStyle(color: Color(0xFF00B67A), fontSize: 11, fontWeight: FontWeight.w700),
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
          itemCount: phase.topics.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF00B67A), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phase.topics[index],
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

  Widget _buildResourcesSection(PhaseModel phase) {
    if (phase.resources.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Learning Resources',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: phase.resources.asMap().entries.map((entry) {
              final index = entry.key;
              final resource = entry.value;
              final colors = [
                const Color(0xFFE8F5E9), const Color(0xFFE3F2FD), const Color(0xFFFFF3E0), const Color(0xFFF3E5F5)
              ];
              final iconColors = [
                const Color(0xFF2E7D32), const Color(0xFF1565C0), const Color(0xFFEF6C00), const Color(0xFF7B1FA2)
              ];
              final icons = [
                Icons.play_circle_fill_rounded, Icons.article_rounded, Icons.menu_book_rounded, Icons.code_rounded
              ];
              return Padding(
                padding: EdgeInsets.only(right: index == phase.resources.length -1 ?0:12),
                child: _buildResourceCard(
                  icons[index % icons.length],
                  resource.title,
                  resource.type,
                  colors[index % colors.length],
                  iconColors[index % iconColors.length],
                ),
              );
            }).toList(),
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

  Widget _buildProjectsSection(PhaseModel phase) {
    if (phase.projects.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mini Projects',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: phase.projects.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value as Map<String,dynamic>?;
              final colors = [
                const Color(0xFFE8F5E9), const Color(0xFFE3F2FD), const Color(0xFFFCE4EC)
              ];
              final iconColors = [
                const Color(0xFF2E7D32), const Color(0xFF1565C0), const Color(0xFFC2185B)
              ];
              final icons = [
                Icons.calculate_rounded, Icons.timer_rounded, Icons.favorite_rounded
              ];
              final difficulties = ['Easy', 'Medium', 'Hard'];
              return Padding(
                padding: EdgeInsets.only(right: index == phase.projects.length-1?0:12),
                child: _buildProjectCard(
                  icons[index % icons.length],
                  project?['title'] ?? 'Project',
                  difficulties[index % difficulties.length],
                  project?['description'] ?? 'Build a project using Flutter.',
                  colors[index % colors.length],
                  iconColors[index % iconColors.length],
                ),
              );
            }).toList(),
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

  Widget _buildSkillsGainSection(PhaseModel phase) {
    if (phase.skills.isEmpty) return const SizedBox.shrink();
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
          children: phase.skills.map((skill) {
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

  Widget _buildAiTipsSection(PhaseModel phase) {
    if (phase.tips.isEmpty) return const SizedBox.shrink();
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
          ...phase.tips.map((tip) => Padding(
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpertListingScreen(),
                    ),
                  );
                },
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
                  builder: (_) => const ExpertListingScreen(),
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

  Widget _buildMilestoneCard(PhaseModel phase) {
    final roadmapProvider = context.read<RoadmapProvider>();
    final phases = roadmapProvider.roadmap?.phases ?? [];
    final currentIndex = phases.indexWhere((p) => p.id == phase.id);
    final nextPhase = currentIndex != -1 && currentIndex < phases.length -1 ? phases[currentIndex+1] : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00B67A).withValues(alpha:  0.1)),
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
                Text('Complete this phase to unlock ${nextPhase?.title ?? 'next phase'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                if (nextPhase != null)
                  Text(nextPhase.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF00B67A))),
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

  Widget _buildBottomButton(BuildContext context, PhaseModel phase) {
    final roadmapProvider = Provider.of<RoadmapProvider>(context);
    final phases = roadmapProvider.roadmap?.phases ?? [];
    final currentIndex = phases.indexWhere((p) => p.id == phase.id);
    final nextPhase = currentIndex != -1 && currentIndex < phases.length -1 ? phases[currentIndex+1] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
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
          onPressed: roadmapProvider.isCompleting ? null : () async {
            if (phase.isCompleted) return;
            try {
              final progress = await roadmapProvider.completePhase(phase.id);
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoadmapPhaseCompletionScreen(
                      progressPercent: progress,
                      phaseTitle: phase.title,
                      nextPhaseTitle: nextPhase?.title,
                    ),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: phase.isCompleted ? Colors.grey : const Color(0xFF00B67A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: roadmapProvider.isCompleting
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(phase.isCompleted ? 'Already Completed' : 'Mark Phase Complete', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 12),
                  if (!phase.isCompleted) const Icon(Icons.check_circle_rounded, size: 20),
                ],
              ),
        ),
      ),
    );
  }
}

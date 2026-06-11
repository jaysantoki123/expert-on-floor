import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../screens/onboarding_screen.dart';

class OnboardingIllustration extends StatelessWidget {
  final IllustrationType type;

  const OnboardingIllustration({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      IllustrationType.findExperts => const _FindExpertsIllustration(),
      IllustrationType.bookSessions => const _BookSessionsIllustration(),
      IllustrationType.aiRoadmap => const _AiRoadmapIllustration(),
    };
  }
}

// ══════════════════════════════════════════════════════════════════
// 1. Find Experts
// ══════════════════════════════════════════════════════════════════
class _FindExpertsIllustration extends StatelessWidget {
  const _FindExpertsIllustration();

  @override
  Widget build(BuildContext context) {
    return _IllustrationShell(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Search bar
          Container(
            width: 210,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07), blurRadius: 12)
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Find experts...',
                    style: TextStyle(
                        color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Skill chips row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SkillChip(label: 'Flutter', icon: Icons.code_rounded),
              const SizedBox(width: 8),
              _SkillChip(label: 'Design', icon: Icons.palette_outlined),
              const SizedBox(width: 8),
              _SkillChip(label: 'AI/ML', icon: Icons.psychology_outlined),
            ],
          ),
          const SizedBox(height: 18),

          // Expert avatar + stars
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.white, size: 42),
              ),
              Positioned(
                bottom: -6,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8)
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.amber, size: 12),
                      SizedBox(width: 3),
                      Text('4.9',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SkillChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)
          ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 2. Book Sessions
// ══════════════════════════════════════════════════════════════════
class _BookSessionsIllustration extends StatelessWidget {
  const _BookSessionsIllustration();

  @override
  Widget build(BuildContext context) {
    return _IllustrationShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mini calendar
          Container(
            width: 210,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07), blurRadius: 12)
              ],
            ),
            child: Column(
              children: [
                // Month header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('May 2026',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.ink)),
                    Row(
                      children: const [
                        Icon(Icons.chevron_left,
                            size: 16, color: AppColors.muted),
                        Icon(Icons.chevron_right,
                            size: 16, color: AppColors.muted),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Day labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map((d) => Text(d,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted)))
                      .toList(),
                ),
                const SizedBox(height: 6),

                // Day grid
                ...List.generate(3, (row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (col) {
                        final day = row * 7 + col + 1;
                        if (day > 21) return const SizedBox(width: 22);
                        final sel = day == 17;
                        final hasSession = day == 12 || day == 19;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('$day',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: sel
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: sel
                                            ? AppColors.white
                                            : AppColors.ink)),
                              ),
                            ),
                            if (hasSession)
                              Positioned(
                                bottom: -1,
                                left: 8,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Booked badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_rounded,
                    color: AppColors.white, size: 15),
                SizedBox(width: 7),
                Text('Session Booked!',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 3. AI Roadmap
// ══════════════════════════════════════════════════════════════════
class _AiRoadmapIllustration extends StatelessWidget {
  const _AiRoadmapIllustration();

  static const _steps = [
    ('Flutter Basics', true),
    ('State Management', true),
    ('Advanced Flutter', false),
    ('Build Projects', false),
  ];

  @override
  Widget build(BuildContext context) {
    return _IllustrationShell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AI Brain icon
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: AppColors.white, size: 34),
              ),
              const SizedBox(height: 14),

              // Roadmap card
              Container(
                width: 215,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 12)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _steps.length; i++) ...[
                      _RoadmapStep(
                          label: _steps[i].$1, done: _steps[i].$2),
                      if (i < _steps.length - 1) _RoadmapConnector(),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Progress badge
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Column(
                children: [
                  Text('61%',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                  Text('Done',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapStep extends StatelessWidget {
  final String label;
  final bool done;

  const _RoadmapStep({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: done ? AppColors.primary : AppColors.field,
            shape: BoxShape.circle,
            border: Border.all(
                color: done ? AppColors.primary : AppColors.line),
          ),
          child: done
              ? const Icon(Icons.check_rounded,
                  color: AppColors.white, size: 11)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: done ? AppColors.ink : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _RoadmapConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
      child: Container(
        width: 2,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Shared illustration shell
// ══════════════════════════════════════════════════════════════════
class _IllustrationShell extends StatelessWidget {
  final Widget child;

  const _IllustrationShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            left: -15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EditSkillsScreen extends StatefulWidget {
  const EditSkillsScreen({super.key});

  @override
  State<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends State<EditSkillsScreen> {
  // Pre-populate with standard skills matching the mockup
  late List<_SkillItem> _skills;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _skills = [
      _SkillItem(name: 'Flutter Development', level: 'Expert', type: _SkillType.flutter),
      _SkillItem(name: 'Dart Programming', level: 'Expert', type: _SkillType.dart),
      _SkillItem(name: 'Firebase', level: 'Advanced', type: _SkillType.firebase),
      _SkillItem(name: 'Mobile App Architecture', level: 'Advanced', type: _SkillType.architecture),
      _SkillItem(name: 'Git & Version Control', level: 'Intermediate', type: _SkillType.git),
      _SkillItem(name: 'UI/UX Design', level: 'Intermediate', type: _SkillType.uiux),
    ];
  }

  // Predefined lists for adding new skills
  final List<String> _availableSkills = [
    'Node.js Development',
    'React Native',
    'Python Programming',
    'Swift (iOS)',
    'Kotlin (Android)',
    'SQL Databases',
    'AWS Cloud Architecture',
    'Figma UI Design',
    'Docker & CI/CD',
    'Project Management',
  ];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];

  void _saveSkills() {
    setState(() => _isSaving = true);
    // Simulate API call saving skills
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Skills updated successfully! 🎉'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  void _showAddSkillDialog() {
    String selectedSkill = _availableSkills.first;
    String selectedLevel = _levels[1]; // Default to Intermediate

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Add New Skill',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Skill',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inkSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSkill,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
                        items: _availableSkills.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedSkill = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Level',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inkSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLevel,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
                        items: _levels.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedLevel = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Prevent duplicate skills
                      if (!_skills.any((s) => s.name == selectedSkill)) {
                        _skills.add(
                          _SkillItem(
                            name: selectedSkill,
                            level: selectedLevel,
                            type: _SkillType.other,
                          ),
                        );
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Skills',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primary)),
              ),
            )
          else
            TextButton(
              onPressed: _saveSkills,
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Color(0xFF009D45),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.line.withValues(alpha: 0.5)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Tip Card
            _buildBoltBanner(),
            const SizedBox(height: 24),

            // Your Skills Title
            const Text(
              'Your Skills',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),

            // Reorderable list
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent, // Fix transparent drag shadow container
              ),
              child: SizedBox(
                height: _skills.length * 76.0, // Fixed height based on item counts
                child: ReorderableListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _skills.length,
                  buildDefaultDragHandles: false, // Use custom drag handles
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final _SkillItem item = _skills.removeAt(oldIndex);
                      _skills.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final skill = _skills[index];
                    return _buildSkillTile(skill, index);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Add Skill Button
            GestureDetector(
              onTap: _showAddSkillDialog,
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: const Color(0xFF22C55E),
                  radius: 12,
                  strokeWidth: 1,
                  dashPattern: const [6, 4],
                ),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: Color(0xFF22C55E), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Add New Skill',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Skill Levels Legend Title
            const Text(
              'Skill Levels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),

            // Legend rows
            _buildLegendRow('Beginner', const Color(0xFFEFF6FF), const Color(0xFF3B82F6), 'Basic understanding of the skill'),
            const SizedBox(height: 14),
            _buildLegendRow('Intermediate', const Color(0xFFFFF7ED), const Color(0xFFD97706), 'Good practical knowledge'),
            const SizedBox(height: 14),
            _buildLegendRow('Advanced', const Color(0xFFF3E8FF), const Color(0xFFA855F7), 'Strong knowledge and some experience'),
            const SizedBox(height: 14),
            _buildLegendRow('Expert', const Color(0xFFEAF7EF), const Color(0xFF22C55E), 'Extensive experience and deep expertise'),
            
            const SizedBox(height: 28),

            // Bottom Tip Card
            _buildBottomTipCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBoltBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flash_on_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showcase your expertise',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Add skills relevant to your expertise. These will help learners find you easily.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillTile(_SkillItem skill, int index) {
    return Container(
      key: ValueKey(skill.name),
      height: 64,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag Grip Handle
          ReorderableDragStartListener(
            index: index,
            child: const Icon(
              Icons.drag_indicator_rounded,
              color: Color(0xFFD1D5DB),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Skill logo
          _buildSkillLogo(skill.type),
          const SizedBox(width: 14),

          // Skill Name
          Expanded(
            child: Text(
              skill.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Outlined Level Dropdown Button
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (String level) {
              setState(() {
                skill.level = level;
              });
            },
            itemBuilder: (BuildContext context) {
              return _levels.map((String level) {
                return PopupMenuItem<String>(
                  value: level,
                  child: Text(
                    level,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: level == skill.level ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    skill.level,
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF22C55E),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Delete icon
          GestureDetector(
            onTap: () {
              setState(() {
                _skills.removeAt(index);
              });
            },
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillLogo(_SkillType type) {
    switch (type) {
      case _SkillType.flutter:
        return const SizedBox(
          width: 32,
          height: 32,
          child: Center(child: FlutterLogo(size: 22)),
        );
      case _SkillType.dart:
        return Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: 0.785, // 45 degrees
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4DB).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        );
      case _SkillType.firebase:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7ED),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFF59E0B),
            size: 20,
          ),
        );
      case _SkillType.architecture:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF7EF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.phonelink_setup_rounded,
            color: Color(0xFF22C55E),
            size: 18,
          ),
        );
      case _SkillType.git:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFFEF2F2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.commit_rounded,
            color: Color(0xFFEF4444),
            size: 20,
          ),
        );
      case _SkillType.uiux:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F3FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.architecture_rounded,
            color: Color(0xFF8B5CF6),
            size: 18,
          ),
        );
      case _SkillType.other:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.code_rounded,
            color: Color(0xFF6B7280),
            size: 18,
          ),
        );
    }
  }

  Widget _buildLegendRow(String title, Color bg, Color textCol, String desc) {
    return Row(
      children: [
        Container(
          width: 90,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: textCol,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.8), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFF22C55E),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Color(0xFF22C55E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep your skills up to date to attract more learners.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _SkillType { flutter, dart, firebase, architecture, git, uiux, other }

class _SkillItem {
  final String name;
  String level;
  final _SkillType type;

  _SkillItem({
    required this.name,
    required this.level,
    required this.type,
  });
}

// Custom Painter to draw dashed borders for the "Add New Skill" button
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final List<int> dashPattern;

  DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _buildDashedPath(path, dashPattern);

    canvas.drawPath(dashedPath, paint);
  }

  Path _buildDashedPath(Path source, List<int> pattern) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      int index = 0;

      while (distance < metric.length) {
        final double len = pattern[index].toDouble();
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, (distance + len).clamp(0.0, metric.length)),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
        index = (index + 1) % pattern.length;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

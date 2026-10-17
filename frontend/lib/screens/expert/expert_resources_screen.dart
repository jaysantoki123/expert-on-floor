import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SharedResourceItem {
  final String id;
  String title;
  String description;
  String category;
  String url;
  String fileType; // 'pdf', 'code', 'link', 'doc'
  int downloads;
  bool isMenteeOnly;

  SharedResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.url,
    required this.fileType,
    required this.downloads,
    required this.isMenteeOnly,
  });
}

class ExpertResourcesScreen extends StatefulWidget {
  const ExpertResourcesScreen({super.key});

  @override
  State<ExpertResourcesScreen> createState() => _ExpertResourcesScreenState();
}

class _ExpertResourcesScreenState extends State<ExpertResourcesScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Cheat Sheets',
    'Code Templates',
    'Architecture',
    'Interview Prep',
  ];

  final List<SharedResourceItem> _resources = [
    SharedResourceItem(
      id: 'res_1',
      title: 'Clean Architecture in Flutter Boilerplate',
      description:
          'Production-ready starter template with Riverpod, Dio interceptors, Hive offline caching, and automated unit tests.',
      category: 'Code Templates',
      url: 'https://github.com/expert/flutter-clean-arch-starter',
      fileType: 'code',
      downloads: 240,
      isMenteeOnly: false,
    ),
    SharedResourceItem(
      id: 'res_2',
      title: 'Senior Mobile System Design Handbook',
      description:
          '15 high-level architecture designs (offline feed, chat, payment, media sync) with CAP theorem and caching notes.',
      category: 'Architecture',
      url: 'https://expertmentor.app/resources/mobile-system-design.pdf',
      fileType: 'pdf',
      downloads: 184,
      isMenteeOnly: true,
    ),
    SharedResourceItem(
      id: 'res_3',
      title: 'Dart 3 Patterns & Records Quick Reference',
      description:
          'One-page cheat sheet for pattern matching, sealed classes, records, and switch expressions.',
      category: 'Cheat Sheets',
      url: 'https://expertmentor.app/resources/dart-3-patterns.pdf',
      fileType: 'pdf',
      downloads: 320,
      isMenteeOnly: false,
    ),
    SharedResourceItem(
      id: 'res_4',
      title: 'Technical Mock Interview Rubric & Questions',
      description:
          'The exact evaluation criteria used by tier-1 product companies during 45-minute live coding rounds.',
      category: 'Interview Prep',
      url: 'https://expertmentor.app/resources/interview-rubric.docx',
      fileType: 'doc',
      downloads: 142,
      isMenteeOnly: true,
    ),
    SharedResourceItem(
      id: 'res_5',
      title: 'Flutter CI/CD Fastlane & GitHub Actions Script',
      description:
          'Automated build, test, and TestFlight / Play Store Internal deployment workflow config.',
      category: 'Code Templates',
      url: 'https://gist.github.com/expert/fastlane-flutter-actions',
      fileType: 'code',
      downloads: 98,
      isMenteeOnly: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _resources
        : _resources.where((r) => r.category == _selectedCategory).toList();

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
          'Mentee Resources Library',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.line, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Overview
            _buildOverviewHeader(),

            // Filter Tabs
            _buildCategoryFilter(),

            // Resources List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final res = filtered[index];
                        return _buildResourceCard(res);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddResourceSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_link_rounded, color: Colors.white),
        label: const Text(
          'Share Resource',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCol('${_resources.length}', 'Shared Items',
              Icons.folder_outlined, AppColors.primary),
          Container(width: 1, height: 32, color: AppColors.line),
          _buildStatCol('984', 'Total Downloads', Icons.download_rounded,
              Colors.indigo),
          Container(width: 1, height: 32, color: AppColors.line),
          _buildStatCol('2 Exclusive', 'Mentees Only', Icons.lock_outline_rounded,
              Colors.orange),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
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

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
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
                  cat,
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

  Widget _buildResourceCard(SharedResourceItem res) {
    IconData typeIcon;
    Color typeColor;

    switch (res.fileType) {
      case 'code':
        typeIcon = Icons.code_rounded;
        typeColor = const Color(0xFF3B82F6);
        break;
      case 'pdf':
        typeIcon = Icons.picture_as_pdf_rounded;
        typeColor = Colors.redAccent;
        break;
      case 'doc':
        typeIcon = Icons.article_rounded;
        typeColor = Colors.teal;
        break;
      default:
        typeIcon = Icons.link_rounded;
        typeColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            res.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: res.isMenteeOnly
                                ? const Color(0xFFFFFBEB)
                                : AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            res.isMenteeOnly ? 'Mentees Only' : 'Public',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: res.isMenteeOnly
                                  ? const Color(0xFFD97706)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      res.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.download_rounded,
                      size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text(
                    '${res.downloads} downloads',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resource link copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: const Text('Copy Link'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 18),
                    onPressed: () {
                      setState(() {
                        _resources.removeWhere((r) => r.id == res.id);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddResourceSheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String category = 'Cheat Sheets';
    String fileType = 'pdf';
    bool isMenteeOnly = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      const SizedBox(height: 16),
                      const Text(
                        'Share Learning Material',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Title',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                            hintText: 'e.g. Flutter Riverpod Architecture Guide'),
                      ),
                      const SizedBox(height: 12),
                      const Text('Resource Link or Repository URL',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: urlCtrl,
                        decoration: const InputDecoration(
                            hintText: 'https://github.com/... or Google Drive link'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Category',
                                    style: TextStyle(
                                        fontSize: 12.5, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.field,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: category,
                                      isExpanded: true,
                                      items: [
                                        'Cheat Sheets',
                                        'Code Templates',
                                        'Architecture',
                                        'Interview Prep',
                                      ].map((c) {
                                        return DropdownMenuItem(
                                            value: c, child: Text(c));
                                      }).toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setModalState(() => category = v);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Type',
                                    style: TextStyle(
                                        fontSize: 12.5, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.field,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: fileType,
                                      isExpanded: true,
                                      items: [
                                        DropdownMenuItem(
                                            value: 'pdf', child: Text('PDF')),
                                        DropdownMenuItem(
                                            value: 'code', child: Text('Code')),
                                        DropdownMenuItem(
                                            value: 'doc', child: Text('Doc')),
                                        DropdownMenuItem(
                                            value: 'link', child: Text('Link')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) {
                                          setModalState(() => fileType = v);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Description',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            hintText: 'Brief summary of what mentees will learn...'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: isMenteeOnly,
                            activeColor: AppColors.primary,
                            onChanged: (v) {
                              setModalState(() => isMenteeOnly = v ?? false);
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Restrict to booked mentees only (Private)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
                              return;
                            }
                            setState(() {
                              _resources.insert(
                                0,
                                SharedResourceItem(
                                  id: 'res_${DateTime.now().millisecondsSinceEpoch}',
                                  title: titleCtrl.text.trim(),
                                  description: descCtrl.text.trim().isEmpty
                                      ? 'Useful shared material by mentor.'
                                      : descCtrl.text.trim(),
                                  category: category,
                                  url: urlCtrl.text.trim(),
                                  fileType: fileType,
                                  downloads: 0,
                                  isMenteeOnly: isMenteeOnly,
                                ),
                              );
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Resource published to library!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          child: const Text('Publish Resource'),
                        ),
                      ),
                    ],
                  ),
                ),
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
              child: const Icon(Icons.folder_open_rounded,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Resources in this Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Click "Share Resource" to add your first template or cheat sheet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ExpertServiceItem {
  final String id;
  String title;
  String description;
  int durationMinutes;
  double price;
  String category;
  bool isActive;
  IconData icon;
  List<String> deliverables;

  ExpertServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.price,
    required this.category,
    required this.isActive,
    required this.icon,
    required this.deliverables,
  });
}

class ExpertManageServicesScreen extends StatefulWidget {
  const ExpertManageServicesScreen({super.key});

  @override
  State<ExpertManageServicesScreen> createState() =>
      _ExpertManageServicesScreenState();
}

class _ExpertManageServicesScreenState
    extends State<ExpertManageServicesScreen> {
  final List<ExpertServiceItem> _services = [
    ExpertServiceItem(
      id: 'srv_1',
      title: '1-on-1 Mentorship & Career Guidance',
      description:
          'Personalized career advice, skill evaluation, and roadmap planning tailored to your goals.',
      durationMinutes: 45,
      price: 999.0,
      category: 'Mentorship',
      isActive: true,
      icon: Icons.person_pin_rounded,
      deliverables: [
        'Personalized roadmap review',
        'Direct Q&A and advice',
        'Actionable next steps summary',
      ],
    ),
    ExpertServiceItem(
      id: 'srv_2',
      title: 'Code & Architecture Review',
      description:
          'Deep dive into your project codebase, state management architecture, performance and clean code.',
      durationMinutes: 60,
      price: 1499.0,
      category: 'Technical',
      isActive: true,
      icon: Icons.code_rounded,
      deliverables: [
        'Code quality audit',
        'Performance optimization tips',
        'Architecture refactoring suggestions',
      ],
    ),
    ExpertServiceItem(
      id: 'srv_3',
      title: 'Technical Mock Interview',
      description:
          'Simulated real-world technical interview with live coding, data structures, and instant feedback.',
      durationMinutes: 45,
      price: 1199.0,
      category: 'Interview',
      isActive: true,
      icon: Icons.psychology_rounded,
      deliverables: [
        'Live coding evaluation',
        'Detailed score & feedback report',
        'Interview tips & resources',
      ],
    ),
    ExpertServiceItem(
      id: 'srv_4',
      title: 'Resume & Portfolio Critique',
      description:
          'ATS optimization, portfolio project review, and presentation tips to stand out to recruiters.',
      durationMinutes: 30,
      price: 599.0,
      category: 'Career',
      isActive: true,
      icon: Icons.description_rounded,
      deliverables: [
        'Line-by-line resume critique',
        'GitHub profile recommendations',
        'LinkedIn profile audit',
      ],
    ),
    ExpertServiceItem(
      id: 'srv_5',
      title: 'Quick Debugging & Bug Resolution',
      description:
          'Got stuck on a tricky issue? Live pair-programming to diagnose and squash pesky bugs quickly.',
      durationMinutes: 30,
      price: 799.0,
      category: 'Technical',
      isActive: false,
      icon: Icons.bug_report_rounded,
      deliverables: [
        'Live screen share debugging',
        'Root-cause analysis',
        'Preventative testing tips',
      ],
    ),
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Mentorship',
    'Technical',
    'Interview',
    'Career',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredServices = _selectedCategory == 'All'
        ? _services
        : _services
            .where((s) => s.category == _selectedCategory)
            .toList();

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
          'Services & Pricing',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 22),
            ),
            tooltip: 'Add Service',
            onPressed: () => _openServiceForm(context),
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
            // Top Summary Card
            _buildSummaryBanner(),

            // Category Filter Chips
            _buildCategoryTabs(),

            // Services List
            Expanded(
              child: filteredServices.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: filteredServices.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        return _buildServiceCard(service);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openServiceForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add New Service',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        elevation: 3,
      ),
    );
  }

  Widget _buildSummaryBanner() {
    final activeCount = _services.where((s) => s.isActive).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009D45), Color(0xFF007A35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Mentorship Catalog',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$activeCount of ${_services.length} services active and bookable by learners',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
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

  Widget _buildCategoryTabs() {
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.line,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(ExpertServiceItem service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: service.isActive
              ? AppColors.line
              : AppColors.line.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category tag, Status switch, Menu
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 13, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        '${service.durationMinutes} mins',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  service.isActive ? 'Active' : 'Paused',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: service.isActive
                        ? const Color(0xFF22C55E)
                        : AppColors.muted,
                  ),
                ),
                const SizedBox(width: 6),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: service.isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => service.isActive = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            service.isActive
                                ? '${service.title} is now active'
                                : '${service.title} is now paused',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Service Title & Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(service.icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${service.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              service.description,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Deliverables Checklist
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What the learner gets:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...service.deliverables.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              d,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Actions row: Edit & Delete
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openServiceForm(context, service: service),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 20),
                  tooltip: 'Delete Service',
                  onPressed: () => _confirmDeleteService(service),
                ),
              ],
            ),
          ],
        ),
      ),
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
              child: const Icon(Icons.category_outlined,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Services Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'There are no services matching this category filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  void _openServiceForm(BuildContext context, {ExpertServiceItem? service}) {
    final isEditing = service != null;
    final titleCtrl = TextEditingController(text: service?.title ?? '');
    final descCtrl = TextEditingController(text: service?.description ?? '');
    final priceCtrl =
        TextEditingController(text: service != null ? '${service.price.toInt()}' : '999');
    int duration = service?.durationMinutes ?? 45;
    String category = service?.category ?? 'Mentorship';
    final List<TextEditingController> deliverableCtrls = (service?.deliverables ?? [
      'Live 1:1 consultation & screen share',
      'Follow-up summary notes and next steps',
    ])
        .map((d) => TextEditingController(text: d))
        .toList();

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
                  padding: const EdgeInsets.all(20),
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
                      Text(
                        isEditing ? 'Edit Service' : 'Add New Service',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      const Text('Service Title',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          hintText: 'e.g. Flutter Architecture Review',
                          prefixIcon: const Icon(Icons.title_rounded,
                              size: 20, color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Category & Duration
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Category',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.field,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: category,
                                      isExpanded: true,
                                      items: [
                                        'Mentorship',
                                        'Technical',
                                        'Interview',
                                        'Career',
                                      ].map((c) {
                                        return DropdownMenuItem(
                                            value: c, child: Text(c));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => category = val);
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
                                const Text('Duration',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.field,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: duration,
                                      isExpanded: true,
                                      items: [15, 30, 45, 60, 90].map((d) {
                                        return DropdownMenuItem(
                                            value: d, child: Text('$d mins'));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() => duration = val);
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
                      const SizedBox(height: 14),

                      // Price
                      const Text('Price (₹ INR)',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '999',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Text(
                              '₹',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Description
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Describe what value this session will provide to learners...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Deliverables
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Key Deliverables',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          TextButton.icon(
                            onPressed: () {
                              setModalState(() {
                                deliverableCtrls.add(TextEditingController());
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Point'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary),
                          ),
                        ],
                      ),
                      ...deliverableCtrls.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final ctrl = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: ctrl,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Code walkthrough & checklist',
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                              if (deliverableCtrls.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    setModalState(() {
                                      deliverableCtrls.removeAt(idx);
                                    });
                                  },
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please enter service title')),
                              );
                              return;
                            }
                            final parsedPrice =
                                double.tryParse(priceCtrl.text) ?? 499.0;
                            final deliverables = deliverableCtrls
                                .map((c) => c.text.trim())
                                .where((t) => t.isNotEmpty)
                                .toList();

                            setState(() {
                              if (isEditing) {
                                service.title = titleCtrl.text.trim();
                                service.description = descCtrl.text.trim();
                                service.price = parsedPrice;
                                service.durationMinutes = duration;
                                service.category = category;
                                service.deliverables = deliverables;
                              } else {
                                _services.add(
                                  ExpertServiceItem(
                                    id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
                                    title: titleCtrl.text.trim(),
                                    description: descCtrl.text.trim(),
                                    durationMinutes: duration,
                                    price: parsedPrice,
                                    category: category,
                                    isActive: true,
                                    icon: Icons.stars_rounded,
                                    deliverables: deliverables.isNotEmpty
                                        ? deliverables
                                        : ['Direct 1:1 session with expert'],
                                  ),
                                );
                              }
                            });

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEditing
                                    ? 'Service updated successfully'
                                    : 'New service published'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          child: Text(
                            isEditing ? 'Save Changes' : 'Publish Service',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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

  void _confirmDeleteService(ExpertServiceItem service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Service',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to delete "${service.title}"? Learners will no longer be able to book this package.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _services.removeWhere((s) => s.id == service.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service removed')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

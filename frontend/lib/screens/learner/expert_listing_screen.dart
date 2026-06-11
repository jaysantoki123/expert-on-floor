import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/expert_model.dart' as model;
import '../../providers/expert_provider.dart';
import 'expert_profile_screen.dart';

// ══════════════════════════════════════════════════════════════════
// Data Model
// ══════════════════════════════════════════════════════════════════
class ExpertModel {
  final String id;
  final String name;
  final String title;
  final String company;
  final double rating;
  final int reviews;
  final int pricePerHour;
  final List<String> skills;
  final String availability;
  final Color avatarColor;
  final bool isOnline;
  final String experience;
  final String bio;

  const ExpertModel({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.rating,
    required this.reviews,
    required this.pricePerHour,
    required this.skills,
    required this.availability,
    required this.avatarColor,
    required this.isOnline,
    required this.experience,
    required this.bio,
  });
}

final List<ExpertModel> dummyExperts = [
  ExpertModel(
    id: '1',
    name: 'Rahul Sharma',
    title: 'Senior Flutter Developer',
    company: 'Google',
    rating: 4.9,
    reviews: 340,
    pricePerHour: 999,
    skills: ['Flutter', 'Dart', 'Firebase', 'UI/UX'],
    availability: 'Available Today',
    avatarColor: const Color(0xFF5C6BC0),
    isOnline: true,
    experience: '8+ years',
    bio:
        'Ex-Google engineer with 8+ years of experience in Flutter and Mobile Development.',
  ),
  ExpertModel(
    id: '2',
    name: 'Amit Verma',
    title: 'Full Stack Developer',
    company: 'Microsoft',
    rating: 4.8,
    reviews: 210,
    pricePerHour: 799,
    skills: ['React', 'Node.js', 'MongoDB', 'AWS'],
    availability: 'Available',
    avatarColor: const Color(0xFF26A69A),
    isOnline: true,
    experience: '6+ years',
    bio:
        'Full stack developer with expertise in modern web technologies and cloud platforms.',
  ),
  ExpertModel(
    id: '3',
    name: 'Sneha Iyer',
    title: 'UI/UX Designer',
    company: 'Figma',
    rating: 4.7,
    reviews: 180,
    pricePerHour: 799,
    skills: ['Figma', 'Adobe XD', 'Prototyping', 'Design Systems'],
    availability: 'Busy Today',
    avatarColor: const Color(0xFFEC407A),
    isOnline: false,
    experience: '5+ years',
    bio:
        'Creative UI/UX designer specializing in user-centered design and design systems.',
  ),
  ExpertModel(
    id: '4',
    name: 'Vikram Patel',
    title: 'AI/ML Engineer',
    company: 'Amazon',
    rating: 4.6,
    reviews: 150,
    pricePerHour: 1199,
    skills: ['Python', 'TensorFlow', 'PyTorch', 'NLP'],
    availability: 'Available',
    avatarColor: const Color(0xFFFF7043),
    isOnline: true,
    experience: '7+ years',
    bio:
        'AI/ML engineer with deep expertise in deep learning, NLP, and production ML systems.',
  ),
  ExpertModel(
    id: '5',
    name: 'Priya Nair',
    title: 'Data Scientist',
    company: 'Netflix',
    rating: 4.8,
    reviews: 195,
    pricePerHour: 899,
    skills: ['Python', 'R', 'Tableau', 'SQL'],
    availability: 'Available Today',
    avatarColor: const Color(0xFF7E57C2),
    isOnline: true,
    experience: '5+ years',
    bio:
        'Data scientist helping businesses unlock insights from complex datasets.',
  ),
  ExpertModel(
    id: '6',
    name: 'Arjun Mehta',
    title: 'DevOps Engineer',
    company: 'Flipkart',
    rating: 4.5,
    reviews: 120,
    pricePerHour: 699,
    skills: ['Docker', 'Kubernetes', 'CI/CD', 'AWS'],
    availability: 'Available',
    avatarColor: const Color(0xFF29B6F6),
    isOnline: false,
    experience: '4+ years',
    bio:
        'DevOps specialist with expertise in containerization and cloud infrastructure.',
  ),
  ExpertModel(
    id: '7',
    name: 'Kavya Reddy',
    title: 'iOS Developer',
    company: 'Apple',
    rating: 4.9,
    reviews: 260,
    pricePerHour: 1099,
    skills: ['Swift', 'SwiftUI', 'Xcode', 'CoreData'],
    availability: 'Available',
    avatarColor: const Color(0xFF66BB6A),
    isOnline: true,
    experience: '6+ years',
    bio:
        'iOS developer with a passion for building elegant and performant Apple ecosystem apps.',
  ),
  ExpertModel(
    id: '8',
    name: 'Rohan Gupta',
    title: 'Blockchain Developer',
    company: 'Coinbase',
    rating: 4.6,
    reviews: 98,
    pricePerHour: 1299,
    skills: ['Solidity', 'Web3.js', 'Ethereum', 'Smart Contracts'],
    availability: 'Busy Today',
    avatarColor: const Color(0xFFFFA726),
    isOnline: false,
    experience: '4+ years',
    bio:
        'Blockchain developer building decentralized applications and smart contracts.',
  ),
];

// ══════════════════════════════════════════════════════════════════
// Expert Listing Screen
// ══════════════════════════════════════════════════════════════════
class ExpertListingScreen extends StatefulWidget {
  const ExpertListingScreen({super.key});

  @override
  State<ExpertListingScreen> createState() => _ExpertListingScreenState();
}

class _ExpertListingScreenState extends State<ExpertListingScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSkill = 'All';
  String _sortBy = 'Top Rated';
  bool _searchFocused = false;

  final List<String> _categories = [
    'All',
    'Development',
    'Design',
    'Data Science',
    'AI/ML',
    'DevOps',
    'Blockchain',
  ];
  final List<String> _skills = [
    'All',
    'Flutter',
    'React',
    'Python',
    'Figma',
    'AWS',
    'Swift',
  ];
  final List<String> _sortOptions = [
    'Top Rated',
    'Price: Low to High',
    'Price: High to Low',
    'Most Reviews',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(
      () => setState(() => _searchFocused = _searchFocus.hasFocus),
    );
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text),
    );
    
    // Fetch experts from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpertProvider>().fetchExperts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Filter + Search ────────────────────────────────────────────
  List<model.ExpertModel> get _filteredExperts {
    final provider = context.read<ExpertProvider>();
    List<model.ExpertModel> result = List.from(provider.experts);

    // Search
    if (_searchQuery.isNotEmpty) {
      result = result.where((e) {
        return e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.skills.any(
              (s) => s.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
      }).toList();
    }

    // Skill filter
    if (_selectedSkill != 'All') {
      result = result.where((e) => e.skills.contains(_selectedSkill)).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Top Rated':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price: Low to High':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpertProvider>();
    final experts = _filteredExperts;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ──────────────────────────────────
            _buildTopBar(),
            const SizedBox(height: 12),
            _buildSummaryCard(),

            // ── Search Bar ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _buildSearchBar(),
            ),

            // ── Filter Chips ─────────────────────────────
            _buildFilterRow(),
            const SizedBox(height: 4),

            // ── Results count ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text(
                    '${experts.length} experts found',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Sort button
                  GestureDetector(
                    onTap: _showSortSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sort_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _sortBy,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Expert List ──────────────────────────────
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? _buildErrorState(provider.error!)
                      : experts.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () => provider.fetchExperts(forceRefresh: true),
                              color: AppColors.primary,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: experts.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (_, i) => _ExpertCard(
                                  expert: experts[i],
                                  onTap: () => _openProfile(experts[i]),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Find Experts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Discover top mentors, coaches, and industry experts for your goals.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primarySoft, Color(0xFFEDEFFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(
                  child: Text(
                    '120+ mentors ready to guide your learning journey.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Icon(
                  Icons.light_mode_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBadge('Average rating', '4.8'),
                _buildStatBadge('Fast response', '92%'),
                _buildStatBadge('Verified experts', '80+'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Use the search and filters below to quickly narrow down the best expert for your needs.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.ink,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchFocused ? AppColors.primary : AppColors.line,
          width: _searchFocused ? 1.8 : 1.4,
        ),
        boxShadow: _searchFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.search_rounded,
              color: _searchFocused ? AppColors.primary : AppColors.muted,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Search experts...',
                hintStyle: TextStyle(
                      color: AppColors.muted.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Filter Row ─────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Category Dropdown
          _DropdownChip(
            label: 'Category',
            value: _selectedCategory,
            items: _categories,
            onSelected: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(width: 10),

          // Skills Dropdown
          _DropdownChip(
            label: 'Skills',
            value: _selectedSkill,
            items: _skills,
            onSelected: (v) => setState(() => _selectedSkill = v),
          ),
          const SizedBox(width: 10),

          // Filters chip
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load experts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.read<ExpertProvider>().fetchExperts(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No experts found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  // ── Sort Bottom Sheet ──────────────────────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map(
              (opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _sortBy == opt
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _sortBy == opt ? AppColors.primary : AppColors.muted,
                  size: 20,
                ),
                title: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _sortBy == opt
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: _sortBy == opt ? AppColors.primary : AppColors.ink,
                  ),
                ),
                onTap: () {
                  setState(() => _sortBy = opt);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Filter Bottom Sheet ────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(
        selectedSkill: _selectedSkill,
        skills: _skills,
        onApply: (skill) {
          setState(() => _selectedSkill = skill);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openProfile(model.ExpertModel expert) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpertProfileScreen(expert: expert)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Dropdown Chip
// ══════════════════════════════════════════════════════════════════
class _DropdownChip extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _DropdownChip({
    required this.label,
    required this.value,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value != 'All';
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: items
                      .map(
                        (item) => GestureDetector(
                          onTap: () {
                            onSelected(item);
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: value == item
                                  ? AppColors.primary
                                  : AppColors.field,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: value == item
                                    ? AppColors.primary
                                    : AppColors.line,
                              ),
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: value == item
                                    ? AppColors.white
                                    : AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySoft : AppColors.field,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Text(
              isActive ? value : label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Filter Sheet
// ══════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final String selectedSkill;
  final List<String> skills;
  final ValueChanged<String> onApply;

  const _FilterSheet({
    required this.selectedSkill,
    required this.skills,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _tempSkill;
  RangeValues _priceRange = const RangeValues(0, 2000);
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    _tempSkill = widget.selectedSkill;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempSkill = 'All';
                      _priceRange = const RangeValues(0, 2000);
                      _minRating = 0;
                    });
                  },
                  child: const Text(
                    'Reset All',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Range
            const Text(
              'Price Range (₹/hr)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${_priceRange.start.toInt()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${_priceRange.end.toInt()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.line,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.12),
                trackHeight: 4,
              ),
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: 2000,
                divisions: 20,
                onChanged: (v) => setState(() => _priceRange = v),
              ),
            ),
            const SizedBox(height: 16),

            // Min Rating
            const Text(
              'Minimum Rating',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [0.0, 3.0, 4.0, 4.5].map((r) {
                final selected = _minRating == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _minRating = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.field,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.line,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (r > 0) ...[
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            r == 0 ? 'Any' : '$r+',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: selected ? AppColors.white : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => widget.onApply(_tempSkill),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Expert Card
// ══════════════════════════════════════════════════════════════════
class _ExpertCard extends StatelessWidget {
  final model.ExpertModel expert;
  final VoidCallback onTap;

  const _ExpertCard({required this.expert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────
            Stack(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    image: expert.profileImage != null
                        ? DecorationImage(
                            image: NetworkImage(expert.profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: expert.profileImage == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 32,
                        )
                      : null,
                ),
                // Online indicator
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // ── Info ─────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + arrow
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expert.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Role
                  Text(
                    expert.role,
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),

                  // Bio snippet
                  Text(
                    expert.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Rating and experience tags
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${expert.rating}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          expert.experience,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Skills chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: expert.skills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // ── Price ────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${expert.price}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '/hr',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: const Text(
                    'Book',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

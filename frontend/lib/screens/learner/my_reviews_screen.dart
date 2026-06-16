import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════
// Data Model
// ══════════════════════════════════════════════════════════════════
class ReviewModel {
  final String id;
  final String expertName;
  final String expertRole;
  final String topic;
  final String date;
  final double rating;
  final String review;
  final Color avatarColor;
  final bool isHelpful;
  final int helpfulCount;
  final String sessionType;
  final String duration;
  final String expertReply;

  const ReviewModel({
    required this.id,
    required this.expertName,
    required this.expertRole,
    required this.topic,
    required this.date,
    required this.rating,
    required this.review,
    required this.avatarColor,
    this.isHelpful = false,
    this.helpfulCount = 0,
    required this.sessionType,
    required this.duration,
    this.expertReply = '',
  });
}

final List<ReviewModel> _dummyReviews = [
  ReviewModel(
    id: '1',
    expertName: 'Rahul Sharma',
    expertRole: 'Senior Flutter Developer',
    topic: 'Flutter State Management',
    date: '10 May, 2026',
    rating: 5.0,
    review:
        'Amazing session! Rahul explained Provider and Riverpod concepts very clearly with real-world examples. I finally understand state management properly. Highly recommend to anyone learning Flutter!',
    avatarColor: const Color(0xFF5C6BC0),
    isHelpful: true,
    helpfulCount: 12,
    sessionType: 'Video Call',
    duration: '60 min',
    expertReply:
        'Thank you so much! It was a pleasure teaching you. Keep building amazing apps! 🚀',
  ),
  ReviewModel(
    id: '2',
    expertName: 'Sneha Iyer',
    expertRole: 'UI/UX Designer',
    topic: 'Figma Fundamentals & Design Systems',
    date: '5 May, 2026',
    rating: 4.5,
    review:
        'Great insights on design systems. Sneha is very patient and explains things step by step. The session was well structured and I learned a lot about component libraries.',
    avatarColor: const Color(0xFFEC407A),
    isHelpful: false,
    helpfulCount: 8,
    sessionType: 'Video Call',
    duration: '45 min',
    expertReply: '',
  ),
  ReviewModel(
    id: '3',
    expertName: 'Vikram Patel',
    expertRole: 'AI/ML Engineer',
    topic: 'Introduction to Machine Learning',
    date: '28 Apr, 2026',
    rating: 5.0,
    review:
        'Mind-blowing session! Vikram has an incredible ability to simplify complex ML concepts. The hands-on Python examples were super helpful. Best investment I have ever made!',
    avatarColor: const Color(0xFFFF7043),
    isHelpful: true,
    helpfulCount: 24,
    sessionType: 'Video Call',
    duration: '90 min',
    expertReply:
        'Glad you enjoyed it! ML is fascinating once you get the basics right. Looking forward to our next session! 🤖',
  ),
  ReviewModel(
    id: '4',
    expertName: 'Arjun Mehta',
    expertRole: 'DevOps Engineer',
    topic: 'Docker & Kubernetes Basics',
    date: '18 Apr, 2026',
    rating: 4.5,
    review:
        'Very detailed and practical explanation of Docker concepts. Arjun walked me through setting up a complete containerized environment. Will definitely book again.',
    avatarColor: const Color(0xFF29B6F6),
    isHelpful: false,
    helpfulCount: 5,
    sessionType: 'Video Call',
    duration: '60 min',
    expertReply: '',
  ),
  ReviewModel(
    id: '5',
    expertName: 'Kavya Reddy',
    expertRole: 'iOS Developer',
    topic: 'SwiftUI Animations',
    date: '12 Apr, 2026',
    rating: 5.0,
    review:
        'Exceptional session on SwiftUI animations! Kavya showed me techniques I had never seen in any tutorial. The custom transition examples were gold. 10/10 would recommend!',
    avatarColor: const Color(0xFF66BB6A),
    isHelpful: true,
    helpfulCount: 18,
    sessionType: 'Audio Call',
    duration: '30 min',
    expertReply:
        'Thank you for the kind words! SwiftUI animations are so fun once you get the hang of it! ✨',
  ),
  ReviewModel(
    id: '6',
    expertName: 'Rahul Sharma',
    expertRole: 'Senior Flutter Developer',
    topic: 'Flutter Animations Deep Dive',
    date: '5 Apr, 2026',
    rating: 5.0,
    review:
        'Second session with Rahul and it was even better than the first! The animation deep dive covered everything from basic to complex custom painters. Absolutely worth every rupee.',
    avatarColor: const Color(0xFF5C6BC0),
    isHelpful: true,
    helpfulCount: 31,
    sessionType: 'Video Call',
    duration: '90 min',
    expertReply:
        'Always a pleasure working with you! Your progress has been incredible. See you in the next session! 💪',
  ),
  ReviewModel(
    id: '7',
    expertName: 'Amit Verma',
    expertRole: 'Full Stack Developer',
    topic: 'React Native Navigation',
    date: '1 May, 2026',
    rating: 4.0,
    review:
        'Good session overall. Amit explained React Navigation v6 clearly. Could have gone deeper into nested navigators but the basics were solid.',
    avatarColor: const Color(0xFF26A69A),
    isHelpful: false,
    helpfulCount: 3,
    sessionType: 'Audio Call',
    duration: '60 min',
    expertReply: '',
  ),
];

// ══════════════════════════════════════════════════════════════════
// My Reviews Screen
// ══════════════════════════════════════════════════════════════════
class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  String _sortBy = 'Newest First';
  double _filterRating = 0;
  bool _showSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  late List<bool> _helpfulStates;

  final _sortOptions = [
    'Newest First',
    'Oldest First',
    'Highest Rated',
    'Lowest Rated',
    'Most Helpful',
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _helpfulStates = _dummyReviews.map((r) => r.isHelpful).toList();
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────
  List<ReviewModel> get _filtered {
    List<ReviewModel> result = List.from(_dummyReviews);

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (r) =>
                r.expertName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                r.topic.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                r.review.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_filterRating > 0) {
      result = result.where((r) => r.rating >= _filterRating).toList();
    }

    switch (_sortBy) {
      case 'Oldest First':
        result = result.reversed.toList();
        break;
      case 'Highest Rated':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Lowest Rated':
        result.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'Most Helpful':
        result.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
    }

    return result;
  }

  double get _avgRating => _dummyReviews.isEmpty
      ? 0
      : _dummyReviews.fold(0.0, (s, r) => s + r.rating) / _dummyReviews.length;

  Map<int, int> get _ratingDistribution {
    final map = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _dummyReviews) {
      final key = r.rating.floor();
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── Summary card ──────────────
                    SliverToBoxAdapter(child: _buildSummaryCard()),

                    // ── Rating breakdown ──────────
                    SliverToBoxAdapter(child: _buildRatingBreakdown()),

                    // ── Controls ──────────────────
                    SliverToBoxAdapter(child: _buildControls()),

                    // ── Search bar ────────────────
                    if (_showSearch)
                      SliverToBoxAdapter(child: _buildSearchBar()),

                    // ── Reviews list ──────────────
                    _filtered.isEmpty
                        ? SliverFillRemaining(child: _buildEmptyState())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 300 + i * 80),
                                curve: Curves.easeOutCubic,
                                builder: (_, val, child) => Opacity(
                                  opacity: val,
                                  child: Transform.translate(
                                    offset: Offset(0, 24 * (1 - val)),
                                    child: child,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    i == _filtered.length - 1 ? 30 : 14,
                                  ),
                                  child: _ReviewCard(
                                    review: _filtered[i],
                                    isHelpful:
                                        _helpfulStates[_dummyReviews.indexOf(
                                          _filtered[i],
                                        )],
                                    onHelpfulTap: () {
                                      final idx = _dummyReviews.indexOf(
                                        _filtered[i],
                                      );
                                      setState(
                                        () => _helpfulStates[idx] =
                                            !_helpfulStates[idx],
                                      );
                                    },
                                    onEdit: () => _showEditSheet(_filtered[i]),
                                    onDelete: () =>
                                        _showDeleteDialog(_filtered[i]),
                                  ),
                                ),
                              ),
                              childCount: _filtered.length,
                            ),
                          ),
                  ],
                ),
              ),
            ],
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
                  'My Reviews',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Reviews you have given to experts',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          // Search
          GestureDetector(
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchCtrl.clear();
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showSearch ? AppColors.primarySoft : AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showSearch ? AppColors.primary : AppColors.line,
                ),
              ),
              child: Icon(
                _showSearch ? Icons.close_rounded : Icons.search_rounded,
                color: _showSearch ? AppColors.primary : AppColors.ink,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sort
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.sort_rounded,
                color: AppColors.ink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Summary Card
  // ══════════════════════════════════════════════════════════════
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
            color: AppColors.primary.withValues(alpha:  0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Deco circles
          Positioned(
            top: -25,
            right: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:  0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:  0.05),
              ),
            ),
          ),

          Row(
            children: [
              // Big rating
              Column(
                children: [
                  Text(
                    _avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < _avgRating.floor()
                            ? Icons.star_rounded
                            : i < _avgRating.ceil()
                            ? Icons.star_half_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_dummyReviews.length} reviews given',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha:  0.75),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Stats column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryStatRow(
                      Icons.thumb_up_rounded,
                      '${_dummyReviews.where((r) => r.isHelpful).length} helpful votes',
                      Colors.lightBlueAccent,
                    ),
                    const SizedBox(height: 8),
                    _summaryStatRow(
                      Icons.reply_rounded,
                      '${_dummyReviews.where((r) => r.expertReply.isNotEmpty).length} expert replies',
                      Colors.greenAccent,
                    ),
                    const SizedBox(height: 8),
                    _summaryStatRow(
                      Icons.emoji_events_rounded,
                      '${_dummyReviews.where((r) => r.rating >= 5).length} five-star sessions',
                      Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:  0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:  0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏅', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          const Text(
                            'Top Reviewer',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
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

  Widget _summaryStatRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha:  0.88),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Rating Breakdown
  // ══════════════════════════════════════════════════════════════
  Widget _buildRatingBreakdown() {
    final dist = _ratingDistribution;
    final max = dist.values.isEmpty
        ? 1
        : dist.values.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating Breakdown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(5, (i) {
            final star = 5 - i;
            final count = dist[star] ?? 0;
            final pct = max == 0 ? 0.0 : count / max.toDouble();
            final isFiltered = _filterRating == star.toDouble();

            return GestureDetector(
              onTap: () => setState(() {
                _filterRating = isFiltered ? 0 : star.toDouble();
              }),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Star number
                    Text(
                      '$star',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isFiltered ? AppColors.primary : AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: isFiltered ? AppColors.primary : Colors.amber,
                    ),
                    const SizedBox(width: 10),

                    // Bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: pct),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (_, val, _) => LinearProgressIndicator(
                            value: val,
                            minHeight: 10,
                            backgroundColor: AppColors.field,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFiltered ? AppColors.primary : Colors.amber,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Count
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isFiltered
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          if (_filterRating > 0) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _filterRating = 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Clear filter (${_filterRating.toInt()}★)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Controls
  // ══════════════════════════════════════════════════════════════
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: [
          Text(
            '${_filtered.length} review${_filtered.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _sortBy,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Search Bar
  // ══════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:  0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Search by expert, topic or keyword...',
                  hintStyle: TextStyle(
                    color: AppColors.muted.withValues(alpha:  0.7),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () => _searchCtrl.clear(),
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.muted,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Empty State
  // ══════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
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
              Icons.rate_review_outlined,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No reviews found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search or filter',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Bottom Sheets / Dialogs
  // ══════════════════════════════════════════════════════════════
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
            const SizedBox(height: 20),
            const Text(
              'Sort Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map((opt) {
              final sel = _sortBy == opt;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.line,
                      width: 2,
                    ),
                  ),
                  child: sel
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 13,
                        )
                      : null,
                ),
                title: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                    color: sel ? AppColors.primary : AppColors.ink,
                  ),
                ),
                onTap: () {
                  setState(() => _sortBy = opt);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(ReviewModel review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditReviewSheet(review: review),
    );
  }

  void _showDeleteDialog(ReviewModel review) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Review?',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        content: Text(
          'Are you sure you want to delete your review for ${review.expertName}?',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Review deleted'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Review Card
// ══════════════════════════════════════════════════════════════════
class _ReviewCard extends StatefulWidget {
  final ReviewModel review;
  final bool isHelpful;
  final VoidCallback onHelpfulTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.isHelpful,
    required this.onHelpfulTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;
  bool _showFullReview = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final isLong = review.review.length > 140;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _expanded
              ? AppColors.primary.withValues(alpha:  0.35)
              : AppColors.line,
          width: _expanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: review.avatarColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: review.avatarColor.withValues(alpha:  0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              review.expertName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          // Options menu
                          GestureDetector(
                            onTap: () => _showOptions(context, review),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.field,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.more_horiz_rounded,
                                color: AppColors.muted,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review.expertRole,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Stars + date
                      Row(
                        children: [
                          // Stars
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < review.rating.floor()
                                    ? Icons.star_rounded
                                    : i < review.rating.ceil()
                                    ? Icons.star_half_rounded
                                    : Icons.star_border_rounded,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            review.date,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Topic chip ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha:  0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.topic_outlined,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          review.topic,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                _miniTag(
                  icon: review.sessionType == 'Video Call'
                      ? Icons.videocam_rounded
                      : Icons.call_rounded,
                  label: review.sessionType,
                  color: Colors.teal,
                ),
                _miniTag(
                  icon: Icons.timer_outlined,
                  label: review.duration,
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Review text ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showFullReview || !isLong
                      ? review.review
                      : '${review.review.substring(0, 140)}...',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.ink,
                    height: 1.6,
                  ),
                ),
                if (isLong) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showFullReview = !_showFullReview),
                    child: Text(
                      _showFullReview ? 'Show less ▲' : 'Read more ▼',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Expert reply ──────────────────────────
          if (review.expertReply.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha:  0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: review.avatarColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.expertName.split(' ')[0],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Expert',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.expertReply,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Footer ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                // Helpful button
                GestureDetector(
                  onTap: widget.onHelpfulTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isHelpful
                          ? const Color(0xFFE3F2FD)
                          : AppColors.field,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.isHelpful ? Colors.blue : AppColors.line,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isHelpful
                              ? Icons.thumb_up_rounded
                              : Icons.thumb_up_outlined,
                          size: 14,
                          color: widget.isHelpful
                              ? Colors.blue
                              : AppColors.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Helpful (${widget.isHelpful ? review.helpfulCount + 1 : review.helpfulCount})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: widget.isHelpful
                                ? Colors.blue
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // Edit button
                GestureDetector(
                  onTap: widget.onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha:  0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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

  Widget _miniTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, ReviewModel review) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _optionTile(
              Icons.edit_rounded,
              'Edit Review',
              AppColors.primary,
              () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
            _optionTile(
              Icons.share_rounded,
              'Share Review',
              Colors.indigo,
              () => Navigator.pop(context),
            ),
            _optionTile(Icons.copy_rounded, 'Copy Review', Colors.teal, () {
              Clipboard.setData(ClipboardData(text: review.review));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Review copied!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }),
            _optionTile(
              Icons.delete_outline_rounded,
              'Delete Review',
              Colors.redAccent,
              () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha:  0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Edit Review Sheet
// ══════════════════════════════════════════════════════════════════
class _EditReviewSheet extends StatefulWidget {
  final ReviewModel review;

  const _EditReviewSheet({required this.review});

  @override
  State<_EditReviewSheet> createState() => _EditReviewSheetState();
}

class _EditReviewSheetState extends State<_EditReviewSheet> {
  late int _selectedStar;
  late TextEditingController _ctrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedStar = widget.review.rating.round();
    _ctrl = TextEditingController(text: widget.review.review);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 20),

            // Expert info
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: widget.review.avatarColor,
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review.expertName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      widget.review.topic,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stars
            const Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedStar = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedScale(
                      scale: _selectedStar > i ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        _selectedStar > i
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 36,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Review text
            const Text(
              'Your Review',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ctrl,
              maxLines: 5,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                hintStyle: TextStyle(
                  color: AppColors.muted.withValues(alpha:  0.7),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.field,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Update button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await Future.delayed(
                          const Duration(milliseconds: 1200),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Review updated successfully! ✅',
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Update Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

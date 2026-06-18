import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'ask_question_screen.dart';
import 'question_detail_screen.dart';


// ══════════════════════════════════════════════════════════════════
// Data Model
// ══════════════════════════════════════════════════════════════════
class CommunityQuestion {
  final String id;
  final String title;
  final String body;
  final String authorName;
  final String authorRole;
  final Color authorColor;
  final String timeAgo;
  final int answers;
  final int likes;
  final int views;
  final List<String> tags;
  final bool isAnswered;
  final bool isPinned;
  final bool isLiked;

  const CommunityQuestion({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.authorRole,
    required this.authorColor,
    required this.timeAgo,
    required this.answers,
    required this.likes,
    required this.views,
    required this.tags,
    this.isAnswered = false,
    this.isPinned = false,
    this.isLiked = false,
  });
}

final List<CommunityQuestion> _allQuestions = [
  CommunityQuestion(
    id: '1',
    title: 'How do I transition from Android to Flutter?',
    body:
        'I have been an Android developer for 3 years and want to move to Flutter. What are the key differences I should know about? Any resources you would recommend?',
    authorName: 'Ravi Kumar',
    authorRole: 'Android Developer',
    authorColor: const Color(0xFF5C6BC0),
    timeAgo: '2 hrs ago',
    answers: 1,
    likes: 34,
    views: 128,
    tags: ['Flutter', 'Android', 'Beginner'],
    isAnswered: true,
    isPinned: true,
    isLiked: false,
  ),
  CommunityQuestion(
    id: '2',
    title: 'Best state management flutter in 2026?',
    body:
        'With so many state management solutions available, which one should I pick for a large-scale Flutter app in 2026? Riverpod, BLoC or GetX?',
    authorName: 'Priya Singh',
    authorRole: 'Flutter Developer',
    authorColor: const Color(0xFFEC407A),
    timeAgo: '5 hrs ago',
    answers: 18,
    likes: 38,
    views: 245,
    tags: ['Flutter', 'State Management', 'Riverpod', 'BLoC'],
    isAnswered: true,
    isLiked: true,
  ),
  CommunityQuestion(
    id: '3',
    title: 'How to improve Flutter app performance?',
    body:
        'My Flutter app is getting slow with large lists. I have tried ListView.builder but still facing jank. Any tips for optimising performance?',
    authorName: 'Arjun Mehta',
    authorRole: 'Mobile Dev',
    authorColor: const Color(0xFF26A69A),
    timeAgo: '1 day ago',
    answers: 8,
    likes: 13,
    views: 89,
    tags: ['Flutter', 'Performance', 'Optimization'],
    isAnswered: false,
    isLiked: false,
  ),
  CommunityQuestion(
    id: '4',
    title: "What's the best way to learn Dart?",
    body:
        'I am new to Dart coming from JavaScript. What learning path would you recommend? Should I start with Dart fundamentals or jump straight into Flutter?',
    authorName: 'Sneha Rao',
    authorRole: 'Web Developer',
    authorColor: const Color(0xFFFF7043),
    timeAgo: '2 days ago',
    answers: 6,
    likes: 10,
    views: 67,
    tags: ['Dart', 'Beginner', 'Learning'],
    isAnswered: false,
    isLiked: false,
  ),
  CommunityQuestion(
    id: '5',
    title: 'Difference between StatelessWidget and StatefulWidget?',
    body:
        'Can someone explain clearly when to use StatelessWidget vs StatefulWidget? I keep getting confused about when the widget needs to rebuild.',
    authorName: 'Kavya Nair',
    authorRole: 'Beginner Developer',
    authorColor: const Color(0xFF7E57C2),
    timeAgo: '3 days ago',
    answers: 22,
    likes: 56,
    views: 320,
    tags: ['Flutter', 'Widgets', 'Beginner'],
    isAnswered: true,
    isLiked: true,
  ),
  CommunityQuestion(
    id: '6',
    title: 'How to implement push notifications in Flutter?',
    body:
        'I want to add FCM push notifications to my Flutter app. Which package should I use and what is the setup process for both iOS and Android?',
    authorName: 'Rohan Gupta',
    authorRole: 'Full Stack Dev',
    authorColor: const Color(0xFF29B6F6),
    timeAgo: '4 days ago',
    answers: 14,
    likes: 29,
    views: 198,
    tags: ['Flutter', 'Firebase', 'Notifications'],
    isAnswered: true,
    isLiked: false,
  ),
  CommunityQuestion(
    id: '7',
    title: 'Best practices for Flutter folder structure?',
    body:
        'How do you organise your Flutter project? Do you prefer feature-first or layer-first folder structure? Share your approach.',
    authorName: 'Divya Sharma',
    authorRole: 'Senior Developer',
    authorColor: const Color(0xFF66BB6A),
    timeAgo: '5 days ago',
    answers: 31,
    likes: 72,
    views: 445,
    tags: ['Flutter', 'Architecture', 'Best Practices'],
    isAnswered: true,
    isLiked: false,
  ),
  CommunityQuestion(
    id: '8',
    title: 'How to handle API errors gracefully in Flutter?',
    body:
        'What is the best pattern for handling network errors and showing user-friendly messages in Flutter apps?',
    authorName: 'Arun Patel',
    authorRole: 'Backend Developer',
    authorColor: const Color(0xFFFFA726),
    timeAgo: '1 week ago',
    answers: 0,
    likes: 7,
    views: 43,
    tags: ['Flutter', 'API', 'Error Handling'],
    isAnswered: false,
    isLiked: false,
  ),
];

// ══════════════════════════════════════════════════════════════════
// Community Screen
// ══════════════════════════════════════════════════════════════════
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  bool _showSearch = false;
  bool _searchFocused = false;
  String _searchQuery = '';
  String _selectedTag = 'All';
  late List<bool> _likedStates;

  final _popularTags = [
    'All',
    'Flutter',
    'Dart',
    'Firebase',
    'State Management',
    'Performance',
    'Beginner',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _likedStates = _allQuestions.map((q) => q.isLiked).toList();
    _searchFocus.addListener(
      () => setState(() => _searchFocused = _searchFocus.hasFocus),
    );
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Filtered lists ─────────────────────────────────────────────
  List<CommunityQuestion> _applySearch(List<CommunityQuestion> list) {
    if (_searchQuery.isEmpty && _selectedTag == 'All') return list;
    return list.where((q) {
      final matchSearch =
          _searchQuery.isEmpty ||
          q.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.body.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      final matchTag = _selectedTag == 'All' || q.tags.contains(_selectedTag);
      return matchSearch && matchTag;
    }).toList();
  }

  List<CommunityQuestion> get _forYou => _applySearch(_allQuestions);
  List<CommunityQuestion> get _recent => _applySearch(
    List.from(_allQuestions)..sort((a, b) => a.id.compareTo(b.id)),
  );
  List<CommunityQuestion> get _unanswered =>
      _applySearch(_allQuestions.where((q) => !q.isAnswered).toList());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────
              _buildHeader(),

              // ── Search Bar ────────────────────────
              if (_showSearch) _buildSearchBar(),

              // ── Tag chips ─────────────────────────
              _buildTagChips(),

              // ── Tab Bar ───────────────────────────
              _buildTabBar(),

              // ── Content ───────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _QuestionList(
                      questions: _forYou,
                      likedStates: _likedStates,
                      allQuestions: _allQuestions,
                      onLike: _toggleLike,
                      onTap: _openQuestion,
                    ),
                    _QuestionList(
                      questions: _recent,
                      likedStates: _likedStates,
                      allQuestions: _allQuestions,
                      onLike: _toggleLike,
                      onTap: _openQuestion,
                    ),
                    _QuestionList(
                      questions: _unanswered,
                      likedStates: _likedStates,
                      allQuestions: _allQuestions,
                      onLike: _toggleLike,
                      onTap: _openQuestion,
                      emptyLabel: 'No unanswered questions',
                      emptySubtitle: 'All questions have been answered!',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Ask FAB ───────────────────────────────
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'community_fab',
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AskQuestionScreen())),
          backgroundColor: AppColors.primary,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Ask Question',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
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
          // Title + subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Learn together, grow together',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),

          // Search toggle
          _HeaderBtn(
            icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
            isActive: _showSearch,
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  _searchFocus.unfocus();
                }
              });
            },
          ),
          const SizedBox(width: 8),

          // Notifications
          _HeaderBtn(
            icon: Icons.notifications_outlined,
            onTap: () {},
            badge: true,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Search Bar
  // ══════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _searchFocused ? AppColors.primary : AppColors.line,
            width: _searchFocused ? 1.8 : 1.2,
          ),
          boxShadow: _searchFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
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
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Search questions, tags...',
                  hintStyle: TextStyle(
                    color: AppColors.muted.withOpacity(0.7),
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
                      color: AppColors.muted.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Tag Chips
  // ══════════════════════════════════════════════════════════════
  Widget _buildTagChips() {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _popularTags.length,
              itemBuilder: (_, i) {
                final tag = _popularTags[i];
                final selected = _selectedTag == tag;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTag = tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.field,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.line,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.white : AppColors.muted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, color: AppColors.line),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Tab Bar
  // ══════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.muted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.line,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [Text('For You')],
            ),
          ),
          const Tab(text: 'Recent'),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unanswered'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_unanswered.length}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

  // ── Actions ────────────────────────────────────────────────────
  void _toggleLike(int globalIndex) {
    setState(() => _likedStates[globalIndex] = !_likedStates[globalIndex]);
  }

  void _openQuestion(CommunityQuestion q) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuestionDetailScreen(question: q)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Question List
// ══════════════════════════════════════════════════════════════════
class _QuestionList extends StatelessWidget {
  final List<CommunityQuestion> questions;
  final List<bool> likedStates;
  final List<CommunityQuestion> allQuestions;
  final Function(int) onLike;
  final Function(CommunityQuestion) onTap;
  final String emptyLabel;
  final String emptySubtitle;

  const _QuestionList({
    required this.questions,
    required this.likedStates,
    required this.allQuestions,
    required this.onLike,
    required this.onTap,
    this.emptyLabel = 'No questions found',
    this.emptySubtitle = 'Try a different filter or search term',
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
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
                Icons.forum_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              emptySubtitle,
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: questions.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.line, indent: 0),
      itemBuilder: (_, i) {
        final q = questions[i];
        final globalIdx = allQuestions.indexOf(q);
        final isLiked = globalIdx >= 0 ? likedStates[globalIdx] : q.isLiked;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 250 + i * 60),
          curve: Curves.easeOutCubic,
          builder: (_, val, child) => Opacity(
            opacity: val,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - val)),
              child: child,
            ),
          ),
          child: _QuestionTile(
            question: q,
            isLiked: isLiked,
            onLike: () {
              if (globalIdx >= 0) onLike(globalIdx);
            },
            onTap: () => onTap(q),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Question Tile  (matches the image design)
// ══════════════════════════════════════════════════════════════════
class _QuestionTile extends StatelessWidget {
  final CommunityQuestion question;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _QuestionTile({
    required this.question,
    required this.isLiked,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primarySoft,
      highlightColor: AppColors.primarySoft.withOpacity(0.3),
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar column ─────────────────────
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: question.authorColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: question.authorColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // ── Content ───────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pinned / answered badges
                  if (question.isPinned || question.isAnswered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          if (question.isPinned)
                            _badge(
                              icon: Icons.push_pin_rounded,
                              label: 'Pinned',
                              color: Colors.orange,
                            ),
                          if (question.isPinned && question.isAnswered)
                            const SizedBox(width: 6),
                          if (question.isAnswered)
                            _badge(
                              icon: Icons.check_circle_rounded,
                              label: 'Answered',
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),

                  // Question title
                  Text(
                    question.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Author + time
                  Row(
                    children: [
                      Text(
                        question.authorName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '  ·  ${question.timeAgo}',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tags
                  if (question.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: question.tags
                          .take(3)
                          .map((tag) => _TagPill(tag: tag))
                          .toList(),
                    ),
                  const SizedBox(height: 10),

                  // Stats row
                  Row(
                    children: [
                      _statItem(
                        icon: Icons.question_answer_outlined,
                        value: '${question.answers} answers',
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '·',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onLike,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _statItem(
                            key: ValueKey(isLiked),
                            icon: isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            value:
                                '${isLiked ? question.likes + 1 : question.likes} likes',
                            color: isLiked ? Colors.redAccent : AppColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '·',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      _statItem(
                        icon: Icons.remove_red_eye_outlined,
                        value: '${question.views}',
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Right arrow ───────────────────────
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    Key? key,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Tag Pill
// ══════════════════════════════════════════════════════════════════
class _TagPill extends StatelessWidget {
  final String tag;

  const _TagPill({required this.tag});

  static const _tagColors = {
    'Flutter': Color(0xFF5C6BC0),
    'Dart': Color(0xFF26A69A),
    'Firebase': Color(0xFFFF7043),
    'Beginner': Color(0xFF66BB6A),
    'Performance': Color(0xFFFF7043),
    'State Management': Color(0xFFEC407A),
    'BLoC': Color(0xFF7E57C2),
    'Riverpod': Color(0xFF29B6F6),
  };

  @override
  Widget build(BuildContext context) {
    final color = _tagColors[tag] ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Header Button
// ══════════════════════════════════════════════════════════════════
class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool badge;

  const _HeaderBtn({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarySoft : AppColors.field,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.line,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.ink,
              size: 20,
            ),
          ),
          if (badge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

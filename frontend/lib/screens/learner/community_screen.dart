import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/community_service.dart';
import 'ask_question_screen.dart';
import 'question_detail_screen.dart';



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
  List<bool> _likedStates = [];

  List<CommunityQuestion> _allQuestions = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final CommunityService _communityService = CommunityService();

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
    _searchFocus.addListener(
      () => setState(() => _searchFocused = _searchFocus.hasFocus),
    );
    _searchCtrl.addListener(
      () => setState(() => _searchQuery = _searchCtrl.text),
    );
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id;

      final data = await _communityService.getPosts();
      final List<CommunityQuestion> loaded = [];
      for (var item in data) {
        final author = item['author'] ?? {};
        final authorName = author['name'] ?? 'User';
        
        final String rawQuestion = item['question'] ?? '';
        final parts = rawQuestion.split('\n\n');
        final title = parts[0];
        final body = parts.length > 1 ? parts.sublist(1).join('\n\n') : '';

        final color = Color((authorName.hashCode & 0x00FFFFFF) | 0xFF000000);

        final String tagStr = item['tag'] ?? 'General';
        final List<String> tags = tagStr.split(',').map((t) => t.trim()).toList();

        String timeAgo = 'Just now';
        try {
          final createdAt = DateTime.parse(item['createdAt']);
          final diff = DateTime.now().difference(createdAt);
          if (diff.inDays > 0) {
            timeAgo = '${diff.inDays} days ago';
          } else if (diff.inHours > 0) {
            timeAgo = '${diff.inHours} hrs ago';
          } else if (diff.inMinutes > 0) {
            timeAgo = '${diff.inMinutes} mins ago';
          }
        } catch (_) {}

        final List<dynamic> likedBy = item['likedBy'] ?? [];
        final isLiked = currentUserId != null &&
            (likedBy.contains(currentUserId) ||
                likedBy.contains(int.tryParse(currentUserId)));

        loaded.add(CommunityQuestion(
          id: item['id'].toString(),
          title: title,
          body: body,
          authorName: authorName,
          authorRole: 'Member',
          authorColor: color,
          timeAgo: timeAgo,
          answers: item['answersCount'] ?? 0,
          likes: item['likes'] ?? 0,
          views: (item['likes'] ?? 0) * 3 + 8,
          tags: tags,
          isAnswered: (item['answersCount'] ?? 0) > 0,
          isPinned: false,
          isLiked: isLiked,
        ));
      }

      setState(() {
        _allQuestions = loaded;
        _likedStates = loaded.map((q) => q.isLiked).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }


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
        extendBody: true,
        backgroundColor: const Color(0xFFF4F6F4),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (_showSearch) _buildSearchBar(),
              _buildTagChips(),
              _buildTabBar(),

              // ── Content ──────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColors.ink, fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchQuestions,
                                    child: const Text('Retry'),
                                  )
                                ],
                              ),
                            ),
                          )
                        : TabBarView(
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
      ),
    );
  }

 
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
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Learn together, grow together',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          // Ask Question button
          GestureDetector(
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AskQuestionScreen()),
              );
              if (result == true) {
                _fetchQuestions();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Ask', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                    color: AppColors.primary.withValues(alpha:  0.1),
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
                    color: AppColors.muted.withValues(alpha:  0.7),
                    fontSize: 14,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
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
                      color: AppColors.muted.withValues(alpha:  0.2),
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
                                color: AppColors.primary.withValues(alpha:  0.25),
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
              children:[const Text('For You'),],
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
                Container (
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

 
  void _toggleLike(int globalIndex) async {
    final q = _allQuestions[globalIndex];
    final int postId = int.tryParse(q.id) ?? 0;
    try {
      final result = await _communityService.toggleLike(postId);
      setState(() {
        _likedStates[globalIndex] = result['isLiked'];
        final updatedQ = CommunityQuestion(
          id: q.id,
          title: q.title,
          body: q.body,
          authorName: q.authorName,
          authorRole: q.authorRole,
          authorColor: q.authorColor,
          timeAgo: q.timeAgo,
          answers: q.answers,
          likes: result['likes'],
          views: q.views,
          tags: q.tags,
          isAnswered: q.isAnswered,
          isPinned: q.isPinned,
          isLiked: result['isLiked'],
        );
        _allQuestions[globalIndex] = updatedQ;
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  void _openQuestion(CommunityQuestion q) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuestionDetailScreen(question: q)),
    );
    _fetchQuestions();
  }
  }



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
      separatorBuilder: (_, _) =>
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
      highlightColor: AppColors.primarySoft.withValues(alpha:  0.3),
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        color: question.authorColor.withValues(alpha:  0.3),
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

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
               
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
                                '${question.likes} likes',
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
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha:  0.3)),
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
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha:  0.25)),
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


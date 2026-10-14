import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/community_service.dart';
import 'community_screen.dart';

class QuestionDetailScreen extends StatefulWidget {
  final CommunityQuestion question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final _answerCtrl = TextEditingController();
  bool _isLiked = false;
  int _likesCount = 0;
  bool _posting = false;
  bool _isLoading = true;
  List<_AnswerModel> _answers = [];
  final CommunityService _communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.question.isLiked;
    _likesCount = widget.question.likes;
    _fetchPostDetails();
  }

  Future<void> _handleLikeTap() async {
    final oldLiked = _isLiked;
    final oldLikes = _likesCount;
    setState(() {
      _isLiked = !_isLiked;
      _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
    });
    try {
      final int postId = int.tryParse(widget.question.id) ?? 0;
      if (postId > 0) {
        final result = await _communityService.toggleLike(postId);
        setState(() {
          _likesCount = result['likes'];
          _isLiked = result['isLiked'];
        });
      }
    } catch (e) {
      debugPrint('Error toggling post like: $e');
      setState(() {
        _isLiked = oldLiked;
        _likesCount = oldLikes;
      });
    }
  }

  Future<void> _fetchPostDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final int postId = int.tryParse(widget.question.id) ?? 0;
      final postData = await _communityService.getPostById(postId);
      
      final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      final List<dynamic> answersList = postData['answers'] ?? [];
      final List<_AnswerModel> loadedAnswers = [];

      for (var item in answersList) {
        final author = item['author'] ?? {};
        final authorName = author['name'] ?? 'User';
        
        final color = Color((authorName.hashCode & 0x00FFFFFF) | 0xFF000000);

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

        final likedByList = item['likedBy'] as List?;
        final isLiked = likedByList != null && currentUserId != null && likedByList.contains(currentUserId);

        loadedAnswers.add(_AnswerModel(
          id: item['id']?.toString() ?? '',
          author: authorName,
          role: 'Member',
          color: color,
          text: item['answer'] ?? '',
          likes: item['likes'] ?? 0,
          timeAgo: timeAgo,
          isAccepted: false,
          isLiked: isLiked,
        ));
      }

      final List<dynamic> postLikedBy = postData['likedBy'] ?? [];
      final postIsLiked = currentUserId != null &&
          (postLikedBy.contains(currentUserId) ||
              postLikedBy.contains(int.tryParse(currentUserId.toString())) ||
              postLikedBy.contains(currentUserId.toString()));

      setState(() {
        _answers = loadedAnswers;
        _likesCount = postData['likes'] ?? 0;
        _isLiked = postIsLiked;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading answers: $e');
    }
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.ink,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Question',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_rounded,
              color: AppColors.ink,
              size: 20,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.ink,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.line),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ── Question card ──────────────
                  _buildQuestionCard(),

                  // ── Answers header ─────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          '${_answers.length} Answers',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Best first',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),

                  // ── Answers ────────────────────
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_answers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No answers yet. Be the first to answer!',
                          style: TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ..._answers.asMap().entries.map(
                      (e) => _AnswerCard(answer: e.value),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Answer input ──────────────────────
          _buildAnswerInput(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          // Author row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.question.authorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.question.authorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${widget.question.authorRole}  ·  ${widget.question.timeAgo}',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (widget.question.isAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Answered',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            widget.question.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Body
          Text(
            widget.question.body,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 14),

          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.question.tags
                .map((t) => _TagPill(tag: t))
                .toList(),
          ),
          const SizedBox(height: 14),

          Divider(color: AppColors.line),
          const SizedBox(height: 10),

          // Stats + Like
          Row(
            children: [
              _iconStat(
                Icons.question_answer_outlined,
                '${widget.question.answers} answers',
                AppColors.muted,
              ),
              const SizedBox(width: 16),
              _iconStat(
                Icons.remove_red_eye_outlined,
                '${widget.question.views} views',
                AppColors.muted,
              ),
              const Spacer(),
              GestureDetector(
                onTap: _handleLikeTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _isLiked ? const Color(0xFFFFEBEE) : AppColors.field,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isLiked ? Colors.redAccent : AppColors.line,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 15,
                        color: _isLiked ? Colors.redAccent : AppColors.muted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$_likesCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _isLiked ? Colors.redAccent : AppColors.muted,
                        ),
                      ),
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

  Widget _iconStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: TextField(
                controller: _answerCtrl,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Write your answer...',
                  hintStyle: TextStyle(
                    color: AppColors.muted.withValues(alpha:  0.7),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _posting ? null : _postAnswer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _posting
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postAnswer() async {
    if (_answerCtrl.text.trim().isEmpty) return;
    setState(() => _posting = true);
    try {
      final int postId = int.tryParse(widget.question.id) ?? 0;
      await _communityService.createAnswer(
        postId: postId,
        answer: _answerCtrl.text.trim(),
      );

      _answerCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Answer posted! 🎉'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      _fetchPostDetails(); // Refresh list dynamically!
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Failed to post answer'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _posting = false);
      }
    }
  }
}

class _TagPill extends StatelessWidget {
  final String
  tag; // Assuming 't' is a String, change the type if it's a custom object

  const _TagPill({Key? key, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 12, color: AppColors.ink, fontWeight: FontWeight.w600),
      ),
    );
  }
}



class _AnswerModel {
  final String id;
  final String author;
  final String role;
  final Color color;
  final String text;
  final int likes;
  final String timeAgo;
  final bool isAccepted;
  final bool isLiked;

  const _AnswerModel({
    required this.id,
    required this.author,
    required this.role,
    required this.color,
    required this.text,
    required this.likes,
    required this.timeAgo,
    required this.isAccepted,
    required this.isLiked,
  });
}

class _AnswerCard extends StatefulWidget {
  final _AnswerModel answer;

  const _AnswerCard({required this.answer});

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  bool _liked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _liked = widget.answer.isLiked;
    _likesCount = widget.answer.likes;
  }

  @override
  void didUpdateWidget(covariant _AnswerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.answer.id != widget.answer.id ||
        oldWidget.answer.isLiked != widget.answer.isLiked ||
        oldWidget.answer.likes != widget.answer.likes) {
      _liked = widget.answer.isLiked;
      _likesCount = widget.answer.likes;
    }
  }

  Future<void> _handleLikeTap() async {
    final oldLiked = _liked;
    final oldLikes = _likesCount;
    setState(() {
      _liked = !_liked;
      _likesCount = _liked ? _likesCount + 1 : _likesCount - 1;
    });
    try {
      final ansId = int.tryParse(widget.answer.id) ?? 0;
      if (ansId > 0) {
        final result = await CommunityService().toggleLikeAnswer(ansId);
        setState(() {
          _likesCount = result['likes'];
          _liked = result['isLiked'];
        });
      }
    } catch (e) {
      debugPrint('Error toggling answer like: $e');
      setState(() {
        _liked = oldLiked;
        _likesCount = oldLikes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.answer.isAccepted
              ? AppColors.primary.withValues(alpha:  0.4)
              : AppColors.line,
          width: widget.answer.isAccepted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accepted badge
          if (widget.answer.isAccepted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Accepted Answer',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Author
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.answer.color,
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.answer.author,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${widget.answer.role}  ·  ${widget.answer.timeAgo}',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Answer text
          Text(
            widget.answer.text,
            style: TextStyle(fontSize: 13, color: AppColors.ink, height: 1.6),
          ),
          const SizedBox(height: 12),

          // Like button
          Row(
            children: [
              GestureDetector(
                onTap: _handleLikeTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _liked ? const Color(0xFFFFEBEE) : AppColors.field,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _liked ? Colors.redAccent : AppColors.line,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 14,
                        color: _liked ? Colors.redAccent : AppColors.muted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$_likesCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _liked ? Colors.redAccent : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.reply_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                label: Text(
                  'Reply',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
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

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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
  bool _posting = false;

  final _answers = [
    _AnswerModel(
      author: 'Rahul Sharma',
      role: 'Flutter Expert',
      color: const Color(0xFF5C6BC0),
      text:
          'Great question! When transitioning from Android to Flutter, the key thing to understand is that everything is a widget. The widget tree replaces your view hierarchy. I recommend starting with the official Flutter docs and building a few small apps.',
      likes: 24,
      timeAgo: '1 hr ago',
      isAccepted: true,
    ),
    _AnswerModel(
      author: 'Priya Singh',
      role: 'Mobile Developer',
      color: const Color(0xFFEC407A),
      text:
          'I made this transition 2 years ago! The biggest adjustment was the reactive UI model. Flutter uses a declarative approach — you describe what the UI should look like for a given state, and Flutter handles the rendering.',
      likes: 12,
      timeAgo: '2 hrs ago',
      isAccepted: false,
    ),
  ];

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
            color: Colors.black.withOpacity(0.04),
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
                onTap: () => setState(() => _isLiked = !_isLiked),
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
                        '${_isLiked ? widget.question.likes + 1 : widget.question.likes}',
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
            color: Colors.black.withOpacity(0.06),
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
                    color: AppColors.muted.withOpacity(0.7),
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
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _posting = false);
      _answerCtrl.clear();
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
        color: const Color.fromARGB(255, 20, 23, 26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 12, color: Colors.blue),
      ),
    );
  }
}



class _AnswerModel {
  final String author;
  final String role;
  final Color color;
  final String text;
  final int likes;
  final String timeAgo;
  final bool isAccepted;

  const _AnswerModel({
    required this.author,
    required this.role,
    required this.color,
    required this.text,
    required this.likes,
    required this.timeAgo,
    required this.isAccepted,
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
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.line,
          width: widget.answer.isAccepted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                onTap: () => setState(() => _liked = !_liked),
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
                        '${_liked ? widget.answer.likes + 1 : widget.answer.likes}',
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

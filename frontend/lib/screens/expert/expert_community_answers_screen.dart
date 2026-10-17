import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommunityQuestionItem {
  final String id;
  final String title;
  final String body;
  final String askerName;
  final String timeAgo;
  final List<String> tags;
  final int answersCount;
  final int upvotes;
  final bool isAnsweredByMe;

  CommunityQuestionItem({
    required this.id,
    required this.title,
    required this.body,
    required this.askerName,
    required this.timeAgo,
    required this.tags,
    required this.answersCount,
    required this.upvotes,
    this.isAnsweredByMe = false,
  });
}

class ExpertCommunityAnswersScreen extends StatefulWidget {
  const ExpertCommunityAnswersScreen({super.key});

  @override
  State<ExpertCommunityAnswersScreen> createState() =>
      _ExpertCommunityAnswersScreenState();
}

class _ExpertCommunityAnswersScreenState
    extends State<ExpertCommunityAnswersScreen> {
  String _selectedTab = 'For You';
  final List<String> _tabs = ['For You', 'Unanswered', 'My Answers'];

  final List<CommunityQuestionItem> _questions = [
    CommunityQuestionItem(
      id: 'q_1',
      title: 'How to structure Riverpod providers for large enterprise Flutter apps?',
      body:
          'We have an app with 40+ screens. Currently struggling with cyclic provider dependencies and test mockability. What is the recommended repository and controller pattern?',
      askerName: 'Kunal Patil',
      timeAgo: '2 hours ago',
      tags: ['Flutter', 'Riverpod', 'Architecture'],
      answersCount: 1,
      upvotes: 18,
    ),
    CommunityQuestionItem(
      id: 'q_2',
      title: 'Why does GoRouter cause page rebuilds when query parameters change?',
      body:
          'Whenever I update query parameters for search filters, the entire ShellRoute rebuilds instead of just the nested tab. Is there a way to prevent full scaffold re-rendering?',
      askerName: 'Devansh Roy',
      timeAgo: '4 hours ago',
      tags: ['Flutter', 'GoRouter', 'Navigation'],
      answersCount: 0,
      upvotes: 9,
    ),
    CommunityQuestionItem(
      id: 'q_3',
      title: 'Best practice for handling offline token refresh with Dio interceptor?',
      body:
          'When 3 parallel requests hit 401 simultaneously, my QueuedInterceptor fires 3 refresh calls instead of one. How do you properly lock token renewal?',
      askerName: 'Aarav Sharma',
      timeAgo: '1 day ago',
      tags: ['Dart', 'Dio', 'Authentication'],
      answersCount: 2,
      upvotes: 24,
      isAnsweredByMe: true,
    ),
    CommunityQuestionItem(
      id: 'q_4',
      title: 'What should I prepare for a Senior Mobile Engineer system design round?',
      body:
          'I have an upcoming interview. They asked to design WhatsApp or Instagram offline feed. What key areas do interviewers look for in client-side architecture?',
      askerName: 'Manish Tyagi',
      timeAgo: '1 day ago',
      tags: ['System Design', 'Interview', 'Mobile'],
      answersCount: 0,
      upvotes: 31,
    ),
    CommunityQuestionItem(
      id: 'q_5',
      title: 'Comparing Isar, Hive, and SQLite for 500k+ records in Flutter',
      body:
          'Building an offline analytics dashboard on device. Which database yields the fastest full-text search and query performance on low-end Android devices?',
      askerName: 'Ananya Sen',
      timeAgo: '2 days ago',
      tags: ['Database', 'Hive', 'Performance'],
      answersCount: 3,
      upvotes: 15,
      isAnsweredByMe: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _questions.where((q) {
      if (_selectedTab == 'Unanswered') return q.answersCount == 0;
      if (_selectedTab == 'My Answers') return q.isAnsweredByMe;
      return true; // 'For You' shows all matching skills
    }).toList();

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
          'Expert Q&A Community',
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
            // Mentor Reputation Card
            _buildReputationBanner(),

            // Filter Tabs
            _buildTabsRow(),

            // Questions List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final question = filtered[index];
                        return _buildQuestionCard(question);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReputationBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: Color(0xFFFFD54F), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Mentor Reputation Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Top 1% Answerer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'High-quality answers establish your technical authority and directly generate 1-on-1 bookings.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('38', 'Answered'),
              Container(width: 1, height: 24, color: Colors.white24),
              _buildMetric('214', 'Helpful Votes'),
              Container(width: 1, height: 24, color: Colors.white24),
              _buildMetric('29', 'Accepted Solns'),
              Container(width: 1, height: 24, color: Colors.white24),
              _buildMetric('1,450', 'Reputation'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = tab == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.line,
                  ),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuestionCard(CommunityQuestionItem q) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asker info & time
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    q.askerName.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  q.askerName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('•', style: TextStyle(color: AppColors.muted)),
                const SizedBox(width: 6),
                Text(
                  q.timeAgo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
                const Spacer(),
                if (q.isAnsweredByMe)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7EF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 12, color: Color(0xFF22C55E)),
                        SizedBox(width: 4),
                        Text(
                          'You Answered',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              q.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Body preview
            Text(
              q.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: q.tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Footer row: Upvotes, Answers count, Answer Button
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined,
                        size: 15, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      '${q.upvotes}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.mode_comment_outlined,
                        size: 15, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      '${q.answersCount} answers',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openAnswerSheet(q),
                  icon: const Icon(Icons.reply_rounded, size: 15),
                  label: Text(q.isAnsweredByMe ? 'Add Another Answer' : 'Answer Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  void _openAnswerSheet(CommunityQuestionItem q) {
    final answerCtrl = TextEditingController();
    bool attachConsultationInvite = true;

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
                      const Text(
                        'Write Expert Answer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        q.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Text Field
                      TextField(
                        controller: answerCtrl,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText:
                              'Provide a thorough technical solution, architectural explanation or code snippet...',
                          fillColor: const Color(0xFFF9FAFB),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Promotional toggle: Invite learner to 1:1 mentorship
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7EF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars_rounded,
                                color: AppColors.primary, size: 22),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attach Mentorship Card',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    'Allows learner to book 1-on-1 session directly from your answer.',
                                    style: TextStyle(
                                        fontSize: 11, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: attachConsultationInvite,
                              activeThumbColor: AppColors.primary,
                              onChanged: (val) {
                                setModalState(() {
                                  attachConsultationInvite = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (answerCtrl.text.trim().isEmpty) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Your answer has been published!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          child: const Text('Post Solution'),
                        ),
                      ),
                      const SizedBox(height: 8),
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
              child: const Icon(Icons.forum_outlined,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Questions in this Tab',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Switch tabs to view recent community inquiries.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

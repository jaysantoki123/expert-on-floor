import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ExpertSessionNotesScreen extends StatefulWidget {
  final String menteeName;
  final String sessionTitle;
  final String sessionDate;

  const ExpertSessionNotesScreen({
    super.key,
    this.menteeName = 'Priya Mehta',
    this.sessionTitle = 'Career Guidance & Roadmap Review',
    this.sessionDate = 'Today, 11:00 AM - 11:45 AM',
  });

  @override
  State<ExpertSessionNotesScreen> createState() =>
      _ExpertSessionNotesScreenState();
}

class _ExpertSessionNotesScreenState extends State<ExpertSessionNotesScreen> {
  final TextEditingController _summaryCtrl = TextEditingController(
    text:
        'Reviewed current progress on Flutter clean architecture and state management. Discussed transition from basic Provider to Riverpod and offline-first SQLite/Hive caching strategies.',
  );
  final TextEditingController _privateNoteCtrl = TextEditingController(
    text:
        'Priya has great foundational grasp of OOP. Needs to work on error handling and asynchronous stream controllers before next mock interview.',
  );

  final List<TextEditingController> _actionItemCtrls = [
    TextEditingController(
        text: 'Build demo app demonstrating Riverpod StateNotifier'),
    TextEditingController(
        text: 'Implement Hive caching with encryption key storage'),
    TextEditingController(
        text: 'Review documentation on GoRouter deep linking'),
  ];

  final List<TextEditingController> _resourceCtrls = [
    TextEditingController(text: 'https://docs.flutter.dev/data-and-backend/state-mgmt'),
    TextEditingController(text: 'https://codewithandrea.com/articles/flutter-app-architecture/'),
  ];

  int _menteeRating = 5;
  final Set<String> _selectedFeedbackTags = {
    'Well Prepared',
    'Quick Learner',
    'Good Communication',
  };

  final List<String> _feedbackTagOptions = [
    'Well Prepared',
    'Quick Learner',
    'Strong Problem Solving',
    'Good Communication',
    'Active Listener',
    'Needs More Practice',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppColors.ink, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post-Session Notes & Summary',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.line, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Summary Header Banner
              _buildSessionHeaderCard(),
              const SizedBox(height: 20),

              // Mentee Rating Section
              _buildRatingSection(),
              const SizedBox(height: 20),

              // Session Summary (Sent to Student)
              _buildSummarySection(),
              const SizedBox(height: 20),

              // Action Items Checklist
              _buildActionItemsSection(),
              const SizedBox(height: 20),

              // Shared Resource Links
              _buildResourcesSection(),
              const SizedBox(height: 20),

              // Private Mentor Notes
              _buildPrivateNotesSection(),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.line)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveAndSendSummary,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Complete & Send to Mentee',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHeaderCard() {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_rounded,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sessionTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mentee: ${widget.menteeName}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.sessionDate,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mentee Performance & Preparedness',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _menteeRating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    starIndex <= _menteeRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFB300),
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _feedbackTagOptions.map((tag) {
              final isSelected = _selectedFeedbackTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFeedbackTags.remove(tag);
                    } else {
                      _selectedFeedbackTags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySoft
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.line,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_rounded,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Key Takeaways & Feedback for Mentee',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'This summary will be visible to the learner in their roadmap notes.',
            style: TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summaryCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter session summary and actionable feedback...',
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.checklist_rounded,
                      size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Assigned Tasks & Action Items',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary, size: 22),
                tooltip: 'Add Task',
                onPressed: () {
                  setState(() {
                    _actionItemCtrls.add(TextEditingController());
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._actionItemCtrls.asMap().entries.map((entry) {
            final idx = entry.key;
            final ctrl = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: InputDecoration(
                        hintText: 'Action item for learner...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        fillColor: const Color(0xFFF9FAFB),
                      ),
                    ),
                  ),
                  if (_actionItemCtrls.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 20),
                      onPressed: () {
                        setState(() {
                          _actionItemCtrls.removeAt(idx);
                        });
                      },
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResourcesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.link_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Shared Resources & Links',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_link_rounded,
                    color: AppColors.primary, size: 22),
                tooltip: 'Add Link',
                onPressed: () {
                  setState(() {
                    _resourceCtrls.add(TextEditingController());
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._resourceCtrls.asMap().entries.map((entry) {
            final idx = entry.key;
            final ctrl = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.open_in_new_rounded,
                      size: 16, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: InputDecoration(
                        hintText: 'https://...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        fillColor: const Color(0xFFF9FAFB),
                      ),
                    ),
                  ),
                  if (_resourceCtrls.length > 1)
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.muted, size: 18),
                      onPressed: () {
                        setState(() {
                          _resourceCtrls.removeAt(idx);
                        });
                      },
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPrivateNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 18, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'Private Mentor Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Only you can see this. Use this to track learner weaknesses and private observations.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFFB45309)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _privateNoteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter confidential notes...',
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFDE68A)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAndSendSummary() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF7EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Session Complete!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          'Notes, ${_actionItemCtrls.length} action items, and resources have been sent to ${widget.menteeName}. The session has been recorded in your earnings ledger.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }
}

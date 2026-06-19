import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════
// Add Review Screen
// ══════════════════════════════════════════════════════════════════
class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;
  bool _loading = false;
  final List<String> _selectedTags = [];

  final List<String> _tags = [
    'Knowledge',
    'Explanation',
    'Communication',
    'Practical Examples',
    'Punctuality',
    'Helpful Resources',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
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
              // Header
              _buildHeader(),
              // Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expert Info Card
                      _buildExpertInfo(),
                      const SizedBox(height: 20),
                      // Rating Section
                      _buildRatingSection(),
                      const SizedBox(height: 20),
                      // Review Title
                      _buildReviewTitle(),
                      const SizedBox(height: 20),
                      // Review Description
                      _buildReviewDescription(),
                      const SizedBox(height: 20),
                      // Tags Section
                      _buildTagsSection(),
                      const SizedBox(height: 20),
                      // Session Details
                      _buildSessionDetails(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 20),
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
                  'Add Review',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Share your experience with this expert',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Expert Info
  // ══════════════════════════════════════════════════════════════
  Widget _buildExpertInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5C6BC0).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rahul Sharma',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Senior Flutter Developer',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified Expert',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Rating Section
  // ══════════════════════════════════════════════════════════════
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to rate your experience',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    index < _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 42,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        if (_rating > 0)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRatingText(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getRatingText() {
    switch (_rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Review Title
  // ══════════════════════════════════════════════════════════════
  Widget _buildReviewTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Summarize your experience in a few words',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 15, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'Enter a title for your review',
              hintStyle: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                Icons.edit_outlined,
                color: AppColors.muted,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Review Description
  // ══════════════════════════════════════════════════════════════
  Widget _buildReviewDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Review',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tell others about your experience',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 6,
            style: const TextStyle(fontSize: 15, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'Write your review here...',
              hintStyle: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.7),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                child: Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.muted,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Tags Section
  // ══════════════════════════════════════════════════════════════
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What did you like most? (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select all that apply',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _tags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => _toggleTag(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primarySoft
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.line,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Session Details
  // ══════════════════════════════════════════════════════════════
  Widget _buildSessionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Flutter State Management',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '10 May, 2026 • 60 min • ₹1,020',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                color: AppColors.muted,
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Submit Button
  // ══════════════════════════════════════════════════════════════
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _rating == 0
              ? null
              : _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await Future.delayed(const Duration(milliseconds: 1200));
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Review submitted successfully!'),
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
            backgroundColor: _rating == 0
                ? AppColors.line
                : AppColors.primary,
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
                  'Submit Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

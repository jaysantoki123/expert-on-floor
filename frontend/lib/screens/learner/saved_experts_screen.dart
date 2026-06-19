import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/learner/expert_profile_screen.dart';
import '../../core/theme/app_colors.dart';
import 'expert_profile_screen.dart';

class ExpertModel {
  final String id;
  final String name;
  final String role;
  final double rating;
  final int reviews;
  final int price;
  final Color avatarColor;
  final bool isVerified;
  final List<String> tags;
  final bool isAvailable;
  final String availableTime;

  const ExpertModel({
    required this.id,
    required this.name,
    required this.role,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.avatarColor,
    required this.tags,
    this.isVerified = true,
    this.isAvailable = true,
    this.availableTime = 'Available Now',
  });
}

final List<ExpertModel> dummySavedExperts = [
  ExpertModel(
    id: '1',
    name: 'Rahul Sharma',
    role: 'Senior Flutter Developer',
    rating: 4.9,
    reviews: 128,
    price: 1020,
    avatarColor: const Color(0xFF5C6BC0),
    tags: ['Flutter', 'Dart', 'Bloc', 'Riverpod'],
    availableTime: 'Available Tomorrow',
  ),
  ExpertModel(
    id: '2',
    name: 'Sneha Patel',
    role: 'UI/UX Designer',
    rating: 4.8,
    reviews: 96,
    price: 950,
    avatarColor: const Color(0xFFEC407A),
    tags: ['UI Design', 'Figma', 'Prototyping', 'UX Research'],
    availableTime: 'Available Today',
  ),
  ExpertModel(
    id: '3',
    name: 'Arjun Verma',
    role: 'Backend Developer',
    rating: 4.7,
    reviews: 72,
    price: 900,
    avatarColor: const Color(0xFF26A69A),
    tags: ['Node.js', 'MongoDB', 'Firebase', 'API Design'],
    availableTime: 'Available on 12 May',
    isAvailable: false,
  ),
  ExpertModel(
    id: '4',
    name: 'Neha Singh',
    role: 'Product Manager',
    rating: 4.9,
    reviews: 64,
    price: 1000,
    avatarColor: const Color(0xFFFFCA28),
    tags: ['Product Strategy', 'Roadmap', 'Agile', 'User Research'],
    availableTime: 'Available Tomorrow',
  ),
  ExpertModel(
    id: '5',
    name: 'Vikram Reddy',
    role: 'DevOps Engineer',
    rating: 4.8,
    reviews: 53,
    price: 920,
    avatarColor: const Color(0xFF1565C0),
    tags: ['AWS', 'Docker', 'Kubernetes', 'CI/CD'],
    availableTime: 'Available Today',
  ),
];

class SavedExpertsScreen extends StatefulWidget {
  const SavedExpertsScreen({super.key});

  @override
  State<SavedExpertsScreen> createState() => _SavedExpertsScreenState();
}

class _SavedExpertsScreenState extends State<SavedExpertsScreen> {
  String _selectedFilter = 'All Experts';
  final List<String> _filters = [
    'All Experts',
    'Available Now',
    'Top Rated',
    'Recently Added'
  ];

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
              _buildFilterRow(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: dummySavedExperts.length,
                  itemBuilder: (context, index) {
                    return _ExpertCard(expert: dummySavedExperts[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                  'Saved Experts',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Experts you have saved for later',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.ink,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.sort_rounded,
              color: AppColors.ink,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.line,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${filter == 'All Experts' ? dummySavedExperts.length : dummySavedExperts.where((e) => e.isAvailable).length})',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final ExpertModel expert;

  const _ExpertCard({required this.expert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: expert.avatarColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: expert.avatarColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expert.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (expert.isVerified)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                color: AppColors.primary,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expert.role,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < expert.rating.floor()
                                    ? Icons.star_rounded
                                    : i < expert.rating.ceil()
                                        ? Icons.star_half_rounded
                                        : Icons.star_border_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${expert.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${expert.reviews} reviews)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: expert.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '₹${expert.price}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            '/ session',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: expert.isAvailable
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: expert.isAvailable ? Colors.green : Colors.grey,
                        size: 8,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expert.availableTime,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: expert.isAvailable ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.bookmark_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
         Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the Book Session Screen

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Book Session',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

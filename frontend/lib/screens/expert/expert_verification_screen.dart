import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VerificationStepItem {
  final String title;
  final String description;
  final String status; // 'verified', 'pending', 'action_required'
  final IconData icon;

  VerificationStepItem({
    required this.title,
    required this.description,
    required this.status,
    required this.icon,
  });
}

class ExpertVerificationScreen extends StatefulWidget {
  const ExpertVerificationScreen({super.key});

  @override
  State<ExpertVerificationScreen> createState() =>
      _ExpertVerificationScreenState();
}

class _ExpertVerificationScreenState extends State<ExpertVerificationScreen> {
  final List<VerificationStepItem> _steps = [
    VerificationStepItem(
      title: 'Government Identity Proof',
      description: 'Aadhaar Card / Passport verified. Full name and DOB matched.',
      status: 'verified',
      icon: Icons.badge_rounded,
    ),
    VerificationStepItem(
      title: 'Professional Experience & LinkedIn',
      description: 'Senior Software Engineer verified via work email & LinkedIn profile.',
      status: 'verified',
      icon: Icons.work_outline_rounded,
    ),
    VerificationStepItem(
      title: 'PAN Card & Tax Identification',
      description: 'Tax compliance verified for instant TDS deduction & payouts.',
      status: 'verified',
      icon: Icons.receipt_long_rounded,
    ),
    VerificationStepItem(
      title: 'Cloud & Tech Certifications',
      description: 'Google Cloud Certified Professional Cloud Architect uploaded.',
      status: 'verified',
      icon: Icons.workspace_premium_rounded,
    ),
    VerificationStepItem(
      title: 'Video Introduction & Speaking Demo',
      description: '1-minute introduction video to demonstrate mentorship communication skills.',
      status: 'action_required',
      icon: Icons.video_camera_front_rounded,
    ),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification & Trust Badges',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verified Status Banner
              _buildTrustStatusCard(),
              const SizedBox(height: 20),

              // Checklist Header
              const Text(
                'Verification Milestones',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),

              // Steps List
              ..._steps.map((step) => _buildStepCard(step)),

              const SizedBox(height: 16),

              // Upload New Certificate Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _showUploadCertificateSheet,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Upload New Credential or Certificate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Benefits of Verified Mentor
              _buildBenefitsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009D45), Color(0xFF007A35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verified Expert Mentor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Trust Score: 98/100 (Tier 1 Certified)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your verified badge is displayed on search results and public mentor profile.',
                    style: TextStyle(color: Colors.white, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(VerificationStepItem step) {
    final isVerified = step.status == 'verified';
    final isActionRequired = step.status == 'action_required';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActionRequired
              ? const Color(0xFFFDE68A)
              : AppColors.line,
          width: isActionRequired ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFFEAF7EF)
                  : (isActionRequired
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              step.icon,
              color: isVerified
                  ? const Color(0xFF22C55E)
                  : (isActionRequired ? const Color(0xFFD97706) : AppColors.muted),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? const Color(0xFFEAF7EF)
                            : (isActionRequired
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFF3F4F6)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified
                                ? Icons.check_circle_rounded
                                : (isActionRequired
                                    ? Icons.pending_rounded
                                    : Icons.access_time_rounded),
                            size: 11,
                            color: isVerified
                                ? const Color(0xFF22C55E)
                                : (isActionRequired
                                    ? const Color(0xFFB45309)
                                    : AppColors.muted),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVerified
                                ? 'Verified'
                                : (isActionRequired ? 'Action Needed' : 'Pending'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isVerified
                                  ? const Color(0xFF22C55E)
                                  : (isActionRequired
                                      ? const Color(0xFFB45309)
                                      : AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Verification Matters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          _buildBenefitRow(
            Icons.trending_up_rounded,
            '3.5x higher booking conversion',
            'Students prefer booking verified mentors by a wide margin.',
          ),
          const SizedBox(height: 10),
          _buildBenefitRow(
            Icons.verified_user_outlined,
            'Featured in Search & Floor Spotlight',
            'Verified experts receive top ranking in algorithm matches.',
          ),
          const SizedBox(height: 10),
          _buildBenefitRow(
            Icons.bolt_rounded,
            'Instant Payouts Enabled',
            'Skip the 48-hour escrow clearing period with verified KYC.',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUploadCertificateSheet() {
    final titleCtrl = TextEditingController();
    final issuerCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
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
                    'Upload Credential Certificate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Certificate Name',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. AWS Certified Solutions Architect',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Issuing Organization',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: issuerCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Amazon Web Services / Google',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.line, style: BorderStyle.solid),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 32, color: AppColors.primary),
                        SizedBox(height: 6),
                        Text(
                          'Upload PDF or Image (Max 5MB)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Supported: PDF, JPG, PNG',
                          style: TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.isEmpty) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Certificate submitted for manual verification review.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: const Text('Submit for Verification'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'expert_availability_screen.dart';

class ExpertSettingsScreen extends StatefulWidget {
  const ExpertSettingsScreen({super.key});

  @override
  State<ExpertSettingsScreen> createState() => _ExpertSettingsScreenState();
}

class _ExpertSettingsScreenState extends State<ExpertSettingsScreen> {
  // Booking Preferences
  bool _autoAcceptBookings = true;
  String _minNotice = '2 Hours';
  int _bufferMinutes = 10;
  bool _allowSameDay = true;

  // Notification Preferences
  bool _sessionReminders = true;
  bool _messageAlerts = true;
  bool _bookingRequests = true;
  bool _communityAlerts = false;

  // Calendar & Tools
  bool _googleCalendarSynced = true;
  String _preferredMeetingPlatform = 'In-App WebRTC (Recommended)';

  // Security
  bool _biometricEnabled = true;
  bool _twoFactorAuth = true;

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
          'Expert Settings',
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Booking & Scheduling Preferences
              _buildSectionHeader('Booking & Scheduling Preferences'),
              const SizedBox(height: 10),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Auto-Accept Bookings',
                  subtitle:
                      'Automatically confirm bookings that match your availability slots without manual approval.',
                  value: _autoAcceptBookings,
                  onChanged: (val) => setState(() => _autoAcceptBookings = val),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildDropdownTile(
                  icon: Icons.timelapse_rounded,
                  title: 'Minimum Notice Required',
                  subtitle: 'How much advance notice you need before a session starts.',
                  value: _minNotice,
                  options: ['1 Hour', '2 Hours', '6 Hours', '12 Hours', '24 Hours'],
                  onChanged: (val) => setState(() => _minNotice = val),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildBufferMinutesTile(),
                const Divider(height: 1, color: AppColors.line),
                _buildSwitchTile(
                  icon: Icons.today_rounded,
                  title: 'Allow Same-Day Bookings',
                  subtitle: 'Permit mentees to book open slots on the current day.',
                  value: _allowSameDay,
                  onChanged: (val) => setState(() => _allowSameDay = val),
                ),
                const Divider(height: 1, color: AppColors.line),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(Icons.event_available_rounded,
                      color: AppColors.primary),
                  title: const Text('Manage Weekly Time Slots',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Configure recurring days and vacation mode',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExpertAvailabilityScreen()),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // 2. Notifications & Alerts
              _buildSectionHeader('Notifications & Reminders'),
              const SizedBox(height: 10),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.alarm_rounded,
                  title: 'Session Reminder Alerts',
                  subtitle: 'Get notified 15 minutes before your video call begins.',
                  value: _sessionReminders,
                  onChanged: (val) => setState(() => _sessionReminders = val),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildSwitchTile(
                  icon: Icons.mark_chat_unread_outlined,
                  title: 'Mentee Direct Messages',
                  subtitle: 'Push notifications when learners send you a chat.',
                  value: _messageAlerts,
                  onChanged: (val) => setState(() => _messageAlerts = val),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildSwitchTile(
                  icon: Icons.notification_add_outlined,
                  title: 'New Booking Requests',
                  subtitle: 'Instant alert when a learner books or reschedules.',
                  value: _bookingRequests,
                  onChanged: (val) => setState(() => _bookingRequests = val),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildSwitchTile(
                  icon: Icons.forum_outlined,
                  title: 'Community Q&A Mentions',
                  subtitle: 'Notify when learner questions match your expertise tags.',
                  value: _communityAlerts,
                  onChanged: (val) => setState(() => _communityAlerts = val),
                ),
              ]),
              const SizedBox(height: 24),

              // 3. Integrations & Meeting Setup
              _buildSectionHeader('Calendar & Video Meeting Setup'),
              const SizedBox(height: 10),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.sync_rounded,
                  title: 'Google Calendar Sync',
                  subtitle: 'Sync confirmed bookings to your personal Google Calendar.',
                  value: _googleCalendarSynced,
                  onChanged: (val) =>
                      setState(() => _googleCalendarSynced = val),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildDropdownTile(
                  icon: Icons.video_call_rounded,
                  title: 'Default Video Platform',
                  subtitle: 'Preferred meeting room tool for 1:1 sessions.',
                  value: _preferredMeetingPlatform,
                  options: [
                    'In-App WebRTC (Recommended)',
                    'Google Meet Link',
                    'Zoom Meeting',
                  ],
                  onChanged: (val) =>
                      setState(() => _preferredMeetingPlatform = val),
                ),
              ]),
              const SizedBox(height: 24),

              // 4. Security & Privacy
              _buildSectionHeader('Security & Login'),
              const SizedBox(height: 10),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric / Face ID Unlock',
                  subtitle: 'Require biometric authentication to open expert dashboard.',
                  value: _biometricEnabled,
                  onChanged: (val) =>
                      setState(() => _biometricEnabled = val),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildSwitchTile(
                  icon: Icons.security_rounded,
                  title: 'Two-Factor Authentication (2FA)',
                  subtitle: 'Protect your payouts and profile with SMS OTP verify.',
                  value: _twoFactorAuth,
                  onChanged: (val) => setState(() => _twoFactorAuth = val),
                ),
              ]),
              const SizedBox(height: 24),

              // 5. Policies & Help
              _buildSectionHeader('Platform Policies & Guidelines'),
              const SizedBox(height: 10),
              _buildCard([
                _buildNavTile(
                  icon: Icons.gavel_rounded,
                  title: 'Expert Code of Conduct',
                  subtitle: 'Punctuality, ethics, and session quality standards.',
                  onTap: () => _showPolicyDialog(
                    'Code of Conduct',
                    'Experts must join calls 2 minutes prior, maintain professional decorum, and provide actionable post-session summaries. Any no-show without 6 hours notice incurs penalty.',
                  ),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildNavTile(
                  icon: Icons.percent_rounded,
                  title: 'Commission & Payout Schedule',
                  subtitle: '15% platform commission on completed sessions.',
                  onTap: () => _showPolicyDialog(
                    'Commission Terms',
                    'The platform retains 15% on each completed consultation to cover payment gateway processing, video infrastructure, and learner acquisition.',
                  ),
                ),
                const Divider(height: 1, color: AppColors.line),
                _buildNavTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App Version',
                  subtitle: 'ExpertMentor v1.0.0 (Build 240)',
                  onTap: () {},
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isDense: true,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      items: options.map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text(opt),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) onChanged(v);
                      },
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

  Widget _buildBufferMinutesTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.coffee_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buffer Time Between Sessions',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Rest & notes preparation break between back-to-back bookings.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [5, 10, 15, 30].map((mins) {
              final isSelected = mins == _bufferMinutes;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _bufferMinutes = mins),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.line,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$mins mins',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.ink, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(content,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.ink)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}

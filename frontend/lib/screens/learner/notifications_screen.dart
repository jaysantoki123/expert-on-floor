import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/notification_provider.dart';

// ══════════════════════════════════════════════════════════════════
// Notification Data Model
// ══════════════════════════════════════════════════════════════════
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.type,
  });
}

// ══════════════════════════════════════════════════════════════════
// Notifications Screen
// ══════════════════════════════════════════════════════════════════
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  int get _unreadCount =>
      Provider.of<NotificationProvider>(context, listen: false).unreadCount;

  NotificationModel _mapToModel(dynamic json) {
    final typeStr = json['type']?.toString() ?? '';
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? '';
    final message = json['body']?.toString() ?? '';
    final isRead = json['isRead'] == true || json['isRead'] == 1 || json['is_read'] == true || json['is_read'] == 1;

    String timeStr = 'Recent';
    try {
      if (json['createdAt'] != null) {
        timeStr = _formatTime(DateTime.parse(json['createdAt']).toLocal());
      }
    } catch (_) {}

    IconData icon = Icons.notifications_none_rounded;
    Color iconColor = AppColors.primary;
    Color iconBg = AppColors.primarySoft;

    switch (typeStr) {
      case 'booking_confirmed':
      case 'session_reminder':
        icon = Icons.calendar_today_rounded;
        iconColor = AppColors.primary;
        iconBg = AppColors.primarySoft;
        break;
      case 'new_message':
        icon = Icons.chat_bubble_outline_rounded;
        iconColor = Colors.deepPurple;
        iconBg = const Color(0xFFF3E5F5);
        break;
      case 'review_received':
      case 'review_like':
        icon = Icons.star_outline_rounded;
        iconColor = Colors.amber;
        iconBg = const Color(0xFFFFF8E1);
        break;
      case 'payment_success':
        icon = Icons.payment_outlined;
        iconColor = Colors.green;
        iconBg = const Color(0xFFE8F5E9);
        break;
      case 'community_post':
        icon = Icons.forum_outlined;
        iconColor = Colors.blue;
        iconBg = const Color(0xFFE3F2FD);
        break;
      case 'community_answer':
        icon = Icons.question_answer_outlined;
        iconColor = const Color(0xFF7C4DFF);
        iconBg = const Color(0xFFEDE7F6);
        break;
      case 'post_like':
        icon = Icons.favorite_rounded;
        iconColor = Colors.redAccent;
        iconBg = const Color(0xFFFFEBEE);
        break;
      case 'answer_like':
        icon = Icons.thumb_up_alt_outlined;
        iconColor = Colors.orange;
        iconBg = const Color(0xFFFFE0B2);
        break;
      default:
        icon = Icons.notifications_active_outlined;
        iconColor = Colors.teal;
        iconBg = const Color(0xFFE0F2F1);
        break;
    }

    return NotificationModel(
      id: id,
      title: title,
      message: message,
      time: timeStr,
      isRead: isRead,
      icon: icon,
      iconColor: iconColor,
      iconBg: iconBg,
      type: typeStr,
    );
  }

  /// Smart human-readable time formatter
  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    }

    final today = DateTime(now.year, now.month, now.day);
    final dtDay = DateTime(dt.year, dt.month, dt.day);
    final daysDiff = today.difference(dtDay).inDays;

    final timeStr = DateFormat('h:mm a').format(dt);
    if (daysDiff == 0) return 'Today at $timeStr';
    if (daysDiff == 1) return 'Yesterday at $timeStr';
    if (daysDiff < 7) return '${_weekday(dt.weekday)} at $timeStr';
    return DateFormat('d MMM y').format(dt);
  }

  String _weekday(int w) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(w - 1).clamp(0, 6)];
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
              // ── Header ───────────────────────────
              _buildHeader(),

              // ── List ─────────────────────────────
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.notifications.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    if (provider.notifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => provider.fetchNotifications(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.notifications.length,
                        itemBuilder: (_, i) {
                          final notif = _mapToModel(provider.notifications[i]);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _NotificationTile(
                              notification: notif,
                              onTap: () => _handleNotificationTap(notif),
                              onDismiss: () => _deleteNotification(notif),
                            ),
                          ).animate().fade(duration: 350.ms).slideX(begin: 0.15);
                        },
                      ),
                    );
                  },
                ),
              ),
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
    final unread = _unreadCount;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          // Back button
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

          // Title + unread count subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                if (unread > 0)
                  Text(
                    '$unread new notification${unread > 1 ? "s" : ""}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const Text(
                    'Stay updated with your activities',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
              ],
            ),
          ),

          // Mark all as read
          if (unread > 0)
            GestureDetector(
              onTap: _markAllAsRead,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Mark all as read',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),

          // Settings
          GestureDetector(
            onTap: _showSettingsSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.ink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something important happens',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────
  void _handleNotificationTap(NotificationModel notif) {
    // Handle tap locally
  }

  void _deleteNotification(NotificationModel notif) {
    // Mock delete
  }

  void _markAllAsRead() {
    Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _NotificationSettingsSheet(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Notification Tile
// ══════════════════════════════════════════════════════════════════
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 2),
            const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: !notification.isRead
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.line,
              width: !notification.isRead ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  !notification.isRead ? 0.07 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Icon ───────────────────────────
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: notification.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // ── Content ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: !notification.isRead
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: !notification.isRead
                                ? AppColors.primary
                                : AppColors.muted,
                            fontWeight: !notification.isRead
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: !notification.isRead
                            ? AppColors.ink
                            : AppColors.muted,
                        fontWeight: !notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Notification Settings Sheet
// ══════════════════════════════════════════════════════════════════
class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState
    extends State<_NotificationSettingsSheet> {
  bool _sessionNotifications = true;
  bool _messageNotifications = true;
  bool _reviewNotifications = true;
  bool _paymentNotifications = true;
  bool _announcementNotifications = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 20),
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.calendar_today_outlined,
              title: 'Session Notifications',
              subtitle: 'Get notified about session confirmations, reminders, etc.',
              value: _sessionNotifications,
              onChanged: (value) =>
                  setState(() => _sessionNotifications = value),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Message Notifications',
              subtitle: 'Get notified about new messages from experts',
              value: _messageNotifications,
              onChanged: (value) =>
                  setState(() => _messageNotifications = value),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.star_outline_rounded,
              title: 'Review Notifications',
              subtitle: 'Get notified when you receive a review',
              value: _reviewNotifications,
              onChanged: (value) =>
                  setState(() => _reviewNotifications = value),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.payment_outlined,
              title: 'Payment Notifications',
              subtitle: 'Get notified about payment status updates',
              value: _paymentNotifications,
              onChanged: (value) =>
                  setState(() => _paymentNotifications = value),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.campaign_outlined,
              title: 'Announcements',
              subtitle: 'Get notified about platform updates and new experts',
              value: _announcementNotifications,
              onChanged: (value) =>
                  setState(() => _announcementNotifications = value),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(14),
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
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primarySoft,
          ),
        ],
      ),
    );
  }
}

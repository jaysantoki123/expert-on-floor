import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

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

final List<NotificationModel> _dummyNotifications = [
  NotificationModel(
    id: '1',
    title: 'Session Confirmed',
    message: 'Your session with Rahul Sharma is confirmed for 10 May, 2026 at 4:00 PM.',
    time: '10:30 AM',
    isRead: false,
    icon: Icons.calendar_today_rounded,
    iconColor: AppColors.primary,
    iconBg: AppColors.primarySoft,
    type: 'session',
  ),
  NotificationModel(
    id: '2',
    title: 'New Message',
    message: 'Rahul Sharma sent you a message',
    time: '09:15 AM',
    isRead: false,
    icon: Icons.chat_bubble_outline_rounded,
    iconColor: Colors.deepPurple,
    iconBg: const Color(0xFFF3E5F5),
    type: 'message',
  ),
  NotificationModel(
    id: '3',
    title: 'New Review',
    message: 'You received a 5-star review from Rahul Sharma.',
    time: 'Yesterday, 08:45 AM',
    isRead: true,
    icon: Icons.star_outline_rounded,
    iconColor: Colors.amber,
    iconBg: const Color(0xFFFFF8E1),
    type: 'review',
  ),
  NotificationModel(
    id: '4',
    title: 'Payment Successful',
    message: 'Your payment of ₹1,020 to Rahul Sharma was successful.',
    time: 'Yesterday, 08:30 AM',
    isRead: true,
    icon: Icons.payment_outlined,
    iconColor: Colors.green,
    iconBg: const Color(0xFFE8F5E9),
    type: 'payment',
  ),
  NotificationModel(
    id: '5',
    title: 'New Announcement',
    message: 'We\'ve added new experts in Flutter & Firebase. Check them out!',
    time: 'Yesterday, 06:20 PM',
    isRead: true,
    icon: Icons.campaign_outlined,
    iconColor: Colors.blue,
    iconBg: const Color(0xFFE3F2FD),
    type: 'announcement',
  ),
  NotificationModel(
    id: '6',
    title: 'Milestone Achieved',
    message: 'Congratulations! You completed 3 sessions. Keep learning!',
    time: '8 May, 2026',
    isRead: true,
    icon: Icons.emoji_events_outlined,
    iconColor: Colors.deepOrange,
    iconBg: const Color(0xFFFFE0B2),
    type: 'achievement',
  ),
];

// ══════════════════════════════════════════════════════════════════
// Notifications Screen
// ══════════════════════════════════════════════════════════════════
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late List<Animation<double>> _itemAnims;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _itemAnims = List.generate(
      _dummyNotifications.length,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animCtrl,
          curve: Interval(
            i * 0.08,
            (i * 0.08 + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  int get _unreadCount =>
      _dummyNotifications.where((n) => !n.isRead).length;

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
                child: _dummyNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _dummyNotifications.length,
                        itemBuilder: (_, i) {
                          final notif = _dummyNotifications[i];
                          final anim = _itemAnims[i];

                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.3, 0),
                                end: Offset.zero,
                              ).animate(anim),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _NotificationTile(
                                  notification: notif,
                                  onTap: () => _handleNotificationTap(notif),
                                  onDismiss: () => _deleteNotification(notif),
                                ),
                              ),
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
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount new notification${_unreadCount > 1 ? 's' : ''}',
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
          if (_unreadCount > 0)
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
    // Handle notification tap based on type
    if (!notif.isRead) {
      setState(() {
        final index = _dummyNotifications.indexOf(notif);
        _dummyNotifications[index] = NotificationModel(
          id: notif.id,
          title: notif.title,
          message: notif.message,
          time: notif.time,
          isRead: true,
          icon: notif.icon,
          iconColor: notif.iconColor,
          iconBg: notif.iconBg,
          type: notif.type,
        );
      });
    }
  }

  void _deleteNotification(NotificationModel notif) {
    setState(() {
      _dummyNotifications.remove(notif);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _dummyNotifications.add(notif);
            });
          },
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _dummyNotifications.length; i++) {
        final notif = _dummyNotifications[i];
        if (!notif.isRead) {
          _dummyNotifications[i] = NotificationModel(
            id: notif.id,
            title: notif.title,
            message: notif.message,
            time: notif.time,
            isRead: true,
            icon: notif.icon,
            iconColor: notif.iconColor,
            iconBg: notif.iconBg,
            type: notif.type,
          );
        }
      }
    });
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 16),
        ],
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

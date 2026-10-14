import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  IO.Socket? _socket;

  List<dynamic> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Set the socket from ChatProvider and register to new_notification channel
  void setSocket(IO.Socket? socket) {
    if (_socket == socket) return;
    _socket = socket;

    if (_socket != null) {
      debugPrint('🔔 NotificationProvider registering socket listener');
      _socket!.off('new_notification');
      _socket!.on('new_notification', (data) {
        debugPrint('🔔 Real-time notification received: $data');
        _handleNewNotification(data);
      });
    }
  }

  // Fetch all notifications from backend
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _notificationService.getNotifications();
      _notifications = data;
      _unreadCount = _notifications.where((n) => n['isRead'] == false || n['isRead'] == 0 || n['is_read'] == false || n['is_read'] == 0).length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      for (var i = 0; i < _notifications.length; i++) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(_notifications[i]);
        item['isRead'] = true;
        item['is_read'] = true;
        _notifications[i] = item;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  void _handleNewNotification(dynamic data) {
    if (data == null) return;
    final Map<String, dynamic> notif = Map<String, dynamic>.from(data);
    
    // Avoid duplicates
    final idStr = notif['id']?.toString();
    if (!_notifications.any((n) => n['id']?.toString() == idStr)) {
      _notifications.insert(0, notif);
      _unreadCount++;
      notifyListeners();
    }
  }
}

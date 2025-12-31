// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../service/socket_service.dart';
import '../service/notification_api_service.dart';
import '../model/notification_item.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _items = [];
  int _unreadCount = 0;
  bool _socketInited = false;

  List<NotificationItem> get items => _items;
  int get unreadCount => _unreadCount;

  /// Gọi sau khi login
  void initSocket(String userId, String token) {
    if (_socketInited) return;
    print('🔔 Initializing socket for notifications with userId: $userId,$token');
    final socket = SocketService();
    socket.connect(userId, token);

    socket.onNotification((data) {
      _items.insert(0, NotificationItem.fromSocket(data));
      _unreadCount++;
      notifyListeners();
    });

    _socketInited = true;
  }

  /// Sync khi mở app
  Future<void> syncUnreadCount() async {
    print( '🔔 Syncing unread notification count');
    _unreadCount = await NotificationApiService.getUnreadCount();
    print(  '🔔 Unread notification count: $_unreadCount');
    notifyListeners();
  }

  Future<void> loadNotifications() async {
  final list = await NotificationApiService.getNotifications();

  _items
    ..clear()
    ..addAll(list);

  _unreadCount = _items.where((e) => !e.isRead).length;
  notifyListeners();
}


  // void markAsRead(String id) {
  //   NotificationApiService.markAsRead(id);
  //   _unreadCount = (_unreadCount - 1).clamp(0, 999);
  //   notifyListeners();
  // }
  Future<void> markAsRead(String id) async {
  final index = _items.indexWhere((e) => e.id == id);
  if (index == -1) return;

  // 1. Optimistic update: update local state
  _items[index] = _items[index].copyWith(isRead: true);

  // 2. Update unread count an toàn
  _unreadCount = (_unreadCount - 1).clamp(0, 999);

  notifyListeners();

  // 3. Call API
  try {
    await NotificationApiService.markAsRead(id);
  } catch (e) {
    // rollback nếu API fail
    _items[index] = _items[index].copyWith(isRead: false);
    _unreadCount = (_unreadCount + 1).clamp(0, 999);
    notifyListeners();
    rethrow;
  }
}


  void disconnectSocket() {
    SocketService().disconnect();
    _socketInited = false;
  }
  void clear() {
    _items.clear();
    _unreadCount = 0;
    _socketInited = false;
    notifyListeners();
  }
}

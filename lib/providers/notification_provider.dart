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

  /// Gọi 1 lần sau khi login
  void initSocket(String userId, String token) {
    if (_socketInited) return;

    print('🔔 Initializing notification socket');

    final socket = SocketService();
    socket.connect(userId, token);

    /// Nhận notification realtime
    socket.onNotification((data) {
      _items.insert(0, NotificationItem.fromSocket(data));
      _unreadCount++;
      notifyListeners();
    });

    /// 🔥 RẤT QUAN TRỌNG: sync lại khi socket reconnect
    socket.onReconnect(() async {
      print('🔄 Sync notifications after reconnect');
      await syncUnreadCount();
      await loadNotifications();
    });

    _socketInited = true;
  }

  /// Sync badge (gọi khi mở app / resume)
  Future<void> syncUnreadCount() async {
    _unreadCount = await NotificationApiService.getUnreadCount();
    notifyListeners();
  }

  /// Load full notification list
  Future<void> loadNotifications() async {
    final list = await NotificationApiService.getNotifications();

    _items
      ..clear()
      ..addAll(list);

    _unreadCount = _items.where((e) => !e.isRead).length;
    notifyListeners();
  }

  /// Mark single notification as read (optimistic)
  Future<void> markAsRead(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;

    _items[index] = _items[index].copyWith(isRead: true);
    _unreadCount = (_unreadCount - 1).clamp(0, 999);
    notifyListeners();

    try {
      await NotificationApiService.markAsRead(id);
    } catch (e) {
      // rollback nếu fail
      _items[index] = _items[index].copyWith(isRead: false);
      _unreadCount = (_unreadCount + 1).clamp(0, 999);
      notifyListeners();
      rethrow;
    }
  }

  /// Logout
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

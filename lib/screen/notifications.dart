import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Giả định bạn có package shimmer để làm hiệu ứng loading đẹp hơn
// import 'package:shimmer/shimmer.dart';

import '../providers/notification_provider.dart';
import '../model/notification_item.dart';
import 'notification_detail.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    await Future.wait([
      context.read<NotificationProvider>().syncUnreadCount(),
      context.read<NotificationProvider>().loadNotifications(),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final notifyProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0F),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          // Nút đánh dấu đọc tất cả giúp nâng cao UX
          // if (notifyProvider.items.any((e) => !e.isRead))
          //   TextButton(
          //     onPressed: () => _markAllAsRead(context),
          //     child: const Text('Đọc tất cả', style: TextStyle(color: Colors.redAccent)),
          //   ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.redAccent,
        onRefresh: _initLoad,
        child: _loading
            ? _buildShimmerLoading()
            : notifyProvider.items.isEmpty
            ? _buildEmptyState()
            : _buildNotificationList(notifyProvider),
      ),
    );
  }

  // 1. Hiệu ứng Loading Shimmer (thay cho CircularProgressIndicator)
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // 2. Giao diện khi không có thông báo (Empty State)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hộp thư trống',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 3. Danh sách thông báo với tính năng vuốt để xóa
  Widget _buildNotificationList(NotificationProvider notify) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: notify.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = notify.items[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_sweep, color: Colors.redAccent),
          ),
          onDismissed: (direction) {
            // Gọi hàm xóa trong provider của bạn ở đây
            // notify.deleteNotification(item.id);
          },
          child: _KurumiNotificationTile(item: item),
        );
      },
    );
  }

  // void _markAllAsRead(BuildContext context) {
  //    context.read<NotificationProvider>().markAllAsRead(); // Giả định có hàm này
  // }
}

class _KurumiNotificationTile extends StatelessWidget {
  final NotificationItem item;
  const _KurumiNotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final notify = context.read<NotificationProvider>();

    return InkWell(
      onTap: () {
        // if (!item.isRead) notify.markAsRead(item.id);
        // 1. Đánh dấu đã đọc
        if (!item.isRead) {
          context.read<NotificationProvider>().markAsRead(item.id);
        }

        // 2. Chuyển trang
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(item: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead
              ? const Color(0xFF14141A)
              : const Color(0xFF1E1015),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? Colors.white.withOpacity(0.05)
                : Colors.redAccent.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon với dot chỉ thị trạng thái chưa đọc
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.isRead
                        ? Colors.grey.withOpacity(0.1)
                        : Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: item.isRead ? Colors.grey : Colors.redAccent,
                    size: 20,
                  ),
                ),
                if (!item.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1E1015),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: item.isRead ? Colors.grey.shade400 : Colors.white,
                      fontWeight: item.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.isRead
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(item.createdAt),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${time.day}/${time.month}/${time.year}';
  }
}

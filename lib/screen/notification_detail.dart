import 'package:flutter/material.dart';
import '../model/notification_item.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationItem item;

  const NotificationDetailScreen({super.key, required this.item});

  // Hàm helper để format số có 2 chữ số (ví dụ: 9 -> 09)
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Hàm format ngày tháng thủ công
  String _formatDateTime(DateTime dt) {
    final date = "${_twoDigits(dt.day)}/${_twoDigits(dt.month)}/${dt.year}";
    final time = "${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}";
    return "$time - $date";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F), // Nền đen sâu
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              // Thêm logic xóa tại đây nếu cần
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Badge loại thông báo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Text(
                'HỆ THỐNG',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tiêu đề lớn
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            
            // Thời gian
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  _formatDateTime(item.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(color: Colors.white10, thickness: 1),
            const SizedBox(height: 24),
            
            // Nội dung chi tiết
            Text(
              item.body,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 16,
                height: 1.7, // Giúp đọc nội dung dài dễ hơn
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Nút phản hồi cuối trang (Gợi ý thêm)
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: Colors.redAccent.withOpacity(0.3),
              ),
              child: const Text(
                'Đã xác nhận',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
               // Logic copy nội dung hoặc báo cáo lỗi
            },
            child: Text(
              'Sao chép nội dung',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
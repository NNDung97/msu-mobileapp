class NotificationItem {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  /// Khi lấy từ API
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'],
    );
  }

  /// Khi nhận từ Socket.IO (chưa có id DB)
  factory NotificationItem.fromSocket(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'],
      body: json['body'],
      isRead: false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      data: json['data'],
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}

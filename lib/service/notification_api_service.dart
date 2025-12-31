// //notification_api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../model/notification_item.dart';

// class NotificationApiService {
//   static const _storage = FlutterSecureStorage();

//   /// ⚠️ đổi đúng theo môi trường
//   static const String _baseUrl = 'http://10.0.2.2:3000/api';

//   static Future<String?> _getToken() async {
//     return await _storage.read(key: 'access_token');
//   }

//   static Map<String, String> _headers(String token) => {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       };

//   /// GET /api/notifications
//   static Future<List<NotificationItem>> getNotifications() async {
//     final token = await _getToken();
//     if (token == null) throw Exception('No token');

//     final res = await http.get(
//       Uri.parse('$_baseUrl/notifications'),
//       headers: _headers(token),
//     );

//     if (res.statusCode != 200) {
//       throw Exception('Failed to load notifications');
//     }

//     final body = json.decode(res.body);

//     return (body['notifications'] as List)
//         .map((e) => NotificationItem.fromJson(e))
//         .toList();
//   }

//   /// GET /api/notifications/unread-count
//   static Future<int> getUnreadCount() async {
//     final token = await _getToken();
//     print('DEBUG token from storage: $token');
//     if (token == null) return 0;

//     final res = await http.get(
//       Uri.parse('$_baseUrl/notifications/unread-count'),
//       headers: _headers(token),
//     );

//     print('Unread count response: ${res.statusCode}, body: ${res.body}');

//     if (res.statusCode != 200) return 0;

//     final body = json.decode(res.body);
//     return body['count'] ?? 0;
//   }

//   /// POST /api/notifications/:id/read
//   static Future<void> markAsRead(String id) async {
//     final token = await _getToken();
//     if (token == null) return;

//     await http.post(
//       Uri.parse('$_baseUrl/notifications/$id/read'),
//       headers: _headers(token),
//     );
//   }

//   /// POST /api/notifications/read-all
//   static Future<void> markAllAsRead() async {
//     final token = await _getToken();
//     if (token == null) return;

//     await http.post(
//       Uri.parse('$_baseUrl/notifications/read-all'),
//       headers: _headers(token),
//     );
//   }
// }

// lib/service/notification_api_service.dart
import '../network/api_client.dart';
import '../model/notification_item.dart';

class NotificationApiService {
  /// GET /api/notifications
  static Future<List<NotificationItem>> getNotifications() async {
    final res = await ApiClient.dio.get('/notifications');

    return (res.data['notifications'] as List)
        .map((e) => NotificationItem.fromJson(e))
        .toList();
  }

  /// GET /api/notifications/unread-count
  static Future<int> getUnreadCount() async {
    final res = await ApiClient.dio.get('/notifications/unread-count');
    return res.data['count'] ?? 0;
  }

  // /// POST /api/notifications/:id/read
  // static Future<void> markAsRead(String id) async {
  //   await ApiClient.dio.post('/notifications/$id/read');
  // }

  /// PATCH /api/notifications/:id/read
  static Future<void> markAsRead(String id) async {
    await ApiClient.dio.patch('/notifications/$id/read');
  }

  /// POST /api/notifications/read-all
  static Future<void> markAllAsRead() async {
    await ApiClient.dio.post('/notifications/read-all');
  }
}

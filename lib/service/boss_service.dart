// lib/service/boss_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http; // Import thư viện http
import '../model/boss_model.dart';

// Định nghĩa URL API
const String BOSS_API_URL = 'http://10.0.2.2:3000/api/boss';

class BossService {
  
  static Future<BossList> fetchBossList() async {
    try {
      // 1. Thực hiện cuộc gọi HTTP GET
      final response = await http.get(Uri.parse(BOSS_API_URL));
      
      // 2. Kiểm tra mã trạng thái (status code)
      if (response.statusCode == 200) {
        // API thành công (Status 200 OK)
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        
        // Trả về dữ liệu đã parse sang Model
        return BossList.fromJson(jsonResponse);
        
      } else {
        // API thất bại (Status khác 200)
        print('Lỗi API. Mã trạng thái: ${response.statusCode}');
        // Ném ra Exception để FutureBuilder bắt lỗi
        throw Exception('Không thể tải danh sách boss. Mã: ${response.statusCode}');
      }
      
    } catch (e) {
      // Lỗi kết nối mạng hoặc lỗi parsing JSON
      print('Lỗi khi fetch Boss List: $e');
      throw Exception('Lỗi kết nối hoặc dữ liệu: $e');
    }
  }
}

// Giữ nguyên file Model và Screen như cũ.
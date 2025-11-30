import 'dart:convert';
import 'package:http/http.dart' as http;

class ApStat {
  final num ability;
  final num base;
  final num hyperStat;
  final num others;
  final num total;
  final String name;

  ApStat({
    required this.name,
    required this.ability,
    required this.base,
    required this.hyperStat,
    required this.others,
    required this.total,
  });

  factory ApStat.fromJson(String key, Map<String, dynamic> json) {
    // Sử dụng 'as num' để đảm bảo kiểu dữ liệu hợp lệ (int hoặc double)
    return ApStat(
      name: key,
      ability: json['ability'] as num? ?? 0, 
      base: json['base'] as num? ?? 0,
      hyperStat: json['hyperStat'] as num? ?? 0,
      others: json['others'] as num? ?? 0,
      total: json['total'] as num? ?? 0,
    );
  }
}

// Class ApStatService và hàm fetchApStats không cần thay đổi
class ApStatService {
  final String baseUrl = 'https://msu-nodeserver.vercel.app/api/character'; // 👈 base URL

  /// Gọi API: /api/character/{accessKey}/ap-stat
  Future<List<ApStat>> fetchApStats(String accessKey) async {
    final url = Uri.parse('$baseUrl/$accessKey/ap-stat');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hyperStatData = data['data']['apStat'] as Map<String, dynamic>;

      // Lọc bỏ các giá trị null và đảm bảo e.value là Map<String, dynamic>
      return hyperStatData.entries
          .where((e) => e.value != null && e.value is Map)
          .map((e) => ApStat.fromJson(e.key, (e.value as Map).cast<String, dynamic>()))
          .toList();
    } else {
      throw Exception(
          'Không thể tải dữ liệu Hyper Stat (mã lỗi: ${response.statusCode})');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class HyperStat {
  final String name;
  final int code;
  final String desc;
  final int level;

  HyperStat({
    required this.name,
    required this.code,
    required this.desc,
    required this.level,
  });

  factory HyperStat.fromJson(String key, Map<String, dynamic> json) {
    return HyperStat(
      name: key,
      code: json['code'] ?? 0,
      desc: json['desc'] ?? '',
      level: json['level'] ?? 0,
    );
  }
}

class HyperStatService {
  final String baseUrl = 'https://msu-nodeserver.vercel.app/api/character'; // 👈 base URL

  /// Gọi API: /api/character/{accessKey}/hyper-stat
  Future<List<HyperStat>> fetchHyperStats(String accessKey) async {
    final url = Uri.parse('$baseUrl/$accessKey/hyper-stat');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hyperStatData = data['data']['hyperStat'] as Map<String, dynamic>;

      // Lọc bỏ các giá trị null
      return hyperStatData.entries
          .where((e) => e.value != null)
          .map((e) => HyperStat.fromJson(e.key, e.value))
          .toList();
    } else {
      throw Exception(
          'Không thể tải dữ liệu Hyper Stat (mã lỗi: ${response.statusCode})');
    }
  }
}

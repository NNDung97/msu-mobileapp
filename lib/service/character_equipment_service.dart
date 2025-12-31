import 'dart:convert';
import 'package:http/http.dart' as http;

class CharacterEquipmentService {
  final String baseUrl;

  CharacterEquipmentService({
    this.baseUrl = 'https://msu-nodeserver.vercel.app/api/character',
  });

  /// Lấy thông tin trang bị nhân vật (decoEquip, equip, pet)
  Future<Map<String, dynamic>> fetchWearingData(String accessKey) async {
    final url = Uri.parse('$baseUrl/$accessKey/wearing');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final wearing = jsonData['data']?['wearing'];
      if (wearing == null) {
        throw Exception('Không có dữ liệu wearing trong API.');
      }

      return {
        'decoEquip': wearing['decoEquip'],
        'equip': wearing['equip'],
        'pet': wearing['pet'],
      };
    } else {
      throw Exception('Lỗi API (${response.statusCode}): ${response.reasonPhrase}');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/characters.dart';

class CharacterService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/account';

  static Future<List<Character>> fetchCharacters(String walletAddress, int pageNo) async {
    final url = Uri.parse('$baseUrl/$walletAddress/characters?pageNo=$pageNo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print(decoded); // In ra dữ liệu nhận được từ API

      // Lấy danh sách nhân vật từ data.characters
      final List<dynamic> jsonData = decoded['data']['characters'] ?? [];

      // Chuyển thành danh sách model
      return jsonData.map((e) => Character.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải nhân vật: ${response.statusCode}');
    }
  }
}

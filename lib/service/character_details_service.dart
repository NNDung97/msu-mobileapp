import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/CharacterDetails.dart';

class CharacterDetailsService {
  static const String baseUrl = 'https://msu-nodeserver.vercel.app/api/character';

  Future<CharacterCommon?> fetchCharacterDetails(String accessKey) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$accessKey'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // ✅ Lấy đúng nhánh "data" -> "common"
        final commonData = jsonResponse['data']?['common'];
        if (commonData == null) {
          print('Không tìm thấy dữ liệu "common" trong response');
          return null;
        }

        return CharacterCommon.fromJson(commonData);
      } else {
        print('Failed to load character details');
        return null;
      }
    } catch (e) {
      print('Error fetching character details: $e');
      return null;
    }
  }
}
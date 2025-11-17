import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ItemSet.dart';

class ItemSetService {
  static const String baseUrl = "http://10.0.2.2:3000/api/item-details";

  static Future<ItemSet?> fetchItemSet(int? itemID) async {
    if (itemID == null) return null;

    try {
      final url = Uri.parse("$baseUrl/$itemID/set");
      print('Fetching ItemSet from URL: $url'); // Debug log

      final response = await http.get(
        url,
        headers: {
          "accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('ItemSet JSON Data: $jsonData'); // Debug log

        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data']['itemSet'] != null) {
          return ItemSet.fromJson(jsonData['data']['itemSet']);
        } else {
          print("⚠️ Dữ liệu itemSet không tồn tại trong response.");
        }
      } else {
        print("❌ API lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");
    }
    return null;
  }
}
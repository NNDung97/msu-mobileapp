import 'dart:convert';
import 'package:http/http.dart' as http;

class WalletApiService {
  // baseUrl của server Node.js
  static const String baseUrl = "http://10.0.2.2:3000/api";

  // Hàm login-wallet
  static Future<Map<String, dynamic>?> loginWallet(String walletAddress) async {
    final url = Uri.parse("$baseUrl/login-wallet");

    try {
      final response = await http.post(url, body: {
        "walletAddress": walletAddress,
      });

      if (response.statusCode == 200) {
        // Trả JSON dạng Map
        return jsonDecode(response.body);
      } else {
        print("Lỗi API: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return null;
    }
  }
}

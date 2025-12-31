import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/login_result.dart';

class WalletApiService {
  static const String baseUrl =
      // "https://msu-nodeserver.vercel.app/api";
      "https://msu-nodeserver-production.up.railway.app/api";

  static Future<LoginResult?> loginWallet(String walletAddress) async {
    print('check login wallet $walletAddress');
    final url = Uri.parse("$baseUrl/login-wallet");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "walletAddress": walletAddress,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print(  '✅ Login successful: $json');
        return LoginResult.fromJson(json);
      }

      print("❌ Login failed: ${response.statusCode}");
      print(response.body);
      return null;
    } catch (e) {
      print("❌ Login error: $e");
      return null;
    }
  }
}

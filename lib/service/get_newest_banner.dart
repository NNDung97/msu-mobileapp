import 'dart:convert';
import 'package:http/http.dart' as http;

class GetNewestBanner {
  static const String baseUrl = "https://msu.io/marketplace/api/banner";

  static Future<Map<String, String>?> fetchNewestBanner() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final banner = data["banners"][0];
        return {
          "title": banner["title"],
          "url": banner["url"],
          "image": banner["bannerImageTabletPath"],
        };
      } else {
        print("Failed to load banner");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
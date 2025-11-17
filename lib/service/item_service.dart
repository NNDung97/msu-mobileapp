import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/item_model.dart';
import '../model/items-list-model.dart';
import '../model/item_detail_model.dart';

class ItemService {
  static const String itemsbaseUrl = "http://10.0.2.2:3000/api/items";
  static const String baseUrl = "http://10.0.2.2:3000/api/item-details";

  static Future<ItemDetail?> fetchItemDetail(String accessKey) async {
    try {
      print("🔑 Fetching item detail with accessKey: $accessKey");
      final url = Uri.parse("$baseUrl/$accessKey/common");
      print("🌐 Requesting URL: $url");

      final response = await http.get(
        url,
        headers: {
          "accept": "application/json",
          // "x-nxopen-api-key": "YOUR_API_KEY", // thêm nếu cần
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ItemDetail.fromJson(jsonData);
      } else {
        print("❌ API lỗi: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");
      return null;
    }
  }

 static Future<ItemDetailList?> fetchItemDetailWithItemID(int itemID) async {
    try {
        final url = Uri.parse("$baseUrl/id/$itemID/common");
        print("🌐 Requesting URL: $url");
        
        final response = await http.get(
            url,
            headers: {"accept": "application/json"},
        );

        // --- BƯỚC 1: KIỂM TRA TRẠNG THÁI VÀ HEADER ---
        print("\n--- RESPONSE DEBUG ---");
        print("Status Code: ${response.statusCode}");
        print("Content Type: ${response.headers['content-type']}");
        
        // --- BƯỚC 2: KIỂM TRA BODY (CHỈ IN KHI LỖI HOẶC CẦN DEBUG) ---
        if (response.statusCode != 200) {
            print("❌ API lỗi: ${response.statusCode}");
            // In ra body để xem thông báo lỗi từ server (nếu có)
            print("Response Body (Error): ${response.body}"); 
            print("--------------------\n");
            return null;
        }

        // --- BƯỚC 3: XỬ LÝ DỮ LIỆU THÀNH CÔNG (STATUS 200) ---
        
        // Tối ưu hóa việc in body để tránh làm chậm ứng dụng khi response quá lớn
        // Chỉ in vài ký tự đầu để xác nhận JSON hợp lệ (tùy chọn)
        // print("Response Body (Start): ${response.body.substring(0, 50)}...");

        final jsonData = jsonDecode(response.body);

        // 💡 GIẢI PHÁP: Kiểm tra và ép kiểu an toàn
        if (jsonData is Map) {
            // Ép kiểu Map<dynamic, dynamic> sang Map<String, dynamic>
            final Map<String, dynamic> dataMap = jsonData.cast<String, dynamic>();
            print("✅ JSON Parsing SUCCESS.");
            print("--------------------\n");
            return ItemDetailList.fromJson(dataMap);
        }

        // Trường hợp jsonData không phải là Map
        print("❌ Lỗi dữ liệu: jsonData không phải là Map (Type: ${jsonData.runtimeType})");
        print("Response Body (Full): ${response.body}");
        print("--------------------\n");
        return null;

    } catch (e) {
        // In lỗi chính xác (ví dụ: lỗi mạng, lỗi phân tích JSON)
        print("❌ Lỗi khi gọi API (Exception): $e");
        print("--------------------\n");
        return null;
    }
}

  // Future<ItemResponse> fetchItems({int page = 1}) async {
  //   final url = Uri.parse("$baseUrl?page=$page");

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final jsonData = json.decode(response.body);
  //     return ItemResponse.fromJson(jsonData);
  //   } else {
  //     throw Exception("Failed to fetch items (${response.statusCode})");
  //   }
  // }
  Future<ItemResponse> fetchItems({
    int page = 1,
    // 🚀 Thêm hai tham số lọc mới
    String? name,
    String? category,
  }) async {
    // 1. Xây dựng Map chứa tất cả Query Parameters
    final Map<String, dynamic> queryParams = {'page': page.toString()};

    // 2. Thêm tham số lọc nếu chúng tồn tại (không null và không rỗng)
    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams['category'] = category;
    }

    // 3. Tạo URL với các Query Parameters
    // Ví dụ URL: YOUR_API_ENDPOINT?page=1&query=Veamoth&category=Hat
    final url = Uri.parse(itemsbaseUrl).replace(queryParameters: queryParams);

    print("Fetching URL: $url"); // In ra URL để debug

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // Giả định ItemResponse là class model chứa data và totalPages
      return ItemResponse.fromJson(jsonData);
    } else {
      throw Exception(
        "Failed to fetch items (${response.statusCode}) with URL: $url",
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../model/characters.dart';
import '../service/character_service.dart';

class CharacterProvider with ChangeNotifier {
  List<Character> _characters = [];
  int _currentPage = 1;
  bool _isLoading = false; // Trạng thái tải ban đầu (full screen)
  bool _isLoadingMore = false; // Trạng thái tải thêm (loading spinner ở cuối grid)
  bool _hasMore = true; // để biết còn trang tiếp theo không

  // --- Getters mới ---
  List<Character> get characters => _characters;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore; // 👈 Getter mới
  bool get hasMore => _hasMore;

  void setCharacters(List<Character> chars) {
    _characters = chars;
    notifyListeners();
  }

  /// Tải trang đầu tiên
  Future<void> loadInitialCharacters(String walletAddress) async {
    _currentPage = 1;
    // Đặt _isLoading = true (full screen)
    await _fetchCharacters(walletAddress, isInitialLoad: true); 
  }

  /// Tải thêm khi scroll tới cuối
  Future<void> loadMoreCharacters(String walletAddress) async {
    // 💡 Sửa logic: Kiểm tra cả _isLoading và _isLoadingMore
    if (_isLoading || _isLoadingMore || !_hasMore) return; 
    
    _currentPage++;
    print("Loading page: $_currentPage");
    // Đặt _isLoadingMore = true (spinner ở cuối grid)
    await _fetchCharacters(walletAddress, isInitialLoad: false); 
  }

  // --- Hàm fetch chung đã được cập nhật ---
  Future<void> _fetchCharacters(
    String walletAddress, {
    required bool isInitialLoad,
  }) async {
    if (isInitialLoad) {
      _isLoading = true;
      _characters = []; // Reset dữ liệu chỉ khi tải lần đầu
      _hasMore = true;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final newChars = await CharacterService.fetchCharacters(walletAddress, _currentPage);

      if (newChars.isEmpty) {
        _hasMore = false; // hết dữ liệu
      } else {
        _characters.addAll(newChars);
      }
    } catch (e) {
      print("Error fetching characters: $e");
      // Có thể hiển thị SnackBar lỗi ở đây nếu cần, hoặc xử lý ở UI
      if (!isInitialLoad) {
        _currentPage--; // Hoàn tác số trang nếu loadMore thất bại
      }
    }

    // Reset trạng thái loading phù hợp
    if (isInitialLoad) {
      _isLoading = false;
    } else {
      _isLoadingMore = false;
    }
    notifyListeners();
  }
}
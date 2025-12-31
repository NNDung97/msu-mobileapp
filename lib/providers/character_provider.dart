import 'package:flutter/material.dart';
import '../model/characters.dart';
import '../service/character_service.dart';

class CharacterProvider with ChangeNotifier {
  List<Character> _characters = [];
  int _currentPage = 1;
  bool _isLoading = false;      // loading full screen
  bool _isLoadingMore = false;  // loading thêm ở cuối grid
  bool _hasMore = true;

  // ===== GETTERS =====
  List<Character> get characters => _characters;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  // ===== SET FROM LOGIN =====
  void setCharacters(List<Character> chars) {
    _characters = chars;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  // ===== CLEAR (LOGOUT / RE-LOGIN) =====
  void clear() {
    _characters = [];
    _currentPage = 1;
    _isLoading = false;
    _isLoadingMore = false;
    _hasMore = true;
    notifyListeners();
  }

  // ===== LOAD INITIAL =====
  Future<void> loadInitialCharacters(String walletAddress) async {
    _currentPage = 1;
    await _fetchCharacters(
      walletAddress,
      isInitialLoad: true,
    );
  }

  // ===== LOAD MORE (SCROLL) =====
  Future<void> loadMoreCharacters(String walletAddress) async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _currentPage++;
    print("Loading page: $_currentPage");

    await _fetchCharacters(
      walletAddress,
      isInitialLoad: false,
    );
  }

  // ===== FETCH CORE =====
  Future<void> _fetchCharacters(
    String walletAddress, {
    required bool isInitialLoad,
  }) async {
    if (isInitialLoad) {
      _isLoading = true;
      _characters = [];
      _hasMore = true;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final newChars = await CharacterService.fetchCharacters(
        walletAddress,
        _currentPage,
      );

      if (newChars.isEmpty) {
        _hasMore = false;
      } else {
        _characters.addAll(newChars);
      }
    } catch (e) {
      print("Error fetching characters: $e");
      if (!isInitialLoad) {
        _currentPage--; // rollback page nếu loadMore fail
      }
    }

    if (isInitialLoad) {
      _isLoading = false;
    } else {
      _isLoadingMore = false;
    }
    notifyListeners();
  }
}

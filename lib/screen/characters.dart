// File: lib/screens/characters.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import 'characterdetails.dart';
// Nếu cần, bạn cần import Character model ở đây nếu nó không phải là dynamic
// import '../model/characters.dart'; 

// --- DARK THEME CONSTANTS ---
const Color primaryColor = Color(0xFFF9A825); 
const Color darkBg = Color(0xFF0F0821);       
const Color darkCardBg = Color(0xFF1B0F33);   
const Color secondaryText = Color(0xFFE0E0E0); 
const Color mutedText = Color(0xFF9E9E9E);    

class CharactersPage extends StatefulWidget {
  // 💡 Thêm Key (dùng GlobalKey từ HomePage) để truy cập State
  const CharactersPage({super.key});

  @override
  // 🚨 Sửa: Trả về State với tên PUBLIC (CharacterPageState)
  State<CharactersPage> createState() => CharacterPageState();
}

// 🚨 ĐỔI TÊN STATE TỪ PRIVATE (_CharactersPageState) SANG PUBLIC (CharacterPageState)
class CharacterPageState extends State<CharactersPage> {
  final ScrollController _scrollController = ScrollController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _walletAddress;

  @override
  void initState() {
    super.initState();
    _initWalletAndLoadData();
    _scrollController.addListener(_scrollListener);
  }

  // ✅ PHƯƠNG THỨC MỚI: Cho phép HomePage gọi hàm này sau khi Login thành công
  Future<void> refreshData() async {
    // Đảm bảo StatefulWidget còn hoạt động trước khi gọi setState
    if (mounted) {
      // Gọi lại hàm kiểm tra ví và tải dữ liệu ban đầu
      await _initWalletAndLoadData();
    }
  }

  void _scrollListener() {
    final provider = context.read<CharacterProvider>();

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !provider.isLoadingMore && 
        provider.hasMore &&
        _walletAddress != null) {
      
      provider.loadMoreCharacters(_walletAddress!);
    }
  }

  Future<void> _initWalletAndLoadData() async {
    final wallet = await _storage.read(key: 'wallet_address');
    
    // 🚨 BƯỚC QUAN TRỌNG: Cập nhật _walletAddress trong State
    // Điều này sẽ kích hoạt build() và loại bỏ màn hình "Chưa đăng nhập"
    // nếu ví đã được lưu thành công trong LoginPage
    setState(() {
      _walletAddress = wallet;
    });

    if (wallet != null && wallet.isNotEmpty) {
      // Tải dữ liệu ban đầu
      await context.read<CharacterProvider>().loadInitialCharacters(wallet);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // --- WIDGET CON: Card Nhân Vật ---
  Widget _buildCharacterCard(BuildContext context, dynamic char) {
    // ... (Giữ nguyên logic Card của bạn)
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterDetailPage(character: char),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  char.data.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, color: mutedText, size: 40)),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    char.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: secondaryText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.star, color: primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Level: ${char.data.level}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CHÍNH: BUILD ---
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CharacterProvider>();
    final characters = provider.characters;

    // 1. Chưa đăng nhập
    if (_walletAddress == null) {
      return Scaffold(
        backgroundColor: darkBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 80, color: primaryColor.withOpacity(0.7)),
                const SizedBox(height: 16),
                const Text(
                  "Vui lòng kết nối ví để xem danh sách nhân vật.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: secondaryText),
                ),
                // 💡 Đã bỏ nút "Đăng nhập ngay" vì việc điều hướng phức tạp trong tab widget.
                // Việc đăng nhập nên được xử lý qua Bottom Navigation Bar hoặc AppBar.
              ],
            ),
          ),
        ),
      );
    }
    
    // 2. Loading ban đầu
    if (provider.isLoading && characters.isEmpty) {
      return Scaffold(
        backgroundColor: darkBg,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    // 3. Không có dữ liệu
    if (characters.isEmpty && !provider.isLoading) {
      return Scaffold(
        backgroundColor: darkBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_dissatisfied, size: 60, color: mutedText),
              const SizedBox(height: 10),
              const Text("Không tìm thấy nhân vật nào.", style: TextStyle(fontSize: 16, color: secondaryText)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.loadInitialCharacters(_walletAddress!),
                icon: const Icon(Icons.refresh, color: darkBg),
                label: const Text("Tải lại", style: TextStyle(color: darkBg, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
        ),
      );
    }

    // 4. Hiển thị danh sách nhân vật
    return Scaffold(
      backgroundColor: darkBg,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          controller: _scrollController,
          itemCount: characters.length + (provider.hasMore ? 1 : 0), 
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12, 
            mainAxisSpacing: 12, 
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            if (index == characters.length) {
              return provider.isLoadingMore
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : const SizedBox.shrink(); 
            }

            final char = characters[index];
            return _buildCharacterCard(context, char);
          },
        ),
      ),
    );
  }
}
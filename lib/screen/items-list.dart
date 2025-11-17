import 'package:flutter/material.dart';
import '../model/items-list-model.dart';
import '../service/item_service.dart';
import '../screen/item_details_itemid.dart';

// Giả định: Item, ItemListResponse, ItemService đã tồn tại

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final ItemService _itemService = ItemService();
  List<Item> _items = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;

  // --- FILTER STATE (ĐÃ SỬA LỖI) ---
  String _searchQuery = '';
  // 💡 FIX 1: Khởi tạo giá trị ban đầu là 'All' (String)
  String _selectedCategory = 'All';

  // Giả định danh sách category có thể có
  final List<String> _categories = [
    'All',
    'Weapon',
    'Armor',
    'Hat',
    'Shoes',
    'Accessory',
  ];

  // --- UI/UX: Màu sắc tối ưu ---
  static const Color primaryColor = Color(0xFFF9A825);
  static const Color darkBg = Color(0xFF0F0821);
  static const Color darkCardBg = Color(0xFF1B0F33);
  static const Color inputFillColor = Color(0xFF2B1F45);

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    if (_items.isEmpty) setState(() => _isLoading = true);

    try {
      final response = await _itemService.fetchItems(
        page: _currentPage,
        // Giả định bạn đã đổi tên tham số thành 'query' hoặc giữ nguyên 'name'
        name: _searchQuery,
        // 💡 FIX 2: Gửi null cho API nếu giá trị hiện tại là 'All'
        category: _selectedCategory != 'All' ? _selectedCategory : null,
      );
      if (mounted) {
        setState(() {
          _items = response.data;
          _totalPages = response.totalPages;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
        setState(() {
          _items = [];
          _totalPages = 1;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changePage(int newPage) {
    if (newPage < 1 || newPage > _totalPages || newPage == _currentPage) return;
    setState(() {
      _currentPage = newPage;
      _isLoading = true;
    });
    _fetchItems();
  }

  void _onFilterChanged() {
    setState(() {
      _currentPage = 1;
      _items = [];
    });
    _fetchItems();
  }

  // --- WIDGET TỐI ƯU: Item Grid Card (Giữ nguyên) ---
  Widget _buildItemGridCard(Item item) {
    return InkWell(
      onTap: () {
        // if (item.link != null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("Mở chi tiết Item: ${item.name}")),
        //   );
        // }
        Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => ItemDetailScreen(
                      itemId: item.itemID,
                      imageUrl: item.image ?? '', // Truyền URL hình ảnh
                    ),
                  ),
                );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.grey.shade900,
                  child: item.image != null
                      ? Image.network(
                          item.image!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.inventory_2,
                            color: Colors.white54,
                            size: 40,
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2,
                          color: Colors.white54,
                          size: 40,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 58,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Text(
                      item.name ?? "Không tên",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      item.category ?? "Unknown",
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.8),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TỐI ƯU: AppBar với Filter ---
  PreferredSizeWidget _buildFilterAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: AppBar(
        title: const Text(
          "Item Database",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkCardBg,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // 1. Filter theo tên (TextField)
                Expanded(
                  child: TextField(
                    cursorColor: primaryColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên...',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      filled: true,
                      fillColor: inputFillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // 2. Filter theo Category (Dropdown)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      // 💡 FIX 3: Dùng giá trị String _selectedCategory
                      value: _selectedCategory,
                      hint: const Text(
                        'Category',
                        style: TextStyle(color: Colors.white),
                      ),
                      dropdownColor: darkCardBg,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: primaryColor,
                      ),
                      items: _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          // 💡 FIX 4: Gán giá trị String (bao gồm cả 'All')
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: value == 'All'
                                  ? primaryColor
                                  : Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          // Giá trị không còn là null nữa do đã sửa ở bước 4
                          _selectedCategory = newValue!;
                          _onFilterChanged();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET TỐ ƯU: Pagination Bar (Giữ nguyên) ---
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: darkCardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPaginationButton(
            label: "← Trang trước",
            isEnabled: _currentPage > 1 && !_isLoading,
            onPressed: () => _changePage(_currentPage - 1),
          ),
          Text(
            "Trang $_currentPage / $_totalPages",
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          _buildPaginationButton(
            label: "Trang sau →",
            isEnabled: _currentPage < _totalPages && !_isLoading,
            onPressed: () => _changePage(_currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required String label,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isEnabled
            ? const LinearGradient(
                colors: [Color(0xFFFB8C00), Color(0xFFF9A825)],
              )
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? Colors.transparent
              : Colors.grey.shade700,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  // --- WIDGET CHÍNH: Scaffold ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: _buildFilterAppBar(),
      body: Stack(
        children: [
          _items.isEmpty && !_isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 60,
                        color: Colors.white38,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Không tìm thấy Item nào.",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) =>
                        _buildItemGridCard(_items[index]),
                  ),
                ),
          if (_isLoading)
            Container(
              color: darkBg.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 15),
                    Text(
                      "Đang tải Item...",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildPagination(),
    );
  }
}

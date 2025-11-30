import 'package:flutter/material.dart';
import '../model/items-list-model.dart';
import '../service/item_service.dart';
import '../screen/item_details_itemid.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

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

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Weapon',
    'Armor',
    'Hat',
    'Shoes',
    'Accessory',
  ];

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
        name: _searchQuery,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải dữ liệu: $e")),
        );
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

  // ---------------------------------
  // Grid Item Card
  // ---------------------------------
  Widget _buildItemGridCard(Item item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => ItemDetailScreen(
              itemId: item.itemID,
              imageUrl: item.image ?? '',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                  color: AppColors.cardGradient,
                  child: item.image != null
                      ? Image.network(
                    item.image!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.inventory_2, color: AppColors.textSecondary, size: 40),
                  )
                      : const Icon(Icons.inventory_2, color: AppColors.textSecondary, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 58,
              child: Column(
                children: [
                  Expanded(
                    child: Text(
                      item.name ?? "Không tên",
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    item.category ?? "Unknown",
                    style: const TextStyle(
                      color: AppColors.iconPrimary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // Filter AppBar
  // -------------------------------
  PreferredSizeWidget _buildFilterAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        backgroundColor: AppColors.appBar,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.text),
        title: Text(
          AppLocalizations.of(context)!.itemDatabase,
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: TextField(
                    cursorColor: AppColors.iconPrimary,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.iconPrimary),
                      filled: true,
                      fillColor: AppColors.cardGradient,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // Dropdown Category
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: AppColors.card,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.iconPrimary),
                      style: const TextStyle(color: AppColors.text),
                      items: _categories.map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value,
                              style: TextStyle(
                                  color: value == "All" ? AppColors.iconPrimary : AppColors.text)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
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

  // -------------------------------
  // New Pagination (Kurumi Style)
  // -------------------------------
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prev Button
          _buildPageButton(
            label: AppLocalizations.of(context)!.prev,
            enabled: _currentPage > 1,
            onPressed: () => _changePage(_currentPage - 1),
          ),

          // Page Indicator
          Text(
            "$_currentPage / $_totalPages",
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          // Next Button
          _buildPageButton(
            label: AppLocalizations.of(context)!.next,
            enabled: _currentPage < _totalPages,
            onPressed: () => _changePage(_currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
          colors: [
            AppColors.buttonGradientStart,
            AppColors.buttonGradientEnd,
          ],
        )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? Colors.transparent : AppColors.cardGradient,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white38,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  // -----------------------------------
  // Build UI
  // -----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildFilterAppBar(),
      body: Stack(
        children: [
          _items.isEmpty && !_isLoading
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 60, color: AppColors.textSecondary),
                SizedBox(height: 10),
                Text(
                  "Không tìm thấy Item nào.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: _items.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, i) => _buildItemGridCard(_items[i]),
            ),
          ),

          if (_isLoading)
            Container(
              color: AppColors.background.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        color: AppColors.buttonGradientStart),
                    SizedBox(height: 15),
                    Text(
                      "Đang tải Item...",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
      bottomNavigationBar: _buildPagination(),
    );
  }
}

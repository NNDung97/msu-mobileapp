import 'package:flutter/material.dart';
import 'package:msu_app/model/ItemSet.dart'; // Đảm bảo import đúng
import '../model/item_model.dart'; // Đảm bảo import đúng
import '../service/item_service.dart'; // Đảm bảo import đúng
import '../service/Item_set.dart'; // Đảm bảo import đúng

// --- DARK THEME CONSTANTS ---
const Color primaryColor = Color(0xFFF9A825); // Màu nhấn (cam/vàng)
const Color darkBg = Color(0xFF1B0F33); // Nền Card/Dialog (Sâu)
const Color darkContainer = Color(0xFF0F0821); // Nền bên trong
const Color statBaseColor = Color(0xFFE0E0E0); // Base stat
const Color statExtraColor = Color(0xFF4CAF50); // Extra stat (Xanh lá cây)
const Color statEnhanceColor = Color(0xFFBA68C8); // Enhance stat (Tím)
const Color statTotalColor = Color(0xFF00B0FF); // Total stat (Xanh dương)
const Color mainTextColor = Color(0xFFE0E0E0); // Màu chữ chính
const Color mutedTextColor = Color(0xFF9E9E9E); // Màu chữ phụ

class ItemDialogScreen extends StatefulWidget {
  final String itemName;
  final String imageUrl;
  final String itemAccessKey;
  final int? itemID;

  const ItemDialogScreen({
    super.key,
    required this.itemName,
    required this.imageUrl,
    required this.itemAccessKey,
    required this.itemID,
  });

  @override
  State<ItemDialogScreen> createState() => _ItemDialogScreenState();
}

class _ItemDialogScreenState extends State<ItemDialogScreen> {
  ItemDetail? item;
  ItemSet? itemSet;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    // 1. Gọi API thứ nhất: fetchItemDetail
    final result = await ItemService.fetchItemDetail(widget.itemAccessKey);

    // 💡 GIỮ LẠI DELAY 2S ĐỂ TRÁNH RATE LIMIT (1 request/giây)
    await Future.delayed(const Duration(seconds: 2)); 
    
    // 2. Gọi API thứ hai: fetchItemSet (chỉ gọi nếu itemID hợp lệ)
    final setResult = (widget.itemID != null && widget.itemID! > 0) 
        ? await ItemSetService.fetchItemSet(widget.itemID)
        : null;

    setState(() {
      item = result;
      itemSet = setResult;
      isLoading = false;
    });
  }

  // --- WIDGET CON: Hàng chỉ số phức tạp (có Base/Extra/Enhance) ---
  Widget _buildStatRow(String name, dynamic stat) {
    if (stat == null) return const SizedBox();

    final base = stat.base ?? 0;
    final enhance = stat.enhance ?? 0;
    final extra = stat.extra ?? 0;
    final total = stat.total ?? 0;

    if (base == 0 && enhance == 0 && extra == 0 && total == 0) {
      return const SizedBox();
    }

    final displayBase = total - enhance - extra; 

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tên chỉ số
          Text(
            "$name:",
            style: const TextStyle(
              color: statBaseColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          
          // Giá trị chỉ số (RichText để tô màu)
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: mainTextColor),
              children: [
                // Total (Hiển thị nổi bật)
                TextSpan(
                  text: "$total ", 
                  style: TextStyle(
                    color: statTotalColor, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Chi tiết (Hiển thị trong dấu ngoặc)
                const TextSpan(text: "(", style: TextStyle(color: mutedTextColor)),
                TextSpan(
                  text: "$displayBase", // Base/Initial Stat
                  style: TextStyle(color: statBaseColor),
                ),
                if (extra != 0) ...[
                  const TextSpan(text: " + ", style: TextStyle(color: mutedTextColor)),
                  TextSpan(
                    text: "$extra", // Extra Stat (ví dụ: Potentials)
                    style: TextStyle(color: statExtraColor),
                  ),
                ],
                if (enhance != 0) ...[
                  const TextSpan(text: " + ", style: TextStyle(color: mutedTextColor)),
                  TextSpan(
                    text: "$enhance", // Enhance Stat (ví dụ: Starforce)
                    style: TextStyle(color: statEnhanceColor),
                  ),
                ],
                const TextSpan(text: ")", style: TextStyle(color: mutedTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: Hàng chỉ số Đơn giản (cho Max Starforce) ---
  Widget _buildSimpleStatRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$name:",
            style: const TextStyle(
              color: statBaseColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: statTotalColor, 
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: Phần Set Item (Không thay đổi) ---
  Widget _buildItemSetSection(ItemSet set) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '⭐ ${set.setName} Set',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const Divider(height: 10, color: mutedTextColor),

        // Mảnh Set
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8, 
          ),
          itemCount: set.pieces.length,
          itemBuilder: (context, index) {
            final piece = set.pieces[index];
            return Container(
              decoration: BoxDecoration(
                color: darkContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: mutedTextColor.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  piece.imageUrl.isNotEmpty
                      ? Image.network(
                          piece.imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 30,
                            color: mutedTextColor,
                          ),
                        )
                      : const Icon(Icons.image_not_supported, size: 30, color: mutedTextColor),
                  const SizedBox(height: 4),
                  Text(
                    piece.representName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: mainTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    piece.typeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: mutedTextColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Set Effects
        const Text(
          'Hiệu ứng Set:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: statBaseColor,
          ),
        ),
        const Divider(height: 10, color: mutedTextColor),
        ...set.effects.map(
          (effect) => Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: darkContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${effect.equipCount} Mảnh Set',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: statTotalColor, 
                  ),
                ),
                const SizedBox(height: 4),
                ...effect.desc.map(
                  (d) => Text(
                    '• $d',
                    style: const TextStyle(fontSize: 13, color: mainTextColor),
                  ),
                ).toList(),
              ],
            ),
          ),
        ).toList(),
      ],
    );
  }

  // --- WIDGET CON: Nút Đóng ĐÃ TỐI ƯU HÓA (ĐẸP HƠN) ---
  Widget _buildCloseButton(BuildContext context) {
    return Container(
      // Padding xung quanh nút và shadow
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), 
      decoration: BoxDecoration(
        color: darkBg, // Nền tối giống dialog
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: primaryColor.withOpacity(0.3), width: 1)), // Viền trên
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6), // Shadow đậm hơn
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, -4), // Shadow hướng lên trên rõ ràng hơn
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Nút màu nhấn
          foregroundColor: darkBg, // Màu chữ/icon trên nút
          padding: const EdgeInsets.symmetric(vertical: 14), // Tăng padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bo tròn nhẹ
          ),
          elevation: 5, // Thêm độ nổi cho nút
          shadowColor: primaryColor.withOpacity(0.4), // Shadow màu nhấn
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close_rounded, size: 22), // Icon đóng
            SizedBox(width: 8),
            Text(
              'ĐÓNG CHI TIẾT', // Text rõ ràng hơn
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8), 
      body: Center(
        child: Container(
          width: 380, 
          constraints: const BoxConstraints(maxHeight: 700), 
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: darkBg, 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.5), width: 2), 
          ),
          child: Stack(
            children: [
              // 1. 🧠 Nội dung chính
              if (isLoading)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      const SizedBox(height: 12),
                      const Text(
                        "Đang tải dữ liệu...", 
                        style: TextStyle(color: mainTextColor),
                      ),
                    ],
                  ),
                )
              else if (item == null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 50, color: primaryColor),
                      const SizedBox(height: 12),
                      const Text(
                        "Không thể tải dữ liệu item",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: mainTextColor),
                      ),
                    ],
                  ),
                )
              else
                // 2. Nội dung Item Detail
                Column(
                  children: [
                    // Header (Tên và nút đóng trên cùng)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: darkContainer, 
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        border: Border(bottom: BorderSide(color: primaryColor.withOpacity(0.3))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.itemName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: primaryColor, 
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Nút đóng nhanh ở góc trên
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: mutedTextColor),
                          )
                        ],
                      ),
                    ),
                    
                    // Body cuộn được
                    Expanded(
                      child: SingleChildScrollView(
                        // Thêm padding bottom để nút Đóng không che khuất nội dung
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 🖼 Hình ảnh Item
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: darkContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.network(
                                  widget.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 50, color: mutedTextColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // --- CHỈ SỐ STATS ---
                            const Text(
                              "Chỉ số cơ bản:",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: statBaseColor),
                            ),
                            const Divider(height: 10, color: mutedTextColor),
                            _buildStatRow("STR", item!.stats.str),
                            _buildStatRow("DEX", item!.stats.dex),
                            _buildStatRow("INT", item!.stats.int),
                            _buildStatRow("LUK", item!.stats.luk),
                            _buildStatRow("ATT", item!.stats.pad),
                            _buildStatRow("Magic ATT", item!.stats.mad),
                            _buildStatRow("DEF", item!.stats.pdd),
                            _buildStatRow("Max HP", item!.stats.maxHp),
                            
                            // Max Starforce (Sử dụng hàm Simple Stat)
                            if (item!.common.maxStarforce != null && item!.common.maxStarforce > 0)
                              _buildSimpleStatRow("Max Starforce", item!.common.maxStarforce.toString()),
                            
                            const SizedBox(height: 16),

                            // Mô tả
                            Text(
                              item!.common.desc ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: mutedTextColor,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            
                            // --- THÔNG TIN SET ---
                            if (itemSet != null) _buildItemSetSection(itemSet!),

                          ],
                        ),
                      ),
                    ),
                    
                    // 3. 🔘 Nút Đóng cố định (Footer)
                    _buildCloseButton(context),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
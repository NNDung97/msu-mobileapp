import 'package:flutter/material.dart';
import '../model/item_detail_model.dart'; 
import '../model/ItemSet.dart'; 
import '../service/item_service.dart'; 
import '../service/Item_set.dart';

// --- DARK THEME CONSTANTS ---
const Color primaryColor = Color(0xFFF9A825);
const Color darkBg = Color(0xFF0F0821);       
const Color darkCardBg = Color(0xFF1B0F33);   
const Color secondaryText = Color(0xFFE0E0E0); 
const Color mutedText = Color(0xFF9E9E9E);    
const Color errorColor = Colors.redAccent;    

class ItemDetailScreen extends StatefulWidget {
  final int itemId;
  final String imageUrl;

  const ItemDetailScreen({super.key, required this.itemId, required this.imageUrl});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Future<ItemDetailList?> _itemDetailFuture;
  late Future<ItemSet?> _itemSetFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  
  void _fetchData() {
    // 1. Khởi tạo Future cho Item Detail (API 1 - Future chính)
    final detailFuture = ItemService.fetchItemDetailWithItemID(widget.itemId);
    
    // 2. Tạo Future cho Item Set, bao gồm độ trễ 2s và xử lý lỗi im lặng
    final delayedSetFuture = () async {
      try {
        await Future.delayed(const Duration(seconds: 3)); 
        // Thử fetch Set Item
        return ItemSetService.fetchItemSet(widget.itemId);
      } catch (e) {
        // >>>>> LOGIC SỬA LỖI QUAN TRỌNG <<<<<
        // Nếu fetch thất bại (lỗi mạng, timeout, không tìm thấy Set), 
        // chỉ cần log lỗi (nếu cần) và trả về null.
        // Điều này đảm bảo FutureBuilder không bị lỗi và hiển thị SizedBox.shrink().
        print("Lỗi khi fetch Item Set (ID: ${widget.itemId}): $e");
        return null; 
      }
    }();

    setState(() {
      _itemDetailFuture = detailFuture;
      _itemSetFuture = delayedSetFuture;
    });
  }

  void _reloadData() {
    setState(() {
      _fetchData();
    });
  }

  // --- WIDGET CON: Hiển thị chi tiết Stats (Giữ nguyên) ---
  Widget _buildStatRow(String label, int value, {Color color = secondaryText}) {
    if (value == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: mutedText, 
              fontSize: 14,
            ),
          ),
          Text(
            '+$value',
            style: TextStyle(
              color: color, 
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: Header thông tin chung (Giữ nguyên) ---
  Widget _buildItemHeader(ItemDetailList item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 🖼 Icon và Tên
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                widget.imageUrl.isNotEmpty ? widget.imageUrl : item.icon,
                fit: BoxFit.contain,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.inventory, size: 60, color: primaryColor),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 60, height: 60, 
                    child: Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2)),
                  );
                },
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 📝 Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              item.description.isNotEmpty ? item.description : 'Không có mô tả chi tiết.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: secondaryText,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: Card Stats (Giữ nguyên) ---
  Widget _buildStatsCard(ItemStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chỉ số cơ bản',
            style: TextStyle(
              color: primaryColor, 
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          const Divider(color: mutedText),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('STR', stats.str),
                    _buildStatRow('DEX', stats.dex),
                    _buildStatRow('INT', stats.intt),
                    _buildStatRow('LUK', stats.luk),
                    _buildStatRow('Tốc độ', stats.speed),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('Tấn công vật lý', stats.pad, color: Colors.lightGreenAccent),
                    _buildStatRow('Tấn công phép', stats.mad, color: Colors.blueAccent),
                    _buildStatRow('Phòng thủ vật lý', stats.pdd),
                    _buildStatRow('Máu tối đa', stats.maxHp, color: Colors.redAccent),
                    _buildStatRow('Nhảy', stats.jump),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // --- WIDGET CON: Card Common Info (Giữ nguyên) ---
  Widget _buildCommonCard(ItemCommon common) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin bổ sung',
            style: TextStyle(
              color: primaryColor, 
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          const Divider(color: mutedText),
          
          _buildInfoRow('Starforce tối đa', common.maxStarforce > 0 ? common.maxStarforce.toString() : 'N/A'),
          _buildInfoRow('Phần thưởng Boss', common.isBossReward ? '✅ Có' : '❌ Không'),
          _buildInfoRow('Vật phẩm Cash', common.isCash ? '💰 Có' : '❌ Không'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: mutedText, 
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: secondaryText, 
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  // --- WIDGET CON: Card Set Item (Giữ nguyên) ---
  Widget _buildSetItemCard(ItemSet itemSet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ: ${itemSet.setName}', // Tên Set Item
                style: const TextStyle(
                  color: primaryColor, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '(${itemSet.pieces.length} món)',
                style: const TextStyle(color: mutedText, fontSize: 14),
              ),
            ],
          ),
          const Divider(color: mutedText),
          
          const Text(
            'Hiệu ứng bộ:',
            style: TextStyle(color: secondaryText, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Hiển thị Effects
          ...itemSet.effects.map((effect) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ Khi trang bị ${effect.equipCount} món:',
                  style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 4, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: effect.desc.map((d) => Text(
                      d,
                      style: const TextStyle(color: secondaryText, fontSize: 14),
                    )).toList(),
                  ),
                ),
              ],
            );
          }).toList(),

          const Divider(color: mutedText),

          const Text(
            'Các vật phẩm trong bộ:',
            style: TextStyle(color: secondaryText, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Hiển thị Pieces (Món đồ)
          Wrap(
            spacing: 8.0, 
            runSpacing: 8.0,
            children: itemSet.pieces.map((piece) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: darkBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: mutedText.withOpacity(0.5)),
                    ),
                    child: Image.network(
                      piece.imageUrl,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.inventory, size: 40, color: mutedText),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      piece.typeName.replaceAll(RegExp(r'[()]'), ''), // Xóa dấu ngoặc
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: mutedText, fontSize: 10),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CHÍNH: BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: FutureBuilder<ItemDetailList?>(
          future: _itemDetailFuture,
          builder: (context, snapshot) {
            return Text(
              // Đảm bảo tiêu đề cập nhật ngay khi Item Detail có dữ liệu
              snapshot.hasData && snapshot.data != null ? snapshot.data!.name : "Chi tiết vật phẩm...",
              style: const TextStyle(color: secondaryText, fontWeight: FontWeight.bold, fontSize: 18),
            );
          },
        ),
        backgroundColor: darkCardBg,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: FutureBuilder<ItemDetailList?>(
        future: _itemDetailFuture,
        builder: (context, snapshot) {
          // 1. Loading cho Item Detail
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          // 2. Error hoặc Data null cho Item Detail (Future chính)
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            // Hiển thị thông báo lỗi lớn và nút tải lại
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber, size: 60, color: errorColor),
                    const SizedBox(height: 16),
                    Text(
                      "Không thể tải chi tiết vật phẩm (ID: ${widget.itemId}). ${snapshot.error ?? ''}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: errorColor, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _reloadData, // Gọi hàm tải lại
                      icon: const Icon(Icons.refresh, color: darkBg),
                      label: const Text("Tải lại", style: TextStyle(color: darkBg)),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    )
                  ],
                ),
              ),
            );
          }

          // 3. Item Detail đã Loaded
          final item = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildItemHeader(item),
                const SizedBox(height: 16),
                _buildStatsCard(item.stats),
                const SizedBox(height: 16),
                _buildCommonCard(item.common),
                const SizedBox(height: 16), 

                // --- HIỂN THỊ SET ITEM (FUTURE BUILDER ĐÃ SỬA LỖI) ---
                FutureBuilder<ItemSet?>(
                  future: _itemSetFuture,
                  builder: (context, setSnapshot) {
                    if (setSnapshot.connectionState == ConnectionState.waiting) {
                      // Vẫn đang chờ (kể cả thời gian delay 2s)
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: mutedText, strokeWidth: 2), // Hoặc chỉ Text
                      ));
                    }
                    
                    // Nếu lỗi (đã được xử lý trả về null trong _fetchData) hoặc không có data
                    if (!setSnapshot.hasData || setSnapshot.data == null) {
                       // Mặc định là không có Set Item, không hiển thị gì cả.
                       return const SizedBox.shrink();
                    }

                    // Data Set Item Loaded thành công
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSetItemCard(setSnapshot.data!),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
                // --- KẾT THÚC HIỂN THỊ SET ITEM ---
              ],
            ),
          );
        },
      ),
    );
  }
}
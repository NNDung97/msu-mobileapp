import 'package:flutter/material.dart';
import '../service/character_hyper_stats.dart'; // Đảm bảo đường dẫn đúng

// --- DARK THEME CONSTANTS ---
const Color primaryColor = Color(0xFFF9A825); // Màu nhấn (cam/vàng)
const Color darkBg = Color(0xFF121212); // Nền Scaffold
const Color darkCard = Color(0xFF1E1E1E); // Nền Card/List Item
const Color statValueColor = Color(0xFFBA68C8); // Màu Tím cho Level/Hyper
const Color mainTextColor = Color(0xFFE0E0E0); // Màu chữ chính
const Color mutedTextColor = Color(0xFF9E9E9E); // Màu chữ phụ

class HyperStatScreen extends StatefulWidget {
  final dynamic detail;
  final String accessKey;

  const HyperStatScreen({super.key, required this.detail, required this.accessKey});

  @override
  State<HyperStatScreen> createState() => _HyperStatScreenState();
}

class _HyperStatScreenState extends State<HyperStatScreen> {
  late Future<List<HyperStat>> _hyperStatsFuture;
  final HyperStatService _service = HyperStatService();

  @override
  void initState() {
    super.initState();
    _hyperStatsFuture = _service.fetchHyperStats(widget.accessKey);
  }

  // Hàm ánh xạ Icon (đã tối ưu Icons.case thành Icons.case_rounded)
  IconData _getIcon(String name) {
    switch (name) {
      case 'damage':
        return Icons.whatshot_rounded;
      case 'criticalDamage':
        return Icons.bolt_rounded;
      case 'attackAndMagicAttack':
        return Icons.flash_on_rounded;
      case 'ignoreDefence':
        return Icons.shield_rounded;
      case 'bossMonsterDamage':
        return Icons.catching_pokemon_rounded;
      case 'normalMonsterDamage':
        return Icons.pets_rounded;
      case 'abnormalStatusResistance':
        return Icons.healing_rounded;
      case 'criticalRate':
        return Icons.analytics_rounded;
      case 'str':
        return Icons.fitness_center_rounded;
      case 'dex':
        return Icons.sports_handball_rounded;
      case 'int':
        return Icons.psychology_rounded;
      case 'luk':
        return Icons.auto_fix_high_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  // --- WIDGET CON: HYPER STAT CARD ĐÃ TỐI ƯU ---
  Widget _buildHyperStatCard(HyperStat stat) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: statValueColor.withOpacity(0.3), width: 0.5), // Viền màu tím nhẹ
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Tên Stat và Level
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Icon(
                _getIcon(stat.name),
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),

              // Tên Stat
              Expanded(
                child: Text(
                  stat.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: mainTextColor,
                  ),
                ),
              ),

              // Level (Chip Tím)
              Chip(
                label: Text(
                  'LV.${stat.level}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                backgroundColor: statValueColor.withOpacity(0.8), 
              ),
            ],
          ),
          
          const Divider(height: 15, color: mutedTextColor),

          // Row 2: Mô tả (Description)
          Padding(
            padding: const EdgeInsets.only(left: 36), // Căn chỉnh với Icon
            child: Text(
              stat.desc, // Mô tả hiệu ứng của Hyper Stat
              style: const TextStyle(
                fontSize: 13,
                color: mutedTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CHÍNH: BUILD ---
  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text("Hyper Stats", style: TextStyle(color: mainTextColor)),
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Thông tin nhân vật (Card) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: darkCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: mutedTextColor.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nhân vật: ${detail.name}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Level: ${detail.level}",
                    style: const TextStyle(color: mainTextColor, fontSize: 16)),
                Text("Class: ${detail.job.className}",
                    style: const TextStyle(color: mainTextColor, fontSize: 16)),
                Text("Job: ${detail.job.jobName}",
                    style: const TextStyle(color: mainTextColor, fontSize: 16)),
              ],
            ),
          ),

          // --- Hiển thị danh sách Hyper Stats ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<List<HyperStat>>(
                future: _hyperStatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: primaryColor));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Lỗi khi tải chỉ số Hyper:\n${snapshot.error.toString()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Nhân vật chưa phân bổ Hyper Stats.",
                            style: TextStyle(color: mutedTextColor)));
                  }

                  final hyperStats = snapshot.data!;

                  return ListView.builder(
                    itemCount: hyperStats.length,
                    itemBuilder: (context, index) {
                      final stat = hyperStats[index];
                      // Sử dụng Hyper Stat Card đã tối ưu
                      return _buildHyperStatCard(stat);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
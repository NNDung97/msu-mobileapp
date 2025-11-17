import 'package:flutter/material.dart';
import '../service/character_ap_stat.dart'; // Đảm bảo đường dẫn đúng

// --- DARK THEME CONSTANTS ---
const Color primaryColor = Color(0xFFF9A825); // Màu nhấn (cam/vàng)
const Color darkBg = Color(0xFF121212); // Nền Scaffold
const Color darkCard = Color(0xFF1E1E1E); // Nền Card/List Item
const Color statValueColor = Color(0xFF00B0FF); // Xanh dương cho giá trị (Total)
const Color mainTextColor = Color(0xFFE0E0E0); // Màu chữ chính
const Color mutedTextColor = Color(0xFF9E9E9E); // Màu chữ phụ

class ApStatScreen extends StatefulWidget {
  final dynamic detail;
  final String accessKey;

  const ApStatScreen({super.key, required this.detail, required this.accessKey});

  @override
  State<ApStatScreen> createState() => _ApStatScreenState();
}

class _ApStatScreenState extends State<ApStatScreen> {
  late Future<List<ApStat>> _apStatsFuture;
  final ApStatService _service = ApStatService();

  @override
  void initState() {
    super.initState();
    _apStatsFuture = _service.fetchApStats(widget.accessKey);
  }

  // Hàm ánh xạ Icon không đổi
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
      case 'hp':
      case 'mp':
      case 'defence':
        return Icons.favorite_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  // Hàm ánh xạ đơn vị không đổi
  String _getPercentString(String name) {
    switch (name) {
      case 'damage':
      case 'criticalDamage':
      case 'buffDurationRate':
      case 'ignoreDefence':
      case 'bossMonsterDamage':
      case 'jump':
      case 'speed':
      case 'criticalRate':
      case 'finalDamage': // Final Damage cũng là %
        return "%";
      default:
        return "";
    }
  }

  // --- WIDGET CON: STAT CARD ĐÃ TỐI ƯU ---
  Widget _buildStatCard(ApStat stat) {
    // SỬ DỤNG CHUỖI ĐÃ ĐỊNH DẠNG (Xử lý Int/Double)
    final String formattedTotal =
        stat.total.toString().replaceAll(RegExp(r'\.0*$'), '');

    final String unit = _getPercentString(stat.name);
    final isPercent = unit == '%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Icon(
            _getIcon(stat.name),
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Tên chỉ số
          Expanded(
            child: Text(
              stat.name.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: mainTextColor,
              ),
            ),
          ),

          // Giá trị Total
          Row(
            children: [
              Text(
                formattedTotal,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: isPercent ? 18 : 16,
                  color: statValueColor, // Màu xanh dương nổi bật
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontWeight: isPercent ? FontWeight.w900 : FontWeight.normal,
                  fontSize: isPercent ? 18 : 14,
                  color: statValueColor,
                ),
              ),
            ],
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
        title: const Text("AP Stats", style: TextStyle(color: mainTextColor)),
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
          // const Divider(height: 30, color: mutedTextColor),

          // --- Hiển thị danh sách AP Stats ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<List<ApStat>>(
                future: _apStatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: primaryColor));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Lỗi khi tải chỉ số:\n${snapshot.error.toString()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Không có Hyper Stats nào.",
                            style: TextStyle(color: mutedTextColor)));
                  }

                  final hyperStats = snapshot.data!;

                  return ListView.builder(
                    itemCount: hyperStats.length,
                    itemBuilder: (context, index) {
                      final stat = hyperStats[index];
                      // Sử dụng Stat Card đã tối ưu
                      return _buildStatCard(stat);
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
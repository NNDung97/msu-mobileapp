// lib/screens/boss_database_screen.dart (Đã Cập Nhật)

import 'package:flutter/material.dart';
import '../model/boss_model.dart';
import '../service/boss_service.dart';
import '../screen/item_details_itemid.dart'; // Đảm bảo đã import màn hình chi tiết item

// --- DARK THEME CONSTANTS ---
const Color primaryColor = Color(0xFFF9A825);
const Color darkBg = Color(0xFF0F0821);       
const Color darkCardBg = Color(0xFF1B0F33);   
const Color secondaryText = Color(0xFFE0E0E0); 
const Color mutedText = Color(0xFF9E9E9E);    
const Color errorColor = Colors.redAccent;    
const Color hpColor = Color(0xFFFF5252); 
const Color defenseColor = Color(0xFF64B5F6); 
const Color levelColor = Color(0xFF8BC34A); 

class BossDatabaseScreen extends StatefulWidget {
  const BossDatabaseScreen({super.key});

  @override
  State<BossDatabaseScreen> createState() => _BossDatabaseScreenState();
}

class _BossDatabaseScreenState extends State<BossDatabaseScreen> {
  late Future<BossList> _bossListFuture;

  @override
  void initState() {
    super.initState();
    _fetchBossData();
  }

  void _fetchBossData() {
    setState(() {
      _bossListFuture = BossService.fetchBossList();
    });
  }
  
  // Hàm con để hiển thị một thông tin chi tiết (HP/Defense/Level)
  Widget _buildStatDetail(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label:',
          style: const TextStyle(color: secondaryText, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- WIDGET CON: Hiển thị 1 Boss Card (Giữ nguyên) ---
  Widget _buildBossCard(Boss boss) {
    // Lấy độ khó cao nhất để hiển thị Level và Reset Type của độ khó đó
    final mainDifficulty = boss.difficulties.isNotEmpty ? boss.difficulties.last : null;
    
    // Xác định icon reset
    final String resetIcon = boss.type == 'daily' ? '📅' : '🗓️';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkBg.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Image.network(
          boss.image,
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: primaryColor, size: 30),
        ),
        title: Text(
          boss.name,
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị Max Level
            Row(
              children: [
                const Icon(Icons.auto_graph, color: mutedText, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Max Lv: ${mainDifficulty?.level ?? 'N/A'}',
                  style: const TextStyle(color: secondaryText, fontSize: 13),
                ),
              ],
            ),
            // Hiển thị Reset Type
            if (mainDifficulty != null) 
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '$resetIcon Reset: ${mainDifficulty.resetType.toUpperCase()}',
                  style: TextStyle(
                    color: mutedText, 
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        iconColor: primaryColor,
        collapsedIconColor: mutedText,
        children: boss.difficulties.map((difficulty) => _buildDifficultySection(difficulty)).toList(),
      ),
    );
  }
  

  // --- WIDGET CON: Hiển thị Độ khó và Phần thưởng (Giữ nguyên) ---
  Widget _buildDifficultySection(BossDifficulty difficulty) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header độ khó
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.5)),
            ),
            child: Text(
              '${difficulty.name}', 
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // HÀNG 1: Entry Level & Defense
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatDetail(
                    'Entry Lv', 
                    '${difficulty.entryLevel}+', 
                    Icons.directions_run, 
                    levelColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatDetail(
                    'DEF', 
                    difficulty.defense, 
                    Icons.security, 
                    defenseColor,
                  ),
                ),
              ],
            ),
          ),
          
          // HÀNG 2: Boss Level & HP
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                 Expanded(
                  child: _buildStatDetail(
                    'Boss Lv', 
                    '${difficulty.level}', 
                    Icons.auto_graph_sharp, 
                    mutedText,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatDetail(
                    'HP', 
                    difficulty.hp, 
                    Icons.favorite, 
                    hpColor,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: mutedText),
          
          if (difficulty.rewards.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phần thưởng tiềm năng:',
                  style: TextStyle(color: secondaryText, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  // >>>>> VỊ TRÍ CẬP NHẬT 1: Vòng lặp Reward Item <<<<<
                  children: difficulty.rewards.map((reward) => _buildRewardItem(context, reward)).toList(),
                ),
              ],
            )
          else
            const Text(
              'Không có phần thưởng cụ thể.',
              style: TextStyle(color: mutedText, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
  
  // --- WIDGET CON: Hiển thị 1 Reward Item (ĐÃ CẬP NHẬT) ---
  Widget _buildRewardItem(BuildContext context, BossReward reward) {
    // Chỉ cho phép click nếu có ItemID hợp lệ
    final bool isClickable = reward.itemID > 0;

    return InkWell(
      onTap: isClickable
          ? () {
              // >>>>> VỊ TRÍ CẬP NHẬT 2: Thực hiện Navigator.push <<<<<
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => ItemDetailScreen(
                    itemId: reward.itemID,
                    imageUrl: reward.image, // Truyền URL hình ảnh
                  ),
                ),
              );
            }
          : null, // null nếu không click được
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: darkBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                // Thay đổi màu border nếu click được
                color: isClickable ? primaryColor.withOpacity(0.8) : mutedText.withOpacity(0.5),
                width: isClickable ? 1.5 : 1,
              ),
            ),
            child: Image.network(
              reward.image,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.diamond_outlined, size: 40, color: mutedText),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              reward.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isClickable ? secondaryText : mutedText, 
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // --- WIDGET CON: Boss List View (Giữ nguyên) ---
  Widget _buildBossListView(List<Boss> bosses) {
    if (bosses.isEmpty) {
      return Center(
        child: Text(
          'Chưa có dữ liệu Boss cho mục này.',
          style: TextStyle(color: mutedText, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: bosses.length,
      itemBuilder: (context, index) {
        return _buildBossCard(bosses[index]);
      },
    );
  }

  // --- WIDGET CHÍNH: BUILD (Giữ nguyên) ---
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: darkCardBg,
          iconTheme: const IconThemeData(color: primaryColor),
          title: const Text(
            'Boss Database',
            style: TextStyle(color: secondaryText, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: mutedText,
            tabs: const [
              Tab(text: 'Daily Bosses'),
              Tab(text: 'Weekly Bosses'),
            ],
          ),
        ),
        body: FutureBuilder<BossList>(
          future: _bossListFuture,
          builder: (context, snapshot) {
            // 1. Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryColor));
            }

            // 2. Error
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 60, color: errorColor),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải dữ liệu Boss: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: errorColor, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchBossData,
                      icon: const Icon(Icons.refresh, color: darkBg),
                      label: const Text("Tải lại", style: TextStyle(color: darkBg)),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    ),
                  ],
                ),
              );
            }

            // 3. Data Loaded
            final bossList = snapshot.data!;
            
            return TabBarView(
              children: [
                // Tab 1: Daily Bosses
                _buildBossListView(bossList.daily),
                
                // Tab 2: Weekly Bosses
                _buildBossListView(bossList.weekly),
              ],
            );
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/get_newest_banner.dart';
import '../screen/items-list.dart';
import '../screen/boss_database_screen.dart';
import '../screen/coming_soon_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _bannerUrl;
  String? _bannerTitle;
  String? _bannerLink;
  bool _loadingBanner = true;

  // --- LOGIC: URL LAUNCHER ---
  @override
  void initState() {
    super.initState();
    _loadNewestBanner();
  }

  Future<void> _loadNewestBanner() async {
    // Thêm một độ trễ nhỏ để CircularProgressIndicator không bị nháy quá nhanh
    await Future.delayed(const Duration(milliseconds: 300));

    final banner = await GetNewestBanner.fetchNewestBanner();
    if (mounted) {
      setState(() {
        if (banner != null) {
          _bannerUrl = banner['image'];
          _bannerTitle = banner['title'];
          _bannerLink = banner['url'];
        }
        _loadingBanner = false;
      });
    }
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !(uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https')))) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('URL không hợp lệ.')));
      }
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể mở $url')));
      }
    } catch (e) {
      debugPrint("Lỗi khi mở URL: $e");
    }
  }

  final items = const [
    {
      "icon": Icons.inventory,
      "title": "Item Database",
      "desc": "Explore a comprehensive database of in-game NFT items.",
      "button": "Browse Items",
    },
    {
      "icon": Icons.shield,
      "title": "Boss Database",
      "desc": "Detailed information on MapleStory bosses and loot.",
      "button": "View Bosses",
    },
    {
      "icon": Icons.collections,
      "title": "NFT Collection Viewer",
      "desc": "Track and analyze your NFT collection progress.",
      "button": "View Collection",
    },
    {
      "icon": Icons.history,
      "title": "Item Trade History",
      "desc": "Search and explore NFT trade history and data.",
      "button": "Explore Trades",
    },
    {
      "icon": Icons.people,
      "title": "Character Trade History",
      "desc": "Monitor character trades and trends.",
      "button": "Explore Characters",
    },
    {
      "icon": Icons.bar_chart,
      "title": "Hyper Stat Optimizer",
      "desc": "Optimize your Hyper Stats efficiently.",
      "button": "Optimize Now",
    },
  ];

  // --- WIDGET TỐI ƯU: CARD CHỨC NĂNG ---
  Widget _buildFeatureCard(Map<String, dynamic> item) {
    // 💡 UX/UI: Đổi sang Dark Theme phù hợp ứng dụng game
    const cardColor = Color(0xFF1B0F33); // Nền Card tối
    const iconColor = Color(0xFFF9A825); // Màu cam gold
    const textColor = Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(20), // Tăng độ cong
      // 💡 UX: Thêm hiệu ứng nhấn (splash color)
      splashColor: iconColor.withOpacity(0.3),
      onTap: () {
        // TODO: chuyển màn tương ứng (ví dụ dùng NavigatorHelper)
      },
      child: Container(
        // 💡 UI: Box Decoration mới
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cardColor,
          // 💡 UI: Thêm gradient nhẹ và border
          gradient: LinearGradient(
            colors: [
              cardColor,
              cardColor.withOpacity(0.95),
              const Color(0xFF3D1C7B).withOpacity(0.5), // Thêm chút tím
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item["icon"] as IconData, size: 40, color: iconColor),
            const SizedBox(height: 12),
            Text(
              item["title"] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                item["desc"] as String,
                style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                maxLines: 3, // Giới hạn dòng
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // 💡 UI: Tối ưu nút bấm (Button)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF9A825),
                      Color(0xFFFB8C00),
                    ], // Gradient cam
                  ),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .transparent, // Nền trong suốt để hiển thị gradient
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    switch (item["title"]) {
                      case "Item Database":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ItemListScreen(),
                          ),
                        );
                        break;
                      case "Boss Database":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BossDatabaseScreen(),
                          ),
                        );
                        break;
                      case "NFT Collection Viewer":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ComingSoonScreen(featureName: "NFT Collection Viewer"),
                          ),
                        );
                        break;
                      case "Item Trade History":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ComingSoonScreen(featureName: "Item Trade History"),
                          ),
                        );
                        break;
                      case "Character Trade History":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ComingSoonScreen(featureName: "Character Trade History"),
                          ),
                        );
                        break;
                      case "Hyper Stat Optimizer":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ComingSoonScreen(featureName: "Hyper Stat Optimizer"),
                          ),
                        );
                        break;
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                  ), // Icon hiện đại hơn
                  label: Text(
                    item["button"] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TỐI ƯU: BANNER ---
  Widget _buildBanner() {
    // 💡 UI: Thẻ chứa Banner (Placeholder, Banner, Error/No Data)
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(
          _loadingBanner
              ? 1
              : _bannerUrl != null
              ? 2
              : 3,
        ),
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade900, // Nền tối cho placeholder
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _loadingBanner
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF9A825)),
              )
            : _bannerUrl != null
            ? GestureDetector(
                onTap: () => _openUrl(_bannerLink),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _bannerUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white38,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    // 💡 UI: Overlay Gradient tối ở dưới để làm nổi bật tiêu đề
                    if (_bannerTitle != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    // 💡 UI: Hiển thị tiêu đề ở góc dưới
                    if (_bannerTitle != null)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _bannerTitle!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // 💡 UI: Icon click
                    if (_bannerLink != null)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.open_in_new,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : const Center(
                child: Text(
                  'Không có sự kiện mới.',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 UX/UI: Áp dụng Dark Theme
    return Scaffold(
      backgroundColor: const Color(0xFF0F0821), // Màu nền tối đậm
      // appBar: AppBar(
      //   title: const Text("NFT Game Tools", style: TextStyle(fontWeight: FontWeight.bold)),
      //   backgroundColor: const Color(0xFF1B0F33), // Màu AppBar tối
      //   foregroundColor: Colors.white,
      //   elevation: 8,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16), // Tăng padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼 Banner Section
              const Text(
                "Sự Kiện Nổi Bật",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildBanner(),

              const SizedBox(height: 30),

              Text(
                "🛠️ Khám Phá Công Cụ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF9A825), // Màu cam gold
                ),
              ),
              const SizedBox(height: 16),

              // 🧩 Grid Cards
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16, // Tăng khoảng cách grid
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // Thay đổi tỷ lệ aspect ratio
                ),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _buildFeatureCard(items[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

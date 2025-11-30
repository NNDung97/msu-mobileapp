// File: lib/screens/homescreen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/get_newest_banner.dart';
import '../screen/items-list.dart';
import '../screen/boss_database_screen.dart';
import '../screen/coming_soon_screen.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';   // ❤️ Localization

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

  @override
  void initState() {
    super.initState();
    _loadNewestBanner();
  }

  Future<void> _loadNewestBanner() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final banner = await GetNewestBanner.fetchNewestBanner();
    if (!mounted) return;

    setState(() {
      if (banner != null) {
        _bannerUrl = banner['image'];
        _bannerTitle = banner['title'];
        _bannerLink = banner['url'];
      }
      _loadingBanner = false;
    });
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showMessage(AppLocalizations.of(context)!.invalidUrl);
      return;
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _showMessage("${AppLocalizations.of(context)!.cannotOpen} $url");
    } catch (e) {
      debugPrint("Lỗi khi mở URL: $e");
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ----------------------------------------------------------
  // DANH SÁCH ITEM (DÙNG KEY TEXT)
  // ----------------------------------------------------------
  List<Map<String, dynamic>> buildItems(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return [
      {
        "icon": Icons.inventory,
        "title": t.itemDatabase,
        "desc": t.itemDatabaseDesc,
        "button": t.browse,
        "key": "item"
      },
      {
        "icon": Icons.shield,
        "title": t.bossDatabase,
        "desc": t.bossDatabaseDesc,
        "button": t.view,
        "key": "boss"
      },
      {
        "icon": Icons.collections,
        "title": t.nftViewer,
        "desc": t.nftViewerDesc,
        "button": t.view,
        "key": "nft"
      },
      {
        "icon": Icons.history,
        "title": t.itemTrade,
        "desc": t.itemTradeDesc,
        "button": t.explore,
        "key": "tradeItem"
      },
      {
        "icon": Icons.people,
        "title": t.charTrade,
        "desc": t.charTradeDesc,
        "button": t.explore,
        "key": "tradeChar"
      },
      {
        "icon": Icons.bar_chart,
        "title": t.hyperStat,
        "desc": t.hyperStatDesc,
        "button": t.optimizeNow,
        "key": "hyper"
      },
    ];
  }

  // ----------------------------------------------------------
  // CARD HIỂN THỊ CHỨC NĂNG
  // ----------------------------------------------------------
  Widget _buildFeatureCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card,
            AppColors.card.withValues(alpha: 0.92),
            const Color(0xFF3D1C7B).withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON
          Icon(
            item["icon"],
            size: 42,
            color: AppColors.iconSecondary,
          ),

          const SizedBox(height: 14),

          Text(
            item["title"],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Text(
              item["desc"],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.25,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // BUTTON — FULL WIDTH
          SizedBox(
            width: double.infinity,
            height: 38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.buttonGradientStart,
                    AppColors.buttonGradientEnd,
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () => _openPage(item["title"]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item["button"],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios, size: 14)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // CHUYỂN TRANG
  // ----------------------------------------------------------
  void _openPage(String key) {
    switch (key) {
      case "Item Database" || "Danh sách vật phẩm":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemListScreen()));
        break;

      case "Boss Database" || "Danh sách Boss":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BossDatabaseScreen()));
        break;

      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComingSoonScreen(featureName: key),
          ),
        );
    }
  }

  // ----------------------------------------------------------
  // BANNER (SỰ KIỆN NỔI BẬT)
  // ----------------------------------------------------------
  Widget _buildBanner(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_loadingBanner ? 1 : (_bannerUrl != null ? 2 : 3)),
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bannerPlaceholder,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: _loadingBanner
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.buttonGradientStart,
          ),
        )
            : _bannerUrl != null
            ? GestureDetector(
          onTap: () => _openUrl(_bannerLink),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(_bannerUrl!, fit: BoxFit.cover),
              ),
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
              if (_bannerTitle != null)
                Positioned(
                  left: 12,
                  bottom: 12,
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
            ],
          ),
        )
            : Center(
          child: Text(
            t.noEvents,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final localizedItems = buildItems(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.featuredEvents,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 10),
              _buildBanner(context),

              const SizedBox(height: 30),

              Text(
                t.exploreTools,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: localizedItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (_, i) => _buildFeatureCard(localizedItems[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

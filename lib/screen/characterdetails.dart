import 'package:flutter/material.dart';
import '../model/characters.dart';
import '../service/character_details_service.dart';
import '../service/character_equipment_service.dart';
import './hyperstats.dart';
import './ap_stat.dart';
import './item_details.dart';

// --- DARK THEME CONSTANTS ---
const Color darkBg = Color(0xFF121212); // Nền Scaffold
const Color darkAppBar = Color(0xFF1E1E1E); // Nền AppBar/Card
const Color primaryColor = Color(0xFFF9A825); // Màu nhấn (Vàng/Cam)
const Color secondaryColor = Color(0xFFBA68C8); // Màu nhấn phụ (Tím cho Hyper/Border)
const Color expFillColor = Color(0xFF00B0FF); // Xanh dương cho EXP

class CharacterDetailPage extends StatefulWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> with SingleTickerProviderStateMixin {
  final CharacterDetailsService detailService = CharacterDetailsService();
  late Future<Map<String, dynamic>> equipmentFuture;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    equipmentFuture = Future.delayed(const Duration(milliseconds: 1500), () async {
      return await CharacterEquipmentService().fetchWearingData(
        widget.character.assetKey,
      );
    });

    // --- Animation Controller for Glowing Border ---
    _controller = AnimationController(
      duration: const Duration(seconds: 4), 
      vsync: this,
    )..repeat(reverse: true); 

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- WIDGET CHÍNH: BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: Text(
          widget.character.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: darkAppBar,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder(
        future: detailService.fetchCharacterDetails(widget.character.assetKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu nhân vật.', style: TextStyle(color: Colors.white60)));
          }

          final detail = snapshot.data!;
          final currentExp = double.tryParse(detail.exp) ?? 0;
          final totalExp = double.tryParse(detail.totalExp) ?? 1;
          final progress = (currentExp / totalExp).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // --- Avatar (ĐÃ TĂNG KÍCH THƯỚC) ---
                Hero(
                  tag: widget.character.assetKey,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final glowOpacity = 0.5 + (_animation.value * 0.5); 
                      final glowSpread = 4.0 + (_animation.value * 6.0); 
                      final glowColor = secondaryColor.withOpacity(glowOpacity);
                      
                      const avatarSize = 220.0; // Kích thước mới cho avatar

                      return Container(
                        width: avatarSize, 
                        height: avatarSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24), 
                          gradient: const RadialGradient( 
                            colors: [Color(0xFF3A245C), Color(0xFF1B0F33)],
                            center: Alignment.topCenter,
                            radius: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: glowColor,
                              blurRadius: 15,
                              spreadRadius: glowSpread, 
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Bo tròn ảnh bên trong (nhỏ hơn 4 đơn vị so với container)
                          child: Image.network(
                            widget.character.data.imageUrl,
                            width: avatarSize - 40, // Đảm bảo hình ảnh vừa vặn
                            height: avatarSize - 40,
                            fit: BoxFit.contain, 
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.error, size: 100, color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // --- Basic Info ---
                Text(
                  detail.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: primaryColor, blurRadius: 10, offset: Offset(1, 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.star, color: darkBg, size: 18),
                        label: Text(
                          'Lv. ${detail.level}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: darkBg),
                        ),
                        backgroundColor: primaryColor,
                      ),
                      Chip(
                        avatar: const Icon(Icons.sports_martial_arts, color: Colors.white70, size: 18),
                        label: Text(detail.job.className),
                        backgroundColor: darkAppBar,
                        labelStyle: const TextStyle(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.white12)),
                      ),
                      Chip(
                        avatar: const Icon(Icons.engineering, color: Colors.white70, size: 18),
                        label: Text(detail.job.jobName),
                        backgroundColor: darkAppBar,
                        labelStyle: const TextStyle(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.white12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- EXP Bar ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: darkAppBar,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: expFillColor.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: expFillColor.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 1)
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [expFillColor, Color(0xFF1E90FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'EXP: ${detail.exp} / ${detail.totalExp} (${(progress * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- Buttons ---
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HyperStatScreen(
                                detail: detail,
                                accessKey: widget.character.assetKey,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.electric_bolt_rounded, size: 20),
                        label: const Text(
                          "Hyper Stats",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: secondaryColor.withOpacity(0.9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApStatScreen(
                                detail: detail,
                                accessKey: widget.character.assetKey,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.equalizer_rounded, size: 20),
                        label: const Text(
                          "Detailed Stats",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: darkAppBar,
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: primaryColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 40, color: Colors.white12, thickness: 0.5),

                // --- Equipment Section ---
                FutureBuilder<Map<String, dynamic>>(
                  future: equipmentFuture,
                  builder: (context, equipSnapshot) {
                    if (equipSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(color: primaryColor));
                    }

                    if (equipSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Lỗi tải trang bị: ${equipSnapshot.error}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    if (!equipSnapshot.hasData) {
                      return const Center(
                        child: Text(
                          'Không có dữ liệu trang bị.',
                          style: TextStyle(color: Colors.white60),
                        ),
                      );
                    }

                    final data = equipSnapshot.data!;
                    final decoEquip = data['decoEquip'] as Map<String, dynamic>?;
                    final equip = data['equip'] as Map<String, dynamic>?;
                    final pet = data['pet'] as Map<String, dynamic>?;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEquipSection('✨ DECO EQUIP', Icons.face_retouching_natural_rounded, decoEquip, Colors.pinkAccent),
                        const SizedBox(height: 20),
                        _buildEquipSection('⚔️ EQUIP', Icons.shield_rounded, equip, expFillColor),
                        const SizedBox(height: 20),
                        _buildEquipSection('🐾 PET', Icons.pets_rounded, pet, secondaryColor),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET CON: BUILD ITEM SLOT ---
  Widget _buildItemSlot(
    BuildContext context, {
    required String imageUrl,
    required String itemName,
    required String itemAccessKey,
    required int itemID,
    required Color borderColor,
  }) {
    final isEmpty = imageUrl.isEmpty;
    const itemSize = 60.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: borderColor.withOpacity(0.3),
        onTap: isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => ItemDialogScreen(
                      itemName: itemName,
                      imageUrl: imageUrl,
                      itemAccessKey: itemAccessKey,
                      itemID: itemID,
                    ),
                  ),
                );
              },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isEmpty ? 0.3 : 1.0,
          child: Container(
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              color: darkAppBar,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor.withOpacity(0.8),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isEmpty
                ? Center(
                    child: Icon(
                      Icons.square_foot,
                      size: itemSize * 0.5,
                      color: Colors.white12,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: itemSize,
                      height: itemSize,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET CON: BUILD PET SLOT ---
  Widget _buildPetSlot(
    BuildContext context, {
    required String label,
    required String imageUrl,
    VoidCallback? onTap,
    required Color baseColor,
  }) {
    final isEmpty = imageUrl.isEmpty;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isEmpty ? null : onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isEmpty ? 0.4 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: darkAppBar,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: baseColor.withOpacity(0.6), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isEmpty)
                  Icon(Icons.pets, size: 32, color: baseColor.withOpacity(0.3))
                else
                  Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: Colors.white38,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: baseColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng từng section của trang bị
  Widget _buildEquipSection(
    String title,
    IconData icon,
    Map<String, dynamic>? items,
    Color borderColor,
  ) {
    if (items == null || items.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          '$title: Không có dữ liệu.',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    if (title == '🐾 PET') {
      final validPets = items.entries.where((e) => e.value != null).toList();

      if (validPets.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: validPets.map((entry) {
              final pet = entry.value as Map<String, dynamic>;
              final petImage = pet['imageUrl'] ?? '';
              final petKey = pet['assetKey'] ?? '';
              final petId = pet['itemId'] ?? 0;
              final petName = entry.key;

              final petAcc = pet['petAcc'] as Map<String, dynamic>?;
              final petAccImage = petAcc?['imageUrl'] ?? '';
              final petAccKey = petAcc?['assetKey'] ?? '';
              final petAccId = petAcc?['itemId'] ?? 0;

              return Container(
                width: 160,
                decoration: BoxDecoration(
                  color: darkAppBar,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor.withOpacity(0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPetSlot(
                        context,
                        label: petName.toUpperCase().replaceAll('PET', ''),
                        imageUrl: petImage,
                        baseColor: borderColor,
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (_, __, ___) => ItemDialogScreen(
                              itemName: petName,
                              imageUrl: petImage,
                              itemAccessKey: petKey,
                              itemID: petId,
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, color: Colors.white12),
                      _buildPetSlot(
                        context,
                        label: "ACC",
                        imageUrl: petAccImage,
                        baseColor: borderColor,
                        onTap: petAcc == null
                            ? null
                            : () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) => ItemDialogScreen(
                                      itemName: "Pet Accessory",
                                      imageUrl: petAccImage,
                                      itemAccessKey: petAccKey,
                                      itemID: petAccId,
                                    ),
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    final validItems = items.entries.where((e) => e.value != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: borderColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: validItems.map((entry) {
            final imageUrl = entry.value['imageUrl'] as String? ?? '';
            final itemName = entry.value['itemName'] as String? ?? entry.key;
            final itemAccessKey = entry.value['assetKey'] as String? ?? '';
            final itemId = entry.value['itemId'] as int? ?? 0;

            return _buildItemSlot(
              context,
              imageUrl: imageUrl,
              itemName: itemName,
              itemAccessKey: itemAccessKey,
              itemID: itemId,
              borderColor: borderColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}